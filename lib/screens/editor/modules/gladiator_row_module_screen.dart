import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/gladiator_row_preview.dart';
import 'package:c_editor/widgets/grid_override_wave_groups_bar.dart';

class GladiatorRowModuleScreen extends StatefulWidget {
  const GladiatorRowModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.initialWave,
  });
  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final int? initialWave;

  @override
  State<GladiatorRowModuleScreen> createState() =>
      _GladiatorRowModuleScreenState();
}

class _GladiatorRowModuleScreenState extends State<GladiatorRowModuleScreen> {
  late String _alias;
  late PvzObject _object;
  late GladiatorRowModulePropertiesData _data;
  int _selected = 0;
  final _controllers = <(Object, String), TextEditingController>{};
  GladiatorEncounterData? get _encounter =>
      _data.encounters.elementAtOrNull(_selected);

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _object =
        widget.levelFile.objects.firstWhereOrNull(
          (o) => o.aliases?.contains(_alias) == true,
        ) ??
        PvzObject(
          aliases: [_alias],
          objClass: 'GladiatorRowModuleProperties',
          objData: GladiatorRowModulePropertiesData().toJson(),
        );
    if (!widget.levelFile.objects.contains(_object)) {
      widget.levelFile.objects.add(_object);
    }
    _data = GladiatorRowModulePropertiesData.fromJson(
      Map<String, dynamic>.from(_object.objData as Map),
    );
    final requested = _data.encounters.indexWhere(
      (e) => e.wave == widget.initialWave,
    );
    if (requested >= 0) _selected = requested;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _sync() {
    _object.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  Future<void> _pickZombie(ValueChanged<String> change) async {
    final type = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (pickerContext) => ZombieSelectionScreen(
          stateBucketId: 'gladiator-row',
          onZombieSelected: (id) => Navigator.pop(pickerContext, id),
          onBack: () => Navigator.pop(pickerContext),
        ),
      ),
    );
    if (type == null || !mounted) return;
    await ZombiePropertiesRepository.init();
    if (!mounted) return;
    final original = ZombiePropertiesRepository.getOriginalTypeObject(
      ZombiePropertiesRepository.getTypeNameByAlias(type),
    );
    final groups = original?.objData is Map
        ? (original!.objData as Map)['ResourceGroups']
        : null;
    _data.addResourceGroups([
      'GladiatorRow',
      if (groups is List) ...groups.whereType<String>(),
    ]);
    change(type);
    _sync();
  }

  Future<bool> _confirmRemove(String name) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            scrollable: true,
            title: Text(l10n.removeItem),
            content: Text(l10n.removeItemConfirm(name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.remove),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _number(
    Object owner,
    String field,
    String scope,
    String label,
    num value,
    ValueChanged<num> change, {
    bool integer = false,
    num minimum = 0,
    num? maximum,
  }) {
    final controller = _controllers.putIfAbsent((
      owner,
      field,
    ), () => TextEditingController(text: '$value'));
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: EditorResponsiveInputField(
        label: label,
        builder: (context, decoration) => TextField(
          key: ValueKey('gladiator-$scope-$field'),
          controller: controller,
          decoration: decoration,
          keyboardType: TextInputType.numberWithOptions(decimal: !integer),
          onChanged: (text) {
            final n = integer ? int.tryParse(text) : num.tryParse(text);
            if (n == null ||
                !n.isFinite ||
                n < minimum ||
                (maximum != null && n > maximum)) {
              return;
            }
            change(n);
            _sync();
          },
        ),
      ),
    );
  }

  Widget _level(
    String scope,
    String label,
    int value,
    ValueChanged<int> change,
  ) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: EditorResponsiveInputField(
      key: ObjectKey(scope == 'global' ? _data : _encounter),
      label: label,
      builder: (context, decoration) => DropdownButtonFormField<int>(
        key: ValueKey('gladiator-$scope-Level'),
        initialValue: value >= 0 && value <= 10 ? value : null,
        isExpanded: true,
        decoration: decoration,
        items: [
          for (var level = 0; level <= 10; level++)
            DropdownMenuItem(value: level, child: Text('$level')),
        ],
        onChanged: (level) {
          if (level == null) return;
          change(level);
          _sync();
        },
      ),
    ),
  );

  void _addEncounter() {
    final next = _data.encounters.isEmpty
        ? 0
        : _data.encounters.map((e) => e.wave).reduce((a, b) => a > b ? a : b) +
              1;
    _data.encounters.add(GladiatorEncounterData(wave: next));
    _selected = _data.encounters.length - 1;
    _sync();
  }

  Future<void> _removeEncounter(int index) async {
    final encounter = _data.encounters[index];
    if (!await _confirmRemove(
          AppLocalizations.of(context)!.groupN(index + 1),
        ) ||
        !mounted) {
      return;
    }
    _data.encounters.remove(encounter);
    if (index < _selected) _selected--;
    _selected = _selected.clamp(
      0,
      _data.encounters.isEmpty ? 0 : _data.encounters.length - 1,
    );
    _sync();
  }

  Widget _card(List<Widget> children) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );

  Widget _heading(String text) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  );

  Widget _zombieHeader(
    String type,
    VoidCallback remove,
    ValueChanged<String> replace,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final display = gladiatorZombieDisplayType(type, widget.levelFile);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final identity = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ResourceNames.lookupOrFallback(
                    context,
                    'zombie_$display',
                    type,
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  type,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
            final icon = SizedBox(
              width: 64,
              height: 64,
              child: GladiatorZombieIcon(
                type: type,
                levelFile: widget.levelFile,
              ),
            );
            final actions = IconButton(
              tooltip: l10n.remove,
              icon: const Icon(Icons.delete_outline),
              onPressed: remove,
            );
            if (constraints.maxWidth < 520 ||
                MediaQuery.textScalerOf(context).scale(16) > 20.8) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [icon, const Spacer(), actions]),
                  const SizedBox(height: 12),
                  identity,
                ],
              );
            }
            return Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Expanded(child: identity),
                const SizedBox(width: 8),
                actions,
              ],
            );
          },
        ),
        const Divider(height: 28),
        OutlinedButton.icon(
          onPressed: () => _pickZombie(replace),
          icon: const Icon(Icons.swap_horiz),
          label: Text(l10n.switchZombie),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final warningBrightness = Theme.of(context).brightness;
    final warningForeground = editorWarningBannerForeground(warningBrightness);
    final encounter = _encounter;
    final compatibilityWarnings =
        LevelIssueRegistry.forLevel(context, widget.levelFile).where(
          (issue) => issue.id == 'gladiatorWaveGeneratorCompatibilityWarning',
        );
    final levelDef = LevelParser.parseLevel(widget.levelFile).levelDef;
    final (rows, cols) = LevelParser.getGridDimensions(
      levelDef,
      widget.levelFile,
    );
    final isUnderwaterLawn = LevelParser.isUnderwaterWorldSixRowLawn(
      levelDef,
      widget.levelFile,
    );
    final options = {
      'ArenaDuration': l10n.gladiatorArenaDuration,
      'PlantWinPlantfoodCount': l10n.gladiatorRewardCount,
      'ZombieWinPunishmentCageCount': l10n.gladiatorPunishmentCount,
      'ZombieWinPunishmentDuration': l10n.gladiatorPunishmentDuration,
    };
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: l10n.moduleTitle_GladiatorRowModuleProperties,
          isEvent: false,
          objClass: 'GladiatorRowModuleProperties',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n.moduleTitle_GladiatorRowModuleProperties,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.gladiatorHelpOverview,
                ),
                HelpSectionData(
                  title: l10n.usage,
                  body: l10n.gladiatorHelpUsage,
                ),
                HelpSectionData(
                  title: l10n.gladiatorHelpTipsTitle,
                  body: l10n.gladiatorHelpTips,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModuleAliasInputField(
              rtid: widget.rtid,
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: (value) {
                renameLevelObjectAlias(
                  levelFile: widget.levelFile,
                  oldAlias: _alias,
                  newAlias: value,
                  onChanged: widget.onChanged,
                );
                setState(() => _alias = value);
              },
              onChanged: widget.onChanged,
            ),
            const SizedBox(height: 12),
            for (final warning in compatibilityWarnings) ...[
              EditorWarningBanner(
                key: ValueKey(warning.id),
                margin: EdgeInsets.zero,
                title: warning.title,
                message: warning.message,
              ),
              const SizedBox(height: 12),
            ],
            if (!_data.usesTrophyMode) ...[
              EditorWarningBanner(
                key: const ValueKey('gladiatorLegacyModeWarning'),
                margin: EdgeInsets.zero,
                title: l10n.gladiatorHelpTipsTitle,
                message: l10n.gladiatorLegacyModeWarning,
                children: [
                  const SizedBox(height: 12),
                  EditorFilledButton(
                    key: const ValueKey('gladiator-use-trophy-mode'),
                    onPressed: () {
                      _data.values['GameplayVersion'] = 1;
                      _sync();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: editorWarningBannerBackground(
                        warningBrightness,
                      ),
                      foregroundColor: warningForeground,
                      side: BorderSide(color: warningForeground, width: 1.5),
                    ),
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(l10n.gladiatorUseTrophyMode),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (isUnderwaterLawn) ...[
              EditorWarningBanner(
                key: const ValueKey('gladiatorRowUnderwaterMismatch'),
                margin: EdgeInsets.zero,
                title: l10n.stageMismatch,
                message: l10n.gladiatorUnderwaterMismatchWarning,
              ),
              const SizedBox(height: 12),
            ],
            _card([
              _heading(l10n.gladiatorSettings),
              for (final option in options.entries)
                _number(
                  _data,
                  option.key,
                  'global',
                  option.value,
                  _data.option(option.key),
                  (n) => _data.values[option.key] = n,
                  integer: !option.key.endsWith('Duration'),
                ),
              _level(
                'global',
                l10n.gladiatorPunishmentLevel,
                _data.option('ZombieWinPunishmentZombieLevel').toInt(),
                (level) =>
                    _data.values['ZombieWinPunishmentZombieLevel'] = level,
              ),
            ]),
            _card([
              _heading(l10n.gladiatorEncounters),
              const SizedBox(height: 8),
              GridOverrideWaveGroupsBar(
                itemCount: _data.encounters.length,
                selectedIndex: _selected,
                onSelected: (index) => setState(() => _selected = index),
                onDeleteAt: _removeEncounter,
                onAdd: _addEncounter,
                groupLabel: (index) => l10n.groupN(index + 1),
              ),
              const SizedBox(height: 4),
              if (encounter != null) ...[
                _number(
                  encounter,
                  'Wave',
                  'encounter',
                  l10n.gladiatorWave,
                  encounter.wave,
                  (n) => encounter.wave = n.toInt(),
                  integer: true,
                ),
                _number(
                  encounter,
                  'Row',
                  'encounter',
                  l10n.gladiatorRow,
                  encounter.row,
                  (n) => encounter.row = n.toInt(),
                  integer: true,
                  maximum: rows - 1,
                ),
                _number(
                  encounter,
                  'WarningDuration',
                  'encounter',
                  l10n.gladiatorWarningDuration,
                  encounter.warningDuration,
                  (n) => encounter.values['WarningDuration'] = n,
                ),
                _number(
                  encounter,
                  'FirstCageDelay',
                  'encounter',
                  l10n.gladiatorFirstCageDelay,
                  encounter.firstCageDelay,
                  (n) => encounter.values['FirstCageDelay'] = n,
                ),
              ],
            ]),
            if (encounter != null) ...[
              if (_data.usesTrophyMode)
                _card([
                  _heading(l10n.gladiatorPreviewTitle),
                  const SizedBox(height: 8),
                  Text(l10n.gladiatorPreviewLegend),
                  const SizedBox(height: 12),
                  GladiatorRowPreview(
                    encounter: encounter,
                    levelFile: widget.levelFile,
                    rows: rows,
                    cols: cols,
                    onRowSelected: (row) {
                      encounter.row = row;
                      _controllers[(encounter, 'Row')]?.text = '$row';
                      _sync();
                    },
                  ),
                ]),
              _card([
                _heading(l10n.gladiatorSpawns),
                const SizedBox(height: 12),
                for (var i = 0; i < encounter.spawns.length; i++)
                  _spawnCard(encounter, encounter.spawns[i], i, cols, l10n),
                OutlinedButton.icon(
                  key: const ValueKey('gladiator-add-spawn'),
                  onPressed: () => _pickZombie(
                    (type) => encounter.spawns.add(
                      GladiatorSpawnData(zombieType: type),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.gladiatorAddSpawn),
                ),
              ]),
            ],
            _card([
              _heading(l10n.gladiatorPunishmentPool),
              const SizedBox(height: 8),
              Text(l10n.gladiatorPunishmentHint),
              const SizedBox(height: 12),
              for (var i = 0; i < _data.punishmentPool.length; i++)
                _punishmentCard(_data.punishmentPool[i], i, l10n),
              OutlinedButton.icon(
                key: const ValueKey('gladiator-add-punishment'),
                onPressed: () => _pickZombie(
                  (type) => _data.punishmentPool.add(
                    GladiatorPunishmentZombieData(zombieType: type),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.gladiatorAddPunishment),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _spawnCard(
    GladiatorEncounterData encounter,
    GladiatorSpawnData spawn,
    int index,
    int cols,
    AppLocalizations l10n,
  ) => _card([
    _zombieHeader(spawn.zombieType, () {
      encounter.spawns.remove(spawn);
      _sync();
    }, (type) => spawn.zombieType = type),
    _number(
      spawn,
      'Time',
      'spawn-$index',
      l10n.gladiatorSpawnTime,
      spawn.time,
      (n) => spawn.values['Time'] = n,
    ),
    _number(
      spawn,
      'GridX',
      'spawn-$index',
      l10n.gladiatorSpawnColumn,
      spawn.gridX,
      (n) => spawn.values['GridX'] = n,
      integer: true,
      maximum: cols - 1,
    ),
    _number(
      spawn,
      'Count',
      'spawn-$index',
      l10n.gladiatorSpawnCount,
      spawn.count,
      (n) => spawn.values['Count'] = n,
      integer: true,
      minimum: 1,
    ),
    _number(
      spawn,
      'Interval',
      'spawn-$index',
      l10n.gladiatorSpawnInterval,
      spawn.interval,
      (n) => spawn.values['Interval'] = n,
    ),
    _level(
      'spawn-$index',
      l10n.gladiatorSpawnLevel,
      spawn.level,
      (level) => spawn.values['Level'] = level,
    ),
  ]);

  Widget _punishmentCard(
    GladiatorPunishmentZombieData entry,
    int index,
    AppLocalizations l10n,
  ) => _card([
    _zombieHeader(entry.zombieType, () {
      _data.punishmentPool.remove(entry);
      _sync();
    }, (type) => entry.zombieType = type),
    _number(
      entry,
      'Weight',
      'punishment-$index',
      l10n.gladiatorWeight,
      entry.weight,
      (n) => entry.values['Weight'] = n,
    ),
  ]);
}

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/glacier_module_presets.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_numeric_text_field.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Ice Age glacier-block zombie weights (`GlacierModuleProperties`).
class GlacierModuleScreen extends StatefulWidget {
  const GlacierModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  @override
  State<GlacierModuleScreen> createState() => _GlacierModuleScreenState();
}

class _GlacierModuleScreenState extends State<GlacierModuleScreen> {
  static const _objClass = 'GlacierModuleProperties';
  late String _alias;
  static const _levelMin = 0;
  static const _levelMax = 4;

  late PvzObject _moduleObj;
  late GlacierModulePropertiesData _data;
  String? _selectedPresetId;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: _objClass,
        objData: GlacierModulePropertiesData.createDefault().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = GlacierModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = GlacierModulePropertiesData.createDefault();
    }
    final battle = widget.levelFile.objects.firstWhereOrNull(
      (object) => object.objClass == 'ZombossBattleModuleProperties',
    );
    final variation = battle?.objData is Map
        ? (battle!.objData as Map)['ZombossMechType'] as String?
        : null;
    final variationPreset = GlacierModulePresets.forVariation(variation);
    _selectedPresetId =
        variationPreset != null &&
            GlacierModulePresets.matches(_data, variationPreset)
        ? variationPreset.id
        : GlacierModulePresets.matchingPreset(_data)?.id;
  }

  void _sync() {
    _data = GlacierModulePropertiesData(
      zombieSpawnData: GlacierModulePropertiesData.normalizeColumns(
        _data.zombieSpawnData,
      ),
    );
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _updateColumn(int columnIndex, GlacierColumnSpawnData column) {
    final cols = List<GlacierColumnSpawnData>.from(_data.zombieSpawnData);
    cols[columnIndex] = column;
    _data = GlacierModulePropertiesData(zombieSpawnData: cols);
    _selectedPresetId = null;
    _sync();
  }

  Future<void> _addEntry(int columnIndex) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showEditorChoiceDialog<String>(
      context,
      title: l10n?.glacierModuleAddContentTitle ?? 'Add Ice Chunk content',
      options: [
        EditorChoiceDialogOption(
          value: 'zombie',
          icon: Icons.pest_control_outlined,
          title: l10n?.glacierModuleAddZombieContent ?? 'Add zombie',
        ),
        EditorChoiceDialogOption(
          value: 'empty',
          icon: Icons.block,
          title:
              l10n?.glacierModuleEmptyType ??
              'No zombie appears when the Ice Chunk breaks',
        ),
      ],
    );
    if (!mounted || choice == null) return;

    if (choice == 'empty') {
      final column = _data.zombieSpawnData[columnIndex];
      _updateColumn(
        columnIndex,
        GlacierColumnSpawnData(
          entries: [
            ...column.entries,
            GlacierSpawnEntryData(typeName: ''),
          ],
        ),
      );
      return;
    }

    widget.onRequestZombieSelection((id) {
      if (!mounted) return;
      final column = _data.zombieSpawnData[columnIndex];
      _updateColumn(
        columnIndex,
        GlacierColumnSpawnData(
          entries: [
            ...column.entries,
            GlacierSpawnEntryData(typeName: id),
          ],
        ),
      );
    });
  }

  void _removeEntry(int columnIndex, int entryIndex) {
    final column = _data.zombieSpawnData[columnIndex];
    final entries = List<GlacierSpawnEntryData>.from(column.entries)
      ..removeAt(entryIndex);
    _updateColumn(columnIndex, GlacierColumnSpawnData(entries: entries));
  }

  void _updateEntry(
    int columnIndex,
    int entryIndex,
    GlacierSpawnEntryData entry,
  ) {
    final column = _data.zombieSpawnData[columnIndex];
    final entries = List<GlacierSpawnEntryData>.from(column.entries);
    entries[entryIndex] = entry;
    _updateColumn(columnIndex, GlacierColumnSpawnData(entries: entries));
  }

  void _pickZombie(int columnIndex, int entryIndex) {
    widget.onRequestZombieSelection((id) {
      if (!mounted) return;
      final entry = _data.zombieSpawnData[columnIndex].entries[entryIndex];
      _updateEntry(
        columnIndex,
        entryIndex,
        GlacierSpawnEntryData(
          typeName: id,
          weight: entry.weight,
          level: entry.level,
        ),
      );
    });
  }

  String _presetTitle(
    BuildContext context,
    AppLocalizations? l10n,
    GlacierModulePreset preset,
  ) {
    if (preset.isBlank) {
      return l10n?.glacierModulePresetBlankCustom ?? 'Blank custom preset';
    }
    return ZombossMechL10n.variationLabel(
      context,
      GlacierModulePresets.iceAgeBaseId,
      preset.variation,
      fallback: preset.variation,
    );
  }

  GlacierModulePreset? _currentPreset() {
    final selected = GlacierModulePresets.byId(_selectedPresetId);
    if (selected != null && GlacierModulePresets.matches(_data, selected)) {
      return selected;
    }
    return GlacierModulePresets.matchingPreset(_data);
  }

  Future<void> _applyPreset(GlacierModulePreset preset) async {
    final current = _currentPreset();
    if (current?.id == preset.id) return;
    final l10n = AppLocalizations.of(context);
    final from = current == null
        ? (l10n?.glacierModulePresetCustomConfiguration ??
              'Custom configuration')
        : _presetTitle(context, l10n, current);
    final to = _presetTitle(context, l10n, preset);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              l10n?.glacierModuleSwitchPresetTitle ?? 'Switch preset',
            ),
            content: Text(
              l10n?.glacierModuleSwitchPresetMessage(from, to) ??
                  'Switch from "$from" to "$to"? The current Ice Chunk configuration will be replaced.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n?.switchAction ?? 'Switch'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    _data = preset.createData();
    _selectedPresetId = preset.id;
    _sync();
  }

  Widget _buildPresetSelector(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final current = _currentPreset();
    final currentTitle = current == null
        ? (l10n?.glacierModulePresetCustomConfiguration ??
              'Custom configuration')
        : _presetTitle(context, l10n, current);

    return Card(
      child: ExpansionTile(
        key: const ValueKey('glacierPresetSelector'),
        initiallyExpanded: false,
        leading: const Icon(Icons.tune),
        title: Text(
          l10n?.glacierModulePresetSectionTitle ?? 'Preset configurations',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        subtitle: Text(currentTitle),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 720
                    ? 3
                    : constraints.maxWidth >= 460
                    ? 2
                    : 1;
                final chipWidth =
                    (constraints.maxWidth - 8 * (columns - 1)) / columns;
                final chipLabelWidth = (chipWidth - 32)
                    .clamp(0.0, chipWidth)
                    .toDouble();
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final preset in GlacierModulePresets.all)
                      SizedBox(
                        width: chipWidth,
                        child: ChoiceChip(
                          key: ValueKey('glacierPresetChip_${preset.id}'),
                          showCheckmark: false,
                          label: SizedBox(
                            width: chipLabelWidth,
                            child: Text(
                              _presetTitle(context, l10n, preset),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          selected: current?.id == preset.id,
                          onSelected: (_) => _applyPreset(preset),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleAliasChanged(String newAlias) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: newAlias,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = newAlias);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.glacierModuleTitle ?? 'Glacier module';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.glacierModuleHelpTitle ?? title,
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.glacierModuleHelpOverviewBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.glacierModuleHelpColumnsTitle ?? 'Columns',
                  body: l10n?.glacierModuleHelpColumnsBody ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.glacierModuleHelpRequirementsTitle ??
                      'Requirements',
                  body: l10n?.glacierModuleHelpRequirementsBody ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.glacierModuleHelpPresetsTitle ??
                      'Preset configurations',
                  body: l10n?.glacierModuleHelpPresetsBody ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ModuleAliasInputField(
            rtid: widget.rtid,
            alias: _alias,
            levelFile: widget.levelFile,
            onAliasChanged: _handleAliasChanged,
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: 16),
          _buildPresetSelector(l10n),
          const SizedBox(height: 16),
          ...List.generate(GlacierModulePropertiesData.columnCount, (col) {
            return _ColumnCard(
              columnIndex: col,
              column: _data.zombieSpawnData[col],
              l10n: l10n,
              onAddEntry: () => _addEntry(col),
              onRemoveEntry: (ei) => _removeEntry(col, ei),
              onUpdateEntry: (ei, entry) => _updateEntry(col, ei, entry),
              onPickZombie: (ei) => _pickZombie(col, ei),
            );
          }),
        ],
      ),
    );
  }
}

class _ColumnCard extends StatelessWidget {
  const _ColumnCard({
    required this.columnIndex,
    required this.column,
    required this.l10n,
    required this.onAddEntry,
    required this.onRemoveEntry,
    required this.onUpdateEntry,
    required this.onPickZombie,
  });

  final int columnIndex;
  final GlacierColumnSpawnData column;
  final AppLocalizations? l10n;
  final VoidCallback onAddEntry;
  final void Function(int entryIndex) onRemoveEntry;
  final void Function(int entryIndex, GlacierSpawnEntryData entry)
  onUpdateEntry;
  final void Function(int entryIndex) onPickZombie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columnLabel =
        l10n?.glacierModuleColumn(columnIndex + 1) ??
        'Column ${columnIndex + 1} (from left)';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: columnIndex == 0,
        title: Text(
          columnLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          l10n?.glacierModuleEntryCount(column.entries.length) ??
              '${column.entries.length} entries',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (column.entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n?.glacierModuleNoEntries ??
                          'No zombie entries for this column.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (column.entries.isNotEmpty) const SizedBox(height: 8),
                ...column.entries.asMap().entries.map((e) {
                  return _EntryRow(
                    key: ValueKey(
                      'col_${columnIndex}_entry_${e.key}_'
                      '${e.value.typeName}_${column.entries.length}',
                    ),
                    entry: e.value,
                    l10n: l10n,
                    onRemove: () => onRemoveEntry(e.key),
                    onUpdate: (entry) => onUpdateEntry(e.key, entry),
                    onPickZombie: () => onPickZombie(e.key),
                  );
                }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onAddEntry,
                  icon: const Icon(Icons.add),
                  label: Text(
                    l10n?.glacierModuleAddEntry ?? 'Add zombie entry',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    super.key,
    required this.entry,
    required this.l10n,
    required this.onRemove,
    required this.onUpdate,
    required this.onPickZombie,
  });

  static const _iconSize = 54.0;
  static const _fieldPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 14,
  );
  static const _fieldMinHeight = 52.0;

  final GlacierSpawnEntryData entry;
  final AppLocalizations? l10n;
  final VoidCallback onRemove;
  final void Function(GlacierSpawnEntryData entry) onUpdate;
  final VoidCallback onPickZombie;

  InputDecoration _fieldDecoration() => const InputDecoration(
    border: OutlineInputBorder(),
    isDense: true,
    contentPadding: _fieldPadding,
    constraints: BoxConstraints(minHeight: _fieldMinHeight),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ZombieRepository();
    final typeName = entry.typeName;
    final isEmptyOutcome = typeName.isEmpty;
    final zombie = typeName.isNotEmpty ? repo.getZombieById(typeName) : null;
    final displayName = typeName.isEmpty
        ? (l10n?.glacierModuleEmptyType ?? 'No zombie selected')
        : ResourceNames.lookup(context, repo.getName(typeName));
    final iconPath = zombie?.iconAssetPath;
    final switchLabel =
        l10n?.switchZombie ?? l10n?.switchCustomZombie ?? 'Switch zombie';
    final weightLabel = l10n?.glacierModuleWeight ?? 'Weight';
    final levelLabel = l10n?.glacierModuleLevel ?? 'Zombie level';

    Widget buildIcon() => SizedBox(
      width: _iconSize,
      height: _iconSize,
      child: iconPath != null
          ? AssetImageWidget(
              assetPath: iconPath,
              altCandidates: imageAltCandidates(iconPath),
              width: _iconSize,
              height: _iconSize,
            )
          : Icon(
              Icons.ac_unit,
              size: _iconSize * 0.65,
              color: theme.colorScheme.onSurfaceVariant,
            ),
    );

    Widget buildNameBlock() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (typeName.isNotEmpty)
          Text(
            typeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );

    Widget buildSwitchButton() => TextButton.icon(
      onPressed: onPickZombie,
      icon: const Icon(Icons.swap_horiz, size: 20),
      label: Text(switchLabel, overflow: TextOverflow.ellipsis),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    Widget buildWeightField() => Tooltip(
      message: isEmptyOutcome
          ? (l10n?.glacierModuleEmptyWeightTooltip ??
                'Weight for the outcome in which the Ice Chunk releases no zombie.')
          : (l10n?.glacierModuleWeightTooltip ??
                'Spawn weight for this zombie in this column.'),
      child: EditorResponsiveInputField(
        label: weightLabel,
        decoration: _fieldDecoration(),
        builder: (context, decoration) => EditorNumericTextField(
          key: const ValueKey('glacierZombieWeight'),
          value: entry.weight,
          style: theme.textTheme.bodyLarge,
          decoration: decoration,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: (v) {
            final w = num.tryParse(v);
            if (w != null && w >= 0) {
              onUpdate(
                GlacierSpawnEntryData(
                  typeName: entry.typeName,
                  weight: w,
                  level: entry.level,
                ),
              );
            }
          },
        ),
      ),
    );

    Widget buildLevelField() => Tooltip(
      message: l10n?.glacierModuleLevelTooltip ?? 'Zombie level from 0 to 4.',
      child: EditorResponsiveInputField(
        label: levelLabel,
        decoration: _fieldDecoration(),
        builder: (context, decoration) => DropdownButtonFormField<int>(
          key: ValueKey('lv_${entry.typeName}_${entry.level}'),
          initialValue: entry.level.clamp(
            _GlacierModuleScreenState._levelMin,
            _GlacierModuleScreenState._levelMax,
          ),
          isExpanded: true,
          isDense: true,
          padding: EdgeInsets.zero,
          style: theme.textTheme.bodyLarge,
          iconSize: 22,
          items: List.generate(
            _GlacierModuleScreenState._levelMax -
                _GlacierModuleScreenState._levelMin +
                1,
            (i) {
              final lv = i + _GlacierModuleScreenState._levelMin;
              return DropdownMenuItem(value: lv, child: Text('$lv'));
            },
          ),
          onChanged: (lv) {
            if (lv != null) {
              onUpdate(
                GlacierSpawnEntryData(
                  typeName: entry.typeName,
                  weight: entry.weight,
                  level: lv,
                ),
              );
            }
          },
          decoration: decoration,
        ),
      ),
    );

    Widget buildDeleteButton() => IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: l10n?.delete ?? 'Delete',
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      onPressed: onRemove,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildIcon(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildNameBlock(),
                          if (!isEmptyOutcome) buildSwitchButton(),
                        ],
                      ),
                    ),
                    buildDeleteButton(),
                  ],
                ),
                const SizedBox(height: 10),
                if (isEmptyOutcome)
                  buildWeightField()
                else
                  Row(
                    children: [
                      Expanded(child: buildWeightField()),
                      const SizedBox(width: 8),
                      Expanded(child: buildLevelField()),
                    ],
                  ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildIcon(),
              const SizedBox(width: 6),
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    Flexible(fit: FlexFit.loose, child: buildNameBlock()),
                    if (!isEmptyOutcome) buildSwitchButton(),
                  ],
                ),
              ),
              Expanded(
                flex: isEmptyOutcome ? 6 : 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: buildWeightField(),
                ),
              ),
              if (!isEmptyOutcome)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: buildLevelField(),
                  ),
                ),
              buildDeleteButton(),
            ],
          );
        },
      ),
    );
  }
}

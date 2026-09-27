import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_numeric_text_field.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Wave event editor for `WaveActionZombieTentProps` (zombie / festival tents).
class ZombieTentWaveEventScreen extends StatefulWidget {
  const ZombieTentWaveEventScreen({
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
  State<ZombieTentWaveEventScreen> createState() =>
      _ZombieTentWaveEventScreenState();
}

class _ZombieTentWaveEventScreenState extends State<ZombieTentWaveEventScreen> {
  static const _objClass = 'WaveActionZombieTentProps';
  static const _levelMin = 0;
  static const _levelMax = 10;

  late PvzObject _moduleObj;
  late WaveActionZombieTentPropsData _data;
  late String _alias;
  int _selectedX = 0;
  int _selectedY = 0;
  int? _tentToDelete;
  String _defaultTentType = ZombieTentData.zombieTentTypeFestival;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;

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
        objData: WaveActionZombieTentPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = WaveActionZombieTentPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = WaveActionZombieTentPropsData();
    }
    if (_data.zombieTents.isNotEmpty) {
      _defaultTentType = _data.zombieTents.last.tentType;
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _replaceTents(List<ZombieTentData> tents) {
    _data = WaveActionZombieTentPropsData(zombieTents: tents);
    _sync();
  }

  void _updateTent(int index, ZombieTentData tent) {
    final tents = List<ZombieTentData>.from(_data.zombieTents);
    tents[index] = tent;
    _defaultTentType = tent.tentType;
    _replaceTents(tents);
  }

  void _addTent() {
    final tent = ZombieTentData(
      column: _selectedX + 1,
      row: _selectedY + 1,
      tentType: _defaultTentType,
    );
    _replaceTents([..._data.zombieTents, tent]);
  }

  void _removeTent(int index) {
    final tents = List<ZombieTentData>.from(_data.zombieTents)..removeAt(index);
    _replaceTents(tents);
    setState(() => _tentToDelete = null);
  }

  void _addZombie(int tentIndex) {
    widget.onRequestZombieSelection((id) {
      final tent = _data.zombieTents[tentIndex];
      _updateTent(
        tentIndex,
        tent.copyWith(
          zombieTypesToSpawn: [
            ...tent.zombieTypesToSpawn,
            ZombieTentSpawnEntryData(zombieTypeName: id),
          ],
        ),
      );
    });
  }

  void _switchZombie(int tentIndex, int zombieIndex) {
    widget.onRequestZombieSelection((id) {
      final tent = _data.zombieTents[tentIndex];
      final zombies = List<ZombieTentSpawnEntryData>.from(
        tent.zombieTypesToSpawn,
      );
      final current = zombies[zombieIndex];
      zombies[zombieIndex] = ZombieTentSpawnEntryData(
        zombieTypeName: id,
        weight: current.weight,
        level: current.level,
      );
      _updateTent(tentIndex, tent.copyWith(zombieTypesToSpawn: zombies));
    });
  }

  Future<void> _removeZombie(int tentIndex, int zombieIndex) async {
    final tent = _data.zombieTents[tentIndex];
    final removed = tent.zombieTypesToSpawn[zombieIndex];
    final alias = CustomZombieLevelUtils.resolveCustomZombieAlias(
      widget.levelFile,
      removed.zombieTypeName,
    );
    var eraseOrphan = false;
    if (alias != null && mounted) {
      final choice =
          await CustomZombieLevelUtils.maybePromptDeleteOrphanBeforeRemove(
            context: context,
            levelFile: widget.levelFile,
            alias: alias,
          );
      if (!mounted || choice == null) return;
      eraseOrphan = choice;
    }
    final zombies = List<ZombieTentSpawnEntryData>.from(tent.zombieTypesToSpawn)
      ..removeAt(zombieIndex);
    _updateTent(tentIndex, tent.copyWith(zombieTypesToSpawn: zombies));
    if (alias != null && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(widget.levelFile, alias);
      widget.onChanged();
    }
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

  String _tentTypeLabel(String type, AppLocalizations? l10n) {
    switch (type) {
      case ZombieTentData.zombieTentTypeFestival:
        return l10n?.zombieTentTypeFestival ?? 'Festival tent';
      case ZombieTentData.zombieTentTypeNormal:
      default:
        return l10n?.zombieTentTypeNormal ?? 'Zombie tent';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final tentsAtPosition = <({int index, ZombieTentData tent})>[];
    final tentsOutside = <({int index, ZombieTentData tent})>[];
    for (var i = 0; i < _data.zombieTents.length; i++) {
      final tent = _data.zombieTents[i];
      final x = tent.column - 1;
      final y = tent.row - 1;
      final entry = (index: i, tent: tent);
      if (x == _selectedX &&
          y == _selectedY &&
          x >= 0 &&
          y >= 0 &&
          x < _gridCols &&
          y < _gridRows) {
        tentsAtPosition.add(entry);
      } else if (x < 0 || y < 0 || x >= _gridCols || y >= _gridRows) {
        tentsOutside.add(entry);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: eventTitle,
          isEvent: true,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutEvent ?? 'About this event',
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n?.eventZombieTentSpawn ?? 'Zombie tent spawn',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpZombieTentBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.usage ?? 'Usage',
                  body: l10n?.eventHelpZombieTentUsage ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.eventHelpZombieTentFieldsTitle ??
                      'Parameter Description',
                  body: l10n?.eventHelpZombieTentFields ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EditorAliasInputField(
                    alias: _alias,
                    levelFile: widget.levelFile,
                    onAliasChanged: _handleAliasChanged,
                    onChanged: widget.onChanged,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.selectedPosition ?? 'Selected position',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'R${_selectedY + 1} : C${_selectedX + 1}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildGrid(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.zombieTentSectionTitle ?? 'Tents at selected tile',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...tentsAtPosition.map(
                    (e) => Padding(
                      key: ValueKey(
                        'tent_${_data.zombieTents.length}_${e.index}',
                      ),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TentEditorCard(
                        tent: e.tent,
                        showCoordinates: false,
                        tentTypeLabel: _tentTypeLabel,
                        l10n: l10n,
                        levelMin: _levelMin,
                        levelMax: _levelMax,
                        onDelete: () => setState(() => _tentToDelete = e.index),
                        onChanged: (next) => _updateTent(e.index, next),
                        onAddZombie: () => _addZombie(e.index),
                        onRemoveZombie: (zi) => _removeZombie(e.index, zi),
                        onSwitchZombie: (zi) => _switchZombie(e.index, zi),
                      ),
                    ),
                  ),
                  Center(
                    child: FilledButton.icon(
                      onPressed: _addTent,
                      icon: const Icon(Icons.add),
                      label: Text(l10n?.zombieTentAddTent ?? 'Add tent'),
                    ),
                  ),
                  if (tentsOutside.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      l10n?.outsideLawnItems ?? 'Objects outside the lawn',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...tentsOutside.map(
                      (e) => Padding(
                        key: ValueKey(
                          'tent_${_data.zombieTents.length}_${e.index}',
                        ),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TentEditorCard(
                          tent: e.tent,
                          showCoordinates: true,
                          tentTypeLabel: _tentTypeLabel,
                          l10n: l10n,
                          levelMin: _levelMin,
                          levelMax: _levelMax,
                          onDelete: () =>
                              setState(() => _tentToDelete = e.index),
                          onChanged: (next) => _updateTent(e.index, next),
                          onAddZombie: () => _addZombie(e.index),
                          onRemoveZombie: (zi) => _removeZombie(e.index, zi),
                          onSwitchZombie: (zi) => _switchZombie(e.index, zi),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (_tentToDelete != null)
              AlertDialog(
                title: Text(l10n?.zombieTentDeleteTitle ?? 'Delete tent'),
                content: Text(
                  l10n?.zombieTentDeleteConfirm ?? 'Delete this tent?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => setState(() => _tentToDelete = null),
                    child: Text(l10n?.cancel ?? 'Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => _removeTent(_tentToDelete!),
                    child: Text(l10n?.delete ?? 'Delete'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final theme = Theme.of(context);
    return scaleTableForDesktop(
      context: context,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: EditorItemCardLayout.gridPreviewMaxWidth(context),
        ),
        child: AspectRatio(
          aspectRatio: _gridCols / _gridRows,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF31383B)
                  : const Color(0xFFD7ECF1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF6B899A), width: 1),
            ),
            child: Column(
              children: List.generate(_gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(_gridCols, (col) {
                      final isSelected = row == _selectedY && col == _selectedX;
                      final cellTents = _data.zombieTents
                          .where((t) => t.column - 1 == col && t.row - 1 == row)
                          .toList();
                      final count = cellTents.length;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedX = col;
                            _selectedY = row;
                          }),
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    )
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : const Color(
                                        0xFF6B899A,
                                      ).withValues(alpha: 0.35),
                              ),
                            ),
                            child: count == 0
                                ? null
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final firstTent = cellTents.first;
                                      return Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Positioned.fill(
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: GridItemIcon(
                                                  typeName: firstTent.tentType,
                                                  size: 32,
                                                  fit: BoxFit.contain,
                                                  borderRadius: 4,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (count > 1)
                                            GridCellCountBadge(
                                              label: '+${count - 1}',
                                              cellWidth: constraints.maxWidth,
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TentEditorCard extends StatelessWidget {
  const _TentEditorCard({
    required this.tent,
    required this.showCoordinates,
    required this.tentTypeLabel,
    required this.l10n,
    required this.levelMin,
    required this.levelMax,
    required this.onDelete,
    required this.onChanged,
    required this.onAddZombie,
    required this.onRemoveZombie,
    required this.onSwitchZombie,
  });

  final ZombieTentData tent;
  final bool showCoordinates;
  final String Function(String type, AppLocalizations? l10n) tentTypeLabel;
  final AppLocalizations? l10n;
  final int levelMin;
  final int levelMax;
  final VoidCallback onDelete;
  final void Function(ZombieTentData tent) onChanged;
  final VoidCallback onAddZombie;
  final void Function(int zombieIndex) onRemoveZombie;
  final void Function(int zombieIndex) onSwitchZombie;

  static const _fieldPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 14,
  );
  static const _fieldMinHeight = 52.0;
  static const _tentTypeIconSize = 56.0;

  InputDecoration _decoration(ThemeData theme) => const InputDecoration(
    border: OutlineInputBorder(),
    isDense: true,
    contentPadding: _fieldPadding,
    constraints: BoxConstraints(minHeight: _fieldMinHeight),
  );

  String _displayName(BuildContext context, String typeName) {
    final localized = ResourceNames.lookup(context, 'griditem_$typeName');
    if (localized != 'griditem_$typeName') return localized;
    return tentTypeLabel(typeName, l10n);
  }

  Widget _tentTypeMenuItem(BuildContext context, String typeName) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: _tentTypeIconSize,
          height: _tentTypeIconSize,
          child: GridItemIcon(
            typeName: typeName,
            size: _tentTypeIconSize,
            fit: BoxFit.contain,
            borderRadius: 4,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _displayName(context, typeName),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeName = typeNameIsKnown(tent.tentType)
        ? tent.tentType
        : ZombieTentData.zombieTentTypeNormal;
    const tentTypes = [
      ZombieTentData.zombieTentTypeNormal,
      ZombieTentData.zombieTentTypeFestival,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showCoordinates) ...[
              Text(
                'R${tent.row} : C${tent.column}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 80),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: typeName,
                iconSize: _tentTypeIconSize,
                menuMaxHeight: 520,
                decoration: InputDecoration(
                  labelText:
                      l10n?.zombieTentTypeLabel ?? 'Tent type (TentType)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                ),
                selectedItemBuilder: (context) => [
                  for (final type in tentTypes)
                    _tentTypeMenuItem(context, type),
                ],
                items: [
                  for (final type in tentTypes)
                    DropdownMenuItem(
                      value: type,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: _tentTypeMenuItem(context, type),
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  onChanged(tent.copyWith(tentType: v));
                },
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final hpField = EditorResponsiveInputField(
                  label: l10n?.zombieTentHitpoints ?? 'Hitpoints',
                  decoration: _decoration(theme),
                  builder: (context, decoration) => EditorNumericTextField(
                    key: const ValueKey('tentHitpoints'),
                    value: tent.hitpoints,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: decoration,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n == null) return;
                      onChanged(tent.copyWith(hitpoints: n));
                    },
                  ),
                );
                final intervalField = EditorResponsiveInputField(
                  label:
                      l10n?.zombieTentProductionInterval ??
                      'Production interval (s)',
                  decoration: _decoration(theme),
                  builder: (context, decoration) => EditorNumericTextField(
                    key: const ValueKey('tentProductionInterval'),
                    value: tent.productionInterval,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: decoration,
                    onChanged: (v) {
                      final n = double.tryParse(v);
                      if (n == null) return;
                      onChanged(tent.copyWith(productionInterval: n));
                    },
                  ),
                );
                if (constraints.maxWidth < 420) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      hpField,
                      const SizedBox(height: 12),
                      intervalField,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: hpField),
                    const SizedBox(width: 12),
                    Expanded(child: intervalField),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.zombieTentZombiesSection ?? 'Zombies to spawn',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...tent.zombieTypesToSpawn.asMap().entries.map((entry) {
              final i = entry.key;
              final z = entry.value;
              return Padding(
                key: ValueKey(
                  'spawn_${tent.zombieTypesToSpawn.length}_${i}_${z.zombieTypeName}',
                ),
                padding: const EdgeInsets.only(bottom: 8),
                child: _SpawnEntryRow(
                  entry: z,
                  l10n: l10n,
                  levelMin: levelMin,
                  levelMax: levelMax,
                  onRemove: () => onRemoveZombie(i),
                  onSwitchZombie: () => onSwitchZombie(i),
                  onUpdate: (next) {
                    final list = List<ZombieTentSpawnEntryData>.from(
                      tent.zombieTypesToSpawn,
                    );
                    list[i] = next;
                    onChanged(tent.copyWith(zombieTypesToSpawn: list));
                  },
                ),
              );
            }),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: onAddZombie,
                  icon: const Icon(Icons.add),
                  label: Text(l10n?.zombieTentAddZombie ?? 'Add zombie'),
                ),
                const Spacer(),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n?.zombieTentDeleteTitle ?? 'Delete tent'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static bool typeNameIsKnown(String typeName) =>
      typeName == ZombieTentData.zombieTentTypeFestival ||
      typeName == ZombieTentData.zombieTentTypeNormal;
}

class _SpawnEntryRow extends StatelessWidget {
  const _SpawnEntryRow({
    required this.entry,
    required this.l10n,
    required this.levelMin,
    required this.levelMax,
    required this.onRemove,
    required this.onSwitchZombie,
    required this.onUpdate,
  });

  final ZombieTentSpawnEntryData entry;
  final AppLocalizations? l10n;
  final int levelMin;
  final int levelMax;
  final VoidCallback onRemove;
  final VoidCallback onSwitchZombie;
  final void Function(ZombieTentSpawnEntryData entry) onUpdate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ZombieRepository();
    final typeName = entry.zombieTypeName;
    final zombie = typeName.isNotEmpty ? repo.getZombieById(typeName) : null;
    final displayName = typeName.isEmpty
        ? (l10n?.glacierModuleEmptyType ?? 'No zombie selected')
        : ResourceNames.lookup(context, repo.getName(typeName));
    final iconPath = zombie?.iconAssetPath;
    final switchLabel =
        l10n?.switchZombie ?? l10n?.switchCustomZombie ?? 'Switch zombie';

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: iconPath != null
                      ? AssetImageWidget(
                          assetPath: iconPath,
                          altCandidates: imageAltCandidates(iconPath),
                          width: 40,
                          height: 40,
                        )
                      : Icon(
                          Icons.person_outline,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                  ),
                ),
                IconButton(
                  tooltip: l10n?.delete ?? 'Delete',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onSwitchZombie,
                icon: const Icon(Icons.swap_horiz, size: 20),
                label: Text(switchLabel, overflow: TextOverflow.ellipsis),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final weightField = EditorResponsiveInputField(
                  label: l10n?.zombieTentWeight ?? 'Weight',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  builder: (context, decoration) => EditorNumericTextField(
                    key: const ValueKey('tentZombieWeight'),
                    value: entry.weight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: decoration,
                    onChanged: (v) {
                      final n = num.tryParse(v);
                      if (n == null) return;
                      onUpdate(
                        ZombieTentSpawnEntryData(
                          zombieTypeName: entry.zombieTypeName,
                          weight: n,
                          level: entry.level,
                        ),
                      );
                    },
                  ),
                );
                final levelField = EditorResponsiveInputField(
                  label: l10n?.glacierModuleLevel ?? 'Zombie level',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  builder: (context, decoration) =>
                      DropdownButtonFormField<int>(
                        key: const ValueKey('tentZombieLevel'),
                        initialValue: entry.level.clamp(levelMin, levelMax),
                        isExpanded: true,
                        items: [
                          for (var level = levelMin; level <= levelMax; level++)
                            DropdownMenuItem(
                              value: level,
                              child: Text('$level'),
                            ),
                        ],
                        decoration: decoration,
                        onChanged: (level) {
                          if (level == null) return;
                          onUpdate(
                            ZombieTentSpawnEntryData(
                              zombieTypeName: entry.zombieTypeName,
                              weight: entry.weight,
                              level: level,
                            ),
                          );
                        },
                      ),
                );
                if (constraints.maxWidth < 360) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      weightField,
                      const SizedBox(height: 8),
                      levelField,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: weightField),
                    const SizedBox(width: 8),
                    Expanded(child: levelField),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

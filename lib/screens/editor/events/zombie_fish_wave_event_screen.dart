import 'package:c_editor/widgets/oak_train_warnings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/custom_zombie_properties_actions.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/zombie_row_lane_drag_drop_editor.dart';
import 'package:c_editor/widgets/zombie_row_lane_utils.dart';
import 'package:c_editor/widgets/zombie_spawn_edit_sheet.dart';
import 'package:c_editor/widgets/zombie_selection_flow.dart';
import 'package:c_editor/screens/editor/events/fish_properties_entry_screen.dart';

/// Zombie + fish wave event for submarine levels.
class ZombieFishWaveEventScreen extends StatefulWidget {
  const ZombieFishWaveEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
    this.onRequestPlantSelection,
    this.onEditCustomZombie,
    this.onInjectCustomZombie,
    this.onEditCustomFish,
    this.onInjectCustomFish,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;
  final void Function(void Function(String) onSelected)?
  onRequestPlantSelection;
  final void Function(String rtid)? onEditCustomZombie;
  final String? Function(String baseType)? onInjectCustomZombie;
  final void Function(String rtid)? onEditCustomFish;
  final String? Function(String baseFishAlias)? onInjectCustomFish;

  @override
  State<ZombieFishWaveEventScreen> createState() =>
      _ZombieFishWaveEventScreenState();
}

class _ZombieFishWaveEventScreenState extends State<ZombieFishWaveEventScreen> {
  static const _objClass = 'SpawnZombiesFishWaveActionProps';

  late PvzObject _moduleObj;
  late SpawnZombiesFishWaveActionPropsData _data;
  late String _alias;
  double _batchLevel = 1;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _maxRow => _isDeepSeaLawn ? 6 : 5;

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
        objData: SpawnZombiesFishWaveActionPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SpawnZombiesFishWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SpawnZombiesFishWaveActionPropsData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  String _resolveBaseTypeName(ZombieSpawnData z) {
    final info = RtidParser.parse(z.type);
    final alias = info?.alias ?? z.type;
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (obj != null && obj.objClass == 'ZombieType') {
      final d = obj.objData;
      if (d is Map<String, dynamic> && d['TypeName'] is String) {
        return d['TypeName'] as String;
      }
    }
    return ZombiePropertiesRepository.getTypeNameByAlias(alias);
  }

  bool _isElite(ZombieSpawnData z) =>
      ZombieRepository().isElite(_resolveBaseTypeName(z));

  bool _isCustomZombie(ZombieSpawnData z) {
    return CustomZombieLevelUtils.isCustomZombieRtid(z.type);
  }

  void _addZombie({int? row}) {
    widget.onRequestZombieSelection((id) {
      final aliases = ZombieRepository().buildZombieAliases(id);
      final rtid = RtidParser.build(aliases, 'ZombieTypes');
      final zombies = List<ZombieSpawnData>.from(_data.zombies)
        ..add(ZombieSpawnData(type: rtid, level: 1, row: row));
      _setZombies(zombies, sortRows: true);
    });
  }

  void _setZombies(List<ZombieSpawnData> zombies, {bool sortRows = false}) {
    if (sortRows) {
      sortZombieSpawnListByRow(zombies, maxRow: _maxRow);
    }
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: _data.additionalPlantFood,
      spawnPlantName: _data.spawnPlantName,
      zombies: zombies,
      fishes: _data.fishes,
    );
    _sync();
  }

  void _updateZombie(int index, ZombieSpawnData z) {
    final zombies = List<ZombieSpawnData>.from(_data.zombies);
    final rowChanged = zombies[index].row != z.row;
    zombies[index] = z;
    _setZombies(zombies, sortRows: rowChanged);
  }

  Future<void> _removeZombie(int index, {bool? eraseOrphanProperties}) async {
    final removed = _data.zombies[index];
    final info = RtidParser.parse(removed.type);
    var eraseOrphan = eraseOrphanProperties ?? false;
    if (info?.source == 'CurrentLevel' &&
        eraseOrphanProperties == null &&
        mounted) {
      final choice =
          await CustomZombieLevelUtils.maybePromptDeleteOrphanBeforeRemove(
            context: context,
            levelFile: widget.levelFile,
            alias: info!.alias,
          );
      if (!mounted || choice == null) return;
      eraseOrphan = choice;
    }
    final zombies = List<ZombieSpawnData>.from(_data.zombies)..removeAt(index);
    _setZombies(zombies);
    if (info?.source == 'CurrentLevel' && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(
        widget.levelFile,
        info!.alias,
      );
      widget.onChanged();
    }
  }

  void _openFishProperties() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FishPropertiesEntryScreen(
          levelFile: widget.levelFile,
          fishes: _data.fishes,
          onChanged: (newFishes) {
            _data = SpawnZombiesFishWaveActionPropsData(
              notificationEvents: _data.notificationEvents,
              additionalPlantFood: _data.additionalPlantFood,
              spawnPlantName: _data.spawnPlantName,
              zombies: _data.zombies,
              fishes: newFishes,
            );
            _sync();
          },
          onBack: () => Navigator.pop(context),
          onEditCustomFish: widget.onEditCustomFish,
          onInjectCustomFish: widget.onInjectCustomFish,
        ),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final hasFishes = _data.fishes.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n?.eventZombieFishWave ?? 'Zombie Fish Wave',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpZombieFishWaveBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.fishPropertiesGrid ?? 'Fish placement',
                  body: l10n?.eventHelpZombieFishWaveFish ?? '',
                ),
                HelpSectionData(
                  title: l10n?.batchLevel ?? 'Batch level',
                  body:
                      l10n?.eventHelpBatchLevel ??
                      'Set level for all non-elite zombies in this wave.',
                ),
                HelpSectionData(
                  title: l10n?.dropConfigPlantFood ?? 'Drop config',
                  body:
                      l10n?.eventHelpDropConfig ??
                      'Plant food or plant cards carried by zombies.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OakTrainWarnings(levelFile: widget.levelFile, event: _moduleObj),
              EditorAliasInputField(
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.zombieList ?? 'Zombies',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ZombieRowLaneDragDropEditor(
                maxRow: _maxRow,
                rowLabel: (row) => l10n?.rowN(row) ?? 'Row $row',
                randomRowLabel: l10n?.randomRow ?? 'Random row',
                items: _data.zombies.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final z = entry.value;
                  final baseType = _resolveBaseTypeName(z);
                  final zInfo = ZombieRepository().getZombieById(baseType);
                  final isElite = _isElite(z);
                  return ZombieLaneIconData(
                    identity: z,
                    listIndex: idx,
                    rowValue: z.row ?? 0,
                    iconPath: zInfo?.iconAssetPath,
                    levelDisplay: isElite ? 'E' : '${z.level ?? 1}',
                    isElite: isElite,
                    isCustom: _isCustomZombie(z),
                    isMissingCustomZombie:
                        CustomZombieLevelUtils.isMissingCustomZombie(
                          widget.levelFile,
                          z.type,
                        ),
                  );
                }).toList(),
                onTap: (index) =>
                    _showZombieEditSheet(index, _data.zombies[index]),
                onMove: _handleZombieDragDropMove,
                onAddToRow: (row) => _addZombie(row: row == 0 ? null : row),
              ),
              const SizedBox(height: 16),
              _buildBatchLevelCard(theme, l10n),
              const SizedBox(height: 16),
              _buildDropConfigCard(context, theme, l10n),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.water, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n?.fishPropertiesButton ?? 'Fish properties',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      EditorFilledButton(
                        onPressed: _openFishProperties,
                        icon: Icon(hasFishes ? Icons.edit : Icons.add),
                        label: Text(
                          hasFishes
                              ? (l10n?.editFishProperties ??
                                    'Edit fish properties')
                              : (l10n?.addFishProperties ??
                                    'Add fish properties'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _applyBatchLevel() {
    final level = _batchLevel.round();
    final zombies = _data.zombies.map((z) {
      if (_isElite(z)) {
        return ZombieSpawnData(type: z.type, row: z.row, level: null);
      }
      return ZombieSpawnData(type: z.type, row: z.row, level: level);
    }).toList();
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: _data.additionalPlantFood,
      spawnPlantName: _data.spawnPlantName,
      zombies: zombies,
      fishes: _data.fishes,
    );
    _sync();
  }

  void _updateAdditionalPlantFood(int count) {
    final maxCount = _data.zombies.length;
    final clamped = count.clamp(0, maxCount);
    final currentPlants = List<String>.from(_data.spawnPlantName ?? []);
    if (currentPlants.length > clamped) {
      currentPlants.removeRange(clamped, currentPlants.length);
    }
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: clamped == 0 ? null : clamped,
      spawnPlantName: currentPlants.isEmpty ? null : currentPlants,
      zombies: _data.zombies,
      fishes: _data.fishes,
    );
    _sync();
  }

  void _addSpawnPlant(String id) {
    final plants = List<String>.from(_data.spawnPlantName ?? []);
    final total = _data.additionalPlantFood ?? 0;
    if (_data.zombies.isEmpty || total == 0 || plants.length >= total) {
      return;
    }
    plants.add(id);
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: total,
      spawnPlantName: plants,
      zombies: _data.zombies,
      fishes: _data.fishes,
    );
    _sync();
  }

  void _handleZombieDragDropMove(int fromIndex, int toRow, int rowInsertIndex) {
    final zombies = List<ZombieSpawnData>.from(_data.zombies);
    moveZombieSpawnInListByRowSlot(
      zombies: zombies,
      fromIndex: fromIndex,
      toRow: toRow,
      maxRow: _maxRow,
      rowInsertIndex: rowInsertIndex,
    );
    _setZombies(zombies);
  }

  void _removeSpawnPlantAt(int index) {
    final plants = List<String>.from(_data.spawnPlantName ?? []);
    if (index >= 0 && index < plants.length) {
      plants.removeAt(index);
    }
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: plants.isNotEmpty ? plants.length : null,
      spawnPlantName: plants.isEmpty ? null : plants,
      zombies: _data.zombies,
      fishes: _data.fishes,
    );
    _sync();
  }

  void _clampDropConfigToZombieCount() {
    final maxCount = _data.zombies.length;
    final count = _data.additionalPlantFood ?? 0;
    if (count > maxCount) {
      _updateAdditionalPlantFood(maxCount);
    }
  }

  Widget _buildBatchLevelCard(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.layers, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.batchLevel ?? 'Batch level',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_batchLevel.round()}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final slider = Slider(
                  value: _batchLevel,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _batchLevel.round().toString(),
                  onChanged: (v) => setState(() => _batchLevel = v),
                );
                final applyButton = FilledButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          l10n?.applyBatchLevel ?? 'Apply batch level?',
                        ),
                        content: Text(
                          l10n?.applyBatchLevelContent(_batchLevel.round()) ??
                              'Set all zombies in this wave to level ${_batchLevel.round()} (elite unchanged).',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l10n?.cancel ?? 'Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l10n?.apply ?? 'Apply'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) _applyBatchLevel();
                  },
                  child: Text(l10n?.apply ?? 'Apply'),
                );

                if (constraints.maxWidth < 420) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      slider,
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: applyButton,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: slider),
                    const SizedBox(width: 12),
                    applyButton,
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.appliesToAllNonElite ??
                  'Applies to all non-elite zombies in this wave.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropConfigCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return WaveDropConfigCard(
      totalDropCount: _data.additionalPlantFood ?? 0,
      plants: List<String>.from(_data.spawnPlantName ?? []),
      zombieCount: _data.zombies.length,
      onTotalDropCountChanged: _updateAdditionalPlantFood,
      onRemovePlantAt: _removeSpawnPlantAt,
      onAddPlant: widget.onRequestPlantSelection == null
          ? null
          : () {
              widget.onRequestPlantSelection!.call(_addSpawnPlant);
            },
    );
  }

  void _showZombieEditSheet(int index, ZombieSpawnData zombie) {
    final baseType = _resolveBaseTypeName(zombie);
    final info = ZombieRepository().getZombieById(baseType);
    final isCustom = _isCustomZombie(zombie);
    final isElite = _isElite(zombie);

    showZombieSpawnEditSheet(
      context: context,
      options: ZombieSpawnEditSheetOptions(
        showRow: true,
        maxRow: _maxRow,
        showDirection: true,
        showLevel: true,
      ),
      iconPath: info?.iconAssetPath,
      displayName: info != null
          ? ResourceNames.lookup(context, info.name)
          : baseType,
      isCustom: isCustom,
      isElite: isElite,
      rowValue: zombie.row ?? 0,
      levelValue: zombie.level ?? 1,
      fromLeft: zombie.direction == 'left',
      onChangeType: () {
        Future.microtask(() async {
          if (!mounted) return;
          final selected = await pushZombieSelection(context);
          if (!mounted || selected == null) return;
          final aliases = ZombieRepository().buildZombieAliases(selected);
          final rtid = RtidParser.build(aliases, 'ZombieTypes');
          _updateZombie(
            index,
            ZombieSpawnData(
              type: rtid,
              row: zombie.row,
              level: zombie.level,
              direction: zombie.direction == 'left' ? 'left' : null,
            ),
          );
        });
      },
      onRowChanged: (row) {
        _updateZombie(
          index,
          ZombieSpawnData(
            type: zombie.type,
            row: row == 0 ? null : row,
            level: zombie.level,
            direction: zombie.direction == 'left' ? 'left' : null,
          ),
        );
      },
      onDirectionChanged: (fromLeft) {
        _updateZombie(
          index,
          ZombieSpawnData(
            type: zombie.type,
            row: zombie.row,
            level: zombie.level,
            direction: fromLeft ? 'left' : null,
          ),
        );
      },
      onLevelChanged: (level) {
        _updateZombie(
          index,
          ZombieSpawnData(
            type: zombie.type,
            row: zombie.row,
            level: level == 0 ? null : level,
            direction: zombie.direction == 'left' ? 'left' : null,
          ),
        );
      },
      onCopy: () {
        final copy = ZombieSpawnData(
          type: zombie.type,
          row: zombie.row,
          level: zombie.level,
          direction: zombie.direction == 'left' ? 'left' : null,
        );
        _data = SpawnZombiesFishWaveActionPropsData(
          notificationEvents: _data.notificationEvents,
          additionalPlantFood: _data.additionalPlantFood,
          spawnPlantName: _data.spawnPlantName,
          zombies: [..._data.zombies, copy],
          fishes: _data.fishes,
        );
        _clampDropConfigToZombieCount();
        _sync();
      },
      onDelete: (sheetContext) {
        CustomZombieLevelUtils.handleDeleteFromBottomSheet(
          sheetContext: sheetContext,
          parentContext: context,
          levelFile: widget.levelFile,
          zombieTypeRtid: zombie.type,
          onRemove: (eraseOrphan) =>
              _removeZombie(index, eraseOrphanProperties: eraseOrphan),
        );
      },
      customPropertiesActions:
          widget.onEditCustomZombie != null ||
              widget.onInjectCustomZombie != null
          ? CustomZombiePropertiesSheetActions(
              levelFile: widget.levelFile,
              baseType: baseType,
              currentRtid: zombie.type,
              onEditCustomZombie: widget.onEditCustomZombie,
              onInjectCustomZombie: widget.onInjectCustomZombie,
              onCloseSheet: () {
                if (mounted) Navigator.of(context).pop();
              },
              onRtidSelected: (rtid) {
                _updateZombie(
                  index,
                  ZombieSpawnData(
                    type: rtid,
                    row: zombie.row,
                    level: zombie.level,
                    direction: zombie.direction == 'left' ? 'left' : null,
                  ),
                );
              },
            )
          : null,
    );
  }
}

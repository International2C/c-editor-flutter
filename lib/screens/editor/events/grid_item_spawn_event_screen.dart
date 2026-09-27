import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart'
    show ZombieRepository, ZombieTag;
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/custom_zombie_properties_actions.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/zombie_flat_lane_drag_drop_editor.dart';
import 'package:c_editor/widgets/zombie_row_lane_utils.dart';
import 'package:c_editor/widgets/zombie_spawn_edit_sheet.dart';

/// Spawn zombies from grid item event editor. Ported from Z-Editor-master GridItemSpawnerEventEP.kt.
/// Uses jittered-style zombie icon cards, bottom sheet editing, and button handling.
class GridItemSpawnEventScreen extends StatefulWidget {
  const GridItemSpawnEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestGridItemSelection,
    required this.onRequestZombieSelection,
    this.onEditCustomZombie,
    this.onInjectCustomZombie,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestGridItemSelection;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;
  final void Function(String rtid)? onEditCustomZombie;
  final String? Function(String alias)? onInjectCustomZombie;

  @override
  State<GridItemSpawnEventScreen> createState() =>
      _GridItemSpawnEventScreenState();
}

class _GridItemSpawnEventScreenState extends State<GridItemSpawnEventScreen> {
  static const _objClass = 'SpawnZombiesFromGridItemSpawnerProps';

  late PvzObject _moduleObj;
  late SpawnZombiesFromGridItemData _data;
  late String _alias;

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
        objData: SpawnZombiesFromGridItemData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SpawnZombiesFromGridItemData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SpawnZombiesFromGridItemData();
    }
    for (final z in _data.zombies) {
      if (_isElite(z)) {
        z.level = null;
      } else if ((z.level ?? 1) < 1) {
        z.level = 1;
      }
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    GridItemRepository.cleanupUnusedCustomGridItemTypes(widget.levelFile);
    widget.onChanged();
    setState(() {});
  }

  String _resolveBaseTypeName(ZombieSpawnData zombie) {
    final info = RtidParser.parse(zombie.type);
    final alias = info?.alias ?? zombie.type;
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (obj != null && obj.objClass == 'ZombieType') {
      final data = obj.objData;
      if (data is Map<String, dynamic> && data['TypeName'] is String) {
        return data['TypeName'] as String;
      }
    }
    return ZombiePropertiesRepository.getTypeNameByAlias(alias);
  }

  bool _isElite(ZombieSpawnData zombie) {
    return ZombieRepository().isElite(_resolveBaseTypeName(zombie));
  }

  bool _isCustomZombie(ZombieSpawnData zombie) {
    return CustomZombieLevelUtils.isCustomZombieRtid(zombie.type);
  }

  void _addGridType() {
    widget.onRequestGridItemSelection((id) {
      final rtid = GridItemRepository.buildGridItemTypeRtid(
        id,
        widget.levelFile,
      );
      _data = SpawnZombiesFromGridItemData(
        waveStartMessage: _data.waveStartMessage,
        zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
        gridTypes: [..._data.gridTypes, rtid],
        zombies: _data.zombies,
      );
      _sync();
    });
  }

  void _removeGridType(int index) {
    final gridTypes = List<String>.from(_data.gridTypes)..removeAt(index);
    _data = SpawnZombiesFromGridItemData(
      waveStartMessage: _data.waveStartMessage,
      zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
      gridTypes: gridTypes,
      zombies: _data.zombies,
    );
    _sync();
  }

  void _addZombie() {
    widget.onRequestZombieSelection((id) {
      final aliases = ZombieRepository().buildZombieAliases(id);
      final rtid = RtidParser.build(aliases, 'ZombieTypes');
      final isElite =
          ZombieRepository()
              .getZombieById(id)
              ?.tags
              .contains(ZombieTag.elite) ??
          false;
      _data = SpawnZombiesFromGridItemData(
        waveStartMessage: _data.waveStartMessage,
        zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
        gridTypes: _data.gridTypes,
        zombies: [
          ..._data.zombies,
          ZombieSpawnData(type: rtid, level: isElite ? null : 1, row: null),
        ],
      );
      _sync();
    });
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
    _data = SpawnZombiesFromGridItemData(
      waveStartMessage: _data.waveStartMessage,
      zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
      gridTypes: _data.gridTypes,
      zombies: zombies,
    );
    _sync();
    if (info?.source == 'CurrentLevel' && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(
        widget.levelFile,
        info!.alias,
      );
      widget.onChanged();
    }
  }

  void _updateZombie(int index, ZombieSpawnData zombie) {
    final zombies = List<ZombieSpawnData>.from(_data.zombies);
    zombies[index] = zombie;
    _data = SpawnZombiesFromGridItemData(
      waveStartMessage: _data.waveStartMessage,
      zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
      gridTypes: _data.gridTypes,
      zombies: zombies,
    );
    _sync();
  }

  void _replaceZombieType(int index, String newRtid) {
    final zombies = List<ZombieSpawnData>.from(_data.zombies);
    final current = zombies[index];
    final baseType = ZombiePropertiesRepository.getTypeNameByAlias(
      RtidParser.parse(newRtid)?.alias ?? newRtid,
    );
    final isEliteNew = ZombieRepository().isElite(baseType);
    zombies[index] = ZombieSpawnData(
      type: newRtid,
      level: isEliteNew ? null : current.level,
      row: current.row,
    );
    _data = SpawnZombiesFromGridItemData(
      waveStartMessage: _data.waveStartMessage,
      zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
      gridTypes: _data.gridTypes,
      zombies: zombies,
    );
    _sync();
  }

  void _handleZombieDragDropMove(int fromIndex, int insertIndex) {
    final zombies = List<ZombieSpawnData>.from(_data.zombies);
    reorderZombieFlatListByInsertIndex(
      list: zombies,
      fromIndex: fromIndex,
      insertIndex: insertIndex,
    );
    _data = SpawnZombiesFromGridItemData(
      waveStartMessage: _data.waveStartMessage,
      zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
      gridTypes: _data.gridTypes,
      zombies: zombies,
    );
    _sync();
  }

  void _showZombieEditSheet(int index) {
    final zombie = _data.zombies[index];
    final isElite = _isElite(zombie);
    final baseType = _resolveBaseTypeName(zombie);
    final info = ZombieRepository().getZombieById(baseType);
    final displayName = ResourceNames.lookup(context, info?.name ?? baseType);
    final iconPath = info?.iconAssetPath;
    final isCustom = _isCustomZombie(zombie);

    showZombieSpawnEditSheet(
      context: context,
      options: const ZombieSpawnEditSheetOptions(
        showRow: false,
        showLevel: true,
      ),
      iconPath: iconPath,
      displayName: displayName,
      isCustom: isCustom,
      isElite: isElite,
      levelValue: zombie.level ?? 0,
      onChangeType: () {
        Future.microtask(() {
          widget.onRequestZombieSelection((id) {
            final aliases = ZombieRepository().buildZombieAliases(id);
            final rtid = RtidParser.build(aliases, 'ZombieTypes');
            _replaceZombieType(index, rtid);
          });
        });
      },
      onLevelChanged: (level) {
        _updateZombie(
          index,
          ZombieSpawnData(
            type: zombie.type,
            row: null,
            level: level == 0 ? null : level,
          ),
        );
      },
      onCopy: () {
        final copy = ZombieSpawnData(
          type: zombie.type,
          row: null,
          level: isElite ? null : zombie.level,
        );
        _data = SpawnZombiesFromGridItemData(
          waveStartMessage: _data.waveStartMessage,
          zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
          gridTypes: _data.gridTypes,
          zombies: [..._data.zombies, copy],
        );
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
              onCloseSheet: () => Navigator.of(context).pop(),
              onRtidSelected: (rtid) {
                _updateZombie(
                  index,
                  ZombieSpawnData(type: rtid, row: null, level: zombie.level),
                );
              },
            )
          : null,
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
    final theme = Theme.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final zombieRepo = ZombieRepository();
    final objectAliases = widget.levelFile.objects
        .expand((o) => o.aliases ?? [])
        .toSet();

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
            onPressed: () {
              if (l10n == null) return;
              showEditorHelpDialog(
                context,
                isEvent: true,
                title: l10n.eventGraveSpawn,
                sections: [
                  HelpSectionData(
                    title: l10n.overview,
                    body: l10n.eventHelpGraveSpawnBody,
                  ),
                  HelpSectionData(
                    title: l10n.zombieSpawnWait,
                    body: l10n.eventHelpGraveSpawnZombieWait,
                  ),
                ],
              );
            },
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
                        l10n?.basicParameters ?? 'Basic parameters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      EditorResponsiveInputField(
                        label: l10n?.waveStartMessage ?? 'Wave start message',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        builder: (context, decoration) => TextFormField(
                          initialValue: _data.waveStartMessage ?? '',
                          decoration: decoration,
                          onChanged: (v) {
                            _data = SpawnZombiesFromGridItemData(
                              waveStartMessage: v.isEmpty ? null : v,
                              zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
                              gridTypes: _data.gridTypes,
                              zombies: _data.zombies,
                            );
                            _sync();
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      EditorResponsiveInputField(
                        label:
                            l10n?.zombieSpawnWaitSec ??
                            'Zombie spawn wait (seconds)',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        builder: (context, decoration) => TextFormField(
                          initialValue: _data.zombieSpawnWaitTime.toString(),
                          decoration: decoration,
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            if (n != null) {
                              _data = SpawnZombiesFromGridItemData(
                                waveStartMessage: _data.waveStartMessage,
                                zombieSpawnWaitTime: n,
                                gridTypes: _data.gridTypes,
                                zombies: _data.zombies,
                              );
                              _sync();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              EditorResponsiveActionRow(
                content: Text(
                  l10n?.gridTypes ?? 'Grid types',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                action: PvzAddButton(
                  onPressed: _addGridType,
                  size: 40,
                  label: l10n?.add ?? 'Add',
                ),
              ),
              const SizedBox(height: 8),
              ..._data.gridTypes.asMap().entries.map((e) {
                final idx = e.key;
                final rtid = e.value;
                final parsed = RtidParser.parse(rtid);
                final gridAlias = parsed?.alias ?? rtid;
                final displayTypeName =
                    GridItemRepository.getByTypeName(
                      gridAlias,
                    )?.actualTypeName ??
                    gridAlias;
                final isValid = parsed?.source == 'CurrentLevel'
                    ? objectAliases.contains(gridAlias)
                    : GridItemRepository.isValid(displayTypeName);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isValid ? null : theme.colorScheme.errorContainer,
                  child: ListTile(
                    leading: PresetAwareGridItemIcon(
                      typeName: displayTypeName,
                      size: 40,
                      fit: BoxFit.contain,
                    ),
                    title: Text(() {
                      final d = ResourceNames.lookup(
                        context,
                        'griditem_$displayTypeName',
                      );
                      return d != 'griditem_$displayTypeName'
                          ? d
                          : displayTypeName;
                    }()),
                    subtitle: Text(
                      displayTypeName,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: l10n?.delete ?? 'Delete',
                      onPressed: () => _removeGridType(idx),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Text(
                l10n?.zombiesCount(_data.zombies.length) ??
                    'Zombies: ${_data.zombies.length}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ZombieFlatLaneDragDropEditor(
                items: _data.zombies.asMap().entries.map((e) {
                  final idx = e.key;
                  final z = e.value;
                  final baseType = _resolveBaseTypeName(z);
                  final info = zombieRepo.getZombieById(baseType);
                  final isElite = _isElite(z);
                  return ZombieLaneIconData(
                    identity: z,
                    listIndex: idx,
                    rowValue: 0,
                    iconPath: info?.iconAssetPath,
                    levelDisplay: isElite
                        ? 'E'
                        : (z.level == null ? '0' : '${z.level}'),
                    isElite: isElite,
                    isCustom: _isCustomZombie(z),
                    isMissingCustomZombie:
                        CustomZombieLevelUtils.isMissingCustomZombie(
                          widget.levelFile,
                          z.type,
                        ),
                  );
                }).toList(),
                onTap: _showZombieEditSheet,
                onMove: _handleZombieDragDropMove,
                onAdd: _addZombie,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

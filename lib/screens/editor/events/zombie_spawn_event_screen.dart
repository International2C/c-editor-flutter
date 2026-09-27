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
import 'package:c_editor/widgets/zombie_selection_flow.dart';
import 'package:c_editor/widgets/zombie_ztalemate_perks_editor.dart';

/// Zombie spawn event editor for JitteredWave and GroundSpawner.
/// Ported from Z-Editor-master JitteredWaveEventEP.kt, SpawnZombiesFromGroundEventEP.kt
class ZombieSpawnEventScreen extends StatefulWidget {
  const ZombieSpawnEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.eventSubtitle,
    required this.isGroundSpawner,
    required this.onRequestZombieSelection,
    this.onRequestPlantSelection,
    this.onEditCustomZombie,
    this.onInjectCustomZombie,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final String eventSubtitle;
  final bool isGroundSpawner;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;
  final void Function(void Function(String) onSelected)?
  onRequestPlantSelection;
  final void Function(String rtid)? onEditCustomZombie;
  final String? Function(String alias)? onInjectCustomZombie;

  @override
  State<ZombieSpawnEventScreen> createState() => _ZombieSpawnEventScreenState();
}

class _ZombieSpawnEventScreenState extends State<ZombieSpawnEventScreen> {
  late PvzObject _moduleObj;
  late dynamic _data;
  late String _alias;
  late final String _objClass;
  double _batchLevel = 1;
  bool _zombieDragging = false;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  bool get _supportsLevelJamMusic =>
      LevelParser.supportsLevelJamMusicFromFile(widget.levelFile);

  static const _jamOptions = [
    (null, 'None'),
    ('jam_pop', 'Pop'),
    ('jam_rap', 'Rap'),
    ('jam_metal', 'Metal'),
    ('jam_punk', 'Punk'),
    ('jam_8bit', '8-Bit'),
  ];

  @override
  void initState() {
    super.initState();
    _objClass = widget.isGroundSpawner
        ? 'SpawnZombiesFromGroundSpawnerProps'
        : 'SpawnZombiesJitteredWaveActionProps';
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    final objClass = _objClass;
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: objClass,
        objData: widget.isGroundSpawner
            ? SpawnZombiesFromGroundData().toJson()
            : WaveActionData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      if (widget.isGroundSpawner) {
        _data = SpawnZombiesFromGroundData.fromJson(
          Map<String, dynamic>.from(_moduleObj.objData as Map),
        );
      } else {
        _data = WaveActionData.fromJson(
          Map<String, dynamic>.from(_moduleObj.objData as Map),
        );
      }
    } catch (_) {
      _data = widget.isGroundSpawner
          ? SpawnZombiesFromGroundData()
          : WaveActionData();
    }
    for (final zombie in _zombies) {
      if (_isElite(zombie)) {
        zombie.level = null;
      } else if ((zombie.level ?? 1) < 1) {
        zombie.level = 1;
      }
    }
  }

  List<ZombieSpawnData> get _zombies => widget.isGroundSpawner
      ? (_data as SpawnZombiesFromGroundData).zombies
      : (_data as WaveActionData).zombies;

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
    final baseType = _resolveBaseTypeName(zombie);
    return ZombieRepository().isElite(baseType);
  }

  bool _isCustomZombie(ZombieSpawnData zombie) {
    return CustomZombieLevelUtils.isCustomZombieRtid(zombie.type);
  }

  void _sync() {
    _moduleObj.objData = widget.isGroundSpawner
        ? (_data as SpawnZombiesFromGroundData).toJson()
        : (_data as WaveActionData).toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addZombie({int? row}) {
    widget.onRequestZombieSelection((id) {
      final aliases = ZombieRepository().buildZombieAliases(id);
      final rtid = RtidParser.build(aliases, 'ZombieTypes');
      final zombies = List<ZombieSpawnData>.from(_zombies)
        ..add(ZombieSpawnData(type: rtid, level: null, row: row));
      _updateZombies(zombies, sortRows: true);
    });
  }

  void _updateZombies(List<ZombieSpawnData> zombies, {bool sortRows = false}) {
    if (sortRows) {
      sortZombieSpawnListByRow(zombies, maxRow: _isDeepSeaLawn ? 6 : 5);
    }
    if (widget.isGroundSpawner) {
      _data = SpawnZombiesFromGroundData(
        columnStart: (_data as SpawnZombiesFromGroundData).columnStart,
        columnEnd: (_data as SpawnZombiesFromGroundData).columnEnd,
        additionalPlantFood:
            (_data as SpawnZombiesFromGroundData).additionalPlantFood,
        spawnPlantName: (_data as SpawnZombiesFromGroundData).spawnPlantName,
        zombies: zombies,
      );
    } else {
      _data = WaveActionData(
        notificationEvents: (_data as WaveActionData).notificationEvents,
        additionalPlantFood: (_data as WaveActionData).additionalPlantFood,
        spawnPlantName: (_data as WaveActionData).spawnPlantName,
        zombies: zombies,
      );
    }
    _clampDropConfigToZombieCount();
    _sync();
  }

  Future<void> _removeZombie(int index, {bool? eraseOrphanProperties}) async {
    final removed = _zombies[index];
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
    final zombies = List<ZombieSpawnData>.from(_zombies)..removeAt(index);
    _updateZombies(zombies);
    if (info?.source == 'CurrentLevel' && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(
        widget.levelFile,
        info!.alias,
      );
      widget.onChanged();
    }
  }

  void _handleZombieDragDropMove(int fromIndex, int toRow, int rowInsertIndex) {
    final zombies = List<ZombieSpawnData>.from(_zombies);
    moveZombieSpawnInListByRowSlot(
      zombies: zombies,
      fromIndex: fromIndex,
      toRow: toRow,
      maxRow: _isDeepSeaLawn ? 6 : 5,
      rowInsertIndex: rowInsertIndex,
    );
    _updateZombies(zombies);
  }

  Future<void> _changeZombieTypeFromSheet({
    required BuildContext sheetContext,
    required int index,
    required ZombieSpawnData zombie,
    required bool fromLeft,
    required int rowValue,
    required int levelValue,
    required bool isElite,
  }) async {
    final selected = await pushZombieSelection(context);
    if (!mounted) return;
    if (selected == null) return;
    final aliases = ZombieRepository().buildZombieAliases(selected);
    final rtid = RtidParser.build(aliases, 'ZombieTypes');
    final isEliteNew = ZombieRepository().isElite(selected);
    _updateZombie(
      index,
      zombie.copyWith(
        type: rtid,
        level: isEliteNew ? null : (levelValue == 0 ? null : levelValue),
        clearLevel: isEliteNew || levelValue == 0,
        row: rowValue == 0 ? null : rowValue,
        clearRow: rowValue == 0,
        direction: fromLeft ? 'left' : null,
        clearDirection: !fromLeft,
      ),
    );
    if (sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
  }

  void _updateZombie(int index, ZombieSpawnData zombie) {
    final zombies = List<ZombieSpawnData>.from(_zombies);
    final rowChanged = zombies[index].row != zombie.row;
    zombies[index] = zombie;
    _updateZombies(zombies, sortRows: rowChanged);
  }

  void _applyBatchLevel() {
    final level = _batchLevel.round();
    final zombies = _zombies.map((z) {
      if (_isElite(z)) {
        return z.copyWith(clearLevel: true);
      }
      return z.copyWith(level: level);
    }).toList();
    _updateZombies(zombies);
  }

  void _updateNotificationEvent(String? value) {
    if (widget.isGroundSpawner) return;
    final list = value == null ? null : <String>[value];
    _data = WaveActionData(
      notificationEvents: list,
      additionalPlantFood: (_data as WaveActionData).additionalPlantFood,
      spawnPlantName: (_data as WaveActionData).spawnPlantName,
      zombies: _zombies,
    );
    _sync();
  }

  void _updateAdditionalPlantFood(int count) {
    final maxCount = _zombies.length;
    final clamped = count.clamp(0, maxCount);
    if (widget.isGroundSpawner) {
      final data = _data as SpawnZombiesFromGroundData;
      final currentPlants = List<String>.from(data.spawnPlantName ?? []);
      if (currentPlants.length > clamped) {
        currentPlants.removeRange(clamped, currentPlants.length);
      }
      _data = SpawnZombiesFromGroundData(
        columnStart: data.columnStart,
        columnEnd: data.columnEnd,
        additionalPlantFood: clamped == 0 ? null : clamped,
        spawnPlantName: currentPlants.isEmpty ? null : currentPlants,
        zombies: data.zombies,
      );
    } else {
      final data = _data as WaveActionData;
      final currentPlants = List<String>.from(data.spawnPlantName ?? []);
      if (currentPlants.length > clamped) {
        currentPlants.removeRange(clamped, currentPlants.length);
      }
      _data = WaveActionData(
        notificationEvents: data.notificationEvents,
        additionalPlantFood: clamped == 0 ? null : clamped,
        spawnPlantName: currentPlants.isEmpty ? null : currentPlants,
        zombies: data.zombies,
      );
    }
    _sync();
  }

  void _addSpawnPlant(String plantId) {
    if (_zombies.isEmpty) return;
    if (widget.isGroundSpawner) {
      final data = _data as SpawnZombiesFromGroundData;
      final list = List<String>.from(data.spawnPlantName ?? []);
      final total = data.additionalPlantFood ?? 0;
      if (total == 0 || list.length >= total) return;
      list.add(plantId);
      _data = SpawnZombiesFromGroundData(
        columnStart: data.columnStart,
        columnEnd: data.columnEnd,
        additionalPlantFood: total,
        spawnPlantName: list,
        zombies: data.zombies,
      );
    } else {
      final data = _data as WaveActionData;
      final list = List<String>.from(data.spawnPlantName ?? []);
      final total = data.additionalPlantFood ?? 0;
      if (total == 0 || list.length >= total) return;
      list.add(plantId);
      _data = WaveActionData(
        notificationEvents: data.notificationEvents,
        additionalPlantFood: total,
        spawnPlantName: list,
        zombies: data.zombies,
      );
    }
    _sync();
  }

  void _removeSpawnPlantAt(int index) {
    if (widget.isGroundSpawner) {
      final data = _data as SpawnZombiesFromGroundData;
      final list = List<String>.from(data.spawnPlantName ?? []);
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
      }
      _data = SpawnZombiesFromGroundData(
        columnStart: data.columnStart,
        columnEnd: data.columnEnd,
        additionalPlantFood: data.additionalPlantFood,
        spawnPlantName: list.isEmpty ? null : list,
        zombies: data.zombies,
      );
    } else {
      final data = _data as WaveActionData;
      final list = List<String>.from(data.spawnPlantName ?? []);
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
      }
      _data = WaveActionData(
        notificationEvents: data.notificationEvents,
        additionalPlantFood: data.additionalPlantFood,
        spawnPlantName: list.isEmpty ? null : list,
        zombies: data.zombies,
      );
    }
    _sync();
  }

  int get _dropConfigCount => widget.isGroundSpawner
      ? (_data as SpawnZombiesFromGroundData).additionalPlantFood ?? 0
      : (_data as WaveActionData).additionalPlantFood ?? 0;

  List<String> get _dropConfigPlants => List<String>.from(
    widget.isGroundSpawner
        ? (_data as SpawnZombiesFromGroundData).spawnPlantName ?? []
        : (_data as WaveActionData).spawnPlantName ?? [],
  );

  void _clampDropConfigToZombieCount() {
    final maxCount = _zombies.length;
    if (_dropConfigCount > maxCount) {
      _updateAdditionalPlantFood(maxCount);
    }
  }

  void _showZombieEditSheet(int index) {
    final l10n = AppLocalizations.of(context);
    final zombie = _zombies[index];
    final isElite = _isElite(zombie);
    final baseType = _resolveBaseTypeName(zombie);
    final info = ZombieRepository().getZombieById(baseType);
    final displayName = info?.name ?? baseType;
    final iconPath = info?.iconAssetPath;
    final isCustom = _isCustomZombie(zombie);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        int rowValue = zombie.row ?? 0;
        int levelValue = zombie.level ?? 0;
        bool fromLeft = zombie.direction == 'left';
        var titles = List<String>.from(zombie.titles ?? []);
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ZombieEditSheetIdentityTile(
                      iconPath: iconPath,
                      displayName: ResourceNames.lookup(context, displayName),
                      isCustom: isCustom,
                      customLabel: l10n?.customLabel ?? 'Custom',
                      onChange: () => _changeZombieTypeFromSheet(
                        sheetContext: ctx,
                        index: index,
                        zombie: zombie,
                        fromLeft: fromLeft,
                        rowValue: rowValue,
                        levelValue: levelValue,
                        isElite: isElite,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EditorResponsiveInputField(
                      label: l10n?.row ?? 'Row',
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      builder: (context, decoration) =>
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            initialValue: rowValue,
                            decoration: decoration,
                            selectedItemBuilder: (context) => [
                              Text(
                                l10n?.random ?? 'Random',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              ...List.generate(
                                _isDeepSeaLawn ? 6 : 5,
                                (i) => i + 1,
                              ).map(
                                (v) => Text(
                                  l10n?.rowN(v) ?? 'Row $v',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Text(l10n?.random ?? 'Random'),
                              ),
                              ...List.generate(
                                _isDeepSeaLawn ? 6 : 5,
                                (i) => i + 1,
                              ).map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(l10n?.rowN(v) ?? 'Row $v'),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setModalState(() => rowValue = v);
                              _updateZombie(
                                index,
                                zombie.copyWith(
                                  row: v == 0 ? null : v,
                                  clearRow: v == 0,
                                  direction: fromLeft ? 'left' : null,
                                  clearDirection: !fromLeft,
                                ),
                              );
                            },
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (isElite)
                      Text(
                        l10n?.eliteZombiesUseDefaultLevel ??
                            'Elite zombies use default level.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else ...[
                      SwitchListTile(
                        title: Text(l10n?.autoLevel ?? 'Auto level'),
                        value: levelValue == 0,
                        onChanged: (v) {
                          setModalState(() => levelValue = v ? 0 : 1);
                          _updateZombie(
                            index,
                            zombie.copyWith(
                              level: v ? null : 1,
                              clearLevel: v,
                              direction: fromLeft ? 'left' : null,
                              clearDirection: !fromLeft,
                            ),
                          );
                        },
                      ),
                      if (levelValue != 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.levelFormat(levelValue) ??
                                  'Level: $levelValue',
                            ),
                            Slider(
                              value: levelValue.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: '$levelValue',
                              onChanged: (v) {
                                final newLevel = v.round();
                                setModalState(() => levelValue = newLevel);
                                _updateZombie(
                                  index,
                                  zombie.copyWith(
                                    level: newLevel,
                                    direction: fromLeft ? 'left' : null,
                                    clearDirection: !fromLeft,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(l10n?.zombieFromLeft ?? 'From left'),
                      value: fromLeft,
                      onChanged: (v) {
                        setModalState(() => fromLeft = v);
                        _updateZombie(
                          index,
                          zombie.copyWith(
                            direction: v ? 'left' : null,
                            clearDirection: !v,
                          ),
                        );
                      },
                    ),
                    if (!widget.isGroundSpawner) ...[
                      const SizedBox(height: 12),
                      ZombieZtalematePerksEditor(
                        titles: titles,
                        onChanged: (next) {
                          setModalState(() => titles = List<String>.from(next));
                          _updateZombie(
                            index,
                            zombie.copyWith(
                              titles: next,
                              clearTitles: next.isEmpty,
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final copy = zombie.copyWith(
                                row: rowValue == 0 ? null : rowValue,
                                clearRow: rowValue == 0,
                                level: isElite
                                    ? null
                                    : (levelValue == 0 ? null : levelValue),
                                clearLevel: isElite || levelValue == 0,
                                direction: fromLeft ? 'left' : null,
                                clearDirection: !fromLeft,
                                titles: titles,
                                clearTitles: titles.isEmpty,
                              );
                              final list = List<ZombieSpawnData>.from(_zombies)
                                ..add(copy);
                              _updateZombies(list, sortRows: true);
                              Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.copy),
                            label: Text(l10n?.copy ?? 'Copy'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                            onPressed: () {
                              CustomZombieLevelUtils.handleDeleteFromBottomSheet(
                                sheetContext: ctx,
                                parentContext: context,
                                levelFile: widget.levelFile,
                                zombieTypeRtid: zombie.type,
                                onRemove: (eraseOrphan) => _removeZombie(
                                  index,
                                  eraseOrphanProperties: eraseOrphan,
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete),
                            label: Text(l10n?.delete ?? 'Delete'),
                          ),
                        ),
                      ],
                    ),
                    if (widget.onEditCustomZombie != null ||
                        widget.onInjectCustomZombie != null)
                      CustomZombiePropertiesSheetActions(
                        levelFile: widget.levelFile,
                        baseType: baseType,
                        currentRtid: zombie.type,
                        onEditCustomZombie: widget.onEditCustomZombie,
                        onInjectCustomZombie: widget.onInjectCustomZombie,
                        onCloseSheet: () => Navigator.pop(ctx),
                        onRtidSelected: (rtid) {
                          _updateZombie(index, zombie.copyWith(type: rtid));
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
              title: widget.isGroundSpawner
                  ? (l10n?.eventGroundSpawnTitle ?? 'Ground spawn event')
                  : (l10n?.eventStandardSpawnTitle ?? 'Standard spawn event'),
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.eventHelpStandardOverview ??
                      'Configure zombies that spawn in this wave. Level 0 follows map tier.',
                ),
                if (!widget.isGroundSpawner && _supportsLevelJamMusic)
                  HelpSectionData(
                    title: l10n?.backgroundMusicLevelJam ?? 'Level Jam',
                    body:
                        l10n?.onlyAppliesRockEra ??
                        'Only applies to Rock era maps.',
                  ),
                if (!widget.isGroundSpawner)
                  HelpSectionData(
                    title: l10n?.ztPerksSectionTitle ?? 'Ztalemate perks',
                    body:
                        l10n?.eventHelpJitteredZtPerks ??
                        'Assign Ztalemate Escape buffs to individual zombies via the Titles property. Each perk type can only be used once per zombie.',
                  ),
                HelpSectionData(
                  title: l10n?.row ?? 'Row',
                  body: _isDeepSeaLawn
                      ? (l10n?.eventHelpStandardRowDeepSea ??
                            'Rows 0–5 (6-row lawn). Leave unset for random row.')
                      : (l10n?.eventHelpStandardRow ??
                            'Rows 0–4. Leave unset for random row.'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: _zombieDragging
              ? const NeverScrollableScrollPhysics()
              : null,
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
              if (widget.isGroundSpawner) _buildColumnRangeCard(theme, l10n),
              if (widget.isGroundSpawner) const SizedBox(height: 16),
              if (!widget.isGroundSpawner && _supportsLevelJamMusic) ...[
                _buildNotificationCard(theme, l10n),
                const SizedBox(height: 16),
              ],
              _buildLaneRows(context, theme, l10n),
              const SizedBox(height: 16),
              _buildBatchLevelCard(theme, l10n),
              const SizedBox(height: 16),
              _buildDropConfigCard(context, theme, l10n),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumnRangeCard(ThemeData theme, AppLocalizations? l10n) {
    final d = _data as SpawnZombiesFromGroundData;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.columnRange ?? 'Column range',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            EditorResponsiveFieldRow(
              children: [
                EditorResponsiveInputField(
                  label: l10n?.columnStartLabel ?? 'Start [ColumnStart]',
                  builder: (context, decoration) => TextFormField(
                    initialValue: d.columnStart.toString(),
                    decoration: decoration,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) {
                        _data = SpawnZombiesFromGroundData(
                          columnStart: n,
                          columnEnd: d.columnEnd,
                          additionalPlantFood: d.additionalPlantFood,
                          spawnPlantName: d.spawnPlantName,
                          zombies: d.zombies,
                        );
                        _sync();
                      }
                    },
                  ),
                ),
                EditorResponsiveInputField(
                  label: l10n?.columnEndLabel ?? 'End [ColumnEnd]',
                  builder: (context, decoration) => TextFormField(
                    initialValue: d.columnEnd.toString(),
                    decoration: decoration,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) {
                        _data = SpawnZombiesFromGroundData(
                          columnStart: d.columnStart,
                          columnEnd: n,
                          additionalPlantFood: d.additionalPlantFood,
                          spawnPlantName: d.spawnPlantName,
                          zombies: d.zombies,
                        );
                        _sync();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const EventColumnRangeHint(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(ThemeData theme, AppLocalizations? l10n) {
    final data = _data as WaveActionData;
    final current = data.notificationEvents?.isNotEmpty == true
        ? data.notificationEvents!.first
        : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.music_note, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.backgroundMusicLevelJam ??
                        'Background music (LevelJam)',
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
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: current,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _jamOptions
                  .map(
                    (e) => DropdownMenuItem<String?>(
                      value: e.$1,
                      child: Text(e.$2),
                    ),
                  )
                  .toList(),
              onChanged: _updateNotificationEvent,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.onlyAppliesRockEra ?? 'Only applies to Rock era maps.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaneRows(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    final maxRow = _isDeepSeaLawn ? 6 : 5;
    final laneItems = _zombies.asMap().entries.map((entry) {
      final idx = entry.key;
      final z = entry.value;
      final baseType = _resolveBaseTypeName(z);
      final info = ZombieRepository().getZombieById(baseType);
      final isElite = _isElite(z);
      return ZombieLaneIconData(
        identity: z,
        listIndex: idx,
        rowValue: z.row ?? 0,
        iconPath: info?.iconAssetPath,
        levelDisplay: isElite ? 'E' : (z.level == null ? '0' : '${z.level}'),
        isElite: isElite,
        isCustom: _isCustomZombie(z),
        isMissingCustomZombie: CustomZombieLevelUtils.isMissingCustomZombie(
          widget.levelFile,
          z.type,
        ),
      );
    }).toList();

    if (!widget.isGroundSpawner) {
      return ZombieRowLaneDragDropEditor(
        maxRow: maxRow,
        rowLabel: (row) => l10n?.rowN(row) ?? 'Row $row',
        randomRowLabel: l10n?.randomRow ?? 'Random row',
        items: laneItems,
        onTap: _showZombieEditSheet,
        onMove: _handleZombieDragDropMove,
        onAddToRow: (row) => _addZombie(row: row == 0 ? null : row),
        onDraggingChanged: (dragging) =>
            setState(() => _zombieDragging = dragging),
      );
    }

    return ZombieRowLaneDragDropEditor(
      maxRow: maxRow,
      rowLabel: (row) => l10n?.rowN(row) ?? 'Row $row',
      randomRowLabel: l10n?.randomRow ?? 'Random row',
      items: laneItems,
      onTap: _showZombieEditSheet,
      onMove: _handleZombieDragDropMove,
      onAddToRow: (row) => _addZombie(row: row == 0 ? null : row),
      onDraggingChanged: (dragging) =>
          setState(() => _zombieDragging = dragging),
    );
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
            Slider(
              value: _batchLevel,
              min: 1,
              max: 10,
              divisions: 9,
              label: _batchLevel.round().toString(),
              onChanged: (v) => setState(() => _batchLevel = v),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
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
              ),
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
      totalDropCount: _dropConfigCount,
      plants: _dropConfigPlants,
      zombieCount: _zombies.length,
      onTotalDropCountChanged: _updateAdditionalPlantFood,
      onRemovePlantAt: _removeSpawnPlantAt,
      onAddPlant: widget.onRequestPlantSelection == null
          ? null
          : () {
              widget.onRequestPlantSelection!.call(_addSpawnPlant);
            },
    );
  }
}

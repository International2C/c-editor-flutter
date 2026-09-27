import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/custom_zombie_properties_actions.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/zombie_flat_lane_drag_drop_editor.dart';
import 'package:c_editor/widgets/zombie_row_lane_utils.dart';
import 'package:c_editor/widgets/zombie_spawn_edit_sheet.dart';
import 'package:c_editor/widgets/zombie_selection_flow.dart';

/// Storm zombie spawner event editor. Ported from Z-Editor-master StormSpawnerEventEP.kt.
/// Uses jittered-style zombie icon cards, bottom sheet editing, and button handling.
class StormEventScreen extends StatefulWidget {
  const StormEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
    this.onEditCustomZombie,
    this.onInjectCustomZombie,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;
  final void Function(String rtid)? onEditCustomZombie;
  final String? Function(String alias)? onInjectCustomZombie;

  @override
  State<StormEventScreen> createState() => _StormEventScreenState();
}

class _StormEventScreenState extends State<StormEventScreen> {
  static const _objClass = 'StormZombieSpawnerProps';

  late PvzObject _moduleObj;
  late StormZombieSpawnerPropsData _data;
  late String _alias;
  bool _zombieDragging = false;

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
        objData: StormZombieSpawnerPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = StormZombieSpawnerPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = StormZombieSpawnerPropsData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  String _resolveBaseTypeName(StormZombieData z) {
    final info = RtidParser.parse(z.type);
    final alias = info?.alias ?? z.type;
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

  bool _isElite(StormZombieData z) {
    return ZombieRepository().isElite(_resolveBaseTypeName(z));
  }

  bool _isCustomZombie(StormZombieData z) {
    return CustomZombieLevelUtils.isCustomZombieRtid(z.type);
  }

  void _addZombie() {
    widget.onRequestZombieSelection((id) {
      final aliases = ZombieRepository().buildZombieAliases(id);
      final rtid = RtidParser.build(aliases, 'ZombieTypes');
      _data = StormZombieSpawnerPropsData(
        columnStart: _data.columnStart,
        columnEnd: _data.columnEnd,
        groupSize: _data.groupSize,
        timeBetweenGroups: _data.timeBetweenGroups,
        type: _data.type,
        zombies: [
          ..._data.zombies,
          StormZombieData(type: rtid, level: 0),
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
    final zombies = List<StormZombieData>.from(_data.zombies)..removeAt(index);
    _data = StormZombieSpawnerPropsData(
      columnStart: _data.columnStart,
      columnEnd: _data.columnEnd,
      groupSize: _data.groupSize,
      timeBetweenGroups: _data.timeBetweenGroups,
      type: _data.type,
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

  void _replaceZombieType(int index, String newRtid, [int? preserveLevel]) {
    final zombies = List<StormZombieData>.from(_data.zombies);
    final current = zombies[index];
    zombies[index] = StormZombieData(
      type: newRtid,
      level: preserveLevel ?? current.level ?? 0,
    );
    _data = StormZombieSpawnerPropsData(
      columnStart: _data.columnStart,
      columnEnd: _data.columnEnd,
      groupSize: _data.groupSize,
      timeBetweenGroups: _data.timeBetweenGroups,
      type: _data.type,
      zombies: zombies,
    );
    _sync();
  }

  void _handleZombieDragDropMove(int fromIndex, int insertIndex) {
    final zombies = List<StormZombieData>.from(_data.zombies);
    reorderZombieFlatListByInsertIndex(
      list: zombies,
      fromIndex: fromIndex,
      insertIndex: insertIndex,
    );
    _data = StormZombieSpawnerPropsData(
      columnStart: _data.columnStart,
      columnEnd: _data.columnEnd,
      groupSize: _data.groupSize,
      timeBetweenGroups: _data.timeBetweenGroups,
      type: _data.type,
      zombies: zombies,
    );
    _sync();
  }

  void _showZombieEditSheet(int index) {
    final z = _data.zombies[index];
    final isElite = _isElite(z);
    final baseType = _resolveBaseTypeName(z);
    final info = ZombieRepository().getZombieById(baseType);
    final displayName = ResourceNames.lookup(context, info?.name ?? baseType);
    final iconPath = info?.iconAssetPath;
    final isCustom = _isCustomZombie(z);

    showZombieSpawnEditSheet(
      context: context,
      options: const ZombieSpawnEditSheetOptions(
        showRow: false,
        showLevel: false,
      ),
      iconPath: iconPath,
      displayName: displayName,
      isCustom: isCustom,
      isElite: isElite,
      levelValue: z.level ?? 0,
      onChangeType: () {
        Future.microtask(() async {
          if (!mounted) return;
          final selected = await pushZombieSelection(this.context);
          if (!mounted || selected == null) return;
          final aliases = ZombieRepository().buildZombieAliases(selected);
          final rtid = RtidParser.build(aliases, 'ZombieTypes');
          _replaceZombieType(index, rtid, z.level);
        });
      },
      onCopy: () {
        final copy = StormZombieData(type: z.type, level: z.level ?? 0);
        _data = StormZombieSpawnerPropsData(
          columnStart: _data.columnStart,
          columnEnd: _data.columnEnd,
          groupSize: _data.groupSize,
          timeBetweenGroups: _data.timeBetweenGroups,
          type: _data.type,
          zombies: [..._data.zombies, copy],
        );
        _sync();
      },
      onDelete: (sheetContext) {
        CustomZombieLevelUtils.handleDeleteFromBottomSheet(
          sheetContext: sheetContext,
          parentContext: context,
          levelFile: widget.levelFile,
          zombieTypeRtid: z.type,
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
              currentRtid: z.type,
              onEditCustomZombie: widget.onEditCustomZombie,
              onInjectCustomZombie: widget.onInjectCustomZombie,
              onCloseSheet: () => Navigator.of(context).pop(),
              onRtidSelected: (rtid) =>
                  _replaceZombieType(index, rtid, z.level),
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
              title: l10n?.stormEvent ?? 'Storm event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.eventHelpStormOverview ??
                      'Sandstorm or snowstorm quickly delivers zombies to the front. Excold storm can freeze plants.',
                ),
                HelpSectionData(
                  title: l10n?.columnRange ?? 'Column range',
                  body:
                      l10n?.eventHelpStormColumnRange ??
                      'Columns 0–9. Left edge is 0, right is 9. Start column must be less than end column.',
                ),
                HelpSectionData(
                  title: l10n?.zombieLevels ?? 'Zombie levels',
                  body:
                      l10n?.zombieLevelsBody ??
                      'Zombie level and row cannot be set independently within storms. Manually editing zombie levels has no effect.',
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
                        l10n?.spawnParameters ?? 'Spawn parameters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        children: ['sandstorm', 'snowstorm', 'excoldstorm']
                            .map(
                              (t) => ChoiceChip(
                                label: Text(
                                  t == 'sandstorm'
                                      ? (l10n?.sandstorm ?? 'Sandstorm')
                                      : t == 'snowstorm'
                                      ? (l10n?.snowstorm ?? 'Snowstorm')
                                      : (l10n?.excoldStorm ?? 'Excold storm'),
                                ),
                                selected: _data.type == t,
                                onSelected: (_) {
                                  _data = StormZombieSpawnerPropsData(
                                    columnStart: _data.columnStart,
                                    columnEnd: _data.columnEnd,
                                    groupSize: _data.groupSize,
                                    timeBetweenGroups: _data.timeBetweenGroups,
                                    type: t,
                                    zombies: _data.zombies,
                                  );
                                  _sync();
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      EditorResponsiveFieldRow(
                        children: [
                          EditorResponsiveInputField(
                            label: l10n?.columnStart ?? 'Column start',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            builder: (context, decoration) => TextFormField(
                              initialValue: _data.columnStart.toString(),
                              decoration: decoration,
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final n = int.tryParse(v);
                                if (n != null) {
                                  _data = StormZombieSpawnerPropsData(
                                    columnStart: n,
                                    columnEnd: _data.columnEnd,
                                    groupSize: _data.groupSize,
                                    timeBetweenGroups: _data.timeBetweenGroups,
                                    type: _data.type,
                                    zombies: _data.zombies,
                                  );
                                  _sync();
                                }
                              },
                            ),
                          ),
                          EditorResponsiveInputField(
                            label: l10n?.columnEnd ?? 'Column end',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            builder: (context, decoration) => TextFormField(
                              initialValue: _data.columnEnd.toString(),
                              decoration: decoration,
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final n = int.tryParse(v);
                                if (n != null) {
                                  _data = StormZombieSpawnerPropsData(
                                    columnStart: _data.columnStart,
                                    columnEnd: n,
                                    groupSize: _data.groupSize,
                                    timeBetweenGroups: _data.timeBetweenGroups,
                                    type: _data.type,
                                    zombies: _data.zombies,
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
                      const SizedBox(height: 12),
                      EditorResponsiveInputField(
                        label: l10n?.groupSize ?? 'Group size',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        builder: (context, decoration) => TextFormField(
                          initialValue: _data.groupSize.toString(),
                          decoration: decoration,
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            if (n != null) {
                              _data = StormZombieSpawnerPropsData(
                                columnStart: _data.columnStart,
                                columnEnd: _data.columnEnd,
                                groupSize: n,
                                timeBetweenGroups: _data.timeBetweenGroups,
                                type: _data.type,
                                zombies: _data.zombies,
                              );
                              _sync();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      EditorResponsiveInputField(
                        label: l10n?.timeBetweenGroups ?? 'Time between groups',
                        builder: (context, decoration) => TextFormField(
                          initialValue: _data.timeBetweenGroups.toString(),
                          decoration: decoration,
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            if (n != null) {
                              _data = StormZombieSpawnerPropsData(
                                columnStart: _data.columnStart,
                                columnEnd: _data.columnEnd,
                                groupSize: _data.groupSize,
                                timeBetweenGroups: n,
                                type: _data.type,
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
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  l10n?.stormCarriedZombiesCount(_data.zombies.length) ??
                      'Carried zombies (${_data.zombies.length} total)',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ZombieFlatLaneDragDropEditor(
                items: _data.zombies.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final z = entry.value;
                  final baseType = _resolveBaseTypeName(z);
                  final info = ZombieRepository().getZombieById(baseType);
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
                onDraggingChanged: (dragging) =>
                    setState(() => _zombieDragging = dragging),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

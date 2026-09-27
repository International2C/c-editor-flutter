import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/camel_minigame_conflicts.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/preset_resource_list_tile.dart';
import 'package:c_editor/utils/target_zombie_check.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Seed bank properties. Ported from Z-Editor-master SeedBankPropertiesEP.kt
class SeedBankPropertiesScreen extends StatefulWidget {
  const SeedBankPropertiesScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestPlantSelection,
    required this.onRequestZombieSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(
    void Function(List<String>) onSelected, {
    List<String>? excludeIds,
    List<String>? initialSelectedIds,
    bool blockRealmExclusiveInChooser,
    bool blockHiddenPlantsInChooser,
    bool allowDuplicateSelection,
  })
  onRequestPlantSelection;
  final void Function(void Function(List<String>) onSelected)
  onRequestZombieSelection;

  @override
  State<SeedBankPropertiesScreen> createState() =>
      _SeedBankPropertiesScreenState();
}

class _SeedBankPropertiesScreenState extends State<SeedBankPropertiesScreen> {
  static const _objClass = 'SeedBankProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late SeedBankData _data;

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
        objClass: 'SeedBankProperties',
        objData: SeedBankData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SeedBankData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SeedBankData();
    }
    _data = SeedBankData(
      presetPlantList: List.from(_data.presetPlantList),
      plantWhiteList: List.from(_data.plantWhiteList),
      plantBlackList: List.from(_data.plantBlackList),
      selectionMethod: _data.selectionMethod,
      globalLevel: _data.globalLevel,
      overrideSeedSlotsCount: _data.overrideSeedSlotsCount,
      zombieMode: _data.zombieMode,
      seedPacketType: _data.seedPacketType,
      gridItemMode: _data.gridItemMode,
    );
    _syncGridItemModeFromPreset();
    if (_data.selectionMethod == 'chooser' && _data.zombieMode != true) {
      _stripChooserOnlyBlockedPlantsFromPreset();
    }
  }

  /// Legacy levels may have grid items in preset without GridItemMode flag.
  void _syncGridItemModeFromPreset() {
    if (_data.gridItemMode == true) return;
    if (_data.presetPlantList.any(kSeedBankGridItemIds.contains)) {
      _data.gridItemMode = true;
    }
  }

  bool _isRealmExclusivePlantId(String id) {
    if (kSeedBankGridItemIds.contains(id)) return false;
    final plant = PlantRepository().getPlantInfoById(id);
    if (plant == null) return false;
    return plant.hasInternalTag('_internal_no42') ||
        plant.hasInternalTag('_internal_mausoleum');
  }

  bool _isHiddenPlantId(String id) {
    if (kSeedBankGridItemIds.contains(id)) return false;
    final plant = PlantRepository().getPlantInfoById(id);
    if (plant == null) return false;
    return plant.tags.contains(PlantTag.hidden);
  }

  bool _isChooserOnlyBlockedPlantId(String id) {
    return _isRealmExclusivePlantId(id) || _isHiddenPlantId(id);
  }

  void _stripChooserOnlyBlockedPlantsFromPreset() {
    _data.presetPlantList.removeWhere(_isChooserOnlyBlockedPlantId);
  }

  void _removeGridItemsFromPreset() {
    _data.presetPlantList.removeWhere(
      (id) => kSeedBankGridItemIds.contains(id),
    );
  }

  void _addGridItemToPreset(String id) {
    _data.presetPlantList.add(id);
    _data.gridItemMode = true;
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addToPresetPlants() {
    widget.onRequestPlantSelection(
      (ids) {
        setState(() {
          _data.presetPlantList.addAll(ids);
          _sync();
        });
      },
      blockRealmExclusiveInChooser: _data.selectionMethod == 'chooser',
      blockHiddenPlantsInChooser: _data.selectionMethod == 'chooser',
      allowDuplicateSelection: true,
    );
  }

  void _addToWhiteList() {
    widget.onRequestPlantSelection(
      (ids) {
        setState(() {
          _data.plantWhiteList = List<String>.from(ids);
          _sync();
        });
      },
      excludeIds: _data.plantBlackList,
      initialSelectedIds: _data.plantWhiteList,
      blockRealmExclusiveInChooser: _data.selectionMethod == 'chooser',
      blockHiddenPlantsInChooser: _data.selectionMethod == 'chooser',
    );
  }

  void _addToBlackList() {
    widget.onRequestPlantSelection(
      (ids) {
        setState(() {
          _data.plantBlackList = List<String>.from(ids);
          _sync();
        });
      },
      excludeIds: _data.plantWhiteList,
      initialSelectedIds: _data.plantBlackList,
      blockRealmExclusiveInChooser: _data.selectionMethod == 'chooser',
      blockHiddenPlantsInChooser: _data.selectionMethod == 'chooser',
    );
  }

  void _addToZombies() {
    widget.onRequestZombieSelection((ids) {
      final l10n = AppLocalizations.of(context);
      for (final id in ids) {
        if (isTargetZombieBlocked(id, widget.levelFile)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.targetZombieRequiresOakTrain ??
                    'Target zombies require the OakTrain module. Please add OakTrain to the level first.',
              ),
            ),
          );
          return;
        }
      }
      setState(() {
        for (final id in ids) {
          _data.presetPlantList.add(ZombieRepository().buildZombieAliases(id));
        }
        _sync();
      });
    });
  }

  void _clearSeedBankLists() {
    _data.presetPlantList.clear();
    _data.plantWhiteList.clear();
    _data.plantBlackList.clear();
    _data.gridItemMode = false;
  }

  void _removePresetPlantAt(int index) {
    setState(() {
      _data.presetPlantList.removeAt(index);
      if (!_data.presetPlantList.any(kSeedBankGridItemIds.contains)) {
        _data.gridItemMode = false;
      }
      _sync();
    });
  }

  void _reorderPresetPlant(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    setState(() {
      final item = _data.presetPlantList.removeAt(oldIndex);
      _data.presetPlantList.insert(newIndex, item);
      _sync();
    });
  }

  void _removeFromList(List<String> list, int index) {
    setState(() {
      list.removeAt(index);
      _sync();
    });
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

  Future<void> _switchToChooserMode() async {
    if (_data.selectionMethod == 'chooser') return;

    if (_data.gridItemMode == true) {
      final l10n = AppLocalizations.of(context)!;
      final shouldSwitch = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          content: Text(l10n.seedBankGridItemsPresetOnlySwitchWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.error,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.continueAnyway),
            ),
          ],
        ),
      );
      if (shouldSwitch != true || !mounted) return;
    }

    _data.selectionMethod = 'chooser';
    _data.gridItemMode = false;
    _removeGridItemsFromPreset();
    _stripChooserOnlyBlockedPlantsFromPreset();
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isZombieMode = _data.zombieMode == true;
    final isReversedZombie = _data.seedPacketType == 'UIIZombieSeedPacket';

    final izombieColor = theme.brightness == Brightness.dark
        ? pvzPurpleDark
        : pvzPurpleLight;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: isZombieMode ? theme.colorScheme.surface : null,
        ),
        backgroundColor: isZombieMode ? izombieColor : null,
        foregroundColor: isZombieMode ? theme.colorScheme.surface : null,
        iconTheme: isZombieMode
            ? IconThemeData(color: theme.colorScheme.surface)
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context, isZombieMode),
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
              ModuleAliasInputField(
                rtid: widget.rtid,
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
                accentColor: isZombieMode ? izombieColor : null,
              ),
              const SizedBox(height: 16),
              CamelMinigameConflicts(
                levelFile: widget.levelFile,
                onlyIds: const {'camelMinigameChooserConflict'},
              ),
              _buildBasicRulesCard(context, isZombieMode, l10n),
              const SizedBox(height: 16),
              if (isZombieMode)
                _ResourceListEditor(
                  title: l10n?.availableZombies ?? 'Available zombies',
                  description:
                      l10n?.availableZombiesDescription ??
                      'Zombies available for I, Zombie mode',
                  items: _data.presetPlantList,
                  accentColor: izombieColor,
                  isZombie: true,
                  onAdd: _addToZombies,
                  onRemove: (i) => _removeFromList(_data.presetPlantList, i),
                  onReorder: _reorderPresetPlant,
                )
              else ...[
                _ResourceListEditor(
                  title:
                      l10n?.presetPlants ?? 'Preset plants (PresetPlantList)',
                  description:
                      l10n?.plantsAvailableAtStart ??
                      'Plants available at start',
                  items: _data.presetPlantList,
                  accentColor: theme.colorScheme.secondary,
                  isZombie: false,
                  onAdd: _addToPresetPlants,
                  onRemove: _removePresetPlantAt,
                  onReorder: _reorderPresetPlant,
                ),
                const SizedBox(height: 16),
                _ResourceListEditor(
                  title: l10n?.whiteList ?? 'White list (WhiteList)',
                  description:
                      l10n?.whiteListDescription ??
                      'Only these plants allowed (empty = no limit)',
                  items: _data.plantWhiteList,
                  accentColor: theme.colorScheme.primary,
                  isZombie: false,
                  onAdd: _addToWhiteList,
                  onRemove: (i) => _removeFromList(_data.plantWhiteList, i),
                ),
                const SizedBox(height: 16),
                _ResourceListEditor(
                  title: l10n?.blackList ?? 'Black list (BlackList)',
                  description:
                      l10n?.blackListDescription ??
                      'These plants are forbidden',
                  items: _data.plantBlackList,
                  accentColor: theme.colorScheme.error,
                  isZombie: false,
                  onAdd: _addToBlackList,
                  onRemove: (i) => _removeFromList(_data.plantBlackList, i),
                ),
                if (_data.selectionMethod == 'preset') ...[
                  const SizedBox(height: 16),
                  _buildGridItemsCard(context, l10n),
                ],
              ],
              if (isZombieMode)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: izombieColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n?.izombieCardSlotsHint ??
                                'Only some zombies have IZ card slots. Check Other category in zombie selection.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildZombieModeSwitch(context, isZombieMode, izombieColor),
              const SizedBox(height: 16),
              if (isZombieMode)
                _buildReversedZombieSwitch(
                  context,
                  isReversedZombie,
                  izombieColor,
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicRulesCard(
    BuildContext context,
    bool isZombieMode,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final izombieColor = theme.brightness == Brightness.dark
        ? pvzPurpleDark
        : pvzPurpleLight;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.yard,
                  color: isZombieMode
                      ? izombieColor
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.basicRules ?? 'Basic rules',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              l10n?.selectionMethod ?? 'Selection method',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSelectionModeChip(
                  key: const ValueKey('seedBankChooserModeChip'),
                  label: l10n?.chooser ?? 'Chooser',
                  selected: _data.selectionMethod == 'chooser' && !isZombieMode,
                  onSelected: isZombieMode
                      ? null
                      : (_) => _switchToChooserMode(),
                ),
                _buildSelectionModeChip(
                  key: const ValueKey('seedBankPresetModeChip'),
                  label: l10n?.preset ?? 'Preset',
                  selected: _data.selectionMethod == 'preset' || isZombieMode,
                  onSelected: isZombieMode
                      ? null
                      : (v) {
                          setState(() {
                            _data.selectionMethod = 'preset';
                            _sync();
                          });
                        },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.seedBankPresetModeHint ??
                  'Preset mode enters game immediately regardless of card count.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: isZombieMode ? 0.5 : 1,
              child: EditorResponsiveFieldRow(
                children: [
                  EditorResponsiveInputField(
                    label: l10n?.seedBankPlantLevelLabel ?? 'Plant level (0-5)',
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                    ),
                    builder: (context, decoration) => TextFormField(
                      initialValue: '${_data.globalLevel ?? 0}',
                      decoration: decoration,
                      keyboardType: TextInputType.number,
                      onChanged: (s) {
                        final v = int.tryParse(s) ?? 0;
                        final clamped = v.clamp(0, 5);
                        _data.globalLevel = clamped == 0 ? null : clamped;
                        _sync();
                      },
                    ),
                  ),
                  EditorResponsiveInputField(
                    label: l10n?.seedBankSlotCountLabel ?? 'Slot count (0-9)',
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                    ),
                    builder: (context, decoration) => TextFormField(
                      initialValue: '${_data.overrideSeedSlotsCount ?? 0}',
                      decoration: decoration,
                      keyboardType: TextInputType.number,
                      onChanged: (s) {
                        final v = int.tryParse(s) ?? 0;
                        _data.overrideSeedSlotsCount = v.clamp(0, 9);
                        _sync();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.seedBankCourtyardSlotsHint ??
                  'Courtyard mode ignores slot count. Chooser locks 8 slots.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionModeChip({
    required Key key,
    required String label,
    required bool selected,
    required ValueChanged<bool>? onSelected,
  }) {
    const padding = EdgeInsets.all(8);
    const labelPadding = EdgeInsets.symmetric(horizontal: 8);
    return LayoutBuilder(
      builder: (context, constraints) => FilterChip(
        key: key,
        selected: selected,
        onSelected: onSelected,
        padding: padding,
        labelPadding: labelPadding,
        showCheckmark: false,
        // Chip measures label height before subtracting its padding and native
        // checkmark width. Limit both label layouts to the same available width
        // and include the checkmark in the label so wrapped lines set the height.
        label: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.deflate(padding + labelPadding).maxWidth,
          ),
          child: _buildSelectionModeLabel(label, selected: selected),
        ),
      ),
    );
  }

  Widget _buildSelectionModeLabel(String label, {required bool selected}) {
    // Preserve the chip's resolved text and disabled colors for both children.
    return Builder(
      builder: (context) {
        final style = DefaultTextStyle.of(context);
        return DefaultTextStyle(
          style: style.style,
          textAlign: style.textAlign,
          softWrap: true,
          overflow: TextOverflow.visible,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check, size: 18, color: style.style.color),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridItemsCard(BuildContext context, AppLocalizations? l10n) {
    final gridMode = _data.gridItemMode == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: SwitchListTile(
            title: Text(
              l10n?.seedBankAddGridItemsTitle ?? 'Add grid items',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              l10n?.seedBankAddGridItemsSubtitle ??
                  'Append grid items to PresetPlantList. Duplicates are allowed.',
            ),
            value: gridMode,
            onChanged: (enabled) {
              setState(() {
                _data.gridItemMode = enabled;
                if (!enabled) {
                  _removeGridItemsFromPreset();
                }
                _sync();
              });
            },
          ),
        ),
        if (gridMode) ...[
          const SizedBox(height: 16),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < kSeedBankGridItemIds.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                  _SeedBankGridItemRow(
                    typeName: kSeedBankGridItemIds[i],
                    count: _data.presetPlantList
                        .where((id) => id == kSeedBankGridItemIds[i])
                        .length,
                    onAdd: () {
                      setState(() {
                        _addGridItemToPreset(kSeedBankGridItemIds[i]);
                        _sync();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildZombieModeSwitch(
    BuildContext context,
    bool isZombieMode,
    Color izombieColor,
  ) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(
          switchTheme: SwitchThemeData(
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return izombieColor;
              return null;
            }),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.surface;
              }
              return null;
            }),
          ),
        ),
        child: SwitchListTile(
          title: Text(
            AppLocalizations.of(context)?.izombieModeTitle ?? 'I, Zombie mode',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            AppLocalizations.of(context)?.izombieModeSubtitle ??
                'Enable to place zombies. Locks selection method.',
          ),
          value: isZombieMode,
          onChanged: (v) {
            setState(() {
              if (_data.zombieMode != v) {
                _clearSeedBankLists();
              }
              _data.zombieMode = v;
              if (v) {
                _data.selectionMethod = 'preset';
                _data.seedPacketType = null;
              } else {
                _data.seedPacketType = null;
              }
              _sync();
            });
          },
        ),
      ),
    );
  }

  Widget _buildReversedZombieSwitch(
    BuildContext context,
    bool isReversedZombie,
    Color izombieColor,
  ) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(
          switchTheme: SwitchThemeData(
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return izombieColor;
              return null;
            }),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.surface;
              }
              return null;
            }),
          ),
        ),
        child: SwitchListTile(
          title: Text(
            AppLocalizations.of(context)?.reverseZombieFactionTitle ??
                'Reverse zombie faction',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            AppLocalizations.of(context)?.reverseZombieFactionSubtitle ??
                'Enable to make zombies plant faction. For ZvZ.',
          ),
          value: isReversedZombie,
          onChanged: (v) {
            setState(() {
              _data.seedPacketType = v ? 'UIIZombieSeedPacket' : null;
              _sync();
            });
          },
        ),
      ),
    );
  }

  void _showHelp(BuildContext context, bool isZombieMode) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final helpColor = isZombieMode
        ? (theme.brightness == Brightness.dark ? pvzPurpleDark : pvzPurpleLight)
        : theme.colorScheme.primary;
    showEditorHelpDialog(
      context,
      isEvent: false,
      title: l10n?.seedBankHelp ?? 'Seed Bank',
      themeColor: helpColor,
      sections: [
        HelpSectionData(
          title: l10n?.overview ?? 'Overview',
          body:
              l10n?.seedBankLetsPlayersChoose ??
              'Seed Bank lets players choose from available plants.',
        ),
        HelpSectionData(
          title:
              l10n?.seedBankWhiteAndBlacklistTitle ?? 'Whitelist and blacklist',
          body:
              l10n?.whiteListBlackListHint ??
              'An empty whitelist applies no restriction. The blacklist takes priority.',
        ),
        HelpSectionData(
          title: l10n?.seedBankIZombieHelpTitle ?? 'I, Zombie mode',
          body:
              l10n?.iZombieModePresetHint ??
              'I, Zombie mode uses a preset list of available zombies.',
        ),
        HelpSectionData(
          title: l10n?.seedBankSlotOccupancyTitle ?? 'Slot occupancy',
          body:
              l10n?.invalidIdsHint ??
              'Invalid IDs leave empty slots in the Seed Bank.',
        ),
        HelpSectionData(
          title: l10n?.seedBankAdvancedGameplayTitle ?? 'Advanced gameplay',
          body:
              l10n?.seedBankAdvancedGameplayBody ??
              'The relative order of Seed Bank and Conveyor Belt modules changes sun costs in Preset mode.',
        ),
      ],
    );
  }
}

class _SeedBankGridItemRow extends StatelessWidget {
  const _SeedBankGridItemRow({
    required this.typeName,
    required this.count,
    required this.onAdd,
  });

  final String typeName;
  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const iconBoxSize = 56.0;
    final iconPath = GridItemRepository.getIconPath(typeName);
    final key = 'griditem_$typeName';
    final localized = ResourceNames.lookup(context, key);
    final name = localized != key ? localized : typeName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: iconBoxSize,
            height: iconBoxSize,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AssetImageWidget(
                assetPath: iconPath,
                width: iconBoxSize - 8,
                height: iconBoxSize - 8,
                fit: BoxFit.contain,
                altCandidates: imageAltCandidates(iconPath),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (count > 0)
                  Text(
                    AppLocalizations.of(
                          context,
                        )?.seedBankGridItemCount(count) ??
                        'In preset list: $count',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)?.add ?? 'Add',
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

String _entryDisplayName(
  BuildContext context,
  String id, {
  required bool isZombie,
}) {
  if (kSeedBankGridItemIds.contains(id)) {
    final key = 'griditem_$id';
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : id;
  }
  if (isZombie) {
    final zombieTypeName = ZombiePropertiesRepository.getTypeNameByAlias(id);
    return _zombieDisplayName(context, zombieTypeName);
  }
  return _plantDisplayName(context, id);
}

String _entryIconPath(String id, {required bool isZombie}) {
  if (kSeedBankGridItemIds.contains(id)) {
    return GridItemRepository.getIconPath(id);
  }
  if (isZombie) {
    final zombieTypeName = ZombiePropertiesRepository.getTypeNameByAlias(id);
    final zombie = ZombieRepository().getZombieById(zombieTypeName);
    return zombie?.iconAssetPath ?? 'assets/images/others/unknown.webp';
  }
  final plant = PlantRepository().getPlantInfoById(id);
  return plant?.iconAssetPath ?? 'assets/images/others/unknown.webp';
}

String _plantDisplayName(BuildContext context, String id) {
  final plant = PlantRepository().getPlantInfoById(id);
  if (plant != null) {
    return ResourceNames.lookup(context, plant.name);
  }
  return id;
}

/// For I-zombie mode: show only translated name, never raw codename with zombie_ prefix.
String _zombieDisplayName(BuildContext context, String id) {
  final key = ZombieRepository().getName(id);
  final translated = ResourceNames.lookup(context, key);
  if (translated == key && key.startsWith('zombie_')) {
    final withoutPrefix = key.substring(7);
    return withoutPrefix
        .split('_')
        .map(
          (s) => s.isNotEmpty
              ? '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }
  return translated;
}

class _ResourceListEditor extends StatelessWidget {
  const _ResourceListEditor({
    required this.title,
    required this.description,
    required this.items,
    required this.accentColor,
    required this.isZombie,
    required this.onAdd,
    required this.onRemove,
    this.onReorder,
  });

  final String title;
  final String description;
  final List<String> items;
  final Color accentColor;
  final bool isZombie;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final void Function(int oldIndex, int newIndex)? onReorder;

  static bool _useImmediateDrag(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return true;
      default:
        return false;
    }
  }

  Widget _buildChip(
    BuildContext context, {
    required int index,
    required String id,
  }) {
    final name = _entryDisplayName(context, id, isZombie: isZombie);
    final iconPath = _entryIconPath(id, isZombie: isZombie);
    const iconSize = 48.0;

    return Container(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4, right: 4),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: AssetImageWidget(
                assetPath: iconPath,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.cover,
                altCandidates: imageAltCandidates(iconPath),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(name, overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => onRemove(index),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(4),
              minimumSize: const Size(28, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final reorderHint = _useImmediateDrag(context)
        ? (l10n?.presetPlantListReorderHintDesktop ??
              'Drag the ⋮⋮ handle to reorder.')
        : (l10n?.presetPlantListReorderHint ??
              'Long press the ⋮⋮ handle and drag to reorder.');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAdd,
                  color: accentColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isNotEmpty && onReorder != null) ...[
              Text(
                reorderHint,
                key: const ValueKey('presetPlantListReorderHint'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n?.emptyList ?? 'Empty list',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else if (onReorder != null)
              ReorderableListView.builder(
                clipBehavior: Clip.none,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: items.length,
                onReorderItem: (oldIndex, newIndex) =>
                    onReorder!(oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final id = items[index];
                  final iconPath = _entryIconPath(id, isZombie: isZombie);
                  return PresetResourceListTile(
                    key: ValueKey('preset-resource-$index-$id'),
                    label: _entryDisplayName(context, id, isZombie: isZombie),
                    iconAssetPath: iconPath,
                    iconAltCandidates: imageAltCandidates(iconPath),
                    reorderIndex: index,
                    onRemove: () => onRemove(index),
                  );
                },
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(items.length, (i) {
                  final id = items[i];
                  return _buildChip(context, index: i, id: id);
                }),
              ),
          ],
        ),
      ),
    );
  }
}

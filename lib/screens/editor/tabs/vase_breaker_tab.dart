import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';

class VaseBreakerTab extends StatefulWidget {
  const VaseBreakerTab({
    super.key,
    required this.levelFile,
    required this.onChanged,
    this.onAddModule,
    this.editorCubit,
  });

  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final void Function(String objClass)? onAddModule;
  final EditorCubit? editorCubit;

  @override
  State<VaseBreakerTab> createState() => _VaseBreakerTabState();
}

class _VaseBreakerTabState extends State<VaseBreakerTab> {
  PvzObject? _presetObj;
  late VaseBreakerPresetData _data;
  bool _isLoading = true;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;

  static const _collectableTypes = [
    _CollectableType('plantfood', 'Plant Food', 'plantfood.webp'),
    _CollectableType('sun_large', 'Large Sun', 'sun_large.webp'),
    _CollectableType('rails', 'Rails', 'rails.webp'),
    _CollectableType('rail', 'Rails', 'rails.webp'),
    _CollectableType('railcarts', 'Railcarts', 'railcarts.webp'),
    _CollectableType('railcart', 'Railcarts', 'railcarts.webp'),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _presetObj = widget.levelFile.objects
        .where((o) => o.objClass == 'VaseBreakerPresetProperties')
        .firstOrNull;

    if (_presetObj != null) {
      try {
        _data = VaseBreakerPresetData.fromJson(_presetObj!.objData);
      } catch (e) {
        _data = VaseBreakerPresetData();
      }
    } else {
      // Fallback or handle missing object if needed
      // For now, we assume it exists if the tab is shown,
      // or we show an error in build
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _saveData() {
    if (_presetObj != null) {
      _presetObj!.objData = _data.toJson();
      widget.onChanged();
    }
  }

  void _updateData(void Function(VaseBreakerPresetData) update) {
    setState(() {
      update(_data);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_presetObj == null) {
      return Center(child: Text(l10n?.noLevelDefinition ?? 'Module not found'));
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final minCol = _data.minColumnIndex;
    final maxCol = _data.maxColumnIndex;
    final blacklistCount = _data.gridSquareBlacklist.where((loc) {
      return loc.x >= minCol &&
          loc.x <= maxCol &&
          loc.y >= 0 &&
          loc.y < _gridRows;
    }).length;

    final totalSlots = (maxCol - minCol + 1) * _gridRows - blacklistCount;
    final currentAssigned = _data.vases.fold(0, (sum, v) => sum + v.count);
    final isCapacityError = totalSlots != currentAssigned;

    final outOfArea = _data.gridSquareBlacklist
        .where(
          (loc) =>
              loc.x < 0 ||
              loc.x >= _gridCols ||
              loc.y < 0 ||
              loc.y >= _gridRows,
        )
        .toList();
    final has6RowData =
        !_isDeepSeaLawn && _data.gridSquareBlacklist.any((loc) => loc.y >= 5);
    final showStageWarning = has6RowData;
    final showOutOfAreaWarning = outOfArea.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showStageWarning)
            EditorWarningBanner(
              message:
                  l10n?.warningStageSwitchedTo5Rows ??
                  'Stage uses 5 rows but some data references row 6. These objects may not display correctly in-game.',
            ),
          if (showOutOfAreaWarning)
            _InfoBanner(
              message:
                  l10n?.warningObjectsOutsideArea(_gridRows, _gridCols) ??
                  'Some objects are outside the playable area ($_gridRows rows × $_gridCols cols).',
            ),
          if (showStageWarning || showOutOfAreaWarning)
            const SizedBox(height: 16),
          _buildRangeSection(l10n),
          const SizedBox(height: 16),
          _buildGridSection(l10n),
          const SizedBox(height: 16),
          _buildCapacityInfo(
            l10n,
            totalSlots,
            currentAssigned,
            isCapacityError,
          ),
          const SizedBox(height: 16),
          _buildVaseList(l10n),
        ],
      ),
    );
  }

  Widget _buildRangeSection(AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.vaseRangeTitle ?? 'Vase Generation Range & Blacklist',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            EditorResponsiveFieldRow(
              breakpoint: 420,
              children: [
                _buildStepper(
                  l10n?.startColumnLabel ?? 'Start Col (Min)',
                  _data.minColumnIndex,
                  (val) => _updateData((d) => d.minColumnIndex = val),
                  0,
                  _data.maxColumnIndex,
                ),
                _buildStepper(
                  l10n?.endColumnLabel ?? 'End Col (Max)',
                  _data.maxColumnIndex,
                  (val) => _updateData((d) => d.maxColumnIndex = val),
                  _data.minColumnIndex,
                  _gridCols - 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(
    String label,
    int value,
    ValueChanged<int> onChanged,
    int min,
    int max,
  ) {
    return Column(
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            Text(value.toString()),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridSection(AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(l10n?.toggleBlacklistHint ?? 'Click to toggle blacklist'),
            const SizedBox(height: 8),
            scaleTableForDesktop(
              context: context,
              desktopScale: 0.5,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellSize = (constraints.maxWidth / _gridCols)
                      .floorToDouble();
                  return Column(
                    children: List.generate(_gridRows, (row) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_gridCols, (col) {
                          final isBlacklisted = _data.gridSquareBlacklist.any(
                            (loc) => loc.x == col && loc.y == row,
                          );
                          final isInRange =
                              col >= _data.minColumnIndex &&
                              col <= _data.maxColumnIndex;

                          Color color;
                          if (!isInRange) {
                            color = Colors.grey.withValues(alpha: 0.3);
                          } else if (isBlacklisted) {
                            color = Colors.red.withValues(alpha: 0.5);
                          } else {
                            color = Colors.green.withValues(alpha: 0.5);
                          }

                          return GestureDetector(
                            onTap: () {
                              if (!isInRange) return;
                              _toggleBlacklist(col, row);
                            },
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: color,
                                border: Border.all(color: Colors.grey),
                              ),
                              child: isBlacklisted
                                  ? const Icon(Icons.block, size: 16)
                                  : null,
                            ),
                          );
                        }),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBlacklist(int x, int y) {
    _updateData((d) {
      final index = d.gridSquareBlacklist.indexWhere(
        (loc) => loc.x == x && loc.y == y,
      );
      if (index != -1) {
        d.gridSquareBlacklist.removeAt(index);
      } else {
        d.gridSquareBlacklist.add(LocationData(x: x, y: y));
      }
    });
  }

  Widget _buildCapacityInfo(
    AppLocalizations? l10n,
    int total,
    int current,
    bool isError,
  ) {
    return Card(
      color: isError ? Theme.of(context).colorScheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isError ? editorWarningIcon : Icons.check_circle,
              color: isError
                  ? Theme.of(context).colorScheme.error
                  : Colors.green,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.vaseCapacityTitle ?? 'Vase Capacity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    l10n?.vaseCapacitySummary(
                          current.toString(),
                          total.toString(),
                        ) ??
                        'Assigned: $current / Total Slots: $total',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaseList(AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n?.vaseListTitle ?? 'Vase List',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddVaseDialog(),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _data.vases.length,
          itemBuilder: (context, index) {
            final vase = _data.vases[index];
            return _buildVaseListItem(vase, index, l10n);
          },
        ),
      ],
    );
  }

  Widget _buildVaseListItem(
    VaseDefinition vase,
    int index,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final title = Text(
      _getVaseTitle(context, vase, l10n),
      key: ValueKey('vaseListItemTitle_$index'),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium,
    );
    final subtitle = Text(
      _getVaseSubtitle(vase, l10n),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    final controls = Row(
      key: ValueKey('vaseListItemActions_$index'),
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: vase.count > 1
              ? () => _updateData((_) => vase.count--)
              : null,
        ),
        Text('${vase.count}'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _updateData((_) => vase.count++),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _updateData((d) => d.vases.removeAt(index)),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        return Card(
          key: ValueKey('vaseListItem_$index'),
          child: compact
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildVaseIcon(vase),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                title,
                                const SizedBox(height: 2),
                                subtitle,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(alignment: Alignment.centerRight, child: controls),
                    ],
                  ),
                )
              : ListTile(
                  leading: _buildVaseIcon(vase),
                  title: title,
                  subtitle: subtitle,
                  trailing: controls,
                ),
        );
      },
    );
  }

  Widget _buildVaseIcon(VaseDefinition vase) {
    const size = 40.0;
    if (vase.plantTypeName != null) {
      final plant = PlantRepository().allPlants.firstWhereOrNull(
        (p) => p.id == vase.plantTypeName,
      );
      final asset = plant?.iconAssetPath;
      if (asset != null) {
        return AssetImageWidget(
          assetPath: asset,
          altCandidates: imageAltCandidates(asset),
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
      return const Icon(Icons.local_florist, color: Colors.green, size: size);
    }
    if (vase.zombieTypeName != null) {
      final typeName = ZombiePropertiesRepository.getTypeNameByAlias(
        vase.zombieTypeName!,
      );
      final zombie = ZombieRepository().allZombies.firstWhereOrNull(
        (z) => z.id == typeName,
      );
      final asset = zombie?.iconAssetPath;
      if (asset != null) {
        return AssetImageWidget(
          assetPath: asset,
          altCandidates: imageAltCandidates(asset),
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
      return const Icon(Icons.android, color: Colors.red, size: size);
    }
    if (vase.collectableTypeName != null) {
      final info = _collectableTypes.firstWhereOrNull(
        (e) => e.id == vase.collectableTypeName,
      );
      final iconPath = info != null
          ? 'assets/images/others/${info.iconName}'
          : null;
      if (iconPath != null) {
        return AssetImageWidget(
          assetPath: iconPath,
          altCandidates: imageAltCandidates(iconPath),
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
    }
    return const Icon(Icons.inventory, color: Colors.amber, size: size);
  }

  String _getVaseTitle(
    BuildContext context,
    VaseDefinition vase,
    AppLocalizations? l10n,
  ) {
    if (vase.plantTypeName != null) {
      final plants = PlantRepository().allPlants.where(
        (p) => p.id == vase.plantTypeName,
      );
      return plants.isNotEmpty
          ? ResourceNames.lookup(context, plants.first.name)
          : vase.plantTypeName!;
    }
    if (vase.zombieTypeName != null) {
      final typeName = ZombiePropertiesRepository.getTypeNameByAlias(
        vase.zombieTypeName!,
      );
      final zombies = ZombieRepository().allZombies.where(
        (z) => z.id == typeName,
      );
      return zombies.isNotEmpty
          ? ResourceNames.lookup(context, zombies.first.name)
          : vase.zombieTypeName!;
    }
    final collectableName = _collectableTypes
        .firstWhereOrNull((e) => e.id == vase.collectableTypeName)
        ?.name;
    return collectableName ??
        vase.collectableTypeName ??
        (l10n?.unknownVaseLabel ?? 'Unknown Vase');
  }

  String _getVaseSubtitle(VaseDefinition vase, AppLocalizations? l10n) {
    final parts = <String>[];
    if (vase.plantTypeName != null) {
      parts.add('${l10n?.plantLabel ?? "Plant"}: ${vase.plantTypeName}');
    }
    if (vase.zombieTypeName != null) {
      parts.add('${l10n?.zombieLabel ?? "Zombie"}: ${vase.zombieTypeName}');
    }
    if (vase.collectableTypeName != null) {
      parts.add(
        '${l10n?.itemLabel ?? "Item"}: ${_collectableTypes.firstWhereOrNull((e) => e.id == vase.collectableTypeName)?.name ?? vase.collectableTypeName}',
      );
    }
    return parts.isEmpty ? '${vase.count} vase(s)' : parts.join(', ');
  }

  Future<void> _showAddVaseDialog() async {
    final l10n = AppLocalizations.of(context);
    final choice = await showEditorChoiceDialog<String>(
      context,
      title: l10n?.addVaseTitle ?? 'Add Vase',
      options: [
        EditorChoiceDialogOption(
          value: 'plant',
          icon: Icons.eco_outlined,
          title: l10n?.plantVaseOption ?? 'Plant Vase',
        ),
        EditorChoiceDialogOption(
          value: 'zombie',
          icon: Icons.pest_control_outlined,
          title: l10n?.zombieVaseOption ?? 'Zombie Vase',
        ),
        EditorChoiceDialogOption(
          value: 'collectable',
          icon: Icons.card_giftcard_outlined,
          title: l10n?.itemLabel ?? 'Item',
        ),
      ],
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'plant':
        _showPlantPicker();
        break;
      case 'zombie':
        _showZombiePicker();
        break;
      case 'collectable':
        _showCollectablePicker();
        break;
    }
  }

  void _showPlantPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PlantSelectionScreen(
          onPlantSelected: (id) {
            _addVase(VaseDefinition(plantTypeName: id, count: 1));
            Navigator.pop(ctx);
          },
          onBack: () => Navigator.pop(context),
          levelFile: widget.levelFile,
          onAddModule: widget.onAddModule,
        ),
      ),
    );
  }

  void _showZombiePicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ZombieSelectionScreen(
          editorCubit: widget.editorCubit,
          onZombieSelected: (id) {
            _addVase(VaseDefinition(zombieTypeName: id, count: 1));
            Navigator.pop(ctx);
          },
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showCollectablePicker() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: SizedBox(
          width: 320,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _collectableTypes.length + 1,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l10n?.itemLabel ?? 'Item',
                    style: Theme.of(ctx).textTheme.headlineSmall,
                  ),
                );
              }
              final item = _collectableTypes[index - 1];
              final iconPath = 'assets/images/others/${item.iconName}';
              return EditorOptionTile(
                leading: AssetImageWidget(
                  assetPath: iconPath,
                  altCandidates: imageAltCandidates(iconPath),
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
                title: Text(item.name),
                subtitle: Text(item.id),
                onTap: () {
                  _addVase(
                    VaseDefinition(collectableTypeName: item.id, count: 1),
                  );
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _addVase(VaseDefinition vase) {
    _updateData((d) => d.vases.add(vase));
  }
}

class _CollectableType {
  const _CollectableType(this.id, this.name, this.iconName);
  final String id;
  final String name;
  final String iconName;
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

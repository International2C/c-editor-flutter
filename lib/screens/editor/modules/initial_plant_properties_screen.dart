import 'package:flutter/material.dart';
import 'package:c_editor/data/condition_l10n.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/plant_conditions.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Legacy preset plants (frozen plant placement). Ported from Z-Editor-master InitialPlantPropertiesEP.kt
class InitialPlantPropertiesScreen extends StatefulWidget {
  const InitialPlantPropertiesScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.onAddModule,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(String objClass)? onAddModule;

  @override
  State<InitialPlantPropertiesScreen> createState() =>
      _InitialPlantPropertiesScreenState();
}

class _InitialPlantPropertiesScreenState
    extends State<InitialPlantPropertiesScreen> {
  static const _objClass = 'InitialPlantProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late InitialPlantPropertiesData _data;
  int _selectedX = 0;
  int _selectedY = 0;
  InitialPlantPlacementData? _editingPlacement;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'InitialPlantProperties',
        objData: InitialPlantPropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = InitialPlantPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = InitialPlantPropertiesData();
    }
    _data = InitialPlantPropertiesData(
      placements: List.from(_data.placements),
      isInitialIntensiveCarrotPlacements:
          _data.isInitialIntensiveCarrotPlacements,
    );
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleSelectPlant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantSelectionScreen(
          isMultiSelect: false,
          onPlantSelected: (id) {
            Navigator.pop(context);
            final newList = List<InitialPlantPlacementData>.from(
              _data.placements,
            );
            newList.add(
              InitialPlantPlacementData(
                gridX: _selectedX,
                gridY: _selectedY,
                typeName: id,
                level: 1,
                condition: null,
              ),
            );
            _data = InitialPlantPropertiesData(
              placements: newList,
              isInitialIntensiveCarrotPlacements:
                  _data.isInitialIntensiveCarrotPlacements,
            );
            _sync();
          },
          onBack: () => Navigator.pop(context),
          levelFile: widget.levelFile,
          onAddModule: widget.onAddModule,
        ),
      ),
    );
  }

  void _updatePlacement(
    InitialPlantPlacementData oldPlacement,
    InitialPlantPlacementData newPlacement,
  ) {
    final newList = List<InitialPlantPlacementData>.from(_data.placements);
    final idx = newList.indexOf(oldPlacement);
    if (idx >= 0) {
      newList[idx] = newPlacement;
      _data = InitialPlantPropertiesData(
        placements: newList,
        isInitialIntensiveCarrotPlacements:
            _data.isInitialIntensiveCarrotPlacements,
      );
      _sync();
    }
  }

  void _deletePlacement(InitialPlantPlacementData target) {
    final newList = List<InitialPlantPlacementData>.from(_data.placements);
    newList.remove(target);
    _data = InitialPlantPropertiesData(
      placements: newList,
      isInitialIntensiveCarrotPlacements:
          _data.isInitialIntensiveCarrotPlacements,
    );
    _sync();
  }

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;

  void _showHelp(AppLocalizations l10n) {
    showEditorHelpDialog(
      context,
      isEvent: false,
      title: l10n.frozenPlantPlacementHelpTitle,
      themeColor: Theme.of(context).brightness == Brightness.dark
          ? pvzGreenDark
          : pvzGreenLight,
      sections: [
        HelpSectionData(
          title: l10n.frozenPlantPlacementHelpOverviewTitle,
          body: l10n.frozenPlantPlacementHelpOverviewBody,
        ),
        HelpSectionData(
          title: l10n.frozenPlantPlacementHelpConditionTitle,
          body: l10n.frozenPlantPlacementHelpConditionBody,
        ),
        HelpSectionData(
          title: l10n.frozenPlantPlacementHelpLastStandTitle,
          body: l10n.frozenPlantPlacementHelpLastStandBody,
        ),
      ],
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark ? pvzGreenDark : pvzGreenLight;
    final placementsAtPosition = _data.placements
        .where(
          (p) =>
              p.gridX == _selectedX &&
              p.gridY == _selectedY &&
              p.gridX >= 0 &&
              p.gridY >= 0 &&
              p.gridX < _gridCols &&
              p.gridY < _gridRows,
        )
        .toList();
    final placementsOutsideLawn = _data.placements
        .where(
          (p) =>
              p.gridX < 0 ||
              p.gridY < 0 ||
              p.gridX >= _gridCols ||
              p.gridY >= _gridRows,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        backgroundColor: barColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(l10n),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModuleAliasInputField(
                  rtid: widget.rtid,
                  alias: _alias,
                  levelFile: widget.levelFile,
                  onAliasChanged: _handleAliasChanged,
                  onChanged: widget.onChanged,
                  accentColor: barColor,
                ),
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    title: Text(
                      l10n.frozenPlantPlacementLastStand,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'IsInitialIntensiveCarrotPlacements',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: _data.isInitialIntensiveCarrotPlacements == true,
                    onChanged: (v) {
                      _data = InitialPlantPropertiesData(
                        placements: _data.placements,
                        isInitialIntensiveCarrotPlacements: v ? true : null,
                      );
                      _sync();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                EditorPlacementGridCard(
                  header: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.frozenPlantPlacementSelectedPosition,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                  grid: _buildGrid(),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.frozenPlantPlacementPlantList,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...placementsAtPosition.map(
                      (p) => _PlacementCard(
                        placement: p,
                        gridRows: _gridRows,
                        gridCols: _gridCols,
                        showCoordinates: false,
                        onTap: () {
                          setState(() {
                            _selectedX = p.gridX;
                            _selectedY = p.gridY;
                            _editingPlacement = p;
                          });
                        },
                      ),
                    ),
                    AddItemCard(onPressed: _handleSelectPlant),
                  ],
                ),
                if (placementsOutsideLawn.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.outsideLawnItems,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: placementsOutsideLawn
                        .map(
                          (p) => _PlacementCard(
                            placement: p,
                            gridRows: _gridRows,
                            gridCols: _gridCols,
                            showCoordinates: true,
                            onTap: () {
                              setState(() {
                                _selectedX = p.gridX;
                                _selectedY = p.gridY;
                                _editingPlacement = p;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (_editingPlacement != null) _buildEditDialog(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final theme = Theme.of(context);
    final rows = _gridRows;
    final cols = _gridCols;
    return scaleTableForDesktop(
      context: context,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: EditorItemCardLayout.placementGridMaxWidth,
        ),
        child: AspectRatio(
          aspectRatio: cols / rows,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF3C483D)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
            ),
            child: Column(
              children: List.generate(rows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(cols, (col) {
                      final isSelected = row == _selectedY && col == _selectedX;
                      final cellPlacements = _data.placements
                          .where((p) => p.gridX == col && p.gridY == row)
                          .toList();
                      final firstPlacement = cellPlacements.isNotEmpty
                          ? cellPlacements.first
                          : null;
                      final count = cellPlacements.length;
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
                                    : const Color(0xFFA5D6A7),
                                width: 0.5,
                              ),
                            ),
                            child: count > 0 && firstPlacement != null
                                ? LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Positioned.fill(
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: _PlantIconSmall(
                                                  firstPlacement.typeName,
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
                                  )
                                : null,
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

  Widget _buildEditDialog() {
    final placement = _editingPlacement!;
    return _PlacementEditDialog(
      placement: placement,
      onSave: (updated) {
        _updatePlacement(placement, updated);
        setState(() => _editingPlacement = null);
      },
      onDelete: () {
        _deletePlacement(placement);
        setState(() => _editingPlacement = null);
      },
      onCancel: () => setState(() => _editingPlacement = null),
    );
  }
}

class _PlantIconSmall extends StatelessWidget {
  const _PlantIconSmall(this.plantType);

  final String plantType;

  @override
  Widget build(BuildContext context) {
    final info = PlantRepository().getPlantInfoById(plantType);
    final path = info?.icon != null
        ? 'assets/images/plants/${info!.icon}'
        : 'assets/images/others/unknown.webp';
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AssetImageWidget(
        assetPath: path,
        fit: BoxFit.cover,
        width: 32,
        height: 32,
        altCandidates: imageAltCandidates(path),
      ),
    );
  }
}

class _PlacementCard extends StatelessWidget {
  const _PlacementCard({
    required this.placement,
    required this.gridRows,
    required this.gridCols,
    required this.showCoordinates,
    required this.onTap,
  });

  final InitialPlantPlacementData placement;
  final int gridRows;
  final int gridCols;
  final bool showCoordinates;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final info = PlantRepository().getPlantInfoById(placement.typeName);
    final plantName = ResourceNames.lookup(
      context,
      PlantRepository().getName(placement.typeName),
    );
    final path = info?.icon != null
        ? 'assets/images/plants/${info!.icon}'
        : 'assets/images/others/unknown.webp';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AssetImageWidget(
                      assetPath: path,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      altCandidates: imageAltCandidates(path),
                      errorWidget: Container(
                        color: theme.colorScheme.onSurfaceVariant,
                        width: 64,
                        height: 64,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plantName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${l10n.frozenPlantPlacementLevel}: ${placement.level}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      placement.condition == null
                          ? l10n.noConditions
                          : ConditionL10n.plantLabel(
                              context,
                              placement.condition!,
                            ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (showCoordinates)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              editorWarningIcon,
                              color: editorWarningBannerForeground(
                                theme.brightness,
                              ),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'R${placement.gridY + 1}:C${placement.gridX + 1}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: editorWarningBannerForeground(
                                  theme.brightness,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlacementEditDialog extends StatefulWidget {
  const _PlacementEditDialog({
    required this.placement,
    required this.onSave,
    required this.onDelete,
    required this.onCancel,
  });

  final InitialPlantPlacementData placement;
  final void Function(InitialPlantPlacementData) onSave;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  @override
  State<_PlacementEditDialog> createState() => _PlacementEditDialogState();
}

class _PlacementEditDialogState extends State<_PlacementEditDialog> {
  late int _level;
  late String? _condition;

  @override
  void initState() {
    super.initState();
    _level = widget.placement.level;
    _condition = widget.placement.condition;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = ResourceNames.lookup(
      context,
      PlantRepository().getName(widget.placement.typeName),
    );
    const noConditionOption = '';
    final condition = _condition;
    // Keep legacy and manually entered values visible without adding presets.
    final customCondition =
        condition != null && !PlantConditions.ids.contains(condition)
        ? condition
        : null;
    return AlertDialog(
      scrollable: true,
      constraints: const BoxConstraints.tightFor(width: 560),
      title: Text(l10n.frozenPlantPlacementEditPlant(name)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${l10n.frozenPlantPlacementLevel}: $_level',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _level.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => _level = v.round()),
            ),
            const Divider(),
            EditorResponsiveInputField(
              label: l10n.frozenPlantPlacementCondition,
              decoration: InputDecoration(),
              builder: (context, decoration) => DropdownButtonFormField<String>(
                itemHeight: null,
                isExpanded: true,
                initialValue: customCondition == null
                    ? condition ?? noConditionOption
                    : null,
                hint: customCondition == null
                    ? null
                    : Text(ConditionL10n.plantLabel(context, customCondition)),
                decoration: decoration,
                items: [
                  DropdownMenuItem<String>(
                    value: noConditionOption,
                    child: Text(l10n.frozenPlantPlacementConditionNull),
                  ),
                  for (final id in PlantConditions.ids)
                    DropdownMenuItem<String>(
                      value: id,
                      child: Text(ConditionL10n.plantLabel(context, id)),
                    ),
                ],
                onChanged: (v) => setState(() {
                  _condition = v == noConditionOption ? null : v;
                }),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onDelete,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n.delete),
        ),
        TextButton(onPressed: widget.onCancel, child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            widget.onSave(
              InitialPlantPlacementData(
                gridX: widget.placement.gridX,
                gridY: widget.placement.gridY,
                typeName: widget.placement.typeName,
                level: _level,
                condition: _condition,
              ),
            );
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

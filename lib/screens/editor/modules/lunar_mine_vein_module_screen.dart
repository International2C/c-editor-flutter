import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/lunar_mine_vein_type_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/grid_override_placement_grid.dart';

class LunarMineVeinModuleScreen extends StatefulWidget {
  const LunarMineVeinModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<LunarMineVeinModuleScreen> createState() =>
      _LunarMineVeinModuleScreenState();
}

class _LunarMineVeinModuleScreenState extends State<LunarMineVeinModuleScreen> {
  static const _objClass = 'LunarMineVeinModuleProperties';

  late String _alias;
  late PvzObject _moduleObject;
  late LunarMineVeinModulePropertiesData _data;
  int _selectedX = 0;
  int _selectedY = 0;
  String _selectedType = kLunarMineVeinTypes.first.type;

  int get _gridRows =>
      LevelParser.getGridDimensionsFromFile(widget.levelFile).$1;
  int get _gridCols =>
      LevelParser.getGridDimensionsFromFile(widget.levelFile).$2;

  LunarMineVeinPlacementData? get _selectedPlacement =>
      _data.placements.firstWhereOrNull(
        (entry) => entry.gridX == _selectedX && entry.gridY == _selectedY,
      );

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _moduleObject =
        widget.levelFile.objects.firstWhereOrNull(
          (object) => object.aliases?.contains(_alias) == true,
        ) ??
        PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: LunarMineVeinModulePropertiesData().toJson(),
        );
    if (!widget.levelFile.objects.contains(_moduleObject)) {
      widget.levelFile.objects.add(_moduleObject);
    }
    try {
      _data = LunarMineVeinModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObject.objData as Map),
      );
    } catch (_) {
      _data = LunarMineVeinModulePropertiesData();
    }
    if (_data.placements.isNotEmpty) {
      _selectedX = _data.placements.first.gridX;
      _selectedY = _data.placements.first.gridY;
      _selectedType = _data.placements.first.typeName;
    }
  }

  void _sync() {
    _moduleObject.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  LunarMineVeinPlacementData? _itemAt(int col, int row) => _data.placements
      .firstWhereOrNull((entry) => entry.gridX == col && entry.gridY == row);

  void _tapCell(int col, int row) {
    setState(() {
      _selectedX = col;
      _selectedY = row;
    });
    final existing = _itemAt(col, row);
    if (existing != null) {
      if (existing.typeName == _selectedType) return;
      existing.typeName = _selectedType;
    } else {
      _data.placements.add(
        LunarMineVeinPlacementData(
          typeName: _selectedType,
          gridX: col,
          gridY: row,
          emergenceWave: 1,
        ),
      );
    }
    _sync();
  }

  void _removeAt(int col, int row) {
    _data.placements.removeWhere(
      (entry) => entry.gridX == col && entry.gridY == row,
    );
    _sync();
  }

  void _handleAliasChanged(String value) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: value,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = value);
  }

  Widget _buildTypePalette(BuildContext context) {
    final theme = Theme.of(context);
    const preferredWidth = 112.0;
    const spacing = 8.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.clamp(0.0, preferredWidth);
        final columns =
            ((constraints.maxWidth + spacing) / (preferredWidth + spacing))
                .floor()
                .clamp(1, kLunarMineVeinTypes.length);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (
              var start = 0;
              start < kLunarMineVeinTypes.length;
              start += columns
            ) ...[
              if (start > 0) const SizedBox(height: spacing),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      var i = start;
                      i < start + columns && i < kLunarMineVeinTypes.length;
                      i++
                    ) ...[
                      if (i > start) const SizedBox(width: spacing),
                      SizedBox(
                        width: cardWidth,
                        child: _buildTypeCard(
                          context,
                          theme,
                          kLunarMineVeinTypes[i],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTypeCard(
    BuildContext context,
    ThemeData theme,
    LunarMineVeinTypeInfo info,
  ) {
    final typeSelected = _selectedType == info.type;
    final label = ResourceNames.lookup(context, 'griditem_${info.type}');
    return InkWell(
      key: ValueKey('lunar-vein-type-${info.type}'),
      onTap: () => setState(() => _selectedType = info.type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 112,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: typeSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: typeSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 48,
              child: AssetImageWidget(
                assetPath: info.iconAsset,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),
            Tooltip(
              message: label,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Tooltip(
              message: info.type,
              child: Text(
                info.type,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selected = _selectedPlacement;
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
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.lunarMineVeinHelpTitle ?? 'Lunar Veins',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.lunarMineVeinHelpOverview ?? '',
                ),
                HelpSectionData(
                  title: ResourceNames.lookup(
                    context,
                    'griditem_lunar_mine_vein_hardened',
                  ),
                  body: l10n?.lunarMineVeinHelpHardened ?? '',
                ),
                HelpSectionData(
                  title: ResourceNames.lookup(
                    context,
                    'griditem_lunar_mine_vein_fragile',
                  ),
                  body: l10n?.lunarMineVeinHelpFragile ?? '',
                ),
                HelpSectionData(
                  title: ResourceNames.lookup(
                    context,
                    'griditem_lunar_mine_vein_radiation',
                  ),
                  body: l10n?.lunarMineVeinHelpRadiation ?? '',
                ),
                HelpSectionData(
                  title: l10n?.lunarMineVeinHelpWaveTitle ?? 'Wave numbering',
                  body: l10n?.lunarMineVeinHelpWave ?? '',
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
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.lunarMineVeinPlacements ??
                          'Vein placements (VeinPlacements)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n?.moonPlacementGestureHint ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n?.lunarMineVeinTypePalette ?? 'Crystal vein type',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTypePalette(context),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n?.selectedPosition ?? 'Selected position'}: '
                      'R${_selectedY + 1} : C${_selectedX + 1}',
                    ),
                    const SizedBox(height: 12),
                    GridOverridePlacementGrid(
                      gridRows: _gridRows,
                      gridCols: _gridCols,
                      selectedCol: _selectedX,
                      selectedRow: _selectedY,
                      onPrimaryTap: _tapCell,
                      onRemoveAt: _removeAt,
                      cellImageAt: (col, row) {
                        final item = _itemAt(col, row);
                        return item == null
                            ? null
                            : lunarMineVeinIconAsset(item.typeName);
                      },
                      cellImageScaleAt: (_, _) => 0.92,
                    ),
                    if (selected != null) ...[
                      const SizedBox(height: 16),
                      EditorResponsiveInputField(
                        label:
                            l10n?.lunarMineEmergenceWave ??
                            'Growth wave (EmergenceWave, numbered from 1)',
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                        ),
                        builder: (context, decoration) => TextFormField(
                          key: ValueKey(
                            'vein-wave-${selected.gridX}-${selected.gridY}',
                          ),
                          initialValue: '${selected.emergenceWave}',
                          decoration: decoration,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed != null && parsed >= 1) {
                              selected.emergenceWave = parsed;
                              _sync();
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

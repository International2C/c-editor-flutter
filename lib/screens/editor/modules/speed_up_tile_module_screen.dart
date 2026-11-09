import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/speed_up_tile_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart' show pvzCyanDark, pvzCyanLight;
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Zero-based placement editor for `SpeedUpTileModuleProperties`.
class SpeedUpTileModuleScreen extends StatefulWidget {
  const SpeedUpTileModuleScreen({
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
  State<SpeedUpTileModuleScreen> createState() =>
      _SpeedUpTileModuleScreenState();
}

class _SpeedUpTileModuleScreenState extends State<SpeedUpTileModuleScreen> {
  static const _objClass = 'SpeedUpTileModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late SpeedUpTileModulePropertiesData _data;
  late int _gridCols;
  late int _gridRows;
  String _selectedDirection = SpeedUpTileCatalog.left;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    final isDeepSea = LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
    _gridCols = isDeepSea ? 10 : 9;
    _gridRows = isDeepSea ? 6 : 5;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (object) => object.aliases?.contains(_alias) == true,
      orElse: () => PvzObject(
        aliases: [_alias],
        objClass: _objClass,
        objData: SpeedUpTileModulePropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    _data = SpeedUpTileModulePropertiesData.fromJson(
      Map<String, dynamic>.from(_moduleObj.objData as Map),
    );
  }

  bool _isInside(SpeedUpTileRoadData road) =>
      road.gridX >= 0 &&
      road.gridX < _gridCols &&
      road.gridY >= 0 &&
      road.gridY < _gridRows;

  List<SpeedUpTileRoadData> get _outsideRoads =>
      _data.roads.where((road) => !_isInside(road)).toList();

  SpeedUpTileRoadData? _roadAt(int x, int y) {
    for (final road in _data.roads.reversed) {
      if (road.gridX == x && road.gridY == y) return road;
    }
    return null;
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleGridClick(int x, int y) {
    final current = _roadAt(x, y);
    if (current?.img == _selectedDirection) {
      _data.roads.removeWhere((road) => road.gridX == x && road.gridY == y);
    } else if (current != null) {
      // Modify in place to preserve the imported list order and extra fields.
      current.img = _selectedDirection;
    } else {
      _data.roads.add(
        SpeedUpTileRoadData(gridX: x, gridY: y, img: _selectedDirection),
      );
    }
    _sync();
  }

  String _directionLabel(AppLocalizations? l10n, String direction) =>
      switch (direction) {
        SpeedUpTileCatalog.left => l10n?.speedUpTileDirectionLeft ?? 'Left',
        SpeedUpTileCatalog.right => l10n?.speedUpTileDirectionRight ?? 'Right',
        SpeedUpTileCatalog.up => l10n?.speedUpTileDirectionUp ?? 'Up',
        SpeedUpTileCatalog.down => l10n?.speedUpTileDirectionDown ?? 'Down',
        _ => direction,
      };

  Widget _tileImage(String direction) {
    final asset = SpeedUpTileCatalog.assetForImage(direction);
    if (asset == null) {
      return Tooltip(message: direction, child: const Icon(Icons.help_outline));
    }
    return AssetImageWidget(
      assetPath: asset,
      altCandidates: imageAltCandidates(asset),
      fit: BoxFit.contain,
    );
  }

  Future<void> _requestDelete({required bool outsideOnly}) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          outsideOnly
              ? l10n?.speedUpTileDeleteOutsideConfirmTitle ??
                    'Delete speed-up tiles outside the lawn?'
              : l10n?.speedUpTileClearConfirmTitle ??
                    'Clear all speed-up tiles?',
        ),
        content: Text(
          outsideOnly
              ? l10n?.speedUpTileDeleteOutsideConfirmMessage ??
                    'Remove only the speed-up tiles outside the lawn grid.'
              : l10n?.speedUpTileClearConfirmMessage ??
                    'Remove all placed speed-up tiles, including those outside the lawn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(
              outsideOnly
                  ? l10n?.speedUpTileDeleteOutside ?? 'Delete outside lawn'
                  : l10n?.speedUpTileClearAll ?? 'Clear all',
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (outsideOnly) {
      _data.roads.removeWhere((road) => !_isInside(road));
    } else {
      _data.roads.clear();
    }
    _sync();
  }

  void _handleAliasChanged(String alias) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: alias,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = alias);
  }

  Widget _deleteButton({
    required Key key,
    required String label,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
  }) => FilledButton(
    key: key,
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.delete_outline, size: 18),
        const SizedBox(width: 8),
        Flexible(child: Text(label)),
      ],
    ),
  );

  void _showHelp(Color accent) {
    final l10n = AppLocalizations.of(context);
    showEditorHelpDialog(
      context,
      isEvent: false,
      title: l10n?.speedUpTileTitle ?? 'Speed-Up Tiles',
      themeColor: accent,
      sections: [
        HelpSectionData(
          title: l10n?.overview ?? 'Overview',
          body:
              l10n?.speedUpTileHelpOverview ??
              'Place speed-up tiles on selected lawn cells. Eligible ground zombies move quickly in the arrow direction and resume normal movement after leaving the road. Gargantuars and zombies with special movement ignore speed-up tiles.',
        ),
        HelpSectionData(
          title: l10n?.speedUpTileHelpUsageTitle ?? 'Usage',
          body:
              l10n?.speedUpTileHelpUsageBody ??
              'Choose a direction, then tap a cell to place a speed-up tile. Tap a tile with the same direction to remove it, or select another direction to replace it. A Speed-Up Tile\'s horizontal coordinate (GridX) and vertical coordinate (GridY) both start at 0. For example, horizontal coordinate 0 means the first column and 8 means the ninth column; vertical coordinate 0 means the first row and 2 means the third row.',
        ),
        HelpSectionData(
          title: l10n?.speedUpTileTopologyTitle ?? 'Road connections',
          body:
              l10n?.speedUpTileTopologyBody ??
              'Arrows do not cause an immediate turn on entry. Zombies usually continue along the current direction before checking road connections after roughly one cell. For a turn, the cell ahead in the old direction must be an ordinary lawn tile, with a speed-up tile in the new direction and only one available exit. Use a continuous, one-cell-wide road without branches.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? pvzCyanDark : pvzCyanLight;
    final outside = _outsideRoads;
    final compatibilityWarnings = LevelIssueRegistry.forLevel(
      context,
      widget.levelFile,
    ).where((issue) => issue.id == 'speedUpTileCompatibilityWarning');
    const border = Color(0xFF6B899A);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: l10n?.speedUpTileTitle ?? 'Speed-Up Tiles',
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        backgroundColor: accent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => _showHelp(accent),
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
              accentColor: accent,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
            ),
            const SizedBox(height: 16),
            scaleTableForDesktop(
              context: context,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: AspectRatio(
                  aspectRatio: (_gridCols * 128) / (_gridRows * 152),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF31383B)
                          : const Color(0xFFD7ECF1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: border),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: List.generate(
                        _gridRows,
                        (y) => Expanded(
                          child: Row(
                            children: List.generate(_gridCols, (x) {
                              final road = _roadAt(x, y);
                              return Expanded(
                                child: Semantics(
                                  button: true,
                                  label: '($x, $y)',
                                  child: GestureDetector(
                                    key: ValueKey('speedUpTileCell_${x}_$y'),
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _handleGridClick(x, y),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: border.withValues(alpha: 0.5),
                                          width: 0.5,
                                        ),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: road == null
                                          ? null
                                          : _tileImage(road.img),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            for (final issue in compatibilityWarnings) ...[
              const SizedBox(height: 16),
              EditorWarningBanner(
                key: ValueKey(issue.id),
                message: issue.message,
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.speedUpTileSelectDirection ?? 'Select direction',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) => Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: SpeedUpTileCatalog.directions.map((
                          direction,
                        ) {
                          final selected = direction == _selectedDirection;
                          return SizedBox(
                            width: ((constraints.maxWidth - 12) / 2)
                                .clamp(0, 160)
                                .toDouble(),
                            child: Semantics(
                              selected: selected,
                              button: true,
                              child: InkWell(
                                key: ValueKey(
                                  'speedUpTileDirection_$direction',
                                ),
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(
                                    () => _selectedDirection = direction,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? accent.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected
                                          ? accent
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 64,
                                        height: 64,
                                        child: _tileImage(direction),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _directionLabel(l10n, direction),
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: selected
                                                  ? accent
                                                  : theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EditorResponsiveActionRow(
                  content: Text(
                    '${l10n?.speedUpTilePlacedCount ?? 'Placed'}: ${_data.roads.length}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  action: _deleteButton(
                    key: const ValueKey('speedUpTileClearAll'),
                    onPressed: _data.roads.isEmpty
                        ? null
                        : () => _requestDelete(outsideOnly: false),
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    label: l10n?.speedUpTileClearAll ?? 'Clear all',
                  ),
                ),
              ),
            ),
            if (outside.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: EditorResponsiveActionRow(
                    content: Text(
                      '${l10n?.speedUpTileOutsideLawn ?? 'Outside lawn: '}'
                      '${outside.map((road) => '(${road.gridX}, ${road.gridY})').join(', ')}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    action: _deleteButton(
                      key: const ValueKey('speedUpTileDeleteOutside'),
                      onPressed: () => _requestDelete(outsideOnly: true),
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.black87,
                      label:
                          l10n?.speedUpTileDeleteOutside ??
                          'Delete outside lawn',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

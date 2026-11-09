import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart' show pvzPinkDark, pvzPinkLight;
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Gulliver tunnel placement module (`InitialGridItemGulliverTunnelProperties`).
class GulliverTunnelModuleScreen extends StatefulWidget {
  const GulliverTunnelModuleScreen({
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
  State<GulliverTunnelModuleScreen> createState() =>
      _GulliverTunnelModuleScreenState();
}

class _GulliverTunnelModuleScreenState
    extends State<GulliverTunnelModuleScreen> {
  static const _objClass = 'InitialGridItemGulliverTunnelProperties';
  late String _alias;
  static const _orientationLeft = 'GULLIVERTUNNEL_ORIENTATION_BIG_ON_LEFT';
  static const _orientationRight = 'GULLIVERTUNNEL_ORIENTATION_BIG_ON_RIGHT';

  static const _orientations = [_orientationLeft, _orientationRight];
  static const _assetWidth = 128.0;
  static const _assetHeight = 152.0;
  static const _selectionButtonWidth = 176.0;
  static const _selectionPreviewWidth = 80.0;
  static const _selectionPreviewHeight =
      _selectionPreviewWidth * _assetHeight / _assetWidth;

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  int get _gridCols => _isDeepSeaLawn ? 10 : 9;
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  double get _gridAspectRatio =>
      (_gridCols * _assetWidth) / (_gridRows * _assetHeight);

  late PvzObject _moduleObj;
  late InitialGridItemGulliverTunnelPropertiesData _data;
  late List<List<String?>> _gridState;
  String _selectedOrientation = _orientationLeft;

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
        objClass: 'InitialGridItemGulliverTunnelProperties',
        objData: InitialGridItemGulliverTunnelPropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = InitialGridItemGulliverTunnelPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = InitialGridItemGulliverTunnelPropertiesData();
    }
    _gridState = List.generate(_gridCols, (_) => List.filled(_gridRows, null));
    for (final placement in _data.tunnelPlacements) {
      if (placement.gridX >= 0 &&
          placement.gridX < _gridCols &&
          placement.gridY >= 0 &&
          placement.gridY < _gridRows) {
        _gridState[placement.gridX][placement.gridY] = placement.orientation;
      }
    }
    _selectedOrientation = _orientationLeft;
  }

  void _sync() {
    final placements = <GulliverTunnelPlacementData>[];
    for (var x = 0; x < _gridCols; x++) {
      for (var y = 0; y < _gridRows; y++) {
        final orientation = _gridState[x][y];
        if (orientation != null && orientation.isNotEmpty) {
          placements.add(
            GulliverTunnelPlacementData(
              gridX: x,
              gridY: y,
              orientation: orientation,
            ),
          );
        }
      }
    }
    for (final placement in _data.tunnelPlacements) {
      if (placement.gridX < 0 ||
          placement.gridX >= _gridCols ||
          placement.gridY < 0 ||
          placement.gridY >= _gridRows) {
        placements.add(placement);
      }
    }
    _data = InitialGridItemGulliverTunnelPropertiesData(
      tunnelPlacements: placements,
    );
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleGridClick(int x, int y) {
    final current = _gridState[x][y];
    if (current == _selectedOrientation) {
      _gridState[x][y] = null;
    } else {
      _gridState[x][y] = _selectedOrientation;
    }
    _sync();
  }

  String _assetPath(String orientation) =>
      'assets/images/tunnels/$orientation.webp';

  Widget _buildTunnelImage(String orientation) {
    final path = _assetPath(orientation);
    return AssetImageWidget(
      assetPath: path,
      altCandidates: imageAltCandidates(path),
      fit: BoxFit.contain,
    );
  }

  String _orientationLabel(AppLocalizations? l10n, String orientation) {
    if (orientation == _orientationLeft) {
      return l10n?.gulliverTunnelOrientationBigOnLeft ?? 'Big opening on left';
    }
    return l10n?.gulliverTunnelOrientationBigOnRight ?? 'Big opening on right';
  }

  Future<void> _requestClearAll() async {
    if (_data.tunnelPlacements.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.gulliverTunnelClearConfirmTitle ?? 'Clear all tunnels?',
        ),
        content: Text(
          l10n?.gulliverTunnelClearConfirmMessage ??
              'Remove all placed Gulliver tunnels from the grid.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: Text(l10n?.gulliverTunnelClearAll ?? 'Clear all'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) _clearAll();
  }

  void _clearAll() {
    for (var x = 0; x < _gridCols; x++) {
      for (var y = 0; y < _gridRows; y++) {
        _gridState[x][y] = null;
      }
    }
    _sync();
  }

  List<GulliverTunnelPlacementData> get _placementsOutsideLawn => _data
      .tunnelPlacements
      .where(
        (p) =>
            p.gridX < 0 ||
            p.gridX >= _gridCols ||
            p.gridY < 0 ||
            p.gridY >= _gridRows,
      )
      .toList();

  bool get _isDefaultLawnSize => _gridRows == 5 && _gridCols == 9;

  Future<void> _requestDeleteOutsideLawn() async {
    final outside = _placementsOutsideLawn;
    if (outside.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.gulliverTunnelDeleteOutsideConfirmTitle ??
              'Delete tunnels outside lawn?',
        ),
        content: Text(
          l10n?.gulliverTunnelDeleteOutsideConfirmMessage ??
              'Remove tunnel placements outside the lawn grid.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.black87,
            ),
            child: Text(
              l10n?.gulliverTunnelDeleteOutside ?? 'Delete outside lawn',
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) _deletePlacementsOutsideLawn();
  }

  void _deletePlacementsOutsideLawn() {
    final inside = _data.tunnelPlacements
        .where(
          (p) =>
              p.gridX >= 0 &&
              p.gridX < _gridCols &&
              p.gridY >= 0 &&
              p.gridY < _gridRows,
        )
        .toList();
    _data = InitialGridItemGulliverTunnelPropertiesData(
      tunnelPlacements: inside,
    );
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
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
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? pvzPinkDark : pvzPinkLight;
    final lawnBg = isDark ? const Color(0xFF31383B) : const Color(0xFFD7ECF1);
    const gridBorder = Color(0xFF6B899A);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () {
              showEditorHelpDialog(
                context,
                isEvent: false,
                title: l10n?.gulliverTunnelTitle ?? 'Gulliver tunnels',
                themeColor: accentColor,
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body:
                        l10n?.gulliverTunnelHelpOverview ??
                        'Place pre-set Gulliver tunnels on the lawn.',
                  ),
                  HelpSectionData(
                    title: l10n?.gulliverTunnelHelpUsage ?? 'Usage',
                    body:
                        l10n?.gulliverTunnelHelpUsageBody ??
                        'Select an orientation, then tap the grid to place. Tap again to remove.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
            scaleTableForDesktop(
              context: context,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 560),
                child: AspectRatio(
                  aspectRatio: _gridAspectRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: lawnBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: gridBorder, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Column(
                        children: List.generate(_gridRows, (row) {
                          return Expanded(
                            child: Row(
                              children: List.generate(_gridCols, (col) {
                                final orientation = _gridState[col][row];
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _handleGridClick(col, row),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: gridBorder.withValues(
                                            alpha: 0.5,
                                          ),
                                          width: 0.5,
                                        ),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: orientation != null
                                          ? _buildTunnelImage(orientation)
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
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.gulliverTunnelSelectOrientation ??
                          'Select orientation',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _orientations.map((orientation) {
                        final isSelected = _selectedOrientation == orientation;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(
                                () => _selectedOrientation = orientation,
                              );
                            },
                            child: Container(
                              width: _selectionButtonWidth,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accentColor.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? accentColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: _selectionPreviewWidth,
                                    height: _selectionPreviewHeight,
                                    child: Center(
                                      child: _buildTunnelImage(orientation),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _orientationLabel(l10n, orientation),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isSelected
                                          ? accentColor
                                          : theme.colorScheme.onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
                    '${l10n?.gulliverTunnelPlacedCount ?? 'Placed'}: ${_data.tunnelPlacements.length}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  action: FilledButton.icon(
                    onPressed: _data.tunnelPlacements.isEmpty
                        ? null
                        : _requestClearAll,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(l10n?.gulliverTunnelClearAll ?? 'Clear all'),
                  ),
                ),
              ),
            ),
            if (_isDefaultLawnSize && _placementsOutsideLawn.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: EditorResponsiveActionRow(
                    content: Text(
                      '${l10n?.gulliverTunnelOutsideLawn ?? 'Outside lawn'}: ${_placementsOutsideLawn.map((p) => '${_orientationLabel(l10n, p.orientation)} (R${p.gridY + 1}:C${p.gridX + 1})').join(', ')}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    action: FilledButton.icon(
                      onPressed: _requestDeleteOutsideLawn,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.black87,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        l10n?.gulliverTunnelDeleteOutside ??
                            'Delete outside lawn',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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

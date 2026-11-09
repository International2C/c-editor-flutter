import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart' show pvzBrownDark, pvzBrownLight;
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Tunnel defend (mausoleum) module. Ported from TunnelDefendModuleEP.kt
class TunnelDefendModuleScreen extends StatefulWidget {
  const TunnelDefendModuleScreen({
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
  State<TunnelDefendModuleScreen> createState() =>
      _TunnelDefendModuleScreenState();
}

class _TunnelDefendModuleScreenState extends State<TunnelDefendModuleScreen> {
  static const _objClass = 'TunnelDefendModuleProperties';
  static const _expeditionAlias = 'SouDaCheTunnelDefendDefault';
  static const _expeditionBlockedMarker = '__soudache_blocked__';
  static const _expeditionRoadAsset =
      'assets/images/tunnels/SouDaCheTunnelRoad.webp';
  static const _expeditionBlockedAsset =
      'assets/images/tunnels/SouDaCheTunnelRoadBlocked.webp';
  late String _alias;
  static const _settingsMaxWidth = 960.0;
  static const _assetWidth = 128.0;
  static const _assetHeight = 152.0;

  static const _expeditionPreviewRoads = <(int, int)>[
    (0, 0),
    (1, 0),
    (0, 1),
    (1, 1),
    (5, 1),
    (0, 2),
    (1, 2),
    (5, 2),
    (0, 3),
    (1, 3),
    (5, 3),
    (0, 4),
    (1, 4),
  ];

  static const _expeditionPresetAliases = [
    'SoudacheTunnelDefendStage1',
    'SoudacheTunnelDefendStage2',
    'SoudacheTunnelDefendStage3',
  ];

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  bool get _isIncompatibleExpeditionLawn {
    if (!_isExpedition) return false;
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isUnderwaterWorldSixRowLawn(
      parsed.levelDef,
      widget.levelFile,
    );
  }

  int get _gridCols => _isExpedition ? 9 : (_isDeepSeaLawn ? 10 : 9);
  int get _gridRows => _isExpedition ? 5 : (_isDeepSeaLawn ? 6 : 5);
  double get _gridAspectRatio =>
      (_gridCols * _assetWidth) / (_gridRows * _assetHeight);

  static const _availableAssets = [
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN_3',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN_LEFT',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN_LEFT_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN_LEFT_3',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_3',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_4',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_5',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_6',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_7',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_3',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_LEFT',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_LEFT_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_LEFT_3',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_DOWN',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_DOWN_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_DOWN_LEFT',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_DOWN_LEFT_2',
  ];

  late PvzObject _moduleObj;
  late TunnelDefendModuleData _data;
  late List<List<String?>> _gridState;
  late TextEditingController _sequenceIntervalCtrl;
  String _selectedImg = _availableAssets[0];
  bool _isExpedition = false;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    final isExpeditionAlias = _isExpeditionAlias(alias);
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'TunnelDefendModuleProperties',
        objData: isExpeditionAlias
            ? TunnelDefendModuleData(
                brickMapIndex: 3,
                reportError: false,
              ).toJson(includeTunnelSequenceInterval: false)
            : TunnelDefendModuleData(reportError: true).toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    final objData = _moduleObj.objData is Map
        ? Map<String, dynamic>.from(_moduleObj.objData as Map)
        : <String, dynamic>{};
    _isExpedition =
        isExpeditionAlias || (objData['BrickMapIndex'] as num?)?.toInt() == 3;
    try {
      _data = TunnelDefendModuleData.fromJson(
        objData,
        defaultReportError: _isExpedition ? false : true,
      );
    } catch (_) {
      _data = TunnelDefendModuleData(
        brickMapIndex: _isExpedition ? 3 : 1,
        reportError: !_isExpedition,
      );
    }
    if (_isExpedition) {
      _data.brickMapIndex = 3;
      _data.roads = _normalizeExpeditionRoads(_data.roads);
    }
    _gridState = List.generate(_gridCols, (_) => List.filled(_gridRows, null));
    for (final road in _data.roads) {
      if (road.gridX >= 0 &&
          road.gridX < _gridCols &&
          road.gridY >= 0 &&
          road.gridY < _gridRows) {
        _gridState[road.gridX][road.gridY] = _isExpedition
            ? _expeditionBlockedMarker
            : road.img;
      }
    }
    _selectedImg = _availableAssets[0];
    _sequenceIntervalCtrl = TextEditingController(
      text: '${_data.tunnelSequenceInterval}',
    );
  }

  @override
  void dispose() {
    _sequenceIntervalCtrl.dispose();
    super.dispose();
  }

  static bool _isExpeditionAlias(String alias) =>
      alias == _expeditionAlias ||
      alias.startsWith('SoudacheTunnelDefendStage');

  static List<TunnelRoadData> _normalizeExpeditionRoads(
    Iterable<TunnelRoadData> roads,
  ) {
    final byCoord = <String, TunnelRoadData>{};
    for (final road in roads) {
      if (road.gridX < 0 ||
          road.gridX > 8 ||
          road.gridY < 0 ||
          road.gridY > 4) {
        continue;
      }
      byCoord['${road.gridY}:${road.gridX}'] = TunnelRoadData(
        gridX: road.gridX,
        gridY: road.gridY,
        img: '',
      );
    }
    final out = byCoord.values.toList()
      ..sort((a, b) {
        final row = a.gridY.compareTo(b.gridY);
        if (row != 0) return row;
        return a.gridX.compareTo(b.gridX);
      });
    return out;
  }

  String _roadsKey(Iterable<TunnelRoadData> roads) {
    return _normalizeExpeditionRoads(
      roads,
    ).map((r) => '${r.gridY}:${r.gridX}').join('|');
  }

  void _sync() {
    final roads = <TunnelRoadData>[];
    for (var x = 0; x < _gridCols; x++) {
      for (var y = 0; y < _gridRows; y++) {
        final img = _gridState[x][y];
        if (_isExpedition) {
          if (img == _expeditionBlockedMarker) {
            roads.add(TunnelRoadData(gridX: x, gridY: y, img: ''));
          }
        } else if (img != null && img.isNotEmpty) {
          roads.add(TunnelRoadData(gridX: x, gridY: y, img: img));
        }
      }
    }
    if (!_isExpedition) {
      for (final road in _data.roads) {
        if (road.gridX < 0 ||
            road.gridX >= _gridCols ||
            road.gridY < 0 ||
            road.gridY >= _gridRows) {
          roads.add(road);
        }
      }
    }
    _data = TunnelDefendModuleData(
      roads: _isExpedition ? _normalizeExpeditionRoads(roads) : roads,
      brickMapIndex: _isExpedition ? 3 : _data.brickMapIndex,
      tunnelSequenceInterval: _data.tunnelSequenceInterval,
      reportError: _data.reportError,
    );
    _moduleObj.objData = _data.toJson(
      includeTunnelSequenceInterval: !_isExpedition,
    );
    widget.onChanged();
    setState(() {});
  }

  void _handleGridClick(int x, int y) {
    final current = _gridState[x][y];
    if (_isExpedition) {
      _gridState[x][y] = current == _expeditionBlockedMarker
          ? null
          : _expeditionBlockedMarker;
    } else if (current == _selectedImg) {
      _gridState[x][y] = null;
    } else {
      _gridState[x][y] = _selectedImg;
    }
    _sync();
  }

  Future<void> _requestClearAll() async {
    if (_data.roads.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _isExpedition
              ? (l10n?.expeditionTilesClearConfirmTitle ??
                    'Clear all non-plantable tiles?')
              : (l10n?.tunnelDefendClearConfirmTitle ??
                    'Clear all tunnel components?'),
        ),
        content: Text(
          _isExpedition
              ? (l10n?.expeditionTilesClearConfirmMessage ??
                    'Remove all placed non-plantable tiles from the grid. This cannot be undone.')
              : (l10n?.tunnelDefendClearConfirmMessage ??
                    'Remove all placed tunnel components from the grid. This cannot be undone.'),
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
            child: Text(l10n?.tunnelDefendClearAll ?? 'Clear all'),
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

  List<TunnelRoadData> get _roadsOutsideLawn => _data.roads
      .where(
        (r) =>
            r.gridX < 0 ||
            r.gridX >= _gridCols ||
            r.gridY < 0 ||
            r.gridY >= _gridRows,
      )
      .toList();

  bool get _isDefaultLawnSize => _gridRows == 5 && _gridCols == 9;

  String _roadDisplayName(String img) =>
      img.replaceAll('IMAGE_UI_MAUSOLEUM_TUNNEL_', '');

  String _expeditionPresetTitle(AppLocalizations? l10n, String alias) {
    switch (alias) {
      case 'SoudacheTunnelDefendStage1':
        return l10n?.expeditionTilesPresetFloor1 ?? 'Expedition Gate - Floor 1';
      case 'SoudacheTunnelDefendStage2':
        return l10n?.expeditionTilesPresetFloor2 ?? 'Expedition Gate - Floor 2';
      case 'SoudacheTunnelDefendStage3':
        return l10n?.expeditionTilesPresetFloor3 ?? 'Expedition Gate - Floor 3';
      default:
        return alias;
    }
  }

  List<TunnelRoadData> _expeditionPresetRoads(String alias) {
    final objData = ReferenceRepository.instance.objectForAlias(alias)?.objData;
    if (objData is! Map) return const [];
    final data = TunnelDefendModuleData.fromJson(
      Map<String, dynamic>.from(objData),
      defaultReportError: false,
    );
    return _normalizeExpeditionRoads(data.roads);
  }

  String? _currentExpeditionPresetAlias() {
    final currentKey = _roadsKey(_data.roads);
    for (final alias in _expeditionPresetAliases) {
      if (currentKey == _roadsKey(_expeditionPresetRoads(alias))) {
        return alias;
      }
    }
    return null;
  }

  Future<void> _applyExpeditionPreset(String alias) async {
    final targetRoads = _expeditionPresetRoads(alias);
    final currentKey = _roadsKey(_data.roads);
    final targetKey = _roadsKey(targetRoads);
    if (currentKey == targetKey) return;

    var shouldApply = true;
    if (_data.roads.isNotEmpty) {
      final l10n = AppLocalizations.of(context);
      final currentPresetAlias = _currentExpeditionPresetAlias();
      final fromPresetTitle = currentPresetAlias == null
          ? null
          : _expeditionPresetTitle(l10n, currentPresetAlias);
      final toPresetTitle = _expeditionPresetTitle(l10n, alias);
      final message = currentPresetAlias != null
          ? (l10n?.expeditionTilesSwitchPresetBetweenMessage(
                  fromPresetTitle!,
                  toPresetTitle,
                ) ??
                'Switch from "$fromPresetTitle" to "$toPresetTitle"? This will replace the current non-plantable tile layout and cannot be undone.')
          : (l10n?.expeditionTilesSwitchPresetMessage ??
                'Switch to the preset layout? This will remove all placed non-plantable tiles from the lawn and cannot be undone.');
      shouldApply =
          await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(
                l10n?.expeditionTilesSwitchPresetTitle ??
                    'Switch preset layout',
              ),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n?.cancel ?? 'Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n?.switchAction ?? 'Switch'),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (!shouldApply || !mounted) return;

    for (var x = 0; x < _gridCols; x++) {
      for (var y = 0; y < _gridRows; y++) {
        _gridState[x][y] = null;
      }
    }
    for (final road in targetRoads) {
      _gridState[road.gridX][road.gridY] = _expeditionBlockedMarker;
    }
    _sync();
  }

  Widget _buildErrorBanner({
    required ThemeData theme,
    required String title,
    required String message,
  }) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(editorErrorIcon, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportErrorSwitch(
    ThemeData theme,
    AppLocalizations? l10n,
    Color accentColor,
  ) {
    return Card(
      child: SwitchListTile(
        title: Text(l10n?.sodPlantingPromptTitle ?? 'Sod Planting Prompt'),
        subtitle: Text(
          _isExpedition
              ? (l10n?.expeditionTilesSodPromptBody ??
                    'Whether to show a Sod requirement prompt when planting.')
              : (l10n?.tunnelDefendSodPromptBody ??
                    'Whether to show a Sod requirement prompt when planting. Enabled by default.'),
        ),
        value: _data.reportError,
        activeColor: accentColor,
        onChanged: (value) {
          setState(() => _data.reportError = value);
          _moduleObj.objData = _data.toJson(
            includeTunnelSequenceInterval: !_isExpedition,
          );
          widget.onChanged();
        },
      ),
    );
  }

  Widget _buildSettingsWidth(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth < _settingsMaxWidth
                  ? constraints.maxWidth
                  : _settingsMaxWidth,
            ),
            child: SizedBox(width: double.infinity, child: child),
          ),
        );
      },
    );
  }

  Widget _buildExpeditionPresetSelector(
    ThemeData theme,
    AppLocalizations? l10n,
    Color accentColor,
  ) {
    final selectedAlias = _currentExpeditionPresetAlias();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.expeditionTilesPresetLayout ?? 'Preset Layout',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final columns = maxWidth >= 720
                    ? 3
                    : maxWidth >= 460
                    ? 2
                    : 1;
                final chipWidth = (maxWidth - 8 * (columns - 1)) / columns;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final alias in _expeditionPresetAliases)
                      SizedBox(
                        width: chipWidth,
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: _ExpeditionPresetChipLabel(
                            label: _expeditionPresetTitle(l10n, alias),
                            selected: selectedAlias == alias,
                          ),
                          selected: selectedAlias == alias,
                          onSelected: (_) => _applyExpeditionPreset(alias),
                        ),
                      ),
                    if (selectedAlias == null && _data.roads.isNotEmpty)
                      SizedBox(
                        width: chipWidth,
                        child: Chip(
                          label: _ExpeditionPresetChipLabel(
                            label: l10n?.customLayout ?? 'Custom layout',
                            selected: true,
                            icon: Icons.edit,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildGridCellContent(int col, int row, String? imgName) {
    if (_isExpedition) {
      final hasPreviewRoad = _expeditionPreviewRoads.contains((col, row));
      final isBlocked = imgName == _expeditionBlockedMarker;
      if (!hasPreviewRoad && !isBlocked) return null;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (hasPreviewRoad)
            AssetImageWidget(
              assetPath: _expeditionRoadAsset,
              altCandidates: imageAltCandidates(_expeditionRoadAsset),
              fit: BoxFit.cover,
            ),
          if (isBlocked)
            AssetImageWidget(
              assetPath: _expeditionBlockedAsset,
              altCandidates: imageAltCandidates(_expeditionBlockedAsset),
              fit: BoxFit.cover,
            ),
        ],
      );
    }
    if (imgName == null) return null;
    final assetPath = 'assets/images/tunnels/$imgName.webp';
    return AssetImageWidget(
      assetPath: assetPath,
      altCandidates: imageAltCandidates(assetPath),
      fit: BoxFit.contain,
    );
  }

  Future<void> _requestDeleteOutsideLawn() async {
    final outside = _roadsOutsideLawn;
    if (outside.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.tunnelDefendDeleteOutsideConfirmTitle ??
              'Delete path elements outside lawn?',
        ),
        content: Text(
          l10n?.tunnelDefendDeleteOutsideConfirmMessage ??
              'Remove path elements that are outside the 5×9 lawn grid. This cannot be undone.',
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
              l10n?.tunnelDefendDeleteOutside ??
                  'Delete path elements outside lawn',
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) _deleteRoadsOutsideLawn();
  }

  void _deleteRoadsOutsideLawn() {
    final inside = _data.roads
        .where(
          (r) =>
              r.gridX >= 0 &&
              r.gridX < _gridCols &&
              r.gridY >= 0 &&
              r.gridY < _gridRows,
        )
        .toList();
    _data = TunnelDefendModuleData(
      roads: inside,
      brickMapIndex: _data.brickMapIndex,
      tunnelSequenceInterval: _data.tunnelSequenceInterval,
      reportError: _data.reportError,
    );
    _moduleObj.objData = _data.toJson(
      includeTunnelSequenceInterval: !_isExpedition,
    );
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
    final accentColor = _isExpedition
        ? (isDark ? const Color(0xFF006D7A) : const Color(0xFF008FA1))
        : (isDark ? pvzBrownDark : pvzBrownLight);
    final gridBg = _isExpedition
        ? (isDark ? const Color(0xFF102B33) : const Color(0xFFE0F7FA))
        : (isDark ? const Color(0xFF3E2723) : const Color(0xFFEFEBE9));
    const gridBorder = Color(0xFF9E9E9E);

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
          localizedName: _isExpedition
              ? (l10n?.moduleTitle_SouDaCheTunnelDefendDefault ??
                    'Expedition Tiles')
              : resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () {
              showEditorHelpDialog(
                context,
                isEvent: false,
                title: _isExpedition
                    ? (l10n?.expeditionTilesHelpTitle ??
                          'Expedition Tiles Module')
                    : (l10n?.tunnelDefendTitle ?? 'Tunnel defend'),
                themeColor: accentColor,
                sections: _isExpedition
                    ? [
                        HelpSectionData(
                          title: l10n?.overview ?? 'Overview',
                          body:
                              l10n?.expeditionTilesHelpOverview ??
                              'The Expedition Tiles module configures non-plantable areas on Expedition Gate lawns. Planting Sod on a non-plantable tile can restore that tile\'s planting function.',
                        ),
                        HelpSectionData(
                          title:
                              l10n?.expeditionTilesHelpEditing ??
                              'Tile Editing',
                          body:
                              l10n?.expeditionTilesHelpEditingBody ??
                              'Tap a tile on the lawn to add or remove a non-plantable tile. Whirlpool tiles and blank tiles are both plantable areas; the whirlpool tiles here only recreate the initial lawn layout used by this module.',
                        ),
                        HelpSectionData(
                          title:
                              l10n?.expeditionTilesHelpPresets ??
                              'Preset Layouts',
                          body:
                              l10n?.expeditionTilesHelpPresetsBody ??
                              'The editor includes the three official Expedition Gate layouts. Switching presets replaces the current non-plantable tiles.',
                        ),
                        HelpSectionData(
                          title:
                              l10n?.expeditionTilesHelpSodPrompt ??
                              'Planting Prompt',
                          body:
                              l10n?.expeditionTilesHelpSodPromptBody ??
                              'The Sod Planting Prompt controls whether the game shows a Sod requirement prompt on restricted tiles. Expedition Tiles disables this prompt by default.',
                        ),
                        HelpSectionData(
                          title: l10n?.lastStandHelpNotes ?? 'Notes',
                          body:
                              l10n?.expeditionTilesHelpNotesBody ??
                              'Use Expedition Tiles with Expedition Gate lawns. Do not use it with six-row Underwater World lawns.',
                        ),
                      ]
                    : [
                        HelpSectionData(
                          title: l10n?.overview ?? 'Overview',
                          body:
                              l10n?.tunnelDefendHelpOverview ??
                              'Add mausoleum tunnel paths. Some zombies and plants interact with tunnels.',
                        ),
                        HelpSectionData(
                          title: l10n?.tunnelDefendHelpUsage ?? 'Usage',
                          body:
                              l10n?.tunnelDefendHelpUsageBody ??
                              'Select a tunnel piece below, then tap the grid to place. Tap the same piece again to remove. Tap a different piece to replace.',
                        ),
                        HelpSectionData(
                          title:
                              l10n?.tunnelDefendHelpSequenceInterval ??
                              'Sequence interval',
                          body:
                              l10n?.tunnelDefendHelpSequenceIntervalBody ??
                              'Delay between tunnel sequence steps. Lower values make pathways appear faster.',
                        ),
                        HelpSectionData(
                          title:
                              l10n?.expeditionTilesHelpSodPrompt ??
                              'Planting Prompt',
                          body:
                              l10n?.tunnelDefendHelpSodPromptBody ??
                              'The Sod Planting Prompt controls whether the game shows a Sod requirement prompt on restricted tiles. Underground Palace Pathways enables this prompt by default.',
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
            _buildSettingsWidth(
              ModuleAliasInputField(
                rtid: widget.rtid,
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
                accentColor: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            if (_isIncompatibleExpeditionLawn) ...[
              _buildSettingsWidth(
                _buildErrorBanner(
                  theme: theme,
                  title: l10n?.stageMismatch ?? 'Lawn Type Mismatch',
                  message:
                      l10n?.expeditionTilesUnderwaterMismatchWarning ??
                      'The current lawn uses an Underwater World appearance, which is incompatible with the Expedition Tiles module and will cause the level to crash.',
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_isExpedition) ...[
              _buildSettingsWidth(
                _buildExpeditionPresetSelector(theme, l10n, accentColor),
              ),
              const SizedBox(height: 12),
              _buildSettingsWidth(
                _buildReportErrorSwitch(theme, l10n, accentColor),
              ),
            ] else ...[
              _buildSettingsWidth(
                EditorResponsiveInputField(
                  label:
                      l10n?.tunnelDefendTileStylePreset ?? 'Tile style preset',
                  decoration: const InputDecoration(filled: false),
                  builder: (context, decoration) => InputDecorator(
                    key: const ValueKey('tunnelTileStylePresetField'),
                    decoration: decoration,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        itemHeight: null,
                        value: _data.brickMapIndex == 2 ? 2 : 1,
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              l10n?.tunnelDefendTileStylePart1 ?? 'part 1',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              l10n?.tunnelDefendTileStylePart2 ?? 'part 2',
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _data.brickMapIndex = v;
                            _moduleObj.objData = _data.toJson();
                          });
                          widget.onChanged();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsWidth(
                EditorResponsiveInputField(
                  label:
                      l10n?.tunnelDefendSequenceInterval ??
                      'Tunnel sequence interval (TunnelSequenceInterval, seconds)',
                  decoration: const InputDecoration(
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                  builder: (context, decoration) => TextField(
                    key: const ValueKey('tunnelSequenceIntervalField'),
                    controller: _sequenceIntervalCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: decoration,
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null && parsed >= 0) {
                        setState(() => _data.tunnelSequenceInterval = parsed);
                        _moduleObj.objData = _data.toJson();
                        widget.onChanged();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsWidth(
                _buildReportErrorSwitch(theme, l10n, accentColor),
              ),
            ],
            const SizedBox(height: 16),
            Center(
              key: const ValueKey('tunnelLayoutPreviewCenter'),
              child: scaleTableForDesktop(
                context: context,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: AspectRatio(
                    aspectRatio: _gridAspectRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: gridBg,
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
                                  final imgName = _gridState[col][row];
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
                                        child: _buildGridCellContent(
                                          col,
                                          row,
                                          imgName,
                                        ),
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
            ),
            if (!_isExpedition) ...[
              const SizedBox(height: 16),
              Card(
                color: gridBg,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.tunnelDefendSelectComponent ?? 'Select component',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        key: const ValueKey('tunnelComponentGrid'),
                        shrinkWrap: true,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 88,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: _availableAssets.length,
                        itemBuilder: (context, i) {
                          final asset = _availableAssets[i];
                          final isSelected = _selectedImg == asset;
                          return GestureDetector(
                            key: ValueKey('tunnelComponent_$i'),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedImg = asset);
                            },
                            child: Container(
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 4,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: AssetImageWidget(
                                      assetPath:
                                          'assets/images/tunnels/$asset.webp',
                                      altCandidates: imageAltCandidates(
                                        'assets/images/tunnels/$asset.webp',
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Flexible(
                                    flex: 1,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.center,
                                      child: Text(
                                        asset.replaceAll(
                                          'IMAGE_UI_MAUSOLEUM_TUNNEL_',
                                          '',
                                        ),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: isSelected
                                                  ? accentColor
                                                  : theme.colorScheme.onSurface,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              color: gridBg,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EditorResponsiveActionRow(
                  content: Text(
                    '${_isExpedition ? (l10n?.expeditionTilesBlockedCount ?? 'Non-plantable tiles') : (l10n?.tunnelDefendPlacedCount ?? 'Placed')}: ${_data.roads.length}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  action: FilledButton.icon(
                    onPressed: _data.roads.isEmpty ? null : _requestClearAll,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(l10n?.tunnelDefendClearAll ?? 'Clear all'),
                  ),
                ),
              ),
            ),
            if (!_isExpedition &&
                _isDefaultLawnSize &&
                _roadsOutsideLawn.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: gridBg,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditorResponsiveActionRow(
                        content: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    l10n?.tunnelDefendPathOutsideLawn ??
                                    'Path elements outside of the lawn: ',
                              ),
                              TextSpan(
                                text: _roadsOutsideLawn
                                    .map(
                                      (r) =>
                                          '${_roadDisplayName(r.img)} (R${r.gridY + 1}:C${r.gridX + 1})',
                                    )
                                    .join(', '),
                              ),
                            ],
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
                            l10n?.tunnelDefendDeleteOutside ??
                                'Delete path elements outside lawn',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
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

class _ExpeditionPresetChipLabel extends StatelessWidget {
  const _ExpeditionPresetChipLabel({
    required this.label,
    required this.selected,
    this.icon = Icons.check,
  });

  final String label;
  final bool selected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 20,
          child: selected ? Icon(icon, size: 18) : const SizedBox.shrink(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

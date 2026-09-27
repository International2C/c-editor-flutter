import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Pirate plank properties editor. Ported from Z-Editor-master PiratePlankPropertiesEP.kt
class PiratePlankPropertiesScreen extends StatefulWidget {
  const PiratePlankPropertiesScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.levelDef,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final LevelDefinitionData levelDef;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<PiratePlankPropertiesScreen> createState() =>
      _PiratePlankPropertiesScreenState();
}

class _PiratePlankPropertiesScreenState
    extends State<PiratePlankPropertiesScreen> {
  static const _objClass = 'PiratePlankProperties';
  static const _plankAsset = 'assets/images/others/Pirate_Seas_Planks.webp';
  static const _plankColSpan = 4;
  static const _stackedLayoutBreakpoint = 760.0;

  late String _alias;
  late PvzObject _moduleObj;
  late PiratePlankPropertiesData _data;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawn(widget.levelDef, widget.levelFile);
  bool get _isPirateLawn =>
      LevelParser.isPirateLawn(widget.levelDef, widget.levelFile);
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;
  int get _plankColumnStart => _gridCols - _plankColSpan;

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
        objClass: 'PiratePlankProperties',
        objData: PiratePlankPropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = PiratePlankPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = PiratePlankPropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _hasPlank(int row) => _data.plankRows.contains(row);

  void _setPlank(int row, bool value) {
    final rows = List<int>.from(_data.plankRows);
    if (value) {
      if (!rows.contains(row)) {
        rows.add(row);
        rows.sort();
      }
    } else {
      rows.remove(row);
    }
    _data = PiratePlankPropertiesData(plankRows: rows);
    _sync();
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

  Widget _gridCell(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
    );
  }

  Widget _plankStripeCell(ThemeData theme, {required bool showPlank}) {
    return Container(
      margin: const EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
          right: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: showPlank
          ? AssetImageWidget(assetPath: _plankAsset, fit: BoxFit.fill)
          : null,
    );
  }

  Widget _buildPreviewGrid(ThemeData theme, {double desktopScale = 0.6}) {
    final isDark = theme.brightness == Brightness.dark;
    final lawnColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE8E8E8);

    return scaleTableForDesktop(
      context: context,
      desktopScale: desktopScale,
      child: AspectRatio(
        key: const ValueKey('piratePlankPreviewGrid'),
        aspectRatio: _gridCols / _gridRows,
        child: Container(
          decoration: BoxDecoration(
            color: lawnColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: List.generate(_gridRows, (row) {
              final hasPlank = _hasPlank(row);
              return Expanded(
                child: Row(
                  children: [
                    for (var col = 0; col < _plankColumnStart; col++)
                      Expanded(child: _gridCell(theme)),
                    Expanded(
                      flex: _plankColSpan,
                      child: hasPlank
                          ? _plankStripeCell(theme, showPlank: true)
                          : Row(
                              children: List.generate(
                                _plankColSpan,
                                (_) => Expanded(child: _gridCell(theme)),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPlankRowSelector(ThemeData theme, AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(_gridRows, (row) {
        final hasDivider = row < _gridRows - 1;
        return Column(
          children: [
            InkWell(
              onTap: () => _setPlank(row, !_hasPlank(row)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _hasPlank(row),
                      onChanged: (v) => _setPlank(row, v ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      l10n?.rowN(row + 1) ?? 'Row ${row + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasDivider)
              Divider(
                height: 1,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildPlankRowsAndPreview(ThemeData theme, AppLocalizations? l10n) {
    final rowsTitle = _isDeepSeaLawn
        ? (l10n?.plankRowsDeepSea ?? 'Plank rows (0–5)')
        : (l10n?.plankRows ?? 'Plank rows (0–4)');
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final previewTitleStyle = titleStyle?.copyWith(
      color: theme.colorScheme.primary,
    );

    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useStackedLayout =
              constraints.maxWidth < _stackedLayoutBreakpoint;
          final rowSelector = IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(rowsTitle, style: titleStyle),
                const SizedBox(height: 12),
                _buildPlankRowSelector(theme, l10n),
              ],
            ),
          );
          final preview = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l10n?.plankPreview ?? 'Plank preview',
                style: previewTitleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _buildPreviewGrid(
                theme,
                desktopScale: useStackedLayout ? 1 : 0.6,
              ),
            ],
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: useStackedLayout
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: rowSelector,
                      ),
                      const SizedBox(height: 24),
                      preview,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      rowSelector,
                      const SizedBox(width: 24),
                      Expanded(child: preview),
                    ],
                  ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
            if (!_isPirateLawn) ...[
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        editorErrorIcon,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.stageMismatch ?? 'Lawn mismatch',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.currentStageNotPirate ??
                                  'The current lawn is not Pirate Seas. This module may not work correctly and could cause a crash.',
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
              ),
              const SizedBox(height: 16),
            ],
            _buildPlankRowsAndPreview(theme, l10n),
          ],
        ),
      ),
    );
  }
}

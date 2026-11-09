import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Power tile properties. Ported from Z-Editor-master PowerTilePropertiesEP.kt
class PowerTilePropertiesScreen extends StatefulWidget {
  const PowerTilePropertiesScreen({
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
  State<PowerTilePropertiesScreen> createState() =>
      _PowerTilePropertiesScreenState();
}

typedef _GroupInfo = (String id, String label, Color accent, String fileName);

class _PowerTilePropertiesScreenState extends State<PowerTilePropertiesScreen> {
  static const _objClass = 'PowerTileProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late PowerTilePropertiesData _data;
  String _selectedGroup = 'alpha';

  static const List<_GroupInfo> _groups = [
    ('alpha', 'Alpha (Green)', Color(0xFF41FF4B), 'tool_powertile_alpha.png'),
    ('beta', 'Beta (Red)', Color(0xFFFF493A), 'tool_powertile_beta.png'),
    ('gamma', 'Gamma (Cyan)', Color(0xFF3CFFFF), 'tool_powertile_gamma.png'),
    ('delta', 'Delta (Yellow)', Color(0xFFFFE837), 'tool_powertile_delta.png'),
    (
      'epsilon',
      'Epsilon (Purple)',
      Color(0xFFAB47BC),
      'tool_powertile_epsilon.png',
    ),
  ];

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);

  int get _gridCols => _isDeepSeaLawn ? 10 : 9;
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;

  /// Help text: long-press on mobile native, right-click elsewhere.
  bool get _useLongPressQuickEditHint {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return true;
      default:
        return false;
    }
  }

  String _toolPath(String fileName) => 'assets/images/tools/$fileName';

  LinkedTileData? _tileAt(int mx, int my) => _data.linkedTiles.firstWhereOrNull(
    (t) => t.location.mx == mx && t.location.my == my,
  );

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
        objClass: 'PowerTileProperties',
        objData: PowerTilePropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = PowerTilePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = PowerTilePropertiesData();
    }
    _data = PowerTilePropertiesData(linkedTiles: List.from(_data.linkedTiles));
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _removeTileAt(int mx, int my) {
    final newList = _data.linkedTiles
        .where((t) => !(t.location.mx == mx && t.location.my == my))
        .toList();
    _data = PowerTilePropertiesData(linkedTiles: newList);
    _sync();
  }

  void _upsertTile(int mx, int my, String group, double delay) {
    final newList = List<LinkedTileData>.from(_data.linkedTiles);
    newList.removeWhere((t) => t.location.mx == mx && t.location.my == my);
    newList.add(
      LinkedTileData(
        group: group,
        propagationDelay: delay.clamp(0.0, 5.0),
        location: TileLocationData(mx: mx, my: my),
      ),
    );
    _data = PowerTilePropertiesData(linkedTiles: newList);
    _sync();
  }

  /// Single tap: empty → place; same group → remove; other group → replace (keep delay).
  void _handlePrimaryTap(int mx, int my) {
    final existing = _tileAt(mx, my);
    if (existing == null) {
      _upsertTile(mx, my, _selectedGroup, 1.5);
      return;
    }
    if (existing.group == _selectedGroup) {
      _removeTileAt(mx, my);
      return;
    }
    _upsertTile(mx, my, _selectedGroup, existing.propagationDelay);
  }

  void _removeTile(LinkedTileData tile) {
    _removeTileAt(tile.location.mx, tile.location.my);
  }

  void _updateDelay(LinkedTileData tile, double delay) {
    final d = delay.clamp(0.0, 5.0);
    final newList = _data.linkedTiles.map((t) {
      if (t.location.mx == tile.location.mx &&
          t.location.my == tile.location.my) {
        return LinkedTileData(
          group: t.group,
          propagationDelay: d,
          location: t.location,
        );
      }
      return t;
    }).toList();
    _data = PowerTilePropertiesData(linkedTiles: newList);
    _sync();
  }

  void _openCellEditorDialog(int mx, int my) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _CellEditDialog(
        mx: mx,
        my: my,
        groups: _groups,
        existing: _tileAt(mx, my),
        onApply: (group, delay) {
          if (group == null) {
            _removeTileAt(mx, my);
          } else {
            _upsertTile(mx, my, group, delay);
          }
        },
      ),
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
    final accent = theme.colorScheme.primary;
    final sortedTiles = [..._data.linkedTiles]
      ..sort((a, b) {
        final ry = a.location.my.compareTo(b.location.my);
        if (ry != 0) return ry;
        return a.location.mx.compareTo(b.location.mx);
      });

    return Scaffold(
      appBar: AppBar(
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () {
              final quick = _useLongPressQuickEditHint
                  ? (l10n?.powerTileGridHelpSecondaryMobile ?? '')
                  : (l10n?.powerTileGridHelpSecondaryDesktop ?? '');
              showEditorHelpDialog(
                context,
                isEvent: false,
                title: l10n?.powerTile ?? 'Power Tiles',
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body: [
                      l10n?.powerTileHelpOverview ?? '',
                      l10n?.powerTileHelpGridSize ?? '',
                    ].join('\n\n'),
                  ),
                  HelpSectionData(
                    title: l10n?.usage ?? 'Usage',
                    body: [
                      l10n?.powerTileGridHelpPrimary ?? '',
                      if (quick.isNotEmpty)
                        l10n?.powerTileHelpQuickEdit(quick) ?? quick,
                    ].join('\n\n'),
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
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.selectGroup ?? 'Select group',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _groups.map((g) {
                  final isSelected = _selectedGroup == g.$1;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AssetImageWidget(
                            assetPath: _toolPath(g.$4),
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                            altCandidates: imageAltCandidates(_toolPath(g.$4)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(g.$2),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedGroup = g.$1),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.powerTileGridSection ?? 'Power tile grid',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, _) {
                final screenW = MediaQuery.sizeOf(context).width;
                final desktop = isDesktopPlatform(context);
                final maxGridW = desktop
                    ? math.min(720.0, screenW * 0.72)
                    : math.min(560.0, screenW - 32);
                return scaleTableForDesktop(
                  context: context,
                  desktopScale: desktop ? 0.92 : 1.0,
                  child: Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxGridW),
                      child: AspectRatio(
                        // Cells match tool art 130×155 (portrait); was square cells before.
                        aspectRatio: (_gridCols / _gridRows) * (130 / 155),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Column(
                            children: List.generate(_gridRows, (row) {
                              return Expanded(
                                child: Row(
                                  children: List.generate(_gridCols, (col) {
                                    final tile = _tileAt(col, row);
                                    final groupInfo = _groups.firstWhere(
                                      (g) => g.$1 == (tile?.group ?? ''),
                                      orElse: () => _groups.first,
                                    );
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            _handlePrimaryTap(col, row),
                                        onLongPress: _useLongPressQuickEditHint
                                            ? () => _openCellEditorDialog(
                                                col,
                                                row,
                                              )
                                            : null,
                                        onSecondaryTap:
                                            !_useLongPressQuickEditHint
                                            ? () => _openCellEditorDialog(
                                                col,
                                                row,
                                              )
                                            : null,
                                        child: Container(
                                          margin: const EdgeInsets.all(0.5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: tile != null
                                                  ? groupInfo.$3
                                                  : theme.dividerColor,
                                              width: 0.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: tile != null
                                              ? Opacity(
                                                  opacity:
                                                      tile.group ==
                                                          _selectedGroup
                                                      ? 1.0
                                                      : 0.25,
                                                  child: LayoutBuilder(
                                                    builder: (context, c) {
                                                      final dpr =
                                                          MediaQuery.devicePixelRatioOf(
                                                            context,
                                                          );
                                                      final cw =
                                                          (c.maxWidth * dpr)
                                                              .round()
                                                              .clamp(32, 512);
                                                      final ch =
                                                          (c.maxHeight * dpr)
                                                              .round()
                                                              .clamp(32, 512);
                                                      // Use [contain] so wide cells do not crop square art into a thin strip.
                                                      return ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              3,
                                                            ),
                                                        child: AssetImageWidget(
                                                          assetPath: _toolPath(
                                                            groupInfo.$4,
                                                          ),
                                                          width: c.maxWidth,
                                                          height: c.maxHeight,
                                                          fit: BoxFit.contain,
                                                          altCandidates:
                                                              imageAltCandidates(
                                                                _toolPath(
                                                                  groupInfo.$4,
                                                                ),
                                                              ),
                                                          cacheWidth: cw,
                                                          cacheHeight: ch,
                                                        ),
                                                      );
                                                    },
                                                  ),
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
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.powerTileLinkedTilesSection ?? 'Linked tiles',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...sortedTiles.map((tile) {
              final g = _groups.firstWhere(
                (e) => e.$1 == tile.group,
                orElse: () => _groups.first,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 48,
                          height: 58,
                          child: AssetImageWidget(
                            assetPath: _toolPath(g.$4),
                            width: 48,
                            height: 58,
                            fit: BoxFit.contain,
                            altCandidates: imageAltCandidates(_toolPath(g.$4)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${g.$2} · R${tile.location.my + 1} C${tile.location.mx + 1}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 196,
                        child: _PropagationDelayField(
                          key: ValueKey(
                            '${tile.location.mx}_${tile.location.my}_${tile.group}',
                          ),
                          initialDelay: tile.propagationDelay,
                          label:
                              l10n?.powerTilePropagationDelayLabel ??
                              'Propagation delay (s)',
                          tooltip: l10n?.powerTilePropagationDelayTooltip ?? '',
                          accentColor: accent,
                          compact: true,
                          onChanged: (v) => _updateDelay(tile, v),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeTile(tile),
                        tooltip: l10n?.delete ?? 'Delete',
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PropagationDelayField extends StatefulWidget {
  const _PropagationDelayField({
    super.key,
    required this.initialDelay,
    required this.onChanged,
    required this.label,
    required this.tooltip,
    required this.accentColor,
    this.compact = false,
  });

  final double initialDelay;
  final ValueChanged<double> onChanged;
  final String label;
  final String tooltip;
  final Color accentColor;
  final bool compact;

  @override
  State<_PropagationDelayField> createState() => _PropagationDelayFieldState();
}

class _PropagationDelayFieldState extends State<_PropagationDelayField> {
  late TextEditingController _controller;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _fmt(widget.initialDelay));
    _focus = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant _PropagationDelayField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDelay != widget.initialDelay) {
      final t = _fmt(widget.initialDelay);
      if (_controller.text != t) _controller.text = t;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _fmt(double v) {
    if ((v * 100).round() % 100 == 0) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final base = editorInputDecoration(
      context,
      focusColor: widget.accentColor,
      isFocused: _focus.hasFocus,
    );
    final decoration = widget.compact
        ? base.copyWith(
            isDense: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ),
          )
        : base;
    return Tooltip(
      message: widget.tooltip.isNotEmpty ? widget.tooltip : widget.label,
      child: EditorResponsiveInputField(
        label: widget.label,
        decoration: decoration,
        builder: (context, decoration) => TextField(
          controller: _controller,
          focusNode: _focus,
          style: widget.compact ? Theme.of(context).textTheme.bodyMedium : null,
          textAlign: widget.compact ? TextAlign.center : TextAlign.start,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: decoration,
          onChanged: (s) {
            final v = double.tryParse(s.trim());
            if (v != null) widget.onChanged(v.clamp(0.0, 5.0));
          },
        ),
      ),
    );
  }
}

class _CellEditDialog extends StatefulWidget {
  const _CellEditDialog({
    required this.mx,
    required this.my,
    required this.groups,
    required this.existing,
    required this.onApply,
  });

  final int mx;
  final int my;
  final List<_GroupInfo> groups;
  final LinkedTileData? existing;
  final void Function(String? group, double delay) onApply;

  @override
  State<_CellEditDialog> createState() => _CellEditDialogState();
}

class _CellEditDialogState extends State<_CellEditDialog> {
  late String? _group;
  late TextEditingController _delayController;
  late FocusNode _delayFocus;

  @override
  void initState() {
    super.initState();
    _group = widget.existing?.group;
    _delayController = TextEditingController(
      text: _fmtDelay(widget.existing?.propagationDelay ?? 1.5),
    );
    _delayFocus = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _delayController.dispose();
    _delayFocus.dispose();
    super.dispose();
  }

  String _fmtDelay(double v) {
    if ((v * 100).round() % 100 == 0) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return AlertDialog(
    constraints: const BoxConstraints.tightFor(width: 560),
      title: Text(l10n?.powerTileDialogEditCell ?? 'Edit cell'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'R${widget.my + 1} · C${widget.mx + 1}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.powerTileDialogTileGroup ?? 'Tile group',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            DropdownButton<String?>(
              isExpanded: true,
              value: _group,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n?.powerTileDialogNone ?? 'None'),
                ),
                ...widget.groups.map(
                  (g) =>
                      DropdownMenuItem<String?>(value: g.$1, child: Text(g.$2)),
                ),
              ],
              onChanged: (v) => setState(() => _group = v),
            ),
            if (_group != null) ...[
              const SizedBox(height: 12),
              Tooltip(
                message: l10n?.powerTilePropagationDelayTooltip ?? '',
                child: EditorResponsiveInputField(
                  label:
                      l10n?.powerTileDialogPropagationDelay ??
                      'Propagation delay (seconds)',
                  decoration: editorInputDecoration(
                    context,
                    focusColor: accent,
                    isFocused: _delayFocus.hasFocus,
                  ),
                  builder: (context, decoration) => TextField(
                    controller: _delayController,
                    focusNode: _delayFocus,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: decoration,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_group == null) {
              widget.onApply(null, 0);
            } else {
              final parsed = double.tryParse(_delayController.text.trim());
              final delay = (parsed ?? widget.existing?.propagationDelay ?? 1.5)
                  .clamp(0.0, 5.0);
              widget.onApply(_group, delay);
            }
            Navigator.pop(context);
          },
          child: Text(l10n?.confirm ?? 'Confirm'),
        ),
      ],
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/local_scrollbar_region.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;

export 'package:c_editor/widgets/editor_filled_button.dart';
export 'package:c_editor/theme/app_theme.dart'
    show
        editorWarningIcon,
        editorErrorIcon,
        warningBarDark,
        warningBarLight,
        editorWarningBannerBackground,
        editorWarningBannerForeground;

/// Accepts only positive whole numbers while still allowing the field to be
/// cleared temporarily during editing.
class PositiveIntegerInputFormatter extends TextInputFormatter {
  const PositiveIntegerInputFormatter();

  static final RegExp _positiveInteger = RegExp(r'^[1-9][0-9]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _positiveInteger.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Yellow warning card used across editor screens (Settings, modules, events).
class EditorWarningBanner extends StatelessWidget {
  const EditorWarningBanner({
    super.key,
    this.title,
    required this.message,
    this.children = const [],
    this.margin,
  });

  final String? title;
  final String message;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fg = editorWarningBannerForeground(brightness);
    final bodyStyle = TextStyle(color: fg);
    final titleStyle = TextStyle(fontWeight: FontWeight.bold, color: fg);

    return Card(
      margin: margin,
      color: editorWarningBannerBackground(brightness),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(editorWarningIcon, color: fg),
                const SizedBox(width: 8),
                Expanded(
                  child: title != null
                      ? Text(title!, style: titleStyle)
                      : Text(message, style: bodyStyle),
                ),
              ],
            ),
            if (title != null) ...[
              const SizedBox(height: 8),
              Text(message, style: bodyStyle),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Shared hint for event editors that expose ColumnStart / ColumnEnd.
class EventColumnRangeHint extends StatelessWidget {
  const EventColumnRangeHint({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.55,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.eventColumnRangeBoundaryHint ??
              'The lawn’s left edge is column 0 and the right edge is column 9. The start column must be less than the end column.',
          style: style,
          softWrap: true,
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.eventColumnRangeExampleHint ??
              'To spawn from columns n through m, enter n - 1 for the start column and m for the end column.',
          style: style,
          softWrap: true,
        ),
      ],
    );
  }
}

String localizedPropertyLabel(
  BuildContext context,
  String localizedName,
  String codeName,
) {
  return '$localizedName ($codeName)';
}

String localizedSecondsPropertyLabel(
  BuildContext context,
  String localizedName,
  String codeName,
) {
  final l10n = AppLocalizations.of(context);
  return l10n?.propertyLabelSeconds(localizedName, codeName) ??
      '$localizedName ($codeName; seconds)';
}

/// Shared editor UI components. Ported from Z-Editor-master EditorComponents.kt

/// Square add button with rounded corners and + symbol.
/// Used in jittered, groundspawn and similar row-based editors.
/// Green for numbered rows, gray for random row.
class PvzAddButton extends StatelessWidget {
  const PvzAddButton({
    super.key,
    required this.onPressed,
    this.size = 48,
    this.label,
    this.useSecondaryColor = false,
  });

  final VoidCallback onPressed;
  final double size;
  final String? label;

  /// When true, uses gray (surface variant) instead of green (e.g. for random row).
  final bool useSecondaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color bgColor;
    final Color iconColor;
    if (useSecondaryColor) {
      bgColor = theme.colorScheme.surfaceContainerHighest;
      iconColor = theme.colorScheme.onSurfaceVariant;
    } else {
      bgColor = isDark
          ? pvzGreenDark.withValues(alpha: 0.35)
          : const Color(0xFFC8E6C9);
      iconColor = pvzGreenDark;
    }
    final btn = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.add, color: iconColor, size: size * 0.55),
        ),
      ),
    );
    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn,
          if (label!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  label!,
                  softWrap: true,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ],
        ],
      );
    }
    return btn;
  }
}

/// Layout metrics for editor item cards and placement grids on narrow screens.
abstract final class EditorItemCardLayout {
  static const double gridItemCardHeight = 148;

  static bool compact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 400;

  static double cardWidth(BuildContext context, {double base = 100}) =>
      compact(context) ? base * 0.92 : base;

  static double iconSlotSize(BuildContext context, {double base = 64}) =>
      compact(context) ? base * 0.875 : base;

  static double gridPreviewMaxWidth(BuildContext context) =>
      compact(context) ? 360 : 480;

  /// Matches the wider lawn editors used by Tunnel Defend and Expedition
  /// Tiles while still filling the available width on narrow screens.
  static const double placementGridMaxWidth = 560;

  /// Scales +N count badges from rendered lawn cell width (cells are square).
  static double gridCellBadgeScaleForCell(double cellWidth) {
    if (cellWidth <= 0 || !cellWidth.isFinite) return 1.0;
    const referenceCell = 52.0;
    return (cellWidth / referenceCell).clamp(0.4, 1.0);
  }
}

/// A placement-grid card that lets the lawn use the card's full width on
/// narrow screens. The heading keeps the usual inset so only the grid grows.
class EditorPlacementGridCard extends StatelessWidget {
  const EditorPlacementGridCard({
    super.key,
    required this.header,
    required this.grid,
  });

  final Widget header;
  final Widget grid;

  @override
  Widget build(BuildContext context) {
    final compact = EditorItemCardLayout.compact(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 0 : 16,
          16,
          compact ? 0 : 16,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 0),
              child: header,
            ),
            const SizedBox(height: 16),
            grid,
          ],
        ),
      ),
    );
  }
}

/// Keeps related form controls side by side when there is enough room and
/// stacks them when UI scaling leaves the editor with a narrow layout.
class EditorResponsiveFieldRow extends StatefulWidget {
  const EditorResponsiveFieldRow({
    super.key,
    required this.children,
    this.breakpoint = 600,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double breakpoint;
  final double spacing;

  @override
  State<EditorResponsiveFieldRow> createState() =>
      _EditorResponsiveFieldRowState();
}

class _EditorResponsiveFieldRowState extends State<EditorResponsiveFieldRow> {
  final _labelHeightGroup = _EditorResponsiveLabelHeightGroup();

  @override
  void dispose() {
    _labelHeightGroup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fields = widget.children
            .where(
              (child) =>
                  child is! SizedBox ||
                  child.child != null ||
                  child.width == null ||
                  child.height != null,
            )
            .map((child) => child is Flexible ? child.child : child)
            .toList(growable: false);
        final stack = constraints.maxWidth < widget.breakpoint;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < fields.length; i++) ...[
                if (i > 0) SizedBox(height: widget.spacing),
                fields[i],
              ],
            ],
          );
        }
        return _EditorResponsiveLabelHeightScope(
          notifier: _labelHeightGroup,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < fields.length; i++) ...[
                if (i > 0) SizedBox(width: widget.spacing),
                Expanded(child: fields[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A label and its field use separate lines in compact editor layouts.
class EditorResponsiveLabelField extends StatelessWidget {
  const EditorResponsiveLabelField({
    super.key,
    required this.label,
    required this.field,
    this.labelWidth = 120,
    this.breakpoint = 520,
    this.spacing = 12,
  });

  final Widget label;
  final Widget field;
  final double labelWidth;
  final double breakpoint;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              label,
              SizedBox(height: spacing / 2),
              field,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: labelWidth, child: label),
            SizedBox(width: spacing),
            Expanded(child: field),
          ],
        );
      },
    );
  }
}

typedef EditorInputFieldBuilder =
    Widget Function(BuildContext context, InputDecoration decoration);

final Expando<_EditorResponsiveLabelGroup> _editorResponsiveLabelGroups =
    Expando<_EditorResponsiveLabelGroup>('editorResponsiveLabelGroups');
final Expando<_EditorResponsiveLabelHeightGroup>
_editorResponsiveAutomaticLabelHeightGroups =
    Expando<_EditorResponsiveLabelHeightGroup>(
      'editorResponsiveAutomaticLabelHeightGroups',
    );

class _EditorResponsiveLabelGroup extends ChangeNotifier {
  final Map<Object, bool> _overflowByOwner = Map<Object, bool>.identity();
  bool _forceExternal = false;
  bool _notifyScheduled = false;

  bool get forceExternal => _forceExternal;

  void report(Object owner, bool overflows) {
    if (_overflowByOwner[owner] == overflows) return;
    _overflowByOwner[owner] = overflows;
    _recompute();
  }

  void remove(Object owner) {
    if (_overflowByOwner.remove(owner) == null) return;
    _recompute();
  }

  void _recompute() {
    final next = _overflowByOwner.values.any((overflows) => overflows);
    if (next == _forceExternal) return;
    _forceExternal = next;
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      notifyListeners();
    });
  }
}

class _EditorResponsiveLabelHeightGroup extends ChangeNotifier {
  final Map<Object, double> _heightByOwner = Map<Object, double>.identity();
  double _maxHeight = 0;
  bool _notifyScheduled = false;
  bool _disposed = false;

  double get maxHeight => _maxHeight;

  void report(Object owner, double height) {
    if (_heightByOwner[owner] == height) return;
    _heightByOwner[owner] = height;
    _recompute();
  }

  void remove(Object owner) {
    if (_heightByOwner.remove(owner) == null) return;
    _recompute();
  }

  void _recompute() {
    final next = _heightByOwner.values.fold<double>(0, math.max);
    if (next == _maxHeight) return;
    _maxHeight = next;
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      _notifyScheduled = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class _EditorResponsiveLabelHeightScope
    extends InheritedNotifier<_EditorResponsiveLabelHeightGroup> {
  const _EditorResponsiveLabelHeightScope({
    required super.notifier,
    required super.child,
  });

  static _EditorResponsiveLabelHeightGroup? maybeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<_EditorResponsiveLabelHeightScope>()
      ?.notifier;
}

_EditorResponsiveLabelGroup _responsiveLabelGroupFor(Object key) {
  return _editorResponsiveLabelGroups[key] ??= _EditorResponsiveLabelGroup();
}

Element? _nearestHorizontalFieldRow(BuildContext context) {
  Element? result;
  context.visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is Row) {
      result = ancestor;
      return false;
    }
    // Do not group fields across a vertical form boundary. This keeps the
    // automatic alignment local to controls that actually share one row.
    if (widget is Column) return false;
    return true;
  });
  return result;
}

_EditorResponsiveLabelHeightGroup? _automaticLabelHeightGroupFor(
  BuildContext context,
) {
  final row = _nearestHorizontalFieldRow(context);
  if (row == null) return null;
  return _editorResponsiveAutomaticLabelHeightGroups[row] ??=
      _EditorResponsiveLabelHeightGroup();
}

/// Keeps an outlined input label readable at large text scales. Short labels
/// stay in the field; if any label on the same page cannot fit, every field on
/// that page moves its label above so the form remains visually consistent.
class EditorResponsiveInputField extends StatefulWidget {
  const EditorResponsiveInputField({
    super.key,
    required this.label,
    required this.builder,
    this.decoration = const InputDecoration(border: OutlineInputBorder()),
    this.labelSpacing = 8,
    this.externalLabelStyle,
  });

  final String label;
  final EditorInputFieldBuilder builder;
  final InputDecoration decoration;
  final double labelSpacing;
  final TextStyle? externalLabelStyle;

  @override
  State<EditorResponsiveInputField> createState() =>
      _EditorResponsiveInputFieldState();
}

class _EditorResponsiveInputFieldState
    extends State<EditorResponsiveInputField> {
  Object? _groupKey;
  late _EditorResponsiveLabelGroup _group;
  _EditorResponsiveLabelHeightGroup? _heightGroup;
  bool _usesAutomaticHeightGroup = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scopedHeightGroup = _EditorResponsiveLabelHeightScope.maybeOf(
      context,
    );
    final nextUsesAutomaticHeightGroup = scopedHeightGroup == null;
    final nextHeightGroup =
        scopedHeightGroup ?? _automaticLabelHeightGroupFor(context);
    if (!identical(nextHeightGroup, _heightGroup)) {
      if (_usesAutomaticHeightGroup) {
        _heightGroup?.removeListener(_handleHeightGroupChanged);
      }
      _heightGroup?.remove(this);
      _heightGroup = nextHeightGroup;
      _usesAutomaticHeightGroup = nextUsesAutomaticHeightGroup;
      if (_usesAutomaticHeightGroup) {
        _heightGroup?.addListener(_handleHeightGroupChanged);
      }
    }
    final nextKey = Scaffold.maybeOf(context) ?? ModalRoute.of(context) ?? this;
    if (identical(nextKey, _groupKey)) return;
    if (_groupKey != null) {
      _group.removeListener(_handleGroupChanged);
      _group.remove(this);
    }
    _heightGroup?.remove(this);
    _groupKey = nextKey;
    _group = _responsiveLabelGroupFor(nextKey);
    _group.addListener(_handleGroupChanged);
  }

  void _handleGroupChanged() {
    if (mounted) setState(() {});
  }

  void _handleHeightGroupChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (_groupKey != null) {
      _group.removeListener(_handleGroupChanged);
      _group.remove(this);
    }
    if (_usesAutomaticHeightGroup) {
      _heightGroup?.removeListener(_handleHeightGroupChanged);
    }
    _heightGroup?.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final labelStyle =
            widget.decoration.floatingLabelStyle ??
            widget.decoration.labelStyle ??
            theme.inputDecorationTheme.floatingLabelStyle ??
            theme.inputDecorationTheme.labelStyle ??
            theme.textTheme.bodyLarge ??
            const TextStyle(fontSize: 16);
        final reservedWidth =
            48.0 +
            (widget.decoration.prefixIcon == null ? 0 : 48) +
            (widget.decoration.suffixIcon == null ? 0 : 48);
        final availableLabelWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth - reservedWidth
            : double.infinity;
        final labelPainter = TextPainter(
          text: TextSpan(text: widget.label, style: labelStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout(maxWidth: availableLabelWidth > 0 ? availableLabelWidth : 0);
        final labelOverflows = labelPainter.didExceedMaxLines;
        final externalLabelStyle =
            widget.externalLabelStyle ??
            theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ) ??
            labelStyle;
        final externalLabelPainter =
            TextPainter(
              text: TextSpan(text: widget.label, style: externalLabelStyle),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout(
              maxWidth: constraints.hasBoundedWidth
                  ? constraints.maxWidth
                  : double.infinity,
            );
        _group.report(this, labelOverflows);
        _heightGroup?.report(this, externalLabelPainter.height);
        final showExternalLabel = labelOverflows || _group.forceExternal;
        final effectiveDecoration = showExternalLabel
            ? widget.decoration
            : widget.decoration.copyWith(labelText: widget.label);
        final field = widget.builder(context, effectiveDecoration);

        // Keep the input at the same child position while labels move so
        // resizing preserves focus and partially entered, unparsed values.
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: showExternalLabel
                  ? math.max(
                      _heightGroup?.maxHeight ?? 0,
                      externalLabelPainter.height,
                    )
                  : 0,
              child: showExternalLabel
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.label, style: externalLabelStyle),
                    )
                  : null,
            ),
            SizedBox(height: showExternalLabel ? widget.labelSpacing : 0),
            field,
          ],
        );
      },
    );
  }
}

/// Keeps a heading or status label clear of its trailing action. The action
/// moves below the text when a scaled editor no longer has enough width.
class EditorResponsiveActionRow extends StatelessWidget {
  const EditorResponsiveActionRow({
    super.key,
    required this.content,
    required this.action,
    this.breakpoint = 520,
    this.spacing = 12,
    this.compactActionAlignment = Alignment.centerRight,
  });

  final Widget content;
  final Widget action;
  final double breakpoint;
  final double spacing;
  final AlignmentGeometry compactActionAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              SizedBox(height: spacing / 2),
              Align(alignment: compactActionAlignment, child: action),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: content),
            SizedBox(width: spacing),
            action,
          ],
        );
      },
    );
  }
}

/// A switch row that gives long localized labels the full available width on
/// compact surfaces. The switch moves below the label instead of squeezing it
/// into character-by-character wrapping.
class EditorResponsiveSwitchRow extends StatelessWidget {
  const EditorResponsiveSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.breakpoint = 520,
    this.labelKey,
    this.switchKey,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double breakpoint;
  final Key? labelKey;
  final Key? switchKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      toggled: value,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: EditorResponsiveActionRow(
            breakpoint: breakpoint,
            spacing: 8,
            content: Text(
              key: labelKey,
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            action: Switch.adaptive(
              key: switchKey,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

/// A numeric stepper that keeps localized labels readable at large text scales.
///
/// The label and controls stay on one line while there is enough room. On a
/// narrow surface only the controls move below the label, preventing the label
/// from being squeezed into one-character-wide lines.
class EditorResponsiveStepperRow extends StatelessWidget {
  const EditorResponsiveStepperRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.tooltip = '',
    this.min = 0,
    this.max = 100,
    this.breakpoint = 420,
    this.labelStyle,
    this.valueStyle,
    this.labelKey,
    this.controlsKey,
    this.decreaseKey,
    this.increaseKey,
    this.decreaseIcon = Icons.remove_circle_outline,
    this.increaseIcon = Icons.add_circle_outline,
  });

  final String label;
  final String tooltip;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final double breakpoint;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Key? labelKey;
  final Key? controlsKey;
  final Key? decreaseKey;
  final Key? increaseKey;
  final IconData decreaseIcon;
  final IconData increaseIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controls = Row(
      key: controlsKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: decreaseKey,
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: Icon(decreaseIcon),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: valueStyle ?? theme.textTheme.titleMedium,
          ),
        ),
        IconButton(
          key: increaseKey,
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: Icon(increaseIcon),
        ),
      ],
    );

    return Tooltip(
      message: tooltip.isNotEmpty ? tooltip : label,
      child: EditorResponsiveActionRow(
        breakpoint: breakpoint,
        content: Text(
          key: labelKey,
          label,
          style: labelStyle ?? theme.textTheme.bodyLarge,
        ),
        action: controls,
      ),
    );
  }
}

/// +N overlay badge for interactive lawn grid cells.
/// Tight "borderless" pill: background hugs the label with minimal padding.
class GridCellCountBadge extends StatelessWidget {
  const GridCellCountBadge({
    super.key,
    required this.label,
    required this.cellWidth,
  });

  final String label;
  final double cellWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = EditorItemCardLayout.gridCellBadgeScaleForCell(cellWidth);
    final inset = 1.0 * scale;
    return Positioned(
      top: inset,
      right: inset,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topRight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive grid metrics for asset picker screens (tools, grid items, statues).
abstract final class SelectionGridLayout {
  static const double spacing = 12;
  static const double padding = 16;

  static int crossAxisCount(double maxWidth) {
    if (maxWidth >= 1100) return 5;
    if (maxWidth >= 720) return 4;
    if (maxWidth >= 480) return 3;
    return 2;
  }

  static double childAspectRatio(double maxWidth) {
    if (maxWidth >= 720) return 0.72;
    if (maxWidth >= 480) return 0.68;
    return 0.62;
  }

  static double cellWidth(double maxWidth, int crossAxisCount) {
    return (maxWidth - padding * 2 - spacing * (crossAxisCount - 1)) /
        crossAxisCount;
  }

  static double iconSize(double cellWidth) {
    return (cellWidth * 0.82).clamp(80.0, 120.0);
  }

  static int toolCrossAxisCount(double maxWidth) => maxWidth >= 600 ? 4 : 2;

  static double toolChildAspectRatio(double maxWidth) =>
      maxWidth >= 600 ? 0.88 : 0.72;

  static ({double width, double height}) toolIconBox(double maxWidth) {
    if (maxWidth >= 600) {
      return (width: 112, height: 96);
    }
    return (width: 96, height: 80);
  }
}

/// Layout metrics for Renai statue cards and the statue picker grid.
abstract final class RenaiStatueCardLayout {
  static double tileCardWidth(BuildContext context) =>
      EditorItemCardLayout.cardWidth(
        context,
        base: compact(context) ? 156 : 180,
      );

  static double tileIconSize(BuildContext context) =>
      EditorItemCardLayout.iconSlotSize(
        context,
        base: compact(context) ? 84 : 100,
      );

  static int selectionCrossAxisCount(double maxWidth) =>
      SelectionGridLayout.crossAxisCount(maxWidth);

  static double selectionChildAspectRatio(double maxWidth) =>
      SelectionGridLayout.childAspectRatio(maxWidth);

  static double selectionIconSize(double cellWidth) =>
      SelectionGridLayout.iconSize(cellWidth);

  static bool compact(BuildContext context) =>
      EditorItemCardLayout.compact(context);
}

/// Icon header for editor item cards: artwork in a fixed slot, delete control
/// in its own top-right column so it never overlaps scaled icons or badges.
class EditorDeletableIconHeader extends StatelessWidget {
  const EditorDeletableIconHeader({
    super.key,
    required this.icon,
    required this.onDelete,
    required this.deleteTooltip,
    this.iconSize = 64,
    this.height,
  });

  final Widget icon;
  final VoidCallback onDelete;
  final String deleteTooltip;
  final double iconSize;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = EditorItemCardLayout.compact(context);
    final slotSize = EditorItemCardLayout.iconSlotSize(context, base: iconSize);
    final headerHeight = height ?? (slotSize + (compact ? 14 : 16));
    final deleteSize = compact ? 24.0 : 28.0;

    return SizedBox(
      height: headerHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 8, compact ? 2 : 4, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: SizedBox(width: slotSize, height: slotSize, child: icon),
              ),
            ),
            SizedBox(
              width: deleteSize,
              height: deleteSize,
              child: IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, size: compact ? 16 : 18),
                tooltip: deleteTooltip,
                color: theme.colorScheme.onSurfaceVariant,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: BoxConstraints(
                  minWidth: deleteSize,
                  minHeight: deleteSize,
                  maxWidth: deleteSize,
                  maxHeight: deleteSize,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card-sized add button that matches item card dimensions.
/// Used in initial plant/zombie/grid entry screens.
class AddItemCard extends StatelessWidget {
  const AddItemCard({
    super.key,
    required this.onPressed,
    this.width = 100,
    this.minHeight,
  });

  final VoidCallback onPressed;

  /// Card width. Use 140 to match [RenaiModuleScreen] statue cards.
  final double width;

  /// When set, card uses this height and centers the plus button vertically.
  /// Use to align with taller item cards (e.g. Renai statue cards).
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final cardWidth = EditorItemCardLayout.cardWidth(context, base: width);
    final button = PvzAddButton(onPressed: onPressed, size: 56);
    final content = minHeight != null
        ? Center(
            child: SizedBox(
              width: 64,
              height: 64,
              child: Center(child: button),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Center(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: Center(child: button),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: SizedBox.shrink(),
              ),
            ],
          );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: cardWidth, height: minHeight, child: content),
    );
  }
}

/// Tab label colors for category rows on saturated accent headers.
abstract class AccentBarTabBarStyle {
  AccentBarTabBarStyle._();

  static ({Color label, Color unselectedLabel, Color indicator}) colors(
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final indicator = isDark ? const Color(0xFFEEEEEE) : Colors.white;
    return (
      label: Colors.white,
      unselectedLabel: Colors.white.withValues(alpha: isDark ? 0.72 : 0.88),
      indicator: indicator,
    );
  }
}

/// Horizontally scrollable tag/filter row with an overflow affordance.
///
/// The scrollbar thumb remains visible whenever the tags do not fit, so users
/// can discover the remaining options before they try to drag. The caller's
/// bottom padding is expanded while the scrollbar is visible, keeping the
/// thumb clear of chip contents without adding empty space to rows that fit.
class HorizontalTagScroller extends StatefulWidget {
  const HorizontalTagScroller({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.onAccentBar = false,
    this.initialScrollOffset = 0,
    this.onScrollOffsetChanged,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final bool onAccentBar;
  final double initialScrollOffset;
  final ValueChanged<double>? onScrollOffsetChanged;

  @override
  State<HorizontalTagScroller> createState() => _HorizontalTagScrollerState();
}

class _HorizontalTagScrollerState extends State<HorizontalTagScroller> {
  late final ScrollController _scrollController;
  bool _hasOverflow = false;
  bool _overflowCheckScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    )..addListener(_notifyScrollOffsetChanged);
  }

  @override
  void didUpdateWidget(covariant HorizontalTagScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleOverflowCheck();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_notifyScrollOffsetChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _notifyScrollOffsetChanged() {
    if (_scrollController.hasClients) {
      widget.onScrollOffsetChanged?.call(_scrollController.offset);
    }
  }

  void _scheduleOverflowCheck() {
    if (_overflowCheckScheduled) return;
    _overflowCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overflowCheckScheduled = false;
      if (!mounted || !_scrollController.hasClients) return;
      final hasOverflow =
          _scrollController.position.maxScrollExtent >
          _scrollController.position.minScrollExtent;
      if (hasOverflow != _hasOverflow) {
        setState(() => _hasOverflow = hasOverflow);
      }
    });
  }

  bool _handleScrollMetricsNotification(
    ScrollMetricsNotification notification,
  ) {
    if (notification.depth == 0 &&
        notification.metrics.axis == Axis.horizontal) {
      _scheduleOverflowCheck();
    }
    return false;
  }

  void _onPointerScroll(PointerScrollEvent event) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final delta = event.scrollDelta.dx != 0
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    final target = (_scrollController.offset + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != _scrollController.offset) {
      _scrollController.jumpTo(target);
    }
  }

  ScrollbarThemeData _scrollbarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = widget.onAccentBar
        ? (isDark
              ? Colors.white.withValues(alpha: 0.82)
              : theme.colorScheme.onSurface.withValues(alpha: 0.62))
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.72);
    final trackColor = widget.onAccentBar
        ? (isDark
              ? Colors.white.withValues(alpha: 0.14)
              : theme.colorScheme.onSurface.withValues(alpha: 0.12))
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.10);
    return ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(color),
      trackColor: WidgetStateProperty.all(trackColor),
      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
      thickness: WidgetStateProperty.all(6),
      radius: const Radius.circular(4),
      crossAxisMargin: 2,
      mainAxisMargin: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    _scheduleOverflowCheck();
    final keepThumbVisible = _hasOverflow;
    final requestedPadding = widget.padding.resolve(Directionality.of(context));
    final effectivePadding = requestedPadding.copyWith(
      bottom: keepThumbVisible
          ? math.max(requestedPadding.bottom, 16)
          : requestedPadding.bottom,
    );

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleScrollMetricsNotification,
      child: LocalScrollbarRegion(
        child: ScrollbarTheme(
          data: _scrollbarTheme(context),
          child: Scrollbar(
            key: const ValueKey('horizontalTagScrollerScrollbar'),
            controller: _scrollController,
            thumbVisibility: keepThumbVisible,
            interactive: true,
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) _onPointerScroll(event);
              },
              child: ScrollableWithMouseDrag(
                child: SingleChildScrollView(
                  key: const ValueKey('horizontalTagScrollerScrollView'),
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: effectivePadding,
                  child: Row(children: widget.children),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Scrollable filter tab row for saturated accent headers.
/// Matches [TabBar] underline selection and keeps a horizontal scrollbar below
/// whenever labels overflow. Vertical wheel / trackpad scroll moves the row
/// horizontally.
class AccentBarFilterTabRow extends StatefulWidget {
  const AccentBarFilterTabRow({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 46,
    this.scrollbarSlotHeight = 16,
    this.initialScrollOffset = 0,
    this.onScrollOffsetChanged,
    this.onAccentBar = true,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
  });

  final List<Widget> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double height;
  final double scrollbarSlotHeight;
  final double initialScrollOffset;
  final ValueChanged<double>? onScrollOffsetChanged;
  final bool onAccentBar;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;

  @override
  State<AccentBarFilterTabRow> createState() => _AccentBarFilterTabRowState();
}

class _AccentBarFilterTabRowState extends State<AccentBarFilterTabRow> {
  // The scrollbar is 6 px high. Four additional pixels keep it visually
  // separate from the selected tab's 3 px underline.
  static const double _scrollbarUnderlineGap = 10;

  late final ScrollController _scrollController;
  final List<GlobalKey> _tabKeys = [];
  final GlobalKey _scrollViewKey = GlobalKey();
  bool _selectedVisibilityScheduled = false;
  bool _pendingVisibilityOnlyIfNeeded = true;
  bool _pendingCancelActiveScroll = false;

  @override
  void initState() {
    super.initState();
    _syncTabKeys();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    )..addListener(_notifyScrollOffsetChanged);
    _scheduleSelectedTabVisibility();
  }

  @override
  void didUpdateWidget(covariant AccentBarFilterTabRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTabKeys();
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.tabs.length != widget.tabs.length) {
      _scheduleSelectedTabVisibility();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_notifyScrollOffsetChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _notifyScrollOffsetChanged() {
    if (_scrollController.hasClients) {
      widget.onScrollOffsetChanged?.call(_scrollController.offset);
    }
  }

  void _syncTabKeys() {
    while (_tabKeys.length < widget.tabs.length) {
      _tabKeys.add(GlobalKey());
    }
    if (_tabKeys.length > widget.tabs.length) {
      _tabKeys.removeRange(widget.tabs.length, _tabKeys.length);
    }
  }

  void _scheduleSelectedTabVisibility({
    bool onlyIfNeeded = false,
    bool cancelActiveScroll = false,
  }) {
    if (_selectedVisibilityScheduled) {
      _pendingVisibilityOnlyIfNeeded =
          _pendingVisibilityOnlyIfNeeded && onlyIfNeeded;
      _pendingCancelActiveScroll =
          _pendingCancelActiveScroll || cancelActiveScroll;
      return;
    }
    _selectedVisibilityScheduled = true;
    _pendingVisibilityOnlyIfNeeded = onlyIfNeeded;
    _pendingCancelActiveScroll = cancelActiveScroll;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onlyIfNeeded = _pendingVisibilityOnlyIfNeeded;
      final cancelActiveScroll = _pendingCancelActiveScroll;
      _selectedVisibilityScheduled = false;
      _pendingVisibilityOnlyIfNeeded = true;
      _pendingCancelActiveScroll = false;
      if (!mounted || !_scrollController.hasClients) return;
      if (widget.selectedIndex < 0 || widget.selectedIndex >= _tabKeys.length) {
        return;
      }
      final renderObject = _tabKeys[widget.selectedIndex].currentContext
          ?.findRenderObject();
      if (renderObject == null) return;
      final position = _scrollController.position;
      if (cancelActiveScroll) {
        final safeOffset = position.pixels
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble();
        if (position.isScrollingNotifier.value ||
            safeOffset != position.pixels) {
          _scrollController.jumpTo(safeOffset);
        }
      }
      if (onlyIfNeeded && _isFullyVisible(renderObject)) return;
      _scrollController.position.ensureVisible(
        renderObject,
        alignment: 0.5,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  bool _isFullyVisible(RenderObject tabRenderObject) {
    final scrollRenderObject = _scrollViewKey.currentContext
        ?.findRenderObject();
    if (tabRenderObject is! RenderBox || scrollRenderObject is! RenderBox) {
      return false;
    }
    final tabRect = Rect.fromPoints(
      tabRenderObject.localToGlobal(Offset.zero),
      tabRenderObject.localToGlobal(
        tabRenderObject.size.bottomRight(Offset.zero),
      ),
    );
    final viewportRect = Rect.fromPoints(
      scrollRenderObject.localToGlobal(Offset.zero),
      scrollRenderObject.localToGlobal(
        scrollRenderObject.size.bottomRight(Offset.zero),
      ),
    );
    const tolerance = 0.5;
    return tabRect.left >= viewportRect.left - tolerance &&
        tabRect.right <= viewportRect.right + tolerance;
  }

  bool _handleScrollMetricsNotification(
    ScrollMetricsNotification notification,
  ) {
    if (notification.depth == 0 &&
        notification.metrics.axis == Axis.horizontal) {
      _scheduleSelectedTabVisibility(
        onlyIfNeeded: true,
        cancelActiveScroll: true,
      );
    }
    return false;
  }

  void _onPointerScroll(PointerScrollEvent event) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = (_scrollController.offset + event.scrollDelta.dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != _scrollController.offset) {
      _scrollController.jumpTo(target);
    }
  }

  Widget _buildTab(
    int index,
    ({Color label, Color unselectedLabel, Color indicator}) tabColors,
  ) {
    final selected = index == widget.selectedIndex;
    final baseLabelStyle =
        Theme.of(context).textTheme.titleSmall ?? const TextStyle(fontSize: 14);
    final labelStyle = baseLabelStyle.copyWith(
      color: selected ? tabColors.label : tabColors.unselectedLabel,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
    );
    return KeyedSubtree(
      key: _tabKeys[index],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onSelected(index),
          mouseCursor: SystemMouseCursors.click,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            final overlayBase = widget.onAccentBar
                ? Colors.white
                : Theme.of(context).colorScheme.primary;
            if (states.contains(WidgetState.pressed)) {
              return overlayBase.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return overlayBase.withValues(alpha: 0.08);
            }
            return null;
          }),
          child: IntrinsicWidth(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: widget.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Center(
                        child: IconTheme(
                          data: IconThemeData(color: labelStyle.color),
                          child: DefaultTextStyle(
                            style: labelStyle,
                            child: widget.tabs[index],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      key: selected
                          ? const ValueKey('accentBarFilterSelectedIndicator')
                          : null,
                      height: 3,
                      color: selected
                          ? tabColors.indicator
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabRow(
    ({Color label, Color unselectedLabel, Color indicator}) tabColors,
  ) {
    return Row(
      children: [
        for (var i = 0; i < widget.tabs.length; i++) _buildTab(i, tabColors),
      ],
    );
  }

  ScrollbarThemeData _scrollbarTheme(BuildContext context) {
    final color = widget.onAccentBar
        ? Colors.white.withValues(alpha: 0.75)
        : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    final trackColor = widget.onAccentBar
        ? Colors.white.withValues(alpha: 0.18)
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
    return ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(color),
      trackColor: WidgetStateProperty.all(trackColor),
      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
      thickness: WidgetStateProperty.all(6),
      radius: const Radius.circular(4),
      crossAxisMargin: 0,
      mainAxisMargin: 0,
    );
  }

  Widget _buildScrollableRow(
    ({Color label, Color unselectedLabel, Color indicator}) tabColors, {
    bool alignTabsToBottom = false,
  }) {
    Widget row = _buildTabRow(tabColors);
    if (alignTabsToBottom) {
      row = Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: _scrollbarUnderlineGap),
          child: SizedBox(height: widget.height, child: row),
        ),
      );
    }

    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _onPointerScroll(event);
        }
      },
      child: ScrollableWithMouseDrag(
        child: SingleChildScrollView(
          key: _scrollViewKey,
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: row,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaults = widget.onAccentBar
        ? AccentBarTabBarStyle.colors(context)
        : (
            label: Theme.of(context).colorScheme.primary,
            unselectedLabel: Theme.of(context).colorScheme.onSurfaceVariant,
            indicator: Theme.of(context).colorScheme.primary,
          );
    final tabColors = (
      label: widget.labelColor ?? defaults.label,
      unselectedLabel: widget.unselectedLabelColor ?? defaults.unselectedLabel,
      indicator: widget.indicatorColor ?? defaults.indicator,
    );

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleScrollMetricsNotification,
      child: LocalScrollbarRegion(
        child: SizedBox(
          height: widget.height + widget.scrollbarSlotHeight,
          child: ScrollbarTheme(
            data: _scrollbarTheme(context),
            child: Scrollbar(
              key: const ValueKey('accentBarFilterScrollbar'),
              controller: _scrollController,
              thumbVisibility: true,
              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: _buildScrollableRow(tabColors, alignTabsToBottom: true),
            ),
          ),
        ),
      ),
    );
  }
}

/// Keeps a scrollable tab strip visibly scrollable while synchronizing it with
/// a [TabBarView]. The thumb is shown whenever the tab labels overflow.
class PersistentScrollableTabBar extends StatefulWidget {
  const PersistentScrollableTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.height = 72,
    this.scrollbarSlotHeight = 14,
  });

  final TabController controller;
  final List<Widget> tabs;
  final double height;
  final double scrollbarSlotHeight;

  @override
  State<PersistentScrollableTabBar> createState() =>
      _PersistentScrollableTabBarState();
}

class _PersistentScrollableTabBarState
    extends State<PersistentScrollableTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.controller.index;
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PersistentScrollableTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      _selectedIndex = widget.controller.index;
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    final next = widget.controller.index;
    if (next != _selectedIndex && mounted) {
      setState(() => _selectedIndex = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AccentBarFilterTabRow(
      key: const ValueKey('persistentScrollableTopTabs'),
      tabs: widget.tabs,
      selectedIndex: _selectedIndex,
      onSelected: widget.controller.animateTo,
      height: widget.height,
      scrollbarSlotHeight: widget.scrollbarSlotHeight,
      onAccentBar: false,
    );
  }
}

/// Choice chip with explicit selected/unselected colors for accent header bars.
class AccentBarChoiceChip extends StatelessWidget {
  const AccentBarChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.only(right: 8),
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark ? const Color(0xFFEEEEEE) : Colors.white;
    final selectedFg = isDark
        ? const Color(0xFF1B1B1B)
        : const Color(0xFF212121);
    final unselectedBg = Colors.black.withValues(alpha: isDark ? 0.32 : 0.24);
    const unselectedFg = Colors.white;
    final borderColor = selected
        ? (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF9E9E9E))
        : Colors.white.withValues(alpha: isDark ? 0.45 : 0.55);
    final borderWidth = selected ? 1.5 : 1.0;

    return Padding(
      padding: padding,
      child: Material(
        color: selected ? selectedBg : unselectedBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onSelected(true),
          mouseCursor: SystemMouseCursors.click,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return (selected ? selectedFg : unselectedFg).withValues(
                alpha: 0.12,
              );
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return (selected ? selectedFg : unselectedFg).withValues(
                alpha: 0.08,
              );
            }
            return null;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? selectedFg : unselectedFg,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Event chip for wave timeline. Ported from EventChip in EditorComponents.kt
class EventChipWidget extends StatelessWidget {
  const EventChipWidget({
    super.key,
    required this.rtid,
    required this.objectMap,
    required this.onTap,
  });

  final String rtid;
  final Map<String, PvzObject> objectMap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alias = LevelParser.extractAlias(rtid);
    final obj = objectMap[alias];
    final isInvalid = obj == null;
    final meta = EventRegistry.getByObjClass(obj?.objClass);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isInvalid
        ? theme.colorScheme.error
        : (isDark
              ? (meta?.darkColor ?? theme.colorScheme.primary)
              : (meta?.color ?? theme.colorScheme.primary));

    String? summaryText;
    if (!isInvalid) {
      try {
        summaryText = meta?.summaryProvider?.call(obj);
      } catch (_) {}
    }

    final displayLabel = alias;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isInvalid)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.error_outline,
                    size: 14,
                    color: theme.colorScheme.onError,
                  ),
                )
              else if (meta != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    meta.icon,
                    size: 14,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              Flexible(
                child: Text(
                  displayLabel,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (summaryText != null && summaryText.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    summaryText,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A choice row that gives text its own line when icons or actions would squeeze it.
///
/// Place this in a bounded list or an explicitly sized dialog content area.
class EditorOptionTile extends StatelessWidget {
  const EditorOptionTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.enabled = true,
    this.contentPadding = const EdgeInsets.all(12),
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final bool enabled;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = !enabled
        ? theme.disabledColor
        : selected
        ? colors.primary
        : colors.onSurface;
    final scale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(
      1.0,
      2.0,
    );
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultTextStyle(
          style: (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
            color: foreground,
          ),
          child: title,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          DefaultTextStyle(
            style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
              color: enabled ? colors.onSurfaceVariant : theme.disabledColor,
            ),
            child: subtitle!,
          ),
        ],
      ],
    );
    return Semantics(
      button: onTap != null,
      enabled: enabled,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: IconTheme.merge(
            data: IconThemeData(color: foreground),
            child: Padding(
              padding: contentPadding,
              child: _EditorOptionLayout(
                minTextWidth: 120 * scale,
                minRowWidth: leading == null && trailing == null
                    ? 0
                    : (leading != null && trailing != null ? 240 : 180) *
                          (MediaQuery.textScalerOf(context).scale(14) / 14)
                              .clamp(1.0, 2.0),
                textDirection: Directionality.of(context),
                leading: leading ?? const SizedBox.shrink(),
                text: text,
                trailing: trailing ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Unlike LayoutBuilder, this layout also answers the intrinsic height queries
/// made by AlertDialog on short screens, using the same measurements as paint.
class _EditorOptionLayout extends MultiChildRenderObjectWidget {
  _EditorOptionLayout({
    required this.minRowWidth,
    required this.minTextWidth,
    required this.textDirection,
    required Widget leading,
    required Widget text,
    required Widget trailing,
  }) : super(children: [leading, text, trailing]);

  final double minRowWidth;
  final double minTextWidth;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderEditorOptionLayout(minRowWidth, minTextWidth, textDirection);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderEditorOptionLayout renderObject,
  ) {
    renderObject.updateLayout(minRowWidth, minTextWidth, textDirection);
  }
}

class _EditorOptionParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderEditorOptionLayout extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  _RenderEditorOptionLayout(
    this._minRowWidth,
    this._minTextWidth,
    this._textDirection,
  );

  double _minRowWidth;
  double _minTextWidth;
  TextDirection _textDirection;

  void updateLayout(
    double minRowWidth,
    double minTextWidth,
    TextDirection textDirection,
  ) {
    if (_minRowWidth == minRowWidth &&
        _minTextWidth == minTextWidth &&
        _textDirection == textDirection) {
      return;
    }
    _minRowWidth = minRowWidth;
    _minTextWidth = minTextWidth;
    _textDirection = textDirection;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ContainerBoxParentData<RenderBox>) {
      child.parentData = _EditorOptionParentData();
    }
  }

  List<RenderBox> get _children {
    final leading = firstChild!;
    final text = childAfter(leading)!;
    return [leading, text, childAfter(text)!];
  }

  ({Size size, List<Offset> offsets}) _measure(
    double width,
    Size Function(RenderBox, BoxConstraints) measureChild,
  ) {
    final children = _children;
    final loose = BoxConstraints(maxWidth: width);
    final leading = measureChild(children[0], loose);
    final trailing = measureChild(children[2], loose);
    final leadingGap = leading.width > 0 ? 12.0 : 0.0;
    final trailingGap = trailing.width > 0 ? 12.0 : 0.0;
    final remaining =
        width - leading.width - trailing.width - leadingGap - trailingGap;
    final stacked = width < _minRowWidth || remaining < _minTextWidth;
    final text = measureChild(
      children[1],
      BoxConstraints.tightFor(width: stacked ? width : remaining),
    );
    if (!stacked) {
      final height = math.max(
        text.height,
        math.max(leading.height, trailing.height),
      );
      return (
        size: Size(width, height),
        offsets: [
          Offset(0, (height - leading.height) / 2),
          Offset(leading.width + leadingGap, (height - text.height) / 2),
          Offset(width - trailing.width, (height - trailing.height) / 2),
        ],
      );
    }
    final wrapHeader =
        leading.width > 0 &&
        trailing.width > 0 &&
        leading.width + trailing.width + 12 > width;
    final headerHeight = wrapHeader
        ? leading.height + 8 + trailing.height
        : math.max(leading.height, trailing.height);
    final textTop = headerHeight + (headerHeight > 0 ? 8 : 0);
    return (
      size: Size(width, textTop + text.height),
      offsets: [
        Offset.zero,
        Offset(0, textTop),
        wrapHeader
            ? Offset(0, leading.height + 8)
            : Offset(width - trailing.width, 0),
      ],
    );
  }

  double _width(BoxConstraints constraints) => constraints.hasBoundedWidth
      ? constraints.maxWidth
      : math.max(
          constraints.minWidth,
          computeMaxIntrinsicWidth(double.infinity),
        );

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(
    _measure(
      _width(constraints),
      (child, constraints) => child.getDryLayout(constraints),
    ).size,
  );

  @override
  double computeMinIntrinsicWidth(double height) => _children
      .map((child) => child.getMinIntrinsicWidth(height))
      .reduce(math.max);

  @override
  double computeMaxIntrinsicWidth(double height) {
    final widths = _children
        .map((child) => child.getMaxIntrinsicWidth(height))
        .toList();
    return widths.reduce((a, b) => a + b) +
        (widths[0] > 0 ? 12 : 0) +
        (widths[2] > 0 ? 12 : 0);
  }

  double _intrinsicHeight(double width) => _measure(
    width.isFinite ? width : computeMaxIntrinsicWidth(double.infinity),
    (child, constraints) => child.getDryLayout(constraints),
  ).size.height;

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  void performLayout() {
    final layout = _measure(_width(constraints), (child, constraints) {
      child.layout(constraints, parentUsesSize: true);
      return child.size;
    });
    size = constraints.constrain(layout.size);
    final children = _children;
    for (var i = 0; i < children.length; i++) {
      final offset = layout.offsets[i];
      (children[i].parentData! as ContainerBoxParentData<RenderBox>).offset =
          _textDirection == TextDirection.ltr
          ? offset
          : Offset(size.width - offset.dx - children[i].size.width, offset.dy);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// Bounded content for a popup menu's intrinsic width measurement.
class EditorPopupMenuTile extends StatelessWidget {
  const EditorPopupMenuTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.enabled = true,
    this.contentPadding = EdgeInsets.zero,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool enabled;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: EditorOptionTile(
      enabled: enabled,
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      contentPadding: contentPadding,
    ),
  );
}

/// A rich, reusable choice shown in editor add-content dialogs.
class EditorChoiceDialogOption<T> {
  const EditorChoiceDialogOption({
    required this.value,
    required this.icon,
    required this.title,
    this.subtitle,
    this.key,
  });

  final T value;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Key? key;
}

/// Shows add-content choices as descriptive cards instead of plain text rows.
Future<T?> showEditorChoiceDialog<T>(
  BuildContext context, {
  required String title,
  required List<EditorChoiceDialogOption<T>> options,
  Key? dialogKey,
  String? message,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final colors = theme.colorScheme;
      final l10n = AppLocalizations.of(ctx);
      final compact = MediaQuery.sizeOf(ctx).width < 400;
      return AlertDialog(
        key: dialogKey,
        scrollable: true,
        insetPadding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 40,
          vertical: 24,
        ),
        titlePadding: EdgeInsets.fromLTRB(
          compact ? 16 : 24,
          compact ? 20 : 24,
          compact ? 16 : 24,
          12,
        ),
        contentPadding: EdgeInsets.fromLTRB(
          compact ? 12 : 24,
          0,
          compact ? 12 : 24,
          0,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message?.trim().isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(message!),
                  ),
                ),
              for (final option in options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    key:
                        option.key ??
                        ValueKey('editorChoiceOption_${option.value}'),
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.65,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: EditorOptionTile(
                      onTap: () => Navigator.pop(ctx, option.value),
                      contentPadding: EdgeInsets.all(compact ? 12 : 14),
                      leading: Container(
                        width: compact ? 44 : 48,
                        height: compact ? 44 : 48,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          option.icon,
                          color: colors.onPrimaryContainer,
                          size: 27,
                        ),
                      ),
                      title: Text(
                        option.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: option.subtitle?.trim().isNotEmpty == true
                          ? Text(
                              option.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.3,
                              ),
                            )
                          : null,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          compact ? 16 : 24,
          8,
          compact ? 16 : 24,
          16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
        ],
      );
    },
  );
}

/// Help dialog for editor screens.
void showEditorHelpDialog(
  BuildContext context, {
  required String title,
  required List<HelpSectionData> sections,
  Color? themeColor,
  bool? isEvent,
  bool useNeutralSectionTitles = false,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx);
      final confirmLabel =
          l10n?.helpDialogGotIt ?? MaterialLocalizations.of(ctx).okButtonLabel;
      final displayTitle = isEvent == null
          ? title
          : _standardizeEditorHelpTitle(ctx, title, isEvent: isEvent);
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: themeColor ?? Theme.of(ctx).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                displayTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: sections
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${s.title}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: useNeutralSectionTitles
                                ? Theme.of(ctx).colorScheme.onSurface
                                : themeColor ??
                                      Theme.of(ctx).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            s.body,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: themeColor ?? Theme.of(ctx).colorScheme.primary,
              ),
            ),
          ),
        ],
      );
    },
  );
}

String _standardizeEditorHelpTitle(
  BuildContext context,
  String title, {
  required bool isEvent,
}) {
  final languageCode = Localizations.localeOf(context).languageCode;
  var base = title.trim();

  switch (languageCode) {
    case 'zh':
      base = base
          .replaceFirst(RegExp(r'^事件类型\s*[：:]\s*'), '')
          .replaceFirst(RegExp(r'(模块说明|事件说明|模块|事件|说明|帮助)$'), '')
          .trim();
      return '$base${isEvent ? '事件说明' : '模块说明'}';
    case 'ru':
      base = base
          .replaceFirst(
            RegExp(
              r'^(?:Справка\s+по\s+)?(?:Модуль|Событие)\s*[:：]?\s*',
              caseSensitive: false,
            ),
            '',
          )
          .replaceFirst(
            RegExp(
              r'\s+(?:module|event|модуль|событие)$',
              caseSensitive: false,
            ),
            '',
          )
          .replaceAll(RegExp(r'^[«"]|[»"]$'), '')
          .trim();
      return '${isEvent ? 'Событие' : 'Модуль'} «$base»';
    default:
      base = base
          .replaceFirst(RegExp(r'^event\s*[:：]\s*', caseSensitive: false), '')
          .replaceFirst(
            RegExp(
              r'\s+(?:module|event)(?:\s+(?:help|guide|instructions))?$',
              caseSensitive: false,
            ),
            '',
          )
          .replaceFirst(
            RegExp(r'\s+(?:help|guide|instructions)$', caseSensitive: false),
            '',
          )
          .trim();
      return '$base ${isEvent ? 'event' : 'module'}';
  }
}

class HelpSectionData {
  const HelpSectionData({required this.title, required this.body});
  final String title;
  final String body;
}

const _kWaveDropConfigTitleIconSize = 32.0;
const _kPlantDropIconCardSize = 56.0;
const _kPlantFoodIconPath = 'assets/images/others/plantfood.webp';
const _kPlantDropTagIconPath =
    'assets/images/tags/plants/rarity/Plant_Green.webp';

/// Plant drop token: icon plus a full-height remove strip (easier to tap than a
/// corner overlay on a small square).
class PlantDropIconCard extends StatelessWidget {
  const PlantDropIconCard({
    super.key,
    required this.iconPath,
    required this.onDelete,
    this.label,
    this.size = _kPlantDropIconCardSize,
  });

  final String? iconPath;
  final String? label;
  final VoidCallback onDelete;
  final double size;

  static const _removeStripWidth = 44.0;
  static const _maxLabelWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final removeHint = label != null && label!.isNotEmpty
        ? '${l10n.remove} $label'
        : l10n.remove;

    final chipRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: iconPath != null && iconPath!.isNotEmpty
                  ? AssetImageWidget(
                      assetPath: iconPath!,
                      altCandidates: imageAltCandidates(iconPath!),
                      width: size - 8,
                      height: size - 8,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        Icons.local_florist,
                        size: 24,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
        ),
        if (label != null && label!.isNotEmpty)
          Tooltip(
            message: label!,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxLabelWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        Tooltip(
          message: removeHint,
          child: Semantics(
            button: true,
            label: removeHint,
            child: Material(
              color: theme.colorScheme.surfaceContainerHighest,
              child: InkWell(
                onTap: onDelete,
                child: SizedBox(
                  width: _removeStripWidth,
                  height: size,
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 22,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: size,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: chipRow,
        ),
      ),
    );
  }
}

/// Plant food / carried-plant drop settings for jittered and fish wave events.
class WaveDropConfigCard extends StatelessWidget {
  const WaveDropConfigCard({
    super.key,
    required this.totalDropCount,
    required this.plants,
    required this.zombieCount,
    required this.onTotalDropCountChanged,
    required this.onRemovePlantAt,
    this.onAddPlant,
  });

  /// [AdditionalPlantfood] — total zombies carrying any drop (plant food and/or plants).
  final int totalDropCount;
  final List<String> plants;
  final int zombieCount;
  final ValueChanged<int> onTotalDropCountChanged;
  final ValueChanged<int> onRemovePlantAt;
  final VoidCallback? onAddPlant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final plantColor = isDark ? pvzGreenLight : pvzGreenDark;
    final plantCount = plants.length;
    final hasSeedPacketDrops = plantCount > 0;
    final plantFoodOnlyCount = (totalDropCount - plantCount).clamp(
      0,
      totalDropCount,
    );
    final hasMixedDrops = hasSeedPacketDrops && plantFoodOnlyCount > 0;
    final dropConfigTitle = hasMixedDrops
        ? l10n.waveDropConfigTitle
        : hasSeedPacketDrops
        ? l10n.dropConfigPlants
        : l10n.dropConfigPlantFood;
    final canIncreaseTotal = totalDropCount < zombieCount;
    final canAddPlant =
        onAddPlant != null &&
        zombieCount > 0 &&
        totalDropCount > 0 &&
        plantCount < totalDropCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  key: const ValueKey('waveDropConfigTitleIcon'),
                  hasSeedPacketDrops ? Icons.local_florist : Icons.eco,
                  size: _kWaveDropConfigTitleIconSize,
                  color: plantColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    key: const ValueKey('waveDropConfigTitle'),
                    dropConfigTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final counterRow = Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: const Icon(Icons.remove),
                      onPressed: totalDropCount > 0
                          ? () => onTotalDropCountChanged(totalDropCount - 1)
                          : null,
                    ),
                    Text('$totalDropCount', style: theme.textTheme.titleMedium),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: const Icon(Icons.add),
                      onPressed: canIncreaseTotal
                          ? () => onTotalDropCountChanged(totalDropCount + 1)
                          : null,
                    ),
                  ],
                );
                final counterControls = FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: counterRow,
                );
                final labelText = Text(
                  l10n.waveDropTotalLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                );

                if (constraints.maxWidth < 280) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      labelText,
                      const SizedBox(height: 4),
                      counterControls,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: labelText),
                    counterControls,
                  ],
                );
              },
            ),
            if (zombieCount == 0) ...[
              const SizedBox(height: 8),
              Text(
                l10n.waveDropAddZombiesFirst,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else if (totalDropCount > 0) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (plantFoodOnlyCount > 0)
                    _DropCountBadge(
                      iconPath: _kPlantFoodIconPath,
                      label: l10n.waveDropPlantFoodOnlyCount(
                        plantFoodOnlyCount,
                      ),
                    ),
                  if (plantCount > 0)
                    _DropCountBadge(
                      iconPath: _kPlantDropTagIconPath,
                      label: l10n.waveDropPlantsCount(plantCount),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              key: const ValueKey('waveDropPlantSelectionLabel'),
              l10n.waveDropPlantSelectionLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...plants.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final id = entry.value;
                  final info = PlantRepository().getPlantInfoById(id);
                  final iconPath = info?.iconAssetPath;
                  final localizedName = ResourceNames.lookup(
                    context,
                    PlantRepository().getName(id),
                  );
                  return PlantDropIconCard(
                    iconPath: iconPath,
                    label: localizedName,
                    onDelete: () => onRemovePlantAt(idx),
                  );
                }),
                if (onAddPlant != null)
                  Opacity(
                    opacity: canAddPlant ? 1 : 0.38,
                    child: IgnorePointer(
                      ignoring: !canAddPlant,
                      child: PvzAddButton(
                        onPressed: onAddPlant!,
                        size: _kPlantDropIconCardSize,
                      ),
                    ),
                  ),
              ],
            ),
            if (onAddPlant != null &&
                totalDropCount == 0 &&
                zombieCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                l10n.waveDropIncreaseTotalBeforePlants,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DropCountBadge extends StatelessWidget {
  const _DropCountBadge({required this.iconPath, required this.label});

  final String iconPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const iconSize = 20.0;
        const gap = 6.0;
        const horizontalPadding = 20.0;
        final maxWidth =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity;
        final maxLabelWidth = math.max(
          0.0,
          maxWidth - iconSize - gap - horizontalPadding,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: AssetImageWidget(
                  assetPath: iconPath,
                  altCandidates: imageAltCandidates(iconPath),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: gap),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxLabelWidth),
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Fish icon card with blue C (custom) badge. Similar to ZombieIconCard.
class FishIconCard extends StatelessWidget {
  const FishIconCard({
    super.key,
    required this.iconPath,
    required this.isCustom,
    required this.onTap,
    this.size = 56,
  });

  final String? iconPath;
  final bool isCustom;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (iconPath != null && iconPath!.isNotEmpty)
                  AssetImageWidget(
                    assetPath: iconPath!,
                    altCandidates: imageAltCandidates(iconPath!),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                else
                  Center(
                    child: Icon(
                      Icons.water,
                      size: 24,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (isCustom)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1976D2)
                            : const Color(0xFF42A5F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'C',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Zombie icon card with custom badge top-left and level badge top-right.
/// Reused by jittered, storm, grid item spawn and similar zombie editors.
class ZombieIconCard extends StatelessWidget {
  const ZombieIconCard({
    super.key,
    required this.iconPath,
    required this.levelDisplay,
    required this.isElite,
    required this.isCustom,
    required this.onTap,
    this.size = 56,
    this.showLevelBadge = true,
    this.isMissingCustomZombie = false,
  });

  final String? iconPath;
  final String levelDisplay;
  final bool isElite;
  final bool isCustom;
  final VoidCallback onTap;
  final double size;
  final bool showLevelBadge;
  final bool isMissingCustomZombie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = iconPath?.trim();
    final effectivePath = path == null || path.isEmpty
        ? 'assets/images/others/unknown.webp'
        : path;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isMissingCustomZombie)
                  Center(
                    child: Icon(
                      Icons.warning,
                      size: 24,
                      color: theme.colorScheme.error,
                    ),
                  )
                else
                  AssetImageWidget(
                    assetPath: effectivePath,
                    altCandidates: imageAltCandidates(effectivePath),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  ),
                if (isCustom)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: pvzOrangeLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'C',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (showLevelBadge)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.9,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        levelDisplay,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Clickable zombie identity row for spawn edit bottom sheets (icon, name, custom tag, change).
class ZombieEditSheetIdentityTile extends StatelessWidget {
  const ZombieEditSheetIdentityTile({
    super.key,
    required this.iconPath,
    required this.displayName,
    required this.isCustom,
    required this.onChange,
    this.customLabel = 'Custom',
  });

  final String? iconPath;
  final String displayName;
  final bool isCustom;
  final VoidCallback onChange;
  final String customLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onChange,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (iconPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AssetImageWidget(
                    assetPath: iconPath!,
                    altCandidates: imageAltCandidates(iconPath!),
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      softWrap: true,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCustom)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: pvzOrangeLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            customLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool isDesktopPlatform(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.windows ||
      platform == TargetPlatform.macOS ||
      platform == TargetPlatform.linux;
}

Widget scaleTableForDesktop({
  required BuildContext context,
  required Widget child,
  double desktopScale = 0.6,
}) {
  if (!isDesktopPlatform(context)) return child;
  return LayoutBuilder(
    builder: (context, constraints) {
      final viewportWidth = MediaQuery.sizeOf(context).width;
      final availableWidth = constraints.maxWidth;
      final useFullWidth =
          viewportWidth < 720 ||
          (availableWidth.isFinite && availableWidth < 720);
      return Center(
        child: FractionallySizedBox(
          widthFactor: useFullWidth ? 1 : desktopScale,
          child: child,
        ),
      );
    },
  );
}

/// Input decoration for editor screens.
/// When not focused: border and label (including floating label) use theme onSurface.
/// When focused and [focusColor] set: border and floating label use [focusColor].
/// Pass [isFocused] from the field's FocusNode so the floating label only uses [focusColor] when focused.
InputDecoration editorInputDecoration(
  BuildContext context, {
  String? labelText,
  String? hintText,
  Color? focusColor,
  bool isFocused = false,
  bool filled = false,
  Color? fillColor,
}) {
  final theme = Theme.of(context);
  final unfocusedColor = theme.colorScheme.onSurface;
  final baseDecoration = InputDecoration(
    labelText: labelText,
    hintText: hintText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    border: const OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: unfocusedColor.withValues(alpha: 0.6)),
    ),
    labelStyle: TextStyle(color: unfocusedColor, height: 1.2),
    hintStyle: TextStyle(
      color: unfocusedColor.withValues(alpha: 0.7),
      height: 1.2,
    ),
    filled: filled,
    fillColor: fillColor,
  );
  if (focusColor == null) return baseDecoration;
  return baseDecoration.copyWith(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: focusColor, width: 2),
    ),
    floatingLabelStyle: TextStyle(
      color: isFocused ? focusColor : unfocusedColor,
      height: 1.2,
    ),
    focusColor: focusColor,
  );
}

/// Icon for grid items. Use anywhere grid item icons are displayed.
class GridItemIcon extends StatelessWidget {
  const GridItemIcon({
    super.key,
    required this.typeName,
    this.size = 40,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
  });

  final String typeName;
  final double size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;
    final path = GridItemRepository.getIconPath(typeName);
    final effectiveFit = GridItemRepository.isRenaiStatue(typeName)
        ? BoxFit.contain
        : fit;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AssetImageWidget(
        assetPath: path,
        width: w,
        height: h,
        fit: effectiveFit,
        altCandidates: imageAltCandidates(path),
      ),
    );
  }
}

/// Alias for [GridItemIcon] when used for Renai statues. Maintains backward compatibility.
class RenaiStatueIcon extends StatelessWidget {
  const RenaiStatueIcon({
    super.key,
    required this.typeName,
    this.size = 40,
    this.fit = BoxFit.contain,
  });

  final String typeName;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) =>
      GridItemIcon(typeName: typeName, size: size, fit: fit);
}

/// Default [MaterialScrollBehavior] omits [PointerDeviceKind.mouse], so horizontal
/// [TabBar]s and nested scroll views do not respond to click-drag on desktop.
/// Vertically centered search field for colored app bar titles (light text).
class AppBarSearchField extends StatefulWidget {
  const AppBarSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.query = '',
    this.onClear,
    this.foregroundColor = Colors.white,
    this.borderRadius = 0,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final String query;
  final VoidCallback? onClear;
  final Color foregroundColor;
  final double borderRadius;

  @override
  State<AppBarSearchField> createState() => _AppBarSearchFieldState();
}

class _AppBarSearchFieldState extends State<AppBarSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant AppBarSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.foregroundColor.withValues(alpha: 0.9);
    final hintColor = widget.foregroundColor.withValues(alpha: 0.75);
    final border = widget.borderRadius > 0
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,
          )
        : InputBorder.none;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: widget.foregroundColor, height: 1.2),
      cursorColor: widget.foregroundColor,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: hintColor, height: 1.2),
        prefixIcon: Icon(Icons.search, color: iconColor),
        suffixIcon: widget.query.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: iconColor),
                onPressed: widget.onClear,
              )
            : null,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        filled: true,
        fillColor: widget.foregroundColor.withValues(alpha: 0.18),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        isDense: true,
      ),
    );
  }
}

/// Search field for selection screens (module, plant, zombie, dialogs, etc.).
class SelectionSearchField extends StatefulWidget {
  const SelectionSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.query = '',
    this.onClear,
    this.controller,
    this.fillColor,
    this.foregroundColor,
    this.focusedBorderColor,
    this.borderRadius = 24,
    this.useOutlineBorder = false,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final String query;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final Color? fillColor;
  final Color? foregroundColor;

  /// Accent used for the focus ring. Defaults to the theme primary, but
  /// screens with a non-primary app-bar accent (e.g. the purple zombie
  /// selector) should pass their accent so the ring flows with the app bar.
  final Color? focusedBorderColor;
  final double borderRadius;
  final bool useOutlineBorder;

  @override
  State<SelectionSearchField> createState() => _SelectionSearchFieldState();
}

class _SelectionSearchFieldState extends State<SelectionSearchField> {
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController(text: widget.query);
    }
  }

  @override
  void didUpdateWidget(covariant SelectionSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _internalController?.dispose();
      _internalController = widget.controller == null
          ? TextEditingController(text: widget.query)
          : null;
    }
    final controller = _effectiveController;
    if (widget.query != controller.text) {
      controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = widget.foregroundColor ?? theme.colorScheme.onSurface;
    final hintColor = widget.foregroundColor != null
        ? widget.foregroundColor!.withValues(alpha: 0.75)
        : (isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.65)
              : theme.colorScheme.onSurface.withValues(alpha: 0.55));
    final iconColor = widget.foregroundColor != null
        ? widget.foregroundColor!.withValues(alpha: 0.9)
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final bg =
        widget.fillColor ??
        (widget.foregroundColor != null
            ? widget.foregroundColor!.withValues(alpha: 0.18)
            : theme.colorScheme.surfaceContainerHighest);

    InputBorder border;
    if (widget.useOutlineBorder) {
      border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
        ),
      );
    } else {
      border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide.none,
      );
    }

    return TextField(
      controller: _effectiveController,
      onChanged: widget.onChanged,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: textColor, height: 1.2),
      cursorColor: textColor,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: hintColor, height: 1.2),
        prefixIcon: Icon(Icons.search, color: iconColor),
        suffixIcon: widget.query.isNotEmpty && widget.onClear != null
            ? IconButton(
                icon: Icon(Icons.clear, color: iconColor),
                onPressed: widget.onClear,
              )
            : null,
        filled: true,
        fillColor: bg,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        isDense: true,
        border: border,
        enabledBorder: border,
        focusedBorder: widget.useOutlineBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.focusedBorderColor ?? theme.colorScheme.primary,
                  width: 1.5,
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color:
                      widget.focusedBorderColor ??
                      widget.foregroundColor ??
                      theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
      ),
    );
  }
}

class MouseDragScrollBehavior extends MaterialScrollBehavior {
  const MouseDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

/// Applies [MouseDragScrollBehavior] to [child] (e.g. filter strips with [TabBar]).
class ScrollableWithMouseDrag extends StatelessWidget {
  const ScrollableWithMouseDrag({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const MouseDragScrollBehavior(),
      child: child,
    );
  }
}

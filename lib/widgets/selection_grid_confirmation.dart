import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Keeps confirmation floating and clears covered items at the grid's end.
class SelectionGridConfirmation extends StatelessWidget {
  const SelectionGridConfirmation({
    super.key,
    required this.builder,
    required this.itemCount,
    required this.gridDelegate,
    this.gridPadding = const EdgeInsets.all(12),
    this.confirmation,
    this.selectAll,
  });

  final Widget Function(BuildContext context, EdgeInsets gridPadding) builder;
  final int itemCount;
  final SliverGridDelegate gridDelegate;
  final EdgeInsets gridPadding;

  /// Primary confirm action (typically a [FloatingActionButton]).
  final Widget? confirmation;

  /// Optional control placed to the left (start) of [confirmation].
  final Widget? selectAll;

  static const _buttonSize = 56.0;
  static const _margin = 16.0;
  static const _rowGap = 12.0;

  @override
  Widget build(BuildContext context) {
    final button = confirmation;
    final selectAllControl = selectAll;
    if (button == null && selectAllControl == null) {
      return builder(context, gridPadding);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final safePadding = MediaQuery.paddingOf(context);
        final bottomInset = safePadding.bottom;
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final endMargin =
            _margin + (isRtl ? safePadding.left : safePadding.right);

        final hasSelectAll = selectAllControl != null;
        final hasConfirm = button != null;
        // Select-all chip (~label width) + gap + FAB.
        final stackWidth =
            (hasSelectAll ? 140.0 : 0.0) +
            (hasSelectAll && hasConfirm ? _rowGap : 0.0) +
            (hasConfirm ? _buttonSize : 0.0);
        final stackHeight = _buttonSize;

        final buttonRect = Rect.fromLTWH(
          isRtl ? endMargin : size.width - endMargin - stackWidth,
          size.height - bottomInset - _margin - stackHeight,
          stackWidth,
          stackHeight,
        );
        var needsClearance = false;
        if (itemCount > 0 && size.isFinite) {
          final layout = gridDelegate.getLayout(
            SliverConstraints(
              axisDirection: AxisDirection.down,
              growthDirection: GrowthDirection.forward,
              userScrollDirection: ScrollDirection.idle,
              scrollOffset: 0,
              precedingScrollExtent: 0,
              overlap: 0,
              remainingPaintExtent: size.height,
              crossAxisExtent: math.max(0, size.width - gridPadding.horizontal),
              crossAxisDirection: isRtl
                  ? AxisDirection.left
                  : AxisDirection.right,
              viewportMainAxisExtent: size.height,
              remainingCacheExtent: size.height,
              cacheOrigin: 0,
            ),
          );
          final contentHeight =
              layout.computeMaxScrollOffset(itemCount) + gridPadding.vertical;
          final endOffset = math.max(0, contentHeight - size.height);
          for (var index = itemCount - 1; index >= 0; index--) {
            final item = layout.getGeometryForChildIndex(index);
            final itemRect = Rect.fromLTWH(
              gridPadding.left + item.crossAxisOffset,
              gridPadding.top + item.scrollOffset - endOffset,
              item.crossAxisExtent,
              item.mainAxisExtent,
            );
            if (itemRect.bottom <= buttonRect.top) break;
            if (itemRect.overlaps(buttonRect)) {
              needsClearance = true;
              break;
            }
          }
        }
        final extraBottom = needsClearance
            ? math.max(
                0.0,
                size.height - buttonRect.top + _margin - gridPadding.bottom,
              )
            : 0.0;
        final effectivePadding = gridPadding.copyWith(
          bottom: gridPadding.bottom + extraBottom,
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            builder(context, effectivePadding),
            Positioned.directional(
              textDirection: Directionality.of(context),
              end: endMargin,
              bottom: _margin + bottomInset,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ?selectAllControl,
                  if (selectAllControl != null && button != null)
                    const SizedBox(width: _rowGap),
                  if (button != null)
                    SizedBox.square(dimension: _buttonSize, child: button),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Text-only select-all control matching the confirmation FAB colors/height.
class SelectionGridSelectAllButton extends StatelessWidget {
  const SelectionGridSelectAllButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  static const height = SelectionGridConfirmation._buttonSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fabTheme = theme.floatingActionButtonTheme;
    final colors = theme.colorScheme;
    final bg =
        backgroundColor ?? fabTheme.backgroundColor ?? colors.primaryContainer;
    final fg =
        foregroundColor ??
        fabTheme.foregroundColor ??
        colors.onPrimaryContainer;
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: bg,
        elevation: fabTheme.elevation ?? 6,
        shadowColor: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

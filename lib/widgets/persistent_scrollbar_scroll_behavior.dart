import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoScrollbar;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Keeps every vertical app scrollbar visible, beside rather than over content.
///
/// Flutter only inserts automatic scrollbars on desktop by default. C-Editor
/// uses the same persistent visual cue on mobile and web so a clipped page does
/// not look as though it ends at the bottom of the viewport. Horizontal
/// controls keep their existing, component-specific scrollbar behavior.
class PersistentScrollbarScrollBehavior extends MaterialScrollBehavior {
  const PersistentScrollbarScrollBehavior();

  EdgeInsets? _contentPadding(BuildContext context) {
    EdgeInsetsGeometry? padding;
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Scrollable) return false;
      if (widget is SingleChildScrollView) {
        padding = widget.padding;
        return false;
      }
      if (widget is BoxScrollView) {
        padding = widget.padding;
        return false;
      }
      return true;
    });
    return padding?.resolve(Directionality.of(context));
  }

  ({Widget widget, BuildContext context})? _explicitScrollbar(
    BuildContext context,
  ) {
    ({Widget widget, BuildContext context})? found;
    context.visitAncestorElements((element) {
      final widget = element.widget;

      // An explicit scrollbar outside another Scrollable belongs to that outer
      // scrollable, not to this nested one. Stop there so each independently
      // scrolling vertical region can still receive its own thumb.
      if (widget is Scrollable) return false;

      if (widget is Scrollbar) {
        found = (widget: widget, context: element);
        return false;
      }
      // Material Scrollbar creates a RawScrollbar internally. Prefer its
      // public wrapper above, whose properties are the effective overrides.
      if (widget is RawScrollbar && found == null) {
        found = (widget: widget, context: element);
      }
      return true;
    });
    return found;
  }

  EdgeInsets _scrollbarGutter(BuildContext context, {Widget? scrollbar}) {
    final theme = Theme.of(context);
    var orientation = ScrollbarOrientation.right;
    double thickness;
    double margin;

    if (scrollbar is RawScrollbar) {
      orientation =
          scrollbar.scrollbarOrientation ??
          (Directionality.of(context) == TextDirection.rtl
              ? ScrollbarOrientation.left
              : ScrollbarOrientation.right);
      thickness = scrollbar.thickness ?? 6;
      margin = scrollbar.crossAxisMargin;
      if (scrollbar is CupertinoScrollbar) {
        thickness = math.max(thickness, scrollbar.thicknessWhileDragging);
        margin = 3;
      }
    } else {
      final materialBar = scrollbar is Scrollbar ? scrollbar : null;
      orientation =
          materialBar?.scrollbarOrientation ??
          (materialBar == null ||
                  Directionality.of(context) == TextDirection.ltr
              ? ScrollbarOrientation.right
              : ScrollbarOrientation.left);
      if (theme.platform == TargetPlatform.iOS) {
        thickness =
            materialBar?.thickness ??
            CupertinoScrollbar.defaultThicknessWhileDragging;
        margin = 3;
      } else {
        final scrollbarTheme = ScrollbarTheme.of(context);
        thickness = materialBar?.thickness ?? 12;
        if (materialBar?.thickness == null) {
          // Hovering can widen Material's thumb; reserve the largest state so
          // neither hover nor dragging can move it over the content.
          for (final states in const <Set<WidgetState>>[
            {},
            {WidgetState.hovered},
            {WidgetState.dragged},
            {WidgetState.hovered, WidgetState.dragged},
          ]) {
            thickness = math.max(
              thickness,
              scrollbarTheme.thickness?.resolve(states) ?? 12,
            );
          }
        }
        margin = scrollbarTheme.crossAxisMargin ?? 2;
      }
    }

    final onLeft = orientation == ScrollbarOrientation.left;
    final safePadding = MediaQuery.paddingOf(context);
    final safeInset = onLeft ? safePadding.left : safePadding.right;
    final width = math.max(20.0, thickness + margin * 2 + 4) + safeInset;
    return onLeft
        ? EdgeInsets.only(left: width)
        : EdgeInsets.only(right: width);
  }

  Widget _withGutter(
    BuildContext context,
    Widget child, {
    BuildContext? scrollbarContext,
    Widget? scrollbar,
  }) {
    final barContext = scrollbarContext ?? context;
    final gutter = _scrollbarGutter(barContext, scrollbar: scrollbar);
    final contentPadding = _contentPadding(context);
    Widget paddedViewport(EdgeInsets padding) => Listener(
      // Padding does not hit-test by itself. Include the reserved channel so
      // the scrollbar can receive touches in its larger interactive thumb
      // target, rather than requiring an exact hit on the thin painted line.
      behavior: HitTestBehavior.opaque,
      child: _ScrollbarViewportHitRegion(
        scrollbarGutter: gutter,
        child: Padding(padding: padding, child: child),
      ),
    );
    // Unknown padding belongs to the scrollable itself, for example an
    // editable field or a dialog's internal viewport. Keep its original inset.
    // Popup menus, dropdowns and dialogs own their padding and intrinsic
    // dimensions. Keep their fixed gutter separate from page balancing.
    if (contentPadding == null || ModalRoute.of(context) is PopupRoute) {
      return paddedViewport(gutter);
    }

    // Page padding already gives the thumb some room. Top up both sides at
    // every viewport width, so tablets and zoomed-out pages stay centered too.
    final safe = MediaQuery.paddingOf(barContext);
    final safeOnBarSide = gutter.left > 0 ? safe.left : safe.right;
    final width = math.max(gutter.left, gutter.right) - safeOnBarSide;
    return paddedViewport(
      EdgeInsets.only(
        left: math.max(0.0, width + safe.left - contentPadding.left),
        right: math.max(0.0, width + safe.right - contentPadding.right),
      ),
    );
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    final scrollable = context.widget;
    // Lists and grids that scroll with their parent should not add another
    // scrollbar or gutter inside the page.
    final physics =
        details.physics ??
        (scrollable is Scrollable ? scrollable.physics : null);
    if (axisDirectionToAxis(details.direction) == Axis.horizontal ||
        details.controller == null ||
        physics?.allowUserScrolling == false) {
      return child;
    }

    final explicit = _explicitScrollbar(context);
    if (explicit != null) {
      return _withGutter(
        context,
        child,
        scrollbarContext: explicit.context,
        scrollbar: explicit.widget,
      );
    }

    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      scrollbarOrientation: ScrollbarOrientation.right,
      child: _withGutter(context, child),
    );
  }
}

/// The page's existing padding can share the thumb channel visually, but the
/// viewport's drag recognizer must not compete for touches in that channel.
class _ScrollbarViewportHitRegion extends SingleChildRenderObjectWidget {
  const _ScrollbarViewportHitRegion({
    required this.scrollbarGutter,
    required super.child,
  });

  final EdgeInsets scrollbarGutter;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderScrollbarViewportHitRegion(scrollbarGutter);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderScrollbarViewportHitRegion renderObject,
  ) {
    renderObject.scrollbarGutter = scrollbarGutter;
  }
}

class _RenderScrollbarViewportHitRegion extends RenderProxyBox {
  _RenderScrollbarViewportHitRegion(this.scrollbarGutter);

  EdgeInsets scrollbarGutter;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (!scrollbarGutter.deflateRect(Offset.zero & size).contains(position)) {
      return false;
    }
    return super.hitTestChildren(result, position: position);
  }
}

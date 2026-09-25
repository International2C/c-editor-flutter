import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/widgets/app_ui_scale.dart';

const double _compactUiScaleFactor = 0.85;
const double _compactViewportBreakpoint = 600;

/// Root UI zoom used by [MaterialApp.builder].
///
/// Inflates [MediaQuery] to a larger logical size, lays the navigator out at
/// that size, then paints with a viewport-sized scale layer so hit-tests and
/// pixels share the same transform. Web skips the paint scale entirely: phone
/// browsers already mismatch layout vs visual viewport, and an extra scale
/// leaves untappable strips along the bottom and trailing edge.
///
/// Do **not** use [FittedBox] here: it lays out its child with unbounded
/// constraints, which leaves Material dialog `ConstrainedBox(minWidth: 280)`
/// with `size: MISSING` and crashes hit-testing on pointer moves.
class AppUiScaler extends StatefulWidget {
  const AppUiScaler({
    super.key,
    required this.scale,
    required this.child,
    this.wrapMessenger = true,
    this.applyCompactViewportScale = false,
  });

  final double scale;
  final Widget child;

  /// When false, skips [AppMessageMessenger] (useful in widget tests).
  final bool wrapMessenger;

  /// Applies the app's existing 0.85 compact-screen scale using this frame's
  /// layout constraints instead of potentially stale outer window metrics.
  final bool applyCompactViewportScale;

  @override
  State<AppUiScaler> createState() => _AppUiScalerState();
}

class _AppUiScalerState extends State<AppUiScaler> {
  // Desktop window managers can report a very small non-zero surface between
  // two usable sizes. Laying out the whole app against that transient surface
  // produces overflow error frames before the final metrics arrive.
  static const _minimumLiveViewport = Size(160, 120);
  static const _firstFrameFallbackViewport = Size(320, 480);

  Size? _lastUsableViewport;

  Size _layoutViewport(Size current) {
    if (current.width >= _minimumLiveViewport.width &&
        current.height >= _minimumLiveViewport.height) {
      _lastUsableViewport = current;
      return current;
    }
    return _lastUsableViewport ??
        Size(
          current.width < _minimumLiveViewport.width
              ? _firstFrameFallbackViewport.width
              : current.width,
          current.height < _minimumLiveViewport.height
              ? _firstFrameFallbackViewport.height
              : current.height,
        );
  }

  Widget _unscaledChild() {
    return AppUiScale(
      scale: 1.0,
      child: widget.wrapMessenger
          ? AppMessageMessenger(child: widget.child)
          : widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Transform.scale is a known mobile-web hit-test footgun: the canvas
    // still fills the screen, but pointers along the bottom and trailing
    // edge miss the widgets painted there. Skip the scaler on web entirely.
    if (kIsWeb) return _unscaledChild();

    final mediaQuery = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double viewportExtent(double constrained, double reported) {
          final value = constrained.isFinite ? constrained : reported;
          return value.isFinite && value > 0 ? value : 0;
        }

        // Parent constraints and window metrics can briefly describe different
        // frames while a desktop window or foldable display changes size. Use
        // the constraints that will lay out this frame as the source of truth.
        final visibleViewport = Size(
          viewportExtent(constraints.maxWidth, mediaQuery.size.width),
          viewportExtent(constraints.maxHeight, mediaQuery.size.height),
        );
        final layoutViewport = _layoutViewport(visibleViewport);
        final requestedScale =
            widget.scale *
            (widget.applyCompactViewportScale &&
                    layoutViewport.shortestSide < _compactViewportBreakpoint
                ? _compactUiScaleFactor
                : 1.0);
        final safeScale = requestedScale.isFinite && requestedScale > 0
            ? requestedScale
            : 1.0;
        final scaledSize = Size(
          layoutViewport.width / safeScale,
          layoutViewport.height / safeScale,
        );

        EdgeInsets scaleInsets(EdgeInsets value) => EdgeInsets.fromLTRB(
          value.left / safeScale,
          value.top / safeScale,
          value.right / safeScale,
          value.bottom / safeScale,
        );

        Rect scaleRect(Rect value) => Rect.fromLTRB(
          value.left / safeScale,
          value.top / safeScale,
          value.right / safeScale,
          value.bottom / safeScale,
        );

        final displayFeatures = mediaQuery.displayFeatures
            .map(
              (feature) => ui.DisplayFeature(
                bounds: scaleRect(feature.bounds),
                type: feature.type,
                state: feature.state,
              ),
            )
            .toList(growable: false);
        final content = SizedBox(
          width: scaledSize.width,
          height: scaledSize.height,
          child: AppUiScale(
            scale: safeScale,
            child: widget.wrapMessenger
                ? AppMessageMessenger(child: widget.child)
                : widget.child,
          ),
        );
        final media = MediaQuery(
          data: mediaQuery.copyWith(
            size: scaledSize,
            devicePixelRatio: mediaQuery.devicePixelRatio * safeScale,
            padding: scaleInsets(mediaQuery.padding),
            viewPadding: scaleInsets(mediaQuery.viewPadding),
            viewInsets: scaleInsets(mediaQuery.viewInsets),
            systemGestureInsets: scaleInsets(mediaQuery.systemGestureInsets),
            displayFeatures: displayFeatures,
            textScaler: TextScaler.linear(1.0),
          ),
          child: content,
        );

        // Native Transform.scale takes the child's layout size, so compact
        // phone scale (0.85) and user zoom leave a strip of painted pixels
        // whose hit-tests miss. Size the scale layer to the visible window
        // instead. Web keeps the unscaled path above: this paint scale is a
        // native-only hit-test fix and must not return to the mobile-web canvas.
        return ClipRect(
          key: const ValueKey('appUiScalerClip'),
          child: _ScaledViewport(
            scale: safeScale,
            childSize: scaledSize,
            child: media,
          ),
        );
      },
    );
  }
}

/// Viewport-sized scale layer: layout size is the visible window, the child is
/// laid out at [childSize], and paint + hit-tests share the scale matrix.
class _ScaledViewport extends SingleChildRenderObjectWidget {
  const _ScaledViewport({
    required this.scale,
    required this.childSize,
    required Widget child,
  }) : super(child: child);

  final double scale;
  final Size childSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderScaledViewport(scale: scale, childSize: childSize);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderScaledViewport renderObject,
  ) {
    renderObject
      ..scale = scale
      ..childSize = childSize;
  }
}

class _RenderScaledViewport extends RenderProxyBox {
  _RenderScaledViewport({required double scale, required Size childSize})
    : _scale = scale,
      _childSize = childSize;

  double _scale;
  double get scale => _scale;
  set scale(double value) {
    if (_scale == value) return;
    final wasCompositing = alwaysNeedsCompositing;
    _scale = value;
    markNeedsLayout();
    if (wasCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
  }

  Size _childSize;
  Size get childSize => _childSize;
  set childSize(Size value) {
    if (_childSize == value) return;
    _childSize = value;
    markNeedsLayout();
  }

  Matrix4 get _paintTransform => Matrix4.diagonal3Values(_scale, _scale, 1);

  @override
  bool get alwaysNeedsCompositing => _scale != 1.0;

  @override
  void performLayout() {
    size = Size(
      constraints.hasBoundedWidth
          ? constraints.maxWidth
          : _childSize.width * _scale,
      constraints.hasBoundedHeight
          ? constraints.maxHeight
          : _childSize.height * _scale,
    );
    child?.layout(BoxConstraints.tight(_childSize));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) {
      layer = null;
      return;
    }
    if (_scale == 1.0) {
      context.paintChild(child, offset);
      layer = null;
      return;
    }
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _paintTransform,
      (context, offset) => context.paintChild(child, offset),
      oldLayer: layer as TransformLayer?,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    // Dialog overlays can briefly (or after a failed layout) leave a
    // ConstrainedBox with size MISSING; never hit-test unsized children.
    if (child == null || !child.hasSize) return false;
    return result.addWithPaintTransform(
      transform: _scale == 1.0 ? null : _paintTransform,
      position: position,
      hitTest: (result, position) {
        return child.hitTest(result, position: position);
      },
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    if (_scale != 1.0) transform.multiply(_paintTransform);
  }
}

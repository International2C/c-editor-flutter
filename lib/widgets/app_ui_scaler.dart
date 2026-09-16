import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/widgets/app_ui_scale.dart';

const double _compactUiScaleFactor = 0.85;
const double _compactViewportBreakpoint = 600;

/// Root UI zoom used by [MaterialApp.builder].
///
/// Inflates [MediaQuery] to a larger logical size, lays the navigator out at
/// that size with an [OverflowBox] (bounded constraints), then paints with
/// [Transform.scale].
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

        // Clipping invalidates the visible paint region as the window changes.
        // Leaving filterQuality null keeps the root on a normal transform layer
        // instead of retaining the entire interface in an ImageFilterLayer.
        return ClipRect(
          child: Transform.scale(
            scale: safeScale,
            alignment: Alignment.topLeft,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: scaledSize.width,
              maxWidth: scaledSize.width,
              minHeight: scaledSize.height,
              maxHeight: scaledSize.height,
              child: media,
            ),
          ),
        );
      },
    );
  }
}

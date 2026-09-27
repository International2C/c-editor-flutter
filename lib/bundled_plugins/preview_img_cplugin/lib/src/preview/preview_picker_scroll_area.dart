import 'package:flutter/material.dart';

import 'preview_picker_session.dart';

/// Gives picker contents one scroll controller and a draggable vertical thumb.
class PreviewPickerScrollArea extends StatefulWidget {
  const PreviewPickerScrollArea({
    super.key,
    required this.builder,
    this.controller,
    this.scrollbarKey,
    this.session,
  }) : assert(controller == null || session == null);

  final Widget Function(ScrollController controller) builder;
  final ScrollController? controller;
  final Key? scrollbarKey;
  final PreviewPickerSession? session;

  @override
  State<PreviewPickerScrollArea> createState() =>
      _PreviewPickerScrollAreaState();
}

class _PreviewPickerScrollAreaState extends State<PreviewPickerScrollArea> {
  late final _ownedController = ScrollController(
    initialScrollOffset: widget.session?.scrollOffset ?? 0,
    keepScrollOffset: widget.session == null,
  )..addListener(_rememberOffset);

  void _rememberOffset() {
    if (!_ownedController.hasClients) return;
    _rememberMetrics(_ownedController.position);
  }

  void _rememberMetrics(ScrollMetrics metrics) {
    // A rubber-band overscroll on iOS is not a position to restore next time.
    if (!metrics.hasContentDimensions) return;
    widget.session?.rememberScrollOffset(
      metrics.pixels.clamp(metrics.minScrollExtent, metrics.maxScrollExtent),
    );
  }

  @override
  void dispose() {
    _ownedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? _ownedController;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scrollbar(
        key: widget.scrollbarKey,
        controller: controller,
        thumbVisibility: true,
        interactive: true,
        notificationPredicate: (notification) =>
            notification.depth == 0 &&
            notification.metrics.axis == Axis.vertical,
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            if (notification.depth == 0 &&
                notification.metrics.axis == Axis.vertical) {
              _rememberMetrics(notification.metrics);
            }
            return false;
          },
          child: widget.builder(controller),
        ),
      ),
    );
  }
}

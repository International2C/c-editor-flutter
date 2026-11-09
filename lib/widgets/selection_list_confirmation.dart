import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Keeps a list confirmation floating, with end padding only when it would
/// cover the last item. The item can grow with translated or scaled text.
class SelectionListConfirmation extends StatefulWidget {
  const SelectionListConfirmation({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.builder,
    required this.confirmation,
    this.listPadding = const EdgeInsets.all(16),
  });

  final ScrollController controller;
  final int itemCount;
  final Widget Function(
    BuildContext context,
    EdgeInsets listPadding,
    GlobalKey lastItemKey,
  )
  builder;
  final Widget confirmation;
  final EdgeInsets listPadding;

  @override
  State<SelectionListConfirmation> createState() =>
      _SelectionListConfirmationState();
}

class _SelectionListConfirmationState extends State<SelectionListConfirmation> {
  static const _buttonSize = 56.0;
  static const _margin = 16.0;

  final _lastItemKey = GlobalKey();
  double _extraBottom = 0;
  bool _checkScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scheduleCheck);
  }

  @override
  void didUpdateWidget(covariant SelectionListConfirmation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_scheduleCheck);
      widget.controller.addListener(_scheduleCheck);
    }
    if (oldWidget.itemCount != widget.itemCount) _extraBottom = 0;
    _scheduleCheck();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scheduleCheck);
    super.dispose();
  }

  void _scheduleCheck() {
    if (_checkScheduled) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (!mounted || !widget.controller.hasClients) return;
      final lastBox = _lastItemKey.currentContext?.findRenderObject();
      final viewport = context.findRenderObject();
      if (lastBox is! RenderBox || viewport is! RenderBox) return;
      final position = widget.controller.position;
      // Undo any existing clearance and current scrolling before deciding
      // whether the original end position would overlap the button.
      final baseEndOffset = math.max(
        0.0,
        position.maxScrollExtent - _extraBottom,
      );
      final itemRect =
          lastBox.localToGlobal(Offset.zero, ancestor: viewport) & lastBox.size;
      final originalEndRect = itemRect.translate(
        0,
        position.pixels - baseEndOffset,
      );
      final safe = MediaQuery.paddingOf(context);
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      final buttonRect = Rect.fromLTWH(
        isRtl
            ? _margin + safe.left
            : viewport.size.width - _margin - safe.right - _buttonSize,
        viewport.size.height - safe.bottom - _margin - _buttonSize,
        _buttonSize,
        _buttonSize,
      );
      final extraBottom = originalEndRect.overlaps(buttonRect)
          ? math.max(
              0.0,
              safe.bottom +
                  _margin * 2 +
                  _buttonSize -
                  widget.listPadding.bottom,
            )
          : 0.0;
      if ((_extraBottom - extraBottom).abs() < 0.1) return;
      final wasAtEnd = position.extentAfter < 0.1;
      setState(() => _extraBottom = extraBottom);
      if (wasAtEnd) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.controller.hasClients) {
            widget.controller.jumpTo(
              widget.controller.position.maxScrollExtent,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleCheck();
    final safe = MediaQuery.paddingOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        _scheduleCheck();
        return false;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.builder(
            context,
            widget.listPadding.copyWith(
              bottom: widget.listPadding.bottom + _extraBottom,
            ),
            _lastItemKey,
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: _margin + (isRtl ? safe.left : safe.right),
            bottom: _margin + safe.bottom,
            child: SizedBox.square(
              dimension: _buttonSize,
              child: widget.confirmation,
            ),
          ),
        ],
      ),
    );
  }
}

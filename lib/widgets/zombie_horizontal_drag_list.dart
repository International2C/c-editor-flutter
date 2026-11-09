import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:c_editor/widgets/zombie_lane_drag_item.dart';
import 'package:c_editor/widgets/zombie_lane_drag_scope.dart';
import 'package:c_editor/widgets/zombie_lane_drag_widgets.dart';
import 'package:c_editor/widgets/zombie_lane_editor_common.dart';

/// One lawn-row lane: zombies wrap to the next line based on available width.
class ZombieHorizontalLaneRow extends StatefulWidget {
  const ZombieHorizontalLaneRow({
    super.key,
    required this.rowValue,
    required this.items,
    required this.highlighted,
    this.labelSide,
    this.addButton,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onPreviewInsert,
    required this.onDrop,
    required this.isDragging,
    required this.draggingIdentity,
    required this.commitRowValue,
    required this.commitInsertIndex,
    required this.previewWidget,
  });

  final int rowValue;
  final List<ZombieLaneIconData> items;
  final bool highlighted;
  final Widget? labelSide;
  final Widget? addButton;
  final void Function(int listIndex) onTap;
  final void Function(Object identity) onDragStarted;
  final VoidCallback onDragEnded;
  final void Function(int rowValue, int insertIndex) onPreviewInsert;
  final VoidCallback onDrop;
  final bool isDragging;
  final Object? draggingIdentity;
  final int? commitRowValue;
  final int? commitInsertIndex;
  final Widget? previewWidget;

  static const labelColumnBreakpoint = 200.0;

  @override
  State<ZombieHorizontalLaneRow> createState() =>
      _ZombieHorizontalLaneRowState();
}

class _ZombieHorizontalLaneRowState extends State<ZombieHorizontalLaneRow> {
  List<ZombieLaneIconData> get _visible {
    if (!widget.isDragging || widget.draggingIdentity == null) {
      return widget.items;
    }
    return widget.items
        .where((item) => item.identity != widget.draggingIdentity)
        .toList(growable: false);
  }

  int? get _activeInsertIndex {
    if (!widget.isDragging || widget.commitRowValue != widget.rowValue) {
      return null;
    }
    return widget.commitInsertIndex;
  }

  void _handleLanePointerMove(
    Offset local,
    double laneWidth,
    List<ZombieLaneIconData> visible,
  ) {
    final contentWidth = effectiveWrapContentWidth(laneWidth);
    final insert = insertIndexForWrappedPoint(
      local,
      contentWidth,
      visible.length,
      currentInsert: _activeInsertIndex,
    );
    widget.onPreviewInsert(widget.rowValue, insert);
  }

  Widget _buildLane({
    required ThemeData theme,
    required List<ZombieLaneIconData> visible,
    required bool dragging,
    required int? insertAt,
    required double laneWidth,
  }) {
    final contentWidth = effectiveWrapContentWidth(laneWidth);
    final showPreview =
        dragging && insertAt != null && widget.previewWidget != null;
    final includeAddButton =
        !dragging && widget.addButton != null && visible.isNotEmpty;
    final laneHeight = wrapLaneLayoutHeight(
      contentWidth,
      visible.length,
      insertAt: showPreview ? insertAt : null,
      includeAddButton: includeAddButton || (visible.isEmpty && !dragging),
    );
    final shiftDuration = dragging ? zombieLaneShiftDuration : Duration.zero;

    return Container(
      width: laneWidth,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.highlighted
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        border: widget.highlighted
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.35),
              )
            : null,
      ),
      child: SizedBox(
        width: contentWidth,
        height: laneHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (visible.isEmpty && showPreview)
              AnimatedPositioned(
                duration: shiftDuration,
                curve: zombieLaneShiftCurve,
                left: 0,
                top: 0,
                width: zombieLaneCardSize,
                height: zombieLaneCardSize,
                child: ZombieLanePreviewGap(
                  previewWidget: widget.previewWidget!,
                ),
              )
            else if (visible.isEmpty && widget.addButton != null && !dragging)
              Positioned(
                left: 0,
                top: 0,
                width: zombieLaneCardSize,
                height: zombieLaneCardSize,
                child: widget.addButton!,
              )
            else ...[
              for (var i = 0; i < visible.length; i++)
                AnimatedPositioned(
                  key: ValueKey<(Object, int)>((
                    visible[i].identity,
                    visible[i].rowValue,
                  )),
                  duration: shiftDuration,
                  curve: zombieLaneShiftCurve,
                  left: wrapCardRect(
                    i,
                    showPreview ? insertAt : null,
                    contentWidth,
                    visible.length,
                  ).left,
                  top: wrapCardRect(
                    i,
                    showPreview ? insertAt : null,
                    contentWidth,
                    visible.length,
                  ).top,
                  width: zombieLaneCardSize,
                  height: zombieLaneCardSize,
                  child: ZombieLaneDraggableCard(
                    item: visible[i],
                    feedback: buildZombieLaneDragFeedback(visible[i]),
                    onDragStarted: widget.onDragStarted,
                    onDragEnded: widget.onDragEnded,
                    child: buildZombieLaneCard(
                      item: visible[i],
                      onTap: () => widget.onTap(visible[i].listIndex),
                    ),
                  ),
                ),
              if (showPreview)
                AnimatedPositioned(
                  duration: shiftDuration,
                  curve: zombieLaneShiftCurve,
                  left: wrapPreviewRect(
                    insertAt,
                    contentWidth,
                    visible.length,
                  ).left,
                  top: wrapPreviewRect(
                    insertAt,
                    contentWidth,
                    visible.length,
                  ).top,
                  width: zombieLaneCardSize,
                  height: zombieLaneCardSize,
                  child: ZombieLanePreviewGap(
                    previewWidget: widget.previewWidget!,
                  ),
                ),
              if (includeAddButton)
                AnimatedPositioned(
                  duration: shiftDuration,
                  curve: zombieLaneShiftCurve,
                  left: wrapLaneSlotRects(
                    contentWidth,
                    visible.length + 1,
                  ).last.left,
                  top: wrapLaneSlotRects(
                    contentWidth,
                    visible.length + 1,
                  ).last.top,
                  width: zombieLaneCardSize,
                  height: zombieLaneCardSize,
                  child: widget.addButton!,
                ),
            ],
            if (dragging)
              Positioned.fill(
                child: ZombieLaneRowDropZone(
                  onDrop: widget.onDrop,
                  onDragEntered: visible.isEmpty
                      ? () => widget.onPreviewInsert(widget.rowValue, 0)
                      : null,
                  onPointerMove: (localX, localY, viewportWidth) {
                    _handleLanePointerMove(
                      Offset(localX, localY),
                      laneWidth,
                      visible,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = _visible;
    final dragging = widget.isDragging;
    final insertAt = _activeInsertIndex?.clamp(0, visible.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final hasLabel = widget.labelSide != null;
        final stackLabel =
            hasLabel &&
            maxWidth < ZombieHorizontalLaneRow.labelColumnBreakpoint;
        final laneWidth = !hasLabel || stackLabel
            ? maxWidth
            : math.max(0.0, maxWidth - 84);

        final lane = _buildLane(
          theme: theme,
          visible: visible,
          dragging: dragging,
          insertAt: insertAt,
          laneWidth: laneWidth,
        );

        if (!hasLabel) return lane;

        if (stackLabel) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [widget.labelSide!, const SizedBox(height: 8), lane],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.labelSide!,
            Expanded(child: lane),
          ],
        );
      },
    );
  }
}

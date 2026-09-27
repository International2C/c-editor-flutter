import 'package:flutter/material.dart';

import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zombie_lane_editor_common.dart';

/// Display data for one zombie slot in lane editors.
class ZombieLaneIconData {
  const ZombieLaneIconData({
    required this.identity,
    required this.listIndex,
    required this.rowValue,
    required this.iconPath,
    required this.levelDisplay,
    required this.isElite,
    required this.isCustom,
    required this.isMissingCustomZombie,
  });

  /// Stable object identity (e.g. the backing spawn model instance).
  final Object identity;
  final int listIndex;
  final int rowValue;
  final String? iconPath;
  final String levelDisplay;
  final bool isElite;
  final bool isCustom;
  final bool isMissingCustomZombie;
}

/// Payload for zombie lane drag-and-drop.
class ZombieDragData {
  const ZombieDragData(this.listIndex);

  final int listIndex;
}

const Duration zombieDragLongPressDelay = Duration(milliseconds: 180);
const double zombieDropSlotWidth = 20;

/// Drop slot shown between zombies while dragging.
class ZombieLaneDropSlot extends StatelessWidget {
  const ZombieLaneDropSlot({
    super.key,
    required this.beforeListIndex,
    required this.draggingIndex,
    required this.onAccept,
    this.onHoverChanged,
    this.height = zombieLaneCardSize,
  });

  /// Global list index to insert before, or null to append in the lane.
  final int? beforeListIndex;
  final int? draggingIndex;
  final void Function(ZombieDragData data) onAccept;
  final ValueChanged<bool>? onHoverChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<ZombieDragData>(
      onWillAcceptWithDetails: (details) {
        if (draggingIndex == null) return false;
        final from = details.data.listIndex;
        if (beforeListIndex == null) return true;
        return from != beforeListIndex;
      },
      onMove: (_) => onHoverChanged?.call(true),
      onLeave: (_) => onHoverChanged?.call(false),
      onAcceptWithDetails: (details) {
        onHoverChanged?.call(false);
        onAccept(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final active = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          width: zombieDropSlotWidth,
          height: height,
          alignment: Alignment.center,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: active ? 1 : 0.35,
            child: Container(
              width: active ? 4 : 2,
              height: active ? height * 0.72 : height * 0.45,
              decoration: BoxDecoration(
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Lane background that accepts drops to append when the lane is empty or as fallback.
class ZombieLaneDropBackground extends StatelessWidget {
  const ZombieLaneDropBackground({
    super.key,
    required this.draggingIndex,
    required this.highlighted,
    required this.onAcceptAppend,
    required this.onHoverChanged,
    required this.child,
    this.minHeight = zombieLaneCardSize,
  });

  final int? draggingIndex;
  final bool highlighted;
  final void Function(ZombieDragData data) onAcceptAppend;
  final ValueChanged<bool> onHoverChanged;
  final Widget child;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<ZombieDragData>(
      onWillAcceptWithDetails: (_) => draggingIndex != null,
      onMove: (_) => onHoverChanged(true),
      onLeave: (_) => onHoverChanged(false),
      onAcceptWithDetails: (details) {
        onHoverChanged(false);
        onAcceptAppend(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final active = candidateData.isNotEmpty || highlighted;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: active
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            border: active
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  )
                : null,
          ),
          child: child,
        );
      },
    );
  }
}

class ZombieDraggableCard extends StatelessWidget {
  const ZombieDraggableCard({
    super.key,
    required this.item,
    required this.isDragging,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final ZombieLaneIconData item;
  final bool isDragging;
  final VoidCallback onTap;
  final void Function(int listIndex) onDragStarted;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    final card = buildZombieLaneCard(
      item: item,
      onTap: onTap,
    );

    return LongPressDraggable<ZombieDragData>(
      data: ZombieDragData(item.listIndex),
      delay: zombieDragLongPressDelay,
      maxSimultaneousDrags: 1,
      rootOverlay: true,
      hapticFeedbackOnStart: true,
      onDragStarted: () => onDragStarted(item.listIndex),
      onDragEnd: (_) => onDragEnded(),
      onDraggableCanceled: (_, _) => onDragEnded(),
      feedback: buildZombieLaneDragFeedback(item),
      childWhenDragging: SizedBox(
        width: zombieLaneCardSize,
        height: zombieLaneCardSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
        ),
      ),
      child: Opacity(opacity: isDragging ? 0.45 : 1, child: card),
    );
  }
}

List<Widget> buildZombieLaneChildren({
  required List<ZombieLaneIconData> items,
  required int? draggingIndex,
  required void Function(int index) onTap,
  required void Function(int index) onDelete,
  required void Function(int fromIndex, int? beforeListIndex) onMoveToSlot,
  required void Function(int listIndex) onDragStarted,
  required VoidCallback onDragEnded,
  VoidCallback? onAdd,
  bool useSecondaryAddColor = false,
}) {
  final dragging = draggingIndex != null;
  final widgets = <Widget>[];

  if (dragging && items.isNotEmpty) {
    widgets.add(
      ZombieLaneDropSlot(
        beforeListIndex: items.first.listIndex,
        draggingIndex: draggingIndex,
        onAccept: (data) => onMoveToSlot(data.listIndex, items.first.listIndex),
      ),
    );
  }

  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    widgets.add(
      ZombieDraggableCard(
        item: item,
        isDragging: draggingIndex == item.listIndex,
        onTap: () => onTap(item.listIndex),
        onDragStarted: onDragStarted,
        onDragEnded: onDragEnded,
      ),
    );
    if (dragging) {
      final before = i + 1 < items.length ? items[i + 1].listIndex : null;
      widgets.add(
        ZombieLaneDropSlot(
          beforeListIndex: before,
          draggingIndex: draggingIndex,
          onAccept: (data) => onMoveToSlot(data.listIndex, before),
        ),
      );
    }
  }

  if (dragging) {
    widgets.add(
      ZombieLaneDropSlot(
        beforeListIndex: null,
        draggingIndex: draggingIndex,
        onAccept: (data) => onMoveToSlot(data.listIndex, null),
      ),
    );
  } else if (onAdd != null) {
    widgets.add(
      PvzAddButton(
        onPressed: onAdd,
        useSecondaryColor: useSecondaryAddColor,
        size: zombieLaneCardSize,
      ),
    );
  }

  return widgets;
}

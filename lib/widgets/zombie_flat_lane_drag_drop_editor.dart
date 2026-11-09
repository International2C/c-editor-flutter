import 'package:flutter/material.dart';

import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zombie_horizontal_drag_list.dart';
import 'package:c_editor/widgets/zombie_lane_drag_widgets.dart';
import 'package:c_editor/widgets/zombie_lane_editor_common.dart';

export 'package:c_editor/widgets/zombie_lane_drag_widgets.dart'
    show ZombieLaneIconData;

/// Flat zombie list with horizontal drag-reorder (no row lanes).
class ZombieFlatLaneDragDropEditor extends StatefulWidget {
  const ZombieFlatLaneDragDropEditor({
    super.key,
    required this.items,
    required this.onTap,
    this.onDelete,
    required this.onMove,
    required this.onAdd,
    this.onDraggingChanged,
  });

  final List<ZombieLaneIconData> items;
  final void Function(int index) onTap;
  final void Function(int index)? onDelete;

  /// [insertIndex] is 0-based within the visible lane while dragging.
  final void Function(int fromIndex, int insertIndex) onMove;
  final VoidCallback onAdd;
  final ValueChanged<bool>? onDraggingChanged;

  @override
  State<ZombieFlatLaneDragDropEditor> createState() =>
      _ZombieFlatLaneDragDropEditorState();
}

class _ZombieFlatLaneDragDropEditorState
    extends State<ZombieFlatLaneDragDropEditor> {
  static const _flatRowValue = 0;

  bool _dragging = false;
  bool _endingDrag = false;
  Object? _draggingIdentity;
  int? _commitInsertIndex;
  Widget? _previewWidget;

  ZombieLaneIconData? _itemByIdentity(Object identity) {
    for (final item in widget.items) {
      if (item.identity == identity) return item;
    }
    return null;
  }

  int _visibleInsertIndexForIdentity(Object identity) {
    var insert = 0;
    for (final item in widget.items) {
      if (item.identity == identity) return insert;
      insert++;
    }
    return insert;
  }

  void _setPreviewInsert(int insertIndex) {
    if (!_dragging || _endingDrag) return;
    if (_commitInsertIndex == insertIndex) return;
    setState(() => _commitInsertIndex = insertIndex);
  }

  void _onDragStarted(Object identity) {
    final source = _itemByIdentity(identity);
    if (source == null) return;

    setState(() {
      _endingDrag = false;
      _dragging = true;
      _draggingIdentity = identity;
      _commitInsertIndex = _visibleInsertIndexForIdentity(identity);
      _previewWidget = buildZombieLaneDragFeedback(source);
    });
    widget.onDraggingChanged?.call(true);
  }

  void _applyMove(int? commitInsert, Object? identity) {
    if (commitInsert == null || identity == null) return;

    final source = _itemByIdentity(identity);
    if (source == null) return;

    final sameSlot = commitInsert == _visibleInsertIndexForIdentity(identity);
    if (sameSlot) return;

    widget.onMove(source.listIndex, commitInsert);
  }

  void _onDragEnded() {
    if (!_dragging || _endingDrag) return;
    _endingDrag = true;

    final commitInsert = _commitInsertIndex;
    final identity = _draggingIdentity;

    setState(() {
      _dragging = false;
      _draggingIdentity = null;
      _commitInsertIndex = null;
      _previewWidget = null;
    });
    widget.onDraggingChanged?.call(false);

    _applyMove(commitInsert, identity);

    _endingDrag = false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ZombieHorizontalLaneRow(
          rowValue: _flatRowValue,
          items: widget.items,
          highlighted: _dragging && _commitInsertIndex != null,
          addButton: _dragging
              ? null
              : PvzAddButton(onPressed: widget.onAdd, size: zombieLaneCardSize),
          onTap: widget.onTap,
          onDragStarted: _onDragStarted,
          onDragEnded: _onDragEnded,
          onPreviewInsert: (_, insertIndex) => _setPreviewInsert(insertIndex),
          onDrop: _onDragEnded,
          isDragging: _dragging,
          draggingIdentity: _draggingIdentity,
          commitRowValue: _dragging ? _flatRowValue : null,
          commitInsertIndex: _commitInsertIndex,
          previewWidget: _previewWidget,
        ),
      ),
    );
  }
}

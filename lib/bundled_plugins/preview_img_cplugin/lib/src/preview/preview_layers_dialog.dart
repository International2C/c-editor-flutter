import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';

import 'preview_document.dart';
import 'preview_picker_scroll_area.dart';
import 'preview_picker_session.dart';

/// Lists the complete render order front-to-back, including the background.
/// [onReorder] receives a bottom-to-top permutation and should apply it to [doc]
/// synchronously so editing, export and this dialog share the same order.
Future<void> showPreviewLayersDialog({
  required BuildContext context,
  required PreviewDocument doc,
  String? selectedLayerId,
  required String Function(String key, [String? fallback]) t,
  required String Function(PreviewLayerOrderEntry entry) entryTitle,
  required ValueChanged<String> onSelected,
  required ValueChanged<List<String>> onReorder,
  PreviewPickerSession? session,
}) => showDialog<void>(
  context: context,
  builder: (_) => _PreviewLayersDialog(
    doc: doc,
    selectedLayerId: selectedLayerId,
    t: t,
    entryTitle: entryTitle,
    onSelected: onSelected,
    onReorder: onReorder,
    session: session,
  ),
);

class _PreviewLayersDialog extends StatefulWidget {
  const _PreviewLayersDialog({
    required this.doc,
    required this.selectedLayerId,
    required this.t,
    required this.entryTitle,
    required this.onSelected,
    required this.onReorder,
    this.session,
  });

  final PreviewDocument doc;
  final String? selectedLayerId;
  final String Function(String key, [String? fallback]) t;
  final String Function(PreviewLayerOrderEntry entry) entryTitle;
  final ValueChanged<String> onSelected;
  final ValueChanged<List<String>> onReorder;
  final PreviewPickerSession? session;

  @override
  State<_PreviewLayersDialog> createState() => _PreviewLayersDialogState();
}

class _PreviewLayersDialogState extends State<_PreviewLayersDialog> {
  late String? _selectedLayerId = widget.selectedLayerId;

  String _typeName(PreviewLayerOrderEntry entry) => widget.t(
    'previewGenLayerType_${entry.isBackground ? 'background' : entry.layer!.kind.name}',
  );

  IconData _iconFor(PreviewLayerOrderEntry entry) {
    if (entry.isBackground) return Icons.wallpaper;
    return switch (entry.layer!.kind) {
      PreviewLayerKind.text => Icons.text_fields,
      PreviewLayerKind.image => Icons.sticky_note_2_outlined,
      PreviewLayerKind.iconGrid => Icons.grid_view,
      PreviewLayerKind.shape => Icons.category,
      PreviewLayerKind.stroke => Icons.gesture,
    };
  }

  void _reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final entries = widget.doc.orderedLayerEntries.reversed.toList();
    final moved = entries.removeAt(oldIndex);
    entries.insert(newIndex, moved);
    widget.onReorder([for (final entry in entries.reversed) entry.id]);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = widget.doc.orderedLayerEntries.reversed.toList();
    return Dialog(
      key: const ValueKey('previewLayersDialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ConstrainedBox(
        key: const ValueKey('previewLayersContent'),
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: PreviewPickerScrollArea(
                  scrollbarKey: const ValueKey('previewLayersScrollbar'),
                  session: widget.session,
                  builder: (controller) => ReorderableListView.builder(
                    key: const ValueKey('previewLayersList'),
                    scrollController: controller,
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.all(12),
                    header: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.t('previewGenLayers'),
                            key: const ValueKey('previewLayersTitle'),
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(widget.t('previewGenLayersHint')),
                        ],
                      ),
                    ),
                    itemCount: entries.length,
                    onReorderItem: _reorder,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final selected = _selectedLayerId == entry.id;
                      return Card(
                        key: ValueKey('previewLayerOption-${entry.id}'),
                        margin: const EdgeInsets.only(bottom: 8),
                        color: selected
                            ? theme.colorScheme.primaryContainer
                            : null,
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              key: ValueKey(
                                'previewLayerDragHandle-${entry.id}',
                              ),
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.drag_indicator),
                              ),
                            ),
                            Expanded(
                              child: EditorOptionTile(
                                selected: selected,
                                leading: Icon(_iconFor(entry)),
                                title: Text(
                                  widget.entryTitle(entry),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(_typeName(entry)),
                                onTap: () {
                                  widget.onSelected(entry.id);
                                  if (mounted) {
                                    setState(() => _selectedLayerId = entry.id);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      key: const ValueKey('previewLayersClose'),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(widget.t('previewGenClose')),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

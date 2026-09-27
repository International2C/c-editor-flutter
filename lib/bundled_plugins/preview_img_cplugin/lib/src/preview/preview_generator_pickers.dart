import 'package:flutter/material.dart';
import 'package:c_editor/widgets/editor_components.dart' show EditorOptionTile;

import 'preview_document.dart';
import 'preview_picker_scroll_area.dart';
import 'preview_picker_session.dart';

/// Keeps every figure reachable on short landscape displays.
Future<(PreviewShapeKind, bool)?> showPreviewFiguresPicker({
  required BuildContext context,
  required String Function(String key, [String? fallback]) t,
  PreviewPickerSession? session,
}) => showModalBottomSheet<(PreviewShapeKind, bool)>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  constraints: BoxConstraints(
    maxHeight: MediaQuery.sizeOf(context).height * 0.9,
  ),
  builder: (ctx) => SafeArea(
    top: false,
    child: PreviewPickerScrollArea(
      session: session,
      scrollbarKey: const ValueKey('previewFiguresScrollbar'),
      builder: (controller) => SingleChildScrollView(
        key: const ValueKey('previewFiguresScroll'),
        controller: controller,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                t('previewTool_figures', 'Figures'),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            for (final figure in [
              (PreviewShapeKind.rect, false, Icons.crop_square, 'Rectangle'),
              (PreviewShapeKind.oval, false, Icons.circle_outlined, 'Oval'),
              (PreviewShapeKind.line, false, Icons.show_chart, 'Line'),
              (PreviewShapeKind.star, false, Icons.star_border, 'Star'),
              (PreviewShapeKind.rect, true, Icons.square, 'Filled rectangle'),
              (PreviewShapeKind.oval, true, Icons.circle, 'Filled oval'),
              (PreviewShapeKind.star, true, Icons.star, 'Filled star'),
            ])
              EditorOptionTile(
                key: ValueKey('previewFigure-${figure.$1.name}-${figure.$2}'),
                leading: Icon(figure.$3),
                title: Text(
                  t(
                    'previewFigure_${figure.$1.name}${figure.$2 ? '_filled' : ''}',
                    figure.$4,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, (figure.$1, figure.$2)),
              ),
          ],
        ),
      ),
    ),
  ),
);

/// The header and search field scroll with the entries so they cannot consume
/// the entire list viewport when the keyboard opens on a landscape phone.
Future<String?> showPreviewModuleInfoPicker({
  required BuildContext context,
  required Iterable<String> classes,
  required String Function(BuildContext context, String objClass) titleForClass,
  required String Function(String key, [String? fallback]) t,
  PreviewPickerSession? session,
}) => showDialog<String>(
  context: context,
  builder: (_) => _PreviewModuleInfoPickerDialog(
    classes: classes.toList(),
    titleForClass: titleForClass,
    t: t,
    session: session,
  ),
);

class _PreviewModuleInfoPickerDialog extends StatefulWidget {
  const _PreviewModuleInfoPickerDialog({
    required this.classes,
    required this.titleForClass,
    required this.t,
    this.session,
  });

  final List<String> classes;
  final String Function(BuildContext context, String objClass) titleForClass;
  final String Function(String key, [String? fallback]) t;
  final PreviewPickerSession? session;

  @override
  State<_PreviewModuleInfoPickerDialog> createState() =>
      _PreviewModuleInfoPickerDialogState();
}

class _PreviewModuleInfoPickerDialogState
    extends State<_PreviewModuleInfoPickerDialog> {
  late final _session = widget.session ?? PreviewPickerSession();
  late final _searchController = TextEditingController(text: _session.query);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final filtered = widget.classes.where((objClass) {
      if (_session.query.isEmpty) return true;
      final normalizedQuery = _session.query.toLowerCase();
      return objClass.toLowerCase().contains(normalizedQuery) ||
          widget
              .titleForClass(ctx, objClass)
              .toLowerCase()
              .contains(normalizedQuery);
    });
    return AlertDialog(
      key: const ValueKey('previewModuleInfoPicker'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      content: SizedBox(
        width: double.maxFinite,
        child: PreviewPickerScrollArea(
          session: _session,
          scrollbarKey: const ValueKey('previewModuleInfoScrollbar'),
          builder: (controller) => SingleChildScrollView(
            key: const ValueKey('previewModuleInfoScroll'),
            controller: controller,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    widget.t('previewGenModuleInfo', 'Module info'),
                    style: Theme.of(ctx).textTheme.headlineSmall,
                  ),
                ),
                TextField(
                  key: const ValueKey('previewModuleInfoSearch'),
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    hintText: widget.t('previewGenModuleInfoSearch', 'Search'),
                  ),
                  onChanged: (value) => setState(() => _session.query = value),
                ),
                const SizedBox(height: 8),
                for (final objClass in filtered)
                  EditorOptionTile(
                    key: ValueKey('previewModuleInfo-$objClass'),
                    title: Text(widget.titleForClass(ctx, objClass)),
                    subtitle: Text(
                      objClass,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () => Navigator.pop(ctx, objClass),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('previewModuleInfoCancel'),
          onPressed: () => Navigator.pop(ctx),
          child: Text(widget.t('previewGenCancel', 'Cancel')),
        ),
      ],
    );
  }
}

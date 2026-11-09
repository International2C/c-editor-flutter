import 'package:flutter/material.dart';
import 'package:c_editor/widgets/editor_components.dart';

class SeparatedOptionPickerItem<T> {
  const SeparatedOptionPickerItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.fieldLabel,
  });

  final T value;
  final String label;
  final String? subtitle;
  final String? fieldLabel;
}

/// Form-field-style single selector whose choices use roomy, divided rows.
class SeparatedOptionPickerField<T> extends StatelessWidget {
  const SeparatedOptionPickerField({
    super.key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.decoration,
    this.sheetTitle,
    this.sheetHeader,
    this.sheetSubtitleLines = const [],
    this.fallbackLabel,
    this.selectedTextStyle,
  });

  final String labelText;
  final T? value;
  final List<SeparatedOptionPickerItem<T>> items;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final InputDecoration? decoration;
  final String? sheetTitle;
  final Widget? sheetHeader;
  final List<String> sheetSubtitleLines;

  /// Displays an imported value missing from [items] without making it a choice.
  final String? fallbackLabel;
  final TextStyle? selectedTextStyle;

  SeparatedOptionPickerItem<T>? get _selectedItem {
    for (final item in items) {
      if (item.value == value) return item;
    }
    return null;
  }

  Future<void> _showOptions(BuildContext context) async {
    if (!enabled || items.isEmpty) return;
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return _SeparatedOptionPickerSheet<T>(
          title: sheetTitle ?? labelText,
          header: sheetHeader,
          subtitleLines: sheetSubtitleLines,
          items: items,
          value: value,
        );
      },
    );
    if (selected != null && selected != value) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedItem;
    Widget buildPicker(InputDecoration effectiveDecoration) {
      return Semantics(
        button: enabled,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? () => _showOptions(context) : null,
          child: InputDecorator(
            isEmpty: selected == null && fallbackLabel == null,
            decoration: effectiveDecoration.copyWith(enabled: enabled),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected?.fieldLabel ??
                        selected?.label ??
                        fallbackLabel ??
                        '',
                    style: selectedTextStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      );
    }

    if (decoration != null) return buildPicker(decoration!);
    return EditorResponsiveInputField(
      label: labelText,
      decoration: editorInputDecoration(context),
      builder: (context, effectiveDecoration) =>
          buildPicker(effectiveDecoration),
    );
  }
}

class _SeparatedOptionPickerSheet<T> extends StatefulWidget {
  const _SeparatedOptionPickerSheet({
    required this.title,
    required this.header,
    required this.subtitleLines,
    required this.items,
    required this.value,
  });

  final String title;
  final Widget? header;
  final List<String> subtitleLines;
  final List<SeparatedOptionPickerItem<T>> items;
  final T? value;

  @override
  State<_SeparatedOptionPickerSheet<T>> createState() =>
      _SeparatedOptionPickerSheetState<T>();
}

class _SeparatedOptionPickerSheetState<T>
    extends State<_SeparatedOptionPickerSheet<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;
    final subtitleLines = widget.subtitleLines
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.right,
          child: ListView.separated(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: widget.items.length + 1,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        header: true,
                        child:
                            widget.header ??
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                      ),
                      if (subtitleLines.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        for (final line in subtitleLines)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              line,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              }
              final item = widget.items[index - 1];
              final selected = item.value == widget.value;
              return EditorOptionTile(
                selected: selected,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(item.label),
                subtitle: item.subtitle == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(item.subtitle!),
                      ),
                trailing: selected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(context, item.value),
              );
            },
          ),
        ),
      ),
    );
  }
}

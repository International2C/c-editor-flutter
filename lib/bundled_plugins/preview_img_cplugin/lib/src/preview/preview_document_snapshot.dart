import 'package:flutter/foundation.dart' show listEquals;

import 'preview_document.dart';

/// Immutable content captured for a successful preview export.
/// Editor selection, viewport zoom and scroll offsets are not document content.
class PreviewDocumentSnapshot {
  PreviewDocumentSnapshot.capture(PreviewDocument document)
    : _values = List<Object?>.unmodifiable(_content(document));

  final List<Object?> _values;

  bool matches(PreviewDocument document) =>
      listEquals(_values, _content(document));

  static List<Object?> _style(PreviewTextStyleData? style) => [
    style != null,
    if (style != null) ...[
      style.fontFamily,
      style.fontSize,
      style.color,
      style.fontWeight,
      style.italic,
      style.underline,
      style.outline,
      style.outlineColor,
      style.outlineWidth,
    ],
  ];

  static List<Object?> _items(List<PreviewItem> items) => [
    items.length,
    for (final item in items) ...[
      item.id,
      item.assetPath,
      item.label,
      item.sourceLabel,
      item.gridX,
      item.gridY,
    ],
  ];

  static List<Object?> _content(PreviewDocument document) => [
    document.banner.kind,
    document.banner.stem,
    document.banner.userFilePath,
    document.banner.userFileBytes,
    document.banner.assetPath,
    document.levelFileName,
    document.autoStyle,
    document.orderedLayerEntries.length,
    for (final entry in document.orderedLayerEntries) ...[
      entry.isBackground,
      if (entry.layer != null) ..._layer(entry.layer!),
    ],
  ];

  static List<Object?> _layer(PreviewLayer layer) {
    // Opening a text editor can materialize legacy text as a rich-text run
    // without changing its content. Compare the effective representation.
    final runs = <({String text, List<Object?> style})>[];
    for (final run in layer.effectiveTextRuns()) {
      if (run.text.isEmpty) continue;
      final style = _style(run.style);
      if (runs.isNotEmpty && listEquals(runs.last.style, style)) {
        final previous = runs.removeLast();
        runs.add((text: previous.text + run.text, style: style));
      } else {
        runs.add((text: run.text, style: style));
      }
    }
    return [
      layer.id,
      layer.kind,
      layer.bounds,
      layer.scale,
      layer.rotation,
      layer.opacity,
      layer.visible,
      runs.length,
      for (final run in runs) ...[run.text, ...run.style],
      layer.textAlign,
      layer.textBackgroundColor,
      layer.iconAlign,
      layer.gridKind,
      layer.gridTitle,
      ..._style(layer.gridTitleStyle),
      layer.sourceLabel,
      ..._style(layer.sourceLabelStyle),
      layer.showChrome,
      layer.lawnRows,
      layer.lawnCols,
      ..._items(layer.items),
      layer.sections.length,
      for (final section in layer.sections) ...[
        section.title,
        ..._style(section.titleStyle),
        section.iconSize,
        ..._items(section.items),
        section.rows.length,
        for (final row in section.rows) ...[row.iconSize, ..._items(row.items)],
      ],
      layer.imagePath,
      layer.imageBytes,
      layer.imageAsset,
      layer.shapeKind,
      layer.shapeFilled,
      layer.fillColor,
      layer.strokeColor,
      layer.strokeWidth,
      layer.cornerRadius,
      layer.containedTexts.length,
      for (final text in layer.containedTexts) ...[
        text.id,
        text.text,
        text.bounds,
        ..._style(text.style),
        text.textAlign,
      ],
      layer.points.length,
      ...layer.points,
    ];
  }
}

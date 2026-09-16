import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/tool_repository.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_fonts.dart';

/// Design size of pre-made stage banners.
const Size kPreviewCanvasSize = Size(1144, 439);

/// Eight pixels of padding plus the one-pixel panel border on each side.
const double kPreviewIconGridChromeInset = 18;

/// Icon path for seed-bank / conveyor entries (plants, tools, plant food…).
String previewPlantLikeAssetPath(String id) {
  final plant = PlantRepository().getPlantInfoById(id);
  if (plant?.iconAssetPath != null) return plant!.iconAssetPath!;

  if (id == 'plantfood' || id == 'tool_plantfood') {
    return 'assets/images/others/plantfood.png';
  }
  if (id == 'sun' || id == 'sun_large') {
    return 'assets/images/others/sun_large.webp';
  }

  ToolCardInfo? tool = ToolRepository.get(id);
  if (tool == null && !id.startsWith('tool_')) {
    tool = ToolRepository.get('tool_$id');
  }
  final icon = tool?.icon;
  if (icon != null && icon.isNotEmpty) {
    if (icon.startsWith('assets/')) return icon;
    return 'assets/images/tools/$icon';
  }

  return 'assets/images/others/unknown.webp';
}

/// Family registered from plugin `assets/fonts/`.
const kPreviewCustomFontFamily = 'PvZPreview';

enum PreviewBannerSourceKind { stageMapped, assetStem, userFile }

enum PreviewAutoStyle { normal, simple }

enum PreviewLayerKind { text, iconGrid, image, shape, stroke }

/// The background remains a banner, but has a stable identity in layer order.
const String kPreviewBackgroundLayerId = '__preview_background__';

enum PreviewLayerOrderAction { toFront, forward, backward, toBack }

/// One item in the bottom-to-top render order, including the banner.
@immutable
class PreviewLayerOrderEntry {
  const PreviewLayerOrderEntry.background() : layer = null;

  const PreviewLayerOrderEntry.content(PreviewLayer this.layer);

  final PreviewLayer? layer;

  bool get isBackground => layer == null;

  String get id => layer?.id ?? kPreviewBackgroundLayerId;
}

enum PreviewIconGridKind { plants, zombies, gridItems, custom }

enum PreviewShapeKind { rect, oval, line, star }

enum PreviewEditTool { select, pen, eraser, figures }

enum PreviewBossKind { zombot, zomboss }

enum PreviewTextPartKind { gridTitle, sourceLabel, sectionTitle, contained }

@immutable
class PreviewTextPartSelection {
  const PreviewTextPartSelection({
    required this.layerId,
    required this.kind,
    this.sectionIndex,
    this.containedTextId,
  });

  final String layerId;
  final PreviewTextPartKind kind;
  final int? sectionIndex;
  final String? containedTextId;

  @override
  bool operator ==(Object other) =>
      other is PreviewTextPartSelection &&
      other.layerId == layerId &&
      other.kind == kind &&
      other.sectionIndex == sectionIndex &&
      other.containedTextId == containedTextId;

  @override
  int get hashCode => Object.hash(layerId, kind, sectionIndex, containedTextId);
}

/// A visual icon row, fixed only after the user edits that row.
class PreviewIconRow {
  PreviewIconRow({required this.items, required this.iconSize});

  List<PreviewItem> items;
  double iconSize;

  PreviewIconRow copy() => PreviewIconRow(
    items: items.map((item) => item.copy()).toList(),
    iconSize: iconSize,
  );
}

/// One titled block inside an icon-grid layer (boss, spawned, waves, …).
class PreviewIconSection {
  PreviewIconSection({
    this.title,
    this.titleStyle,
    List<PreviewItem>? items,
    this.iconSize = 36,
    List<PreviewIconRow>? rows,
  }) : items = items ?? <PreviewItem>[],
       rows = rows ?? <PreviewIconRow>[];

  String? title;
  PreviewTextStyleData? titleStyle;
  List<PreviewItem> items;
  double iconSize;

  /// Empty until a row edit; resizing the whole group resumes automatic reflow.
  List<PreviewIconRow> rows;

  PreviewIconSection copy() => PreviewIconSection(
    title: title,
    titleStyle: titleStyle?.copy(),
    items: items.map((e) => e.copy()).toList(),
    iconSize: iconSize,
    rows: rows.map((row) => row.copy()).toList(),
  );
}

/// Resolves the same visual rows used by the canvas and intrinsic measurement.
/// Explicit rows preserve membership when one row is resized independently.
List<PreviewIconRow> previewIconSectionRows(
  PreviewIconSection section, {
  required double maxWidth,
  double spacing = 4,
}) {
  if (section.rows.isNotEmpty) return section.rows;
  final perRow = ((maxWidth + spacing) / (section.iconSize + spacing))
      .floor()
      .clamp(1, 64);
  return [
    for (var start = 0; start < section.items.length; start += perRow)
      PreviewIconRow(
        items: section.items.sublist(
          start,
          math.min(start + perRow, section.items.length),
        ),
        iconSize: section.iconSize,
      ),
  ];
}

/// Keeps fixed row members within their available editing width.
double previewIconRowMaximumSize(
  PreviewIconRow row, {
  required double maxWidth,
  double spacing = 4,
}) {
  if (row.items.isEmpty) return 152;
  return ((maxWidth - (row.items.length - 1) * spacing) / row.items.length)
      .clamp(20.0, 152.0);
}

double previewIconRowMaximumSizeInLayer(
  PreviewLayer layer,
  PreviewIconRow row,
) {
  final scale = layer.scale.clamp(0.25, 4.0).toDouble();
  final chrome = layer.showChrome ? kPreviewIconGridChromeInset : 0.0;
  final availableWidth =
      kPreviewCanvasSize.width * (1 - layer.bounds.left) / scale;
  final availableHeight =
      kPreviewCanvasSize.height * (1 - layer.bounds.top) / scale;
  final content = previewIconGridIntrinsicSize(
    maxWidth: layer.bounds.width * kPreviewCanvasSize.width,
    sections: previewEffectiveSections(layer),
    showChrome: layer.showChrome,
    gridTitle: layer.gridTitle,
    gridTitleStyle: layer.gridTitleStyle,
    sourceLabel: layer.sourceLabel,
    sourceLabelStyle: layer.sourceLabelStyle,
    iconAlign: layer.iconAlign,
  );
  final maximum = math.min(
    (availableHeight - content.height + row.iconSize).clamp(20.0, 152.0),
    previewIconRowMaximumSize(
      row,
      maxWidth: availableWidth - chrome,
      spacing: layer.iconAlign == TextAlign.justify ? 0 : 4,
    ),
  );
  final cosine = math.cos(layer.rotation).abs();
  final sine = math.sin(layer.rotation).abs();
  if (sine < 1e-8 && (math.cos(layer.rotation) - 1).abs() < 1e-8) {
    return maximum;
  }

  final baseWidth = layer.bounds.width * kPreviewCanvasSize.width;
  final spacing = layer.iconAlign == TextAlign.justify ? 0.0 : 4.0;
  final sections = previewEffectiveSections(layer);
  final candidateSections = sections.map((section) => section.copy()).toList();
  PreviewIconRow? candidateRow;
  for (var sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
    final rows = previewIconSectionRows(
      sections[sectionIndex],
      maxWidth: baseWidth - chrome,
      spacing: spacing,
    );
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final original = rows[rowIndex];
      if (identical(original, row) ||
          (original.items.length == row.items.length &&
              original.items.asMap().entries.every(
                (entry) => identical(entry.value, row.items[entry.key]),
              ))) {
        candidateSections[sectionIndex].rows = rows
            .map((original) => original.copy())
            .toList();
        candidateRow = candidateSections[sectionIndex].rows[rowIndex];
        break;
      }
    }
    if (candidateRow != null) break;
  }

  bool fitsRotatedCanvas(double size) {
    final width = math.max(
      baseWidth,
      row.items.length * size +
          math.max(0, row.items.length - 1) * spacing +
          chrome,
    );
    candidateRow?.iconSize = size;
    // Use the resulting content height: widening can reflow other sections or
    // source text, changing the rotation center as well as its footprint.
    final contentHeight = candidateRow == null
        ? content.height + size - row.iconSize
        : previewIconGridIntrinsicSize(
            maxWidth: width,
            sections: candidateSections,
            showChrome: layer.showChrome,
            gridTitle: layer.gridTitle,
            gridTitleStyle: layer.gridTitleStyle,
            sourceLabel: layer.sourceLabel,
            sourceLabelStyle: layer.sourceLabelStyle,
            iconAlign: layer.iconAlign,
          ).height;
    final height = math.max(
      layer.bounds.height * kPreviewCanvasSize.height,
      contentHeight,
    );
    final visibleWidth = width * scale;
    final visibleHeight = height * scale;
    final center = Offset(
      layer.bounds.left * kPreviewCanvasSize.width + visibleWidth / 2,
      layer.bounds.top * kPreviewCanvasSize.height + visibleHeight / 2,
    );
    final halfWidth = (cosine * visibleWidth + sine * visibleHeight) / 2;
    final halfHeight = (sine * visibleWidth + cosine * visibleHeight) / 2;
    return center.dx - halfWidth >= 0 &&
        center.dy - halfHeight >= 0 &&
        center.dx + halfWidth <= kPreviewCanvasSize.width &&
        center.dy + halfHeight <= kPreviewCanvasSize.height;
  }

  if (fitsRotatedCanvas(maximum)) return maximum;
  var lower = row.iconSize.clamp(20.0, maximum).toDouble();
  if (!fitsRotatedCanvas(lower)) {
    lower = 20.0;
    // An already overflowing layer has no safe enlargement to offer. Keep its
    // current size rather than introducing a new enlargement in that case.
    if (!fitsRotatedCanvas(lower)) return row.iconSize.clamp(20.0, maximum);
  }
  var upper = maximum;
  for (var iteration = 0; iteration < 24; iteration++) {
    final middle = (lower + upper) / 2;
    if (fitsRotatedCanvas(middle)) {
      lower = middle;
    } else {
      upper = middle;
    }
  }
  return fitsRotatedCanvas(lower) ? lower : row.iconSize.clamp(20.0, maximum);
}

/// Materializes legacy item-only grids when editing needs persistent sections.
List<PreviewIconSection> previewEditableSections(PreviewLayer layer) {
  if (layer.sections.isEmpty && layer.items.isNotEmpty) {
    layer.sections.add(PreviewIconSection(items: List.of(layer.items)));
  }
  return layer.sections;
}

/// Sets the icon size for the entire group and resumes automatic row wrapping.
/// Explicit rows from earlier edits are flattened without losing visible items.
void resizePreviewIconGroup(PreviewLayer layer, double iconSize) {
  if (layer.kind != PreviewLayerKind.iconGrid || !iconSize.isFinite) return;
  for (final section in previewEditableSections(layer)) {
    if (section.rows.isNotEmpty) {
      section.items = [for (final row in section.rows) ...row.items];
      section.rows.clear();
    }
    section.iconSize = iconSize.clamp(20.0, 152.0);
  }
}

/// Changes only the chosen visual row and persists its original row membership.
void resizePreviewIconRow(
  PreviewLayer layer,
  int sectionIndex,
  int rowIndex,
  double iconSize,
) {
  if (layer.kind != PreviewLayerKind.iconGrid || !iconSize.isFinite) return;
  final sections = previewEditableSections(layer);
  if (sectionIndex < 0 || sectionIndex >= sections.length) return;
  final section = sections[sectionIndex];
  final width =
      layer.bounds.width * kPreviewCanvasSize.width -
      (layer.showChrome ? kPreviewIconGridChromeInset : 0);
  final spacing = layer.iconAlign == TextAlign.justify ? 0.0 : 4.0;
  if (section.rows.isEmpty) {
    section.rows = previewIconSectionRows(
      section,
      maxWidth: width,
      spacing: spacing,
    );
  }
  if (rowIndex < 0 || rowIndex >= section.rows.length) return;
  final row = section.rows[rowIndex];
  final chrome = layer.showChrome ? kPreviewIconGridChromeInset : 0.0;
  final availableWidth =
      kPreviewCanvasSize.width *
      (1 - layer.bounds.left) /
      layer.scale.clamp(0.25, 4.0);
  row.iconSize = iconSize.clamp(
    20.0,
    previewIconRowMaximumSizeInLayer(layer, row),
  );
  final requiredWidth =
      row.items.length * row.iconSize +
      math.max(0, row.items.length - 1) * spacing +
      chrome;
  layer.bounds = Rect.fromLTWH(
    layer.bounds.left,
    layer.bounds.top,
    math
            .max(layer.bounds.width * kPreviewCanvasSize.width, requiredWidth)
            .clamp(0.0, availableWidth) /
        kPreviewCanvasSize.width,
    layer.bounds.height,
  );
}

/// Intrinsic pixel size for an icon-grid layer at [maxWidth].
Size previewIconGridIntrinsicSize({
  required double maxWidth,
  required List<PreviewIconSection> sections,
  bool showChrome = true,
  String? gridTitle,
  PreviewTextStyleData? gridTitleStyle,
  String? sourceLabel,
  PreviewTextStyleData? sourceLabelStyle,
  int? lawnRows,
  int? lawnCols,
  TextAlign iconAlign = TextAlign.left,
}) {
  const pad = kPreviewIconGridChromeInset / 2;
  const sectionGap = 8.0;
  const iconSpacing = 4.0;
  final innerMax = showChrome
      ? (maxWidth - pad * 2).clamp(8.0, maxWidth)
      : maxWidth.clamp(8.0, double.infinity);

  var contentW = 0.0;
  var contentH = 0.0;

  double styledTextHeight(String text, PreviewTextStyleData style) {
    final inset = previewPanelTextOutlineInset(style);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: PreviewFonts.resolve(style, fill: true),
      ),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout(maxWidth: math.max(1.0, innerMax - inset * 2));
    final height = painter.height + inset * 2;
    painter.dispose();
    return height;
  }

  if (showChrome) {
    double textHeight(String text, TextStyle style, int maxLines) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
        maxLines: maxLines,
        ellipsis: '…',
      )..layout(maxWidth: innerMax);
      final height = painter.height;
      painter.dispose();
      return height;
    }

    if (gridTitle != null && gridTitle.isNotEmpty) {
      contentH += gridTitleStyle == null
          ? textHeight(
              gridTitle,
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              1,
            )
          : styledTextHeight(gridTitle, gridTitleStyle);
    }
    if (sourceLabel != null && sourceLabel.isNotEmpty) {
      contentH += sourceLabelStyle == null
          ? textHeight(
              sourceLabel,
              const TextStyle(fontSize: 11, height: 1.25),
              6,
            )
          : styledTextHeight(sourceLabel, sourceLabelStyle);
    }
    if (contentH > 0) contentH += 4; // SizedBox after headers
  }

  final useLawn =
      lawnRows != null &&
      lawnCols != null &&
      lawnRows > 0 &&
      lawnCols > 0 &&
      sections.any((s) => s.items.any((i) => i.hasCell));

  if (useLawn) {
    final lawnH = innerMax / ((lawnCols / lawnRows) * 1.0);
    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      if (section.items.isEmpty) continue;
      if (contentH > 0 && (i > 0 || showChrome)) contentH += sectionGap;
      if (section.title != null && section.title!.isNotEmpty) {
        final titleSize = section.iconSize >= 64 ? 15.0 : 13.0;
        contentH +=
            (section.titleStyle == null
                ? titleSize * 1.25 * 2
                : styledTextHeight(section.title!, section.titleStyle!)) +
            4;
      }
      contentH += lawnH;
      contentW = math.max(contentW, innerMax);
    }
    final totalH = contentH + (showChrome ? pad * 2 : 0);
    return Size(maxWidth, totalH.clamp(24.0, 4096.0));
  }

  for (var i = 0; i < sections.length; i++) {
    final section = sections[i];
    if (section.items.isEmpty &&
        (section.title == null || section.title!.isEmpty)) {
      continue;
    }
    if (contentH > 0 && (i > 0 || showChrome)) contentH += sectionGap;
    if (section.title != null && section.title!.isNotEmpty) {
      // Title Text maxLines:2 + bottom padding 4.
      final titleSize = section.iconSize >= 64 ? 15.0 : 13.0;
      contentH +=
          (section.titleStyle == null
              ? titleSize * 1.25 * 2
              : styledTextHeight(section.title!, section.titleStyle!)) +
          4;
    }
    final spacing = iconAlign == TextAlign.justify ? 0.0 : iconSpacing;
    final rows = previewIconSectionRows(
      section,
      maxWidth: innerMax,
      spacing: spacing,
    );
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      final rowW =
          row.items.length * row.iconSize +
          math.max(0, row.items.length - 1) * spacing;
      contentW = math.max(contentW, rowW);
      contentH += row.iconSize + (rowIndex > 0 ? iconSpacing : 0);
    }
  }

  if (contentW <= 0) contentW = 40;
  if (contentH <= 0) contentH = 40;
  // Slack for strut / rounding so ClipRect never eats the last row.
  contentH += 16;

  if (showChrome) {
    return Size(contentW + pad * 2, contentH + pad * 2);
  }
  return Size(contentW, contentH);
}

List<PreviewIconSection> previewEffectiveSections(PreviewLayer layer) {
  if (layer.sections.isNotEmpty) return layer.sections;
  if (layer.items.isEmpty) return const [];
  return [PreviewIconSection(items: layer.items)];
}

class PreviewBannerRef {
  PreviewBannerRef({
    required this.kind,
    this.stem,
    this.userFilePath,
    this.userFileBytes,
    this.assetPath,
  });

  PreviewBannerSourceKind kind;
  String? stem;
  String? userFilePath;
  Uint8List? userFileBytes;
  String? assetPath;

  PreviewBannerRef copy() => PreviewBannerRef(
    kind: kind,
    stem: stem,
    userFilePath: userFilePath,
    userFileBytes: userFileBytes,
    assetPath: assetPath,
  );
}

class PreviewItem {
  PreviewItem({
    required this.id,
    required this.assetPath,
    this.label,
    this.sourceLabel,
    this.gridX,
    this.gridY,
  });

  final String id;
  final String assetPath;
  final String? label;
  final String? sourceLabel;

  /// Lawn-cell column when this item is placed on a mini lawn grid.
  final int? gridX;

  /// Lawn-cell row when this item is placed on a mini lawn grid.
  final int? gridY;

  bool get hasCell => gridX != null && gridY != null;

  PreviewItem copy() => PreviewItem(
    id: id,
    assetPath: assetPath,
    label: label,
    sourceLabel: sourceLabel,
    gridX: gridX,
    gridY: gridY,
  );
}

class PreviewTextStyleData {
  PreviewTextStyleData({
    this.fontFamily = kPreviewCustomFontFamily,
    this.fontSize = 32,
    this.color = const Color(0xFFFFFFFF),
    this.fontWeight = FontWeight.bold,
    this.italic = false,
    this.underline = false,
    this.outline = true,
    this.outlineColor = const Color(0xFF000000),
    this.outlineWidth = 3,
  });

  /// Defaults to the plugin font (`FBUSV8C5EI.ttf` / [kPreviewCustomFontFamily]).
  String? fontFamily;
  double fontSize;
  Color color;
  FontWeight fontWeight;
  bool italic;
  bool underline;
  bool outline;
  Color outlineColor;
  double outlineWidth;

  PreviewTextStyleData copy() => PreviewTextStyleData(
    fontFamily: fontFamily,
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
    italic: italic,
    underline: underline,
    outline: outline,
    outlineColor: outlineColor,
    outlineWidth: outlineWidth,
  );
}

/// Legacy panel label appearance; returned styles are independent editing drafts.
PreviewTextStyleData previewDefaultPanelTextStyle(
  PreviewTextPartKind kind, {
  double sectionIconSize = 36,
}) => switch (kind) {
  PreviewTextPartKind.gridTitle => PreviewTextStyleData(
    fontFamily: null,
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w600,
    outline: false,
  ),
  PreviewTextPartKind.sourceLabel => PreviewTextStyleData(
    fontFamily: null,
    fontSize: 11,
    color: Colors.white.withValues(alpha: 0.85),
    fontWeight: FontWeight.w400,
    outline: false,
  ),
  PreviewTextPartKind.sectionTitle => PreviewTextStyleData(
    fontFamily: null,
    fontSize: sectionIconSize >= 64 ? 15 : 13,
    color: Colors.white.withValues(alpha: 0.95),
    fontWeight: FontWeight.w600,
    outline: false,
  ),
  PreviewTextPartKind.contained => throw ArgumentError.value(kind, 'kind'),
};

/// Reserve the same stroke gutter in panel text layout and intrinsic measurement.
double previewPanelTextOutlineInset(PreviewTextStyleData style) {
  if (!style.outline) return 0;
  final width =
      style.outlineWidth + (PreviewFonts.needsSyntheticBold(style) ? 1.25 : 0);
  return math.max(0.0, width / 2);
}

/// Editable text positioned inside an icon panel, rectangle, or oval.
class PreviewContainedText {
  PreviewContainedText({
    required this.id,
    required this.text,
    this.bounds = const Rect.fromLTWH(0.1, 0.25, 0.8, 0.5),
    PreviewTextStyleData? style,
    this.textAlign = TextAlign.center,
  }) : style = style ?? PreviewTextStyleData(fontSize: 24);

  final String id;
  String text;

  /// Bounds normalized to the containing layer.
  Rect bounds;
  PreviewTextStyleData style;
  TextAlign textAlign;

  PreviewContainedText copy() => PreviewContainedText(
    id: id,
    text: text,
    bounds: bounds,
    style: style.copy(),
    textAlign: textAlign,
  );
}

/// One contiguous styled run inside a text layer.
class PreviewTextRun {
  PreviewTextRun({required this.text, PreviewTextStyleData? style})
    : style = style ?? PreviewTextStyleData();

  String text;
  PreviewTextStyleData style;

  PreviewTextRun copy() => PreviewTextRun(text: text, style: style.copy());
}

/// Unified canvas object — titles, themes, icon grids, overlays, shapes, strokes.
///
/// [bounds] uses normalized coordinates (0–1) relative to [kPreviewCanvasSize].
class PreviewLayer {
  PreviewLayer({
    required this.id,
    required this.kind,
    required this.bounds,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.visible = true,
    this.zIndex = 0,
    this.text,
    this.textStyle,
    List<PreviewTextRun>? textRuns,
    this.textAlign = TextAlign.left,
    this.textBackgroundColor,
    this.iconAlign = TextAlign.left,
    this.gridKind,
    this.gridTitle,
    this.gridTitleStyle,
    this.sourceLabel,
    this.sourceLabelStyle,
    this.showChrome = true,
    this.lawnRows,
    this.lawnCols,
    List<PreviewItem>? items,
    List<PreviewIconSection>? sections,
    this.imagePath,
    this.imageBytes,
    this.imageAsset,
    this.shapeKind,
    this.shapeFilled = false,
    this.fillColor,
    this.strokeColor = const Color(0xFFFFFFFF),
    this.strokeWidth = 3,
    this.cornerRadius = 0,
    List<PreviewContainedText>? containedTexts,
    List<Offset>? points,
  }) : items = items ?? <PreviewItem>[],
       sections = sections ?? <PreviewIconSection>[],
       containedTexts = containedTexts ?? <PreviewContainedText>[],
       points = points ?? <Offset>[],
       textRuns = textRuns ?? <PreviewTextRun>[];

  final String id;
  PreviewLayerKind kind;
  Rect bounds;
  double scale;

  /// Clockwise radians around the layer center.
  double rotation;

  /// 0–1; applied to the whole layer when painting.
  double opacity;
  bool visible;
  int zIndex;

  // text
  String? text;
  PreviewTextStyleData? textStyle;

  /// Styled runs; when empty, [text] + [textStyle] are used as a single run.
  List<PreviewTextRun> textRuns;
  TextAlign textAlign;

  /// Optional solid background behind text (independent of fill text color).
  Color? textBackgroundColor;

  /// Horizontal alignment for icon-grid content (icons / section titles).
  TextAlign iconAlign;

  // icon grid
  PreviewIconGridKind? gridKind;
  String? gridTitle;
  PreviewTextStyleData? gridTitleStyle;
  String? sourceLabel;
  PreviewTextStyleData? sourceLabelStyle;
  bool showChrome;

  /// When set with [lawnCols], icon-grid content is painted as a mini lawn.
  int? lawnRows;
  int? lawnCols;
  List<PreviewItem> items;
  List<PreviewIconSection> sections;

  // image overlay
  String? imagePath;
  Uint8List? imageBytes;
  String? imageAsset;

  // shape
  PreviewShapeKind? shapeKind;
  bool shapeFilled;
  Color? fillColor;
  Color strokeColor;
  double strokeWidth;
  double cornerRadius;

  // text contained by icon panels and shapes
  List<PreviewContainedText> containedTexts;

  // freehand (normalized canvas coords)
  List<Offset> points;

  String get plainText {
    if (textRuns.isNotEmpty) {
      return textRuns.map((r) => r.text).join();
    }
    return text ?? '';
  }

  List<PreviewTextRun> effectiveTextRuns() {
    if (textRuns.isNotEmpty) return textRuns;
    final t = text ?? '';
    if (t.isEmpty) return const [];
    return [
      PreviewTextRun(
        text: t,
        style: (textStyle ?? PreviewTextStyleData()).copy(),
      ),
    ];
  }

  void ensureTextRuns() {
    if (textRuns.isNotEmpty) return;
    final t = text ?? '';
    textRuns = [
      PreviewTextRun(
        text: t,
        style: (textStyle ?? PreviewTextStyleData()).copy(),
      ),
    ];
  }

  void setPlainText(String value) {
    ensureTextRuns();
    if (textRuns.length == 1) {
      textRuns.first.text = value;
    } else {
      final style = textRuns.isNotEmpty
          ? textRuns.first.style.copy()
          : (textStyle ?? PreviewTextStyleData()).copy();
      textRuns = [PreviewTextRun(text: value, style: style)];
    }
    text = value;
    textStyle = textRuns.first.style.copy();
  }

  /// Updates plain text while preserving per-run styles around the edit.
  ///
  /// Inserted characters use [typingStyle] when provided; otherwise they inherit
  /// the style of the character before the caret (or the first character when
  /// inserting at the start).
  void updatePlainTextPreservingStyles(
    String newValue, {
    PreviewTextStyleData? typingStyle,
  }) {
    ensureTextRuns();
    final oldValue = plainText;
    if (newValue == oldValue) {
      text = newValue;
      return;
    }
    if (textRuns.length == 1 && typingStyle == null) {
      textRuns.first.text = newValue;
      text = newValue;
      textStyle = textRuns.first.style.copy();
      return;
    }

    var prefix = 0;
    final maxPrefix = math.min(oldValue.length, newValue.length);
    while (prefix < maxPrefix && oldValue[prefix] == newValue[prefix]) {
      prefix++;
    }
    var oldEnd = oldValue.length;
    var newEnd = newValue.length;
    while (oldEnd > prefix &&
        newEnd > prefix &&
        oldValue[oldEnd - 1] == newValue[newEnd - 1]) {
      oldEnd--;
      newEnd--;
    }

    final charStyles = <PreviewTextStyleData>[];
    for (final run in textRuns) {
      for (var i = 0; i < run.text.length; i++) {
        charStyles.add(run.style);
      }
    }

    final fallback =
        (textStyle ??
                (charStyles.isNotEmpty
                    ? charStyles.first
                    : PreviewTextStyleData()))
            .copy();
    // Inherit previous character; at the start, inherit the first character.
    final inherited = prefix > 0 && prefix <= charStyles.length
        ? charStyles[prefix - 1].copy()
        : (charStyles.isNotEmpty ? charStyles.first.copy() : fallback);
    final insertStyle = typingStyle?.copy() ?? inherited;

    final nextStyles = <PreviewTextStyleData>[];
    for (var i = 0; i < prefix; i++) {
      nextStyles.add(charStyles[i].copy());
    }
    for (var i = prefix; i < newEnd; i++) {
      nextStyles.add(insertStyle.copy());
    }
    for (var i = oldEnd; i < oldValue.length; i++) {
      nextStyles.add(charStyles[i].copy());
    }

    final next = <PreviewTextRun>[];
    for (var i = 0; i < newValue.length; i++) {
      final ch = newValue[i];
      final style = i < nextStyles.length ? nextStyles[i] : fallback;
      if (next.isNotEmpty && _sameTextStyle(next.last.style, style)) {
        next.last.text += ch;
      } else {
        next.add(PreviewTextRun(text: ch, style: style.copy()));
      }
    }
    textRuns = next.isEmpty
        ? [PreviewTextRun(text: '', style: fallback)]
        : next;
    text = plainText;
    textStyle = textRuns.first.style.copy();
  }

  static bool _sameTextStyle(PreviewTextStyleData a, PreviewTextStyleData b) {
    return a.fontFamily == b.fontFamily &&
        a.fontSize == b.fontSize &&
        a.fontWeight == b.fontWeight &&
        a.italic == b.italic &&
        a.underline == b.underline &&
        a.outline == b.outline &&
        a.color == b.color;
  }

  /// Applies [mutate] to the style of characters in `[start, end)`.
  void applyStyleToRange(
    int start,
    int end,
    void Function(PreviewTextStyleData style) mutate,
  ) {
    ensureTextRuns();
    final plain = plainText;
    final s = start.clamp(0, plain.length);
    final e = end.clamp(0, plain.length);
    if (s >= e) {
      for (final run in textRuns) {
        mutate(run.style);
      }
      textStyle = textRuns.first.style.copy();
      return;
    }

    final next = <PreviewTextRun>[];
    var cursor = 0;
    for (final run in textRuns) {
      final runStart = cursor;
      final runEnd = cursor + run.text.length;
      cursor = runEnd;
      if (runEnd <= s || runStart >= e) {
        next.add(run.copy());
        continue;
      }
      final localStart = (s - runStart).clamp(0, run.text.length);
      final localEnd = (e - runStart).clamp(0, run.text.length);
      if (localStart > 0) {
        next.add(
          PreviewTextRun(
            text: run.text.substring(0, localStart),
            style: run.style.copy(),
          ),
        );
      }
      final mid = PreviewTextRun(
        text: run.text.substring(localStart, localEnd),
        style: run.style.copy(),
      );
      mutate(mid.style);
      if (mid.text.isNotEmpty) next.add(mid);
      if (localEnd < run.text.length) {
        next.add(
          PreviewTextRun(
            text: run.text.substring(localEnd),
            style: run.style.copy(),
          ),
        );
      }
    }
    textRuns = next.where((r) => r.text.isNotEmpty).toList();
    if (textRuns.isEmpty) {
      textRuns = [
        PreviewTextRun(
          text: '',
          style: (textStyle ?? PreviewTextStyleData()).copy(),
        ),
      ];
    }
    text = plainText;
    textStyle = textRuns.first.style.copy();
  }

  PreviewLayer copy() => PreviewLayer(
    id: id,
    kind: kind,
    bounds: bounds,
    scale: scale,
    rotation: rotation,
    opacity: opacity,
    visible: visible,
    zIndex: zIndex,
    text: text,
    textStyle: textStyle?.copy(),
    textRuns: textRuns.map((e) => e.copy()).toList(),
    textAlign: textAlign,
    textBackgroundColor: textBackgroundColor,
    iconAlign: iconAlign,
    gridKind: gridKind,
    gridTitle: gridTitle,
    gridTitleStyle: gridTitleStyle?.copy(),
    sourceLabel: sourceLabel,
    sourceLabelStyle: sourceLabelStyle?.copy(),
    showChrome: showChrome,
    lawnRows: lawnRows,
    lawnCols: lawnCols,
    items: items.map((e) => e.copy()).toList(),
    sections: sections.map((e) => e.copy()).toList(),
    imagePath: imagePath,
    imageBytes: imageBytes,
    imageAsset: imageAsset,
    shapeKind: shapeKind,
    shapeFilled: shapeFilled,
    fillColor: fillColor,
    strokeColor: strokeColor,
    strokeWidth: strokeWidth,
    cornerRadius: cornerRadius,
    containedTexts: containedTexts.map((e) => e.copy()).toList(),
    points: List<Offset>.from(points),
  );
}

class PreviewDocument {
  PreviewDocument({
    required this.banner,
    List<PreviewLayer>? layers,
    this.backgroundZIndex,
    this.levelFileName = 'preview',
    this.autoStyle = PreviewAutoStyle.normal,
  }) : layers = layers ?? <PreviewLayer>[];

  PreviewBannerRef banner;
  List<PreviewLayer> layers;

  /// Null preserves legacy documents: the banner is below every content layer,
  /// even if their original z-indices are negative. Reordering stores a rank.
  int? backgroundZIndex;

  String levelFileName;
  PreviewAutoStyle autoStyle;

  PreviewLayer? layerById(String id) {
    for (final l in layers) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// A deterministic bottom-to-top order shared by editing and export.
  /// Original list position breaks ties without mutating legacy documents.
  List<PreviewLayerOrderEntry> get orderedLayerEntries {
    final indexed = <({PreviewLayerOrderEntry entry, int index, int rank})>[
      if (backgroundZIndex != null)
        (
          entry: const PreviewLayerOrderEntry.background(),
          index: -1,
          rank: backgroundZIndex!,
        ),
      for (var index = 0; index < layers.length; index++)
        (
          entry: PreviewLayerOrderEntry.content(layers[index]),
          index: index,
          rank: layers[index].zIndex,
        ),
    ];
    indexed.sort((a, b) {
      final rankComparison = a.rank.compareTo(b.rank);
      return rankComparison != 0 ? rankComparison : a.index.compareTo(b.index);
    });
    return [
      if (backgroundZIndex == null) const PreviewLayerOrderEntry.background(),
      for (final item in indexed) item.entry,
    ];
  }

  /// Content-only compatibility view of the same render order.
  List<PreviewLayer> get sortedLayers => [
    for (final entry in orderedLayerEntries)
      if (entry.layer != null) entry.layer!,
  ];

  bool canMoveLayer(String id, PreviewLayerOrderAction action) {
    final entries = orderedLayerEntries;
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index < 0) return false;
    return switch (action) {
      PreviewLayerOrderAction.toFront ||
      PreviewLayerOrderAction.forward => index < entries.length - 1,
      PreviewLayerOrderAction.backward ||
      PreviewLayerOrderAction.toBack => index > 0,
    };
  }

  bool moveLayer(String id, PreviewLayerOrderAction action) {
    final entries = orderedLayerEntries;
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index < 0) return false;
    final target = switch (action) {
      PreviewLayerOrderAction.toFront => entries.length - 1,
      PreviewLayerOrderAction.forward => index + 1,
      PreviewLayerOrderAction.backward => index - 1,
      PreviewLayerOrderAction.toBack => 0,
    };
    return moveLayerToIndex(id, target);
  }

  /// Moves an item to its final zero-based bottom-to-top index.
  /// Invalid identities, out-of-range targets and unchanged order are no-ops.
  bool moveLayerToIndex(String id, int index) {
    final entries = orderedLayerEntries;
    final original = entries.indexWhere((entry) => entry.id == id);
    if (original < 0 ||
        index < 0 ||
        index >= entries.length ||
        original == index) {
      return false;
    }
    final entry = entries.removeAt(original);
    entries.insert(index, entry);
    _writeLayerOrder(entries);
    return true;
  }

  /// Applies a complete bottom-to-top permutation, including the background.
  /// Rejects incomplete, repeated or unknown identities before any mutation.
  bool reorderLayers(List<String> bottomToTopIds) {
    final entries = orderedLayerEntries;
    final byId = {for (final entry in entries) entry.id: entry};
    final requested = bottomToTopIds.toSet();
    if (byId.length != entries.length ||
        bottomToTopIds.length != entries.length ||
        requested.length != entries.length ||
        requested.any((id) => !byId.containsKey(id))) {
      throw ArgumentError.value(
        bottomToTopIds,
        'bottomToTopIds',
        'Must contain each current layer and the background exactly once.',
      );
    }
    var changed = false;
    for (var index = 0; index < entries.length; index++) {
      if (entries[index].id != bottomToTopIds[index]) {
        changed = true;
        break;
      }
    }
    if (!changed) return false;
    _writeLayerOrder([for (final id in bottomToTopIds) byId[id]!]);
    return true;
  }

  /// New content is always above all existing content and the background.
  void addLayer(PreviewLayer layer) {
    if (layer.id == kPreviewBackgroundLayerId || layerById(layer.id) != null) {
      throw ArgumentError.value(
        layer.id,
        'layer.id',
        'Content layers need a unique, non-background identity.',
      );
    }
    final entries = orderedLayerEntries;
    layers.add(layer);
    _writeLayerOrder([...entries, PreviewLayerOrderEntry.content(layer)]);
  }

  void _writeLayerOrder(List<PreviewLayerOrderEntry> entries) {
    for (var index = 0; index < entries.length; index++) {
      final layer = entries[index].layer;
      if (layer == null) {
        backgroundZIndex = index;
      } else {
        layer.zIndex = index;
      }
    }
  }

  /// Convenience for editors that still think in title/subtitle.
  String get titleText =>
      layerById('title')?.text ?? layerById('theme')?.text ?? '';

  set titleText(String v) {
    final t = layerById('title') ?? layerById('theme');
    if (t != null) t.text = v;
  }

  String get subtitleText => layerById('subtitle')?.text ?? '';

  set subtitleText(String v) {
    final s = layerById('subtitle');
    if (s != null) s.text = v;
  }

  PreviewDocument copy() => PreviewDocument(
    banner: banner.copy(),
    layers: layers.map((l) => l.copy()).toList(),
    backgroundZIndex: backgroundZIndex,
    levelFileName: levelFileName,
    autoStyle: autoStyle,
  );
}

/// @deprecated Prefer [PreviewLayer] with [PreviewLayerKind.iconGrid].
typedef PreviewPresentationModule = PreviewLayer;

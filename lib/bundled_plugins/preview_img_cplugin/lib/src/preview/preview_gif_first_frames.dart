import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:c_editor/data/repository/level_repository.dart';

import 'preview_document.dart';
import 'preview_png_exporter.dart';

/// Paths share the same identity used by the canvas' image-frame overrides.
class PreviewGifSource {
  const PreviewGifSource(this.path, {required this.isAsset, this.bytes});

  final String path;
  final bool isAsset;
  final Uint8List? bytes;
}

List<PreviewGifSource> previewDocumentGifSources(PreviewDocument document) {
  final sources = <String, PreviewGifSource>{};
  void add(String? path, {required bool isAsset, Uint8List? bytes}) {
    if (path == null || !path.toLowerCase().endsWith('.gif')) return;
    sources.putIfAbsent(
      path,
      () => PreviewGifSource(path, isAsset: isAsset, bytes: bytes),
    );
  }

  final banner = document.banner;
  if (banner.kind == PreviewBannerSourceKind.userFile) {
    add(banner.userFilePath, isAsset: false, bytes: banner.userFileBytes);
  } else {
    add(banner.assetPath, isAsset: true);
  }
  for (final layer in document.layers.where((layer) => layer.visible)) {
    if (layer.kind == PreviewLayerKind.image) {
      if (layer.imagePath != null) {
        add(layer.imagePath, isAsset: false, bytes: layer.imageBytes);
      } else {
        add(layer.imageAsset, isAsset: true);
      }
    } else if (layer.kind == PreviewLayerKind.iconGrid) {
      final sections = previewEffectiveSections(layer);
      final useLawn =
          layer.lawnRows != null &&
          layer.lawnCols != null &&
          layer.lawnRows! > 0 &&
          layer.lawnCols! > 0 &&
          sections.any((section) => section.items.any((item) => item.hasCell));
      for (final section in sections) {
        final items = useLawn || section.rows.isEmpty
            ? section.items
            : [for (final row in section.rows) ...row.items];
        for (final item in items) {
          add(item.assetPath, isAsset: true);
        }
      }
    }
  }
  return sources.values.toList(growable: false);
}

typedef PreviewGifBytesLoader = Future<Uint8List> Function(PreviewGifSource);

Future<Uint8List> _loadSource(PreviewGifSource source) async {
  if (source.bytes != null && source.bytes!.isNotEmpty) {
    return source.bytes!;
  }
  if (source.isAsset) {
    final data = await rootBundle.load(source.path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
  final bytes = await LevelRepository.readLibraryFileBytes(source.path);
  if (bytes == null) {
    throw const PreviewPngExportException(PreviewPngExportFailure.encoding);
  }
  return bytes;
}

/// Decodes exactly one frame per visible GIF for a deterministic PNG capture.
/// The caller owns these images until the canvas no longer references them.
class PreviewGifFirstFrames {
  PreviewGifFirstFrames._(this.images);

  final Map<String, ui.Image> images;

  static Future<PreviewGifFirstFrames> load(
    PreviewDocument document, {
    PreviewGifBytesLoader? bytesLoader,
  }) async {
    final images = <String, ui.Image>{};
    try {
      for (final source in previewDocumentGifSources(document)) {
        final bytes = await (bytesLoader ?? _loadSource)(source);
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        ui.ImageDescriptor? descriptor;
        ui.Codec? codec;
        try {
          descriptor = await ui.ImageDescriptor.encoded(buffer);
          // Bound source decoding by the full-resolution PNG canvas, without
          // reducing the quality of ordinary stickers or background images.
          final scale = math.min(
            1.0,
            math.min(
              kPreviewCanvasSize.width * 2 / descriptor.width,
              kPreviewCanvasSize.height * 2 / descriptor.height,
            ),
          );
          codec = await descriptor.instantiateCodec(
            targetWidth: math.max(1, (descriptor.width * scale).round()),
            targetHeight: math.max(1, (descriptor.height * scale).round()),
          );
          final frame = await codec.getNextFrame();
          images[source.path] = frame.image;
        } finally {
          codec?.dispose();
          descriptor?.dispose();
          buffer.dispose();
        }
      }
      return PreviewGifFirstFrames._(images);
    } catch (_) {
      for (final image in images.values) {
        image.dispose();
      }
      rethrow;
    }
  }

  void dispose() {
    for (final image in images.values) {
      image.dispose();
    }
    images.clear();
  }
}

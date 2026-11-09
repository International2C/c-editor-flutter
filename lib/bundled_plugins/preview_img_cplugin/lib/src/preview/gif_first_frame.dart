import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Decodes the first frame of a GIF (or any multi-frame image) as a static
/// [ui.Image]. Non-GIF assets are decoded as a single frame.
Future<ui.Image?> decodeFirstFrameFromAsset(String assetPath) async {
  try {
    final data = await rootBundle.load(assetPath);
    return await decodeFirstFrameFromBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  } catch (e, st) {
    debugPrint('gif_first_frame: failed to load $assetPath: $e\n$st');
    return null;
  }
}

Future<ui.Image?> decodeFirstFrameFromBytes(Uint8List bytes) async {
  ui.Codec? codec;
  try {
    codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  } catch (e, st) {
    debugPrint('gif_first_frame: decode failed: $e\n$st');
    return null;
  } finally {
    codec?.dispose();
  }
}

/// Returns [assetPath] unchanged unless it ends with `.gif`, in which case
/// callers should prefer [decodeFirstFrameFromAsset] for static display.
bool isGifAssetPath(String assetPath) =>
    assetPath.toLowerCase().endsWith('.gif');

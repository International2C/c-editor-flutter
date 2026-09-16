import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/widgets.dart';

import 'preview_file_image.dart';

/// A user-chosen preview image. [path] is a native filesystem path when one
/// exists; on web it is a stable in-memory key that preserves the file suffix.
class PreviewPickedImage {
  const PreviewPickedImage({required this.path, this.bytes});

  final String path;
  final Uint8List? bytes;
}

@visibleForTesting
PreviewPickedImage? previewPickedImageFromPlatformFile({
  required String name,
  String? path,
  Uint8List? bytes,
}) {
  final hasBytes = bytes != null && bytes.isNotEmpty;
  final nativePath = path != null && path.isNotEmpty ? path : null;
  if (!hasBytes && nativePath == null) return null;
  if (nativePath != null) {
    return PreviewPickedImage(path: nativePath, bytes: hasBytes ? bytes : null);
  }
  final trimmed = name.trim();
  final fileName = trimmed.isEmpty ? 'image' : trimmed;
  final dot = fileName.lastIndexOf('.');
  final suffix = dot >= 0 ? fileName.substring(dot) : '';
  return PreviewPickedImage(
    path: 'memory:${identityHashCode(bytes)}$suffix',
    bytes: bytes,
  );
}

Future<PreviewPickedImage?> pickPreviewUserImage() async {
  final result = await FilePicker.pickFiles(
    type: FileType.image,
    withData: true,
  );
  final file = result?.files.single;
  if (file == null) return null;
  return previewPickedImageFromPlatformFile(
    name: file.name,
    path: file.path,
    bytes: file.bytes,
  );
}

Widget? previewUserImage({
  String? path,
  Uint8List? bytes,
  required BoxFit fit,
  double? width,
  double? height,
  Widget Function()? onError,
}) {
  Widget fallback() => onError?.call() ?? const SizedBox.shrink();
  if (bytes != null && bytes.isNotEmpty) {
    return Image.memory(
      bytes,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => fallback(),
    );
  }
  if (path == null || path.isEmpty) return null;
  return fileBannerImage(path, fit: fit, width: width, height: height) ??
      fallback();
}

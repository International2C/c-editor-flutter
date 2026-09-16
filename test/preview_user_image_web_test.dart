import 'dart:typed_data';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document_snapshot.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_gif_first_frames.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_user_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web picks keep image bytes when the browser has no filesystem path', () {
    final bytes = Uint8List.fromList([137, 80, 78, 71]);
    expect(
      previewPickedImageFromPlatformFile(name: 'bg.png', path: null, bytes: null),
      isNull,
    );
    final picked = previewPickedImageFromPlatformFile(
      name: 'sticker.GIF',
      path: null,
      bytes: bytes,
    );
    expect(picked, isNotNull);
    expect(picked!.path.toLowerCase().endsWith('.gif'), isTrue);
    expect(picked.bytes, same(bytes));
  });

  test('native picks keep the filesystem path and optional bytes', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final picked = previewPickedImageFromPlatformFile(
      name: 'ignored.png',
      path: r'C:\banners\custom.png',
      bytes: bytes,
    );
    expect(picked!.path, r'C:\banners\custom.png');
    expect(picked.bytes, same(bytes));
  });

  test('uploaded GIF backgrounds keep their bytes for export', () {
    final bytes = Uint8List.fromList([71, 73, 70]);
    final picked = previewPickedImageFromPlatformFile(
      name: 'stage.gif',
      path: null,
      bytes: bytes,
    )!;
    final document = PreviewDocument(
      banner: PreviewBannerRef(
        kind: PreviewBannerSourceKind.userFile,
        userFilePath: picked.path,
        userFileBytes: picked.bytes,
      ),
      layers: [
        PreviewLayer(
          id: 'sticker',
          kind: PreviewLayerKind.image,
          bounds: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
          imagePath: picked.path,
          imageBytes: picked.bytes,
        ),
      ],
    );
    final sources = previewDocumentGifSources(document);
    expect(sources, hasLength(1));
    expect(sources.single.isAsset, isFalse);
    expect(sources.single.bytes, same(bytes));

    final snapshot = PreviewDocumentSnapshot.capture(document);
    expect(snapshot.matches(document.copy()), isTrue);
    document.layers.single.imageBytes = Uint8List.fromList([71, 73, 70, 0]);
    expect(snapshot.matches(document), isFalse);
  });
}

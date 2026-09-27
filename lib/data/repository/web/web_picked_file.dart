import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

/// In-memory cache of files chosen by a web picker, keyed by the relative path
/// the picker reports (folder-relative for directories, leaf file name for a
/// flat file pick).
///
/// Bytes are read lazily through [read] so a large import never has to hold
/// every picked file in memory at once, and so the result does not depend on
/// the `FileList` outliving the picker.
class WebPickCache {
  WebPickCache({required this.name, required this.entries});

  /// Display name of the picked folder, or empty for a plain file pick.
  final String name;
  final Map<String, File> entries;

  Future<Uint8List?> read(String path) async {
    final file = entries[path];
    if (file == null) return null;

    final reader = FileReader();
    final completer = Completer<Uint8List?>();
    reader.onLoadEnd.listen((_) {
      if (reader.error != null) {
        completer.complete(null);
        return;
      }
      final buffer = (reader.result as JSArrayBuffer?)?.toDart;
      completer.complete(buffer?.asUint8List());
    });
    reader.readAsArrayBuffer(file);
    return completer.future;
  }
}

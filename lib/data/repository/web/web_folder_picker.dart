import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

import 'web_picked_file.dart';

/// In-memory folder import via `<input webkitdirectory>` (no File System Access API).
class WebFolderPicker {
  WebFolderPicker._();

  static final WebFolderPicker instance = WebFolderPicker._();

  static final _levelPattern = RegExp(r'\.(json|hujson|rton|zlib|bin|smf)$', caseSensitive: false);

  WebPickCache? _cache;

  bool get isSupported => true;

  Future<({String name, List<String> paths})?> pickFolderForImport() async {
    releaseFolderImport();

    final input = HTMLInputElement()
      ..type = 'file'
      ..multiple = true
      ..webkitdirectory = true
      ..style.display = 'none';

    document.body!.append(input);

    final completer = Completer<({String name, List<String> paths})?>();
    var settled = false;
    var changeTriggered = false;

    void settle(({String name, List<String> paths})? value) {
      if (settled) return;
      settled = true;
      input.remove();
      completer.complete(value);
    }

    void onChange(Event _) {
      changeTriggered = true;
      final files = input.files;
      if (files == null || files.length == 0) {
        settle(null);
        return;
      }

      final entries = <String, File>{};
      for (var i = 0; i < files.length; i++) {
        final file = files.item(i);
        if (file == null || !_levelPattern.hasMatch(file.name)) {
          continue;
        }
        final rel = _relativeLevelPath(file);
        if (rel.isEmpty) continue;
        entries[rel] = file;
      }

      if (entries.isEmpty) {
        settle(null);
        return;
      }

      final folderName = _folderNameFromFiles(files);
      _cache = WebPickCache(name: folderName, entries: entries);
      settle((name: folderName, paths: entries.keys.toList()));
    }

    void onCancel(Event _) {
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (!changeTriggered) {
          settle(null);
        }
      });
    }

    input.addEventListener('change', onChange.toJS);
    input.addEventListener('cancel', onCancel.toJS);

    input.click();
    return completer.future;
  }

  Future<Uint8List?> readFolderImportEntry(String path) async =>
      await _cache?.read(path);

  void releaseFolderImport() {
    _cache = null;
  }

  String _relativeLevelPath(File file) {
    final rel = file.webkitRelativePath.isNotEmpty
        ? file.webkitRelativePath
        : file.name;
    final parts = rel.split('/');
    if (parts.length > 1) {
      parts.removeAt(0);
    }
    return parts.join('/');
  }

  String _folderNameFromFiles(FileList files) {
    if (files.length == 0) return 'Imported folder';
    final first = files.item(0);
    if (first == null) return 'Imported folder';
    final rel = first.webkitRelativePath.isNotEmpty
        ? first.webkitRelativePath
        : first.name;
    final slash = rel.indexOf('/');
    return slash >= 0 ? rel.substring(0, slash) : 'Imported folder';
  }
}

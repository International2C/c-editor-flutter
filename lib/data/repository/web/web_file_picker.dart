import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

import 'web_import_filter.dart';
import 'web_picked_file.dart';

/// In-memory file import via `<input type="file">` (no File System Access API).
///
/// Mirrors [WebFolderPicker] on purpose — that shape is what is known to work
/// in phone browsers, and the two differences below are exactly what breaks on
/// Android when a file picker detaches its input or infers cancellation from
/// window focus:
///
///  * The input stays attached to the DOM until the selection settles. Android
///    Chrome opens the picker as a separate activity, so removing the input in
///    the same task as `click()` discards the selection and no `change` ever
///    arrives.
///  * Cancellation is resolved from the input's `cancel` event, not from a
///    `window` focus heuristic. On Android the focus event races `change`, and
///    the heuristic then reports a successful pick as a cancel.
class WebFilePicker {
  WebFilePicker._();

  static final WebFilePicker instance = WebFilePicker._();

  /// How long to keep waiting for a `change` event after the browser reported a
  /// cancel — [_cancelGraceAttempts] polls, [_cancelGraceDelay] apart. Some
  /// browsers emit `cancel` *before* `change`, so one short delay is not enough;
  /// polling the file list is order-independent.
  static const _cancelGraceAttempts = 6;
  static const _cancelGraceDelay = Duration(milliseconds: 250);

  WebPickCache? _cache;

  /// Opens the browser file chooser restricted to [extensions].
  ///
  /// Returns the accepted file names, an empty list when the chooser was opened
  /// but nothing usable was selected, or `null` when the user dismissed it.
  Future<List<String>?> pickFilesForImport(List<String> extensions) {
    releaseFileImport();

    final input = HTMLInputElement()
      ..type = 'file'
      ..multiple = true
      ..style.display = 'none';
    final filter = webPickExtensionFilter(extensions);
    if (filter != null) {
      input.accept = filter.map((ext) => '.$ext').join(',');
    }

    document.body!.append(input);

    final completer = Completer<List<String>?>();
    var settled = false;

    void settle(List<String>? value) {
      if (settled) return;
      settled = true;
      input.remove();
      completer.complete(value);
    }

    // The first `FileList` snapshot is taken from the still-attached input; the
    // cache keeps the `File` handles alive for the later byte reads.
    List<String>? collect() {
      final files = input.files;
      if (files == null || files.length == 0) return null;

      final accepted = <String, File>{};
      for (var i = 0; i < files.length; i++) {
        final file = files.item(i);
        if (file == null || file.name.isEmpty) continue;
        if (!webPickMatchesFilter(file.name, filter)) continue;
        accepted.putIfAbsent(file.name, () => file);
      }

      if (accepted.isEmpty) return const <String>[];
      _cache = WebPickCache(name: '', entries: accepted);
      return accepted.keys.toList();
    }

    void onChange(Event _) {
      settle(collect() ?? const <String>[]);
    }

    void onCancel(Event _) {
      var attemptsLeft = _cancelGraceAttempts;
      void poll() {
        if (settled) return;
        final names = collect();
        if (names != null) {
          settle(names);
          return;
        }
        if (--attemptsLeft <= 0) {
          settle(null);
          return;
        }
        Timer(_cancelGraceDelay, poll);
      }

      Timer(_cancelGraceDelay, poll);
    }

    input.addEventListener('change', onChange.toJS);
    input.addEventListener('cancel', onCancel.toJS);

    // The input is intentionally *not* removed here — see the class doc.
    input.click();
    return completer.future;
  }

  void releaseFileImport() {
    _cache = null;
  }

  Future<Uint8List?> readFileImportEntry(String name) async =>
      await _cache?.read(name);
}

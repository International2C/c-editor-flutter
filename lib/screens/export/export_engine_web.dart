import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/data/repository/web/web_level_opfs_store.dart';
import 'package:c_editor/plugins/plugin_constants.dart';

import 'export_engine_base.dart';
import 'rsb_pipeline.dart';
import 'rsb_worker_protocol.dart';

const String _webPathPrefix = 'web://';

/// Relative URL of the separately-compiled worker script (resolved against the
/// app's `<base href>`). Build it with:
///   dart compile js web/rsb_worker.dart -o web/rsb_worker.dart.js -O2
const String _workerScriptUrl = 'rsb_worker.dart.js';

ExportEngine createExportEngine() => ExportEngineWeb();

/// Web export engine. Browses the OPFS-backed level library through
/// [LevelRepository] and runs the sen pack/unpack pipeline in a dedicated Web
/// Worker (via [runRsbInjectPipeline] compiled into `web/rsb_worker.dart`), so
/// the CPU-heavy zlib work no longer freezes the UI.
///
/// If the worker script is unavailable (not compiled) or fails, it transparently
/// falls back to running the same pipeline on the main isolate — functional, but
/// it will freeze the tab for the duration, as before.
class ExportEngineWeb implements ExportEngine {
  final WebLevelOpfsStore _store = WebLevelOpfsStore.instance;

  web.Worker? _activeWorker;
  Completer<Uint8List?>? _activeCompleter;
  bool _cancelled = false;

  @override
  void cancelExport() {
    _cancelled = true;
    _activeWorker?.terminate();
    _activeWorker = null;
    final completer = _activeCompleter;
    _activeCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(const ExportCancelledException());
    }
  }

  @override
  void resetExportState() => _cancelled = false;

  @override
  bool get isCancelledByUser => _cancelled;

  String _relKey(String path) => path.startsWith(_webPathPrefix)
      ? path.substring(_webPathPrefix.length)
      : path;

  @override
  Future<bool> hasEligibleArchive(String rootPath) async {
    final index = await _store.indexFilesWithSizes();
    for (final key in index.keys) {
      if (!key.toLowerCase().endsWith('.rsb.smf')) continue;
      final underReserved = key
          .split('/')
          .any((seg) => isReservedLibraryFolderName(seg));
      if (!underReserved) return true;
    }
    return false;
  }

  @override
  Future<List<ExportEntry>> listDirectory(
    String path, {
    required bool archiveStep,
  }) async {
    final contents = await LevelRepository.getDirectoryContents(path);
    final result = <ExportEntry>[];
    for (final item in contents) {
      if (item.isDirectory) {
        result.add(
          ExportEntry(name: item.name, path: item.path, isDirectory: true),
        );
        continue;
      }
      final lower = item.name.toLowerCase();
      final eligible = archiveStep
          ? lower.endsWith('.rsb.smf')
          : (lower.endsWith('.json') || lower.endsWith('.rton'));
      if (eligible) {
        result.add(
          ExportEntry(name: item.name, path: item.path, isDirectory: false),
        );
      }
    }
    return result;
  }

  @override
  String parentDirectory(String path) {
    if (!path.startsWith(_webPathPrefix)) return _webPathPrefix;
    final idx = path.lastIndexOf('/');
    if (idx < _webPathPrefix.length) return _webPathPrefix;
    return path.substring(0, idx);
  }

  @override
  Future<void> performExport({
    required String archivePath,
    required Map<String, Uint8List> rtonLevels,
    required void Function(double progress, ExportPhase phase) onProgress,
  }) async {
    _cancelled = false;
    final relKey = _relKey(archivePath);
    final archiveBytes = await _store.read(relKey);
    if (archiveBytes == null) {
      throw Exception('Archive not found: $archivePath');
    }

    onProgress(0.15, ExportPhase.unpackingRsb);

    // Preferred path: run the pipeline in a real Web Worker so the UI stays
    // responsive. Falls back to the main isolate if the worker is unavailable.
    // Cancellation surfaces here as an [ExportCancelledException] thrown from
    // [_packInWorker].
    Uint8List? output = await _packInWorker(
      archiveBytes,
      rtonLevels,
      onProgress,
    );
    output ??= runRsbInjectPipeline(
      archiveBytes: archiveBytes,
      rtonLevels: rtonLevels,
      onProgress: onProgress,
    );

    if (_cancelled) throw const ExportCancelledException();
    onProgress(0.95, ExportPhase.finalizing);
    await _store.write(relKey, output);
  }

  /// Resolves [relative] against the document's `<base href>` (Worker URLs
  /// ignore the base tag on their own, so a subdirectory deploy would otherwise
  /// 404 the script).
  String _resolveWorkerUrl(String relative) {
    final base = web.document.querySelector('base')?.getAttribute('href');
    if (base == null || base.isEmpty) return relative;
    final origin = web.window.location.origin;
    return Uri.parse('$origin$base').resolve(relative).toString();
  }

  /// Runs the pack pipeline in a dedicated worker. Returns the packed bytes, or
  /// `null` if the worker could not be created, errored, or reported a failure
  /// (signalling the caller to fall back to the in-process pipeline).
  Future<Uint8List?> _packInWorker(
    Uint8List archiveBytes,
    Map<String, Uint8List> rtonLevels,
    void Function(double progress, ExportPhase phase) onProgress,
  ) async {
    web.Worker worker;
    try {
      worker = web.Worker(_resolveWorkerUrl(_workerScriptUrl).toJS);
    } catch (_) {
      return null;
    }

    final completer = Completer<Uint8List?>();
    _activeWorker = worker;
    _activeCompleter = completer;
    void finish(Uint8List? result) {
      if (!completer.isCompleted) completer.complete(result);
    }

    worker.onerror = ((web.Event _) => finish(null)).toJS;
    worker.onmessageerror = ((web.MessageEvent _) => finish(null)).toJS;
    worker.onmessage = ((web.MessageEvent event) {
      final data = event.data;
      if (data == null) {
        finish(null);
        return;
      }
      final message = data as WorkerMessage;
      final kind = message.kind;
      if (kind == RsbWorkerKind.progress) {
        final index = message.phase;
        if (index >= 0 && index < ExportPhase.values.length) {
          onProgress(message.value, ExportPhase.values[index]);
        }
      } else if (kind == RsbWorkerKind.done) {
        finish(message.result?.toDart);
      } else {
        finish(null);
      }
    }).toJS;

    // Inputs are cloned (not transferred) so the caller's buffers stay valid for
    // the main-isolate fallback if the worker fails.
    final paths = <JSString>[];
    final buffers = <JSUint8Array>[];
    rtonLevels.forEach((path, bytes) {
      paths.add(path.toJS);
      buffers.add(_tighten(bytes).toJS);
    });
    final request = PackRequest(
      archive: _tighten(archiveBytes).toJS,
      levelPaths: paths.toJS,
      levelBuffers: buffers.toJS,
    );

    try {
      worker.postMessage(request);
    } catch (_) {
      _activeWorker = null;
      _activeCompleter = null;
      worker.terminate();
      return null;
    }

    try {
      return await completer.future;
    } finally {
      _activeWorker = null;
      _activeCompleter = null;
      worker.terminate();
    }
  }
}

/// Returns a Uint8List that owns its whole backing buffer so `.toJS` yields a
/// clean view (a sub-view could otherwise expose the wrong range to JS).
Uint8List _tighten(Uint8List bytes) {
  if (bytes.offsetInBytes == 0 &&
      bytes.lengthInBytes == bytes.buffer.lengthInBytes) {
    return bytes;
  }
  return Uint8List.fromList(bytes);
}

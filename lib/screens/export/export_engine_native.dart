import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'package:c_editor/plugins/plugin_constants.dart';

import 'export_engine_base.dart';
import 'export_inject.dart';
import 'export_rsb_isolate.dart';

ExportEngine createExportEngine() => ExportEngineNative();

bool _isUnderPlugins(String entityPath) {
  return p.split(p.normalize(entityPath)).any(isReservedLibraryFolderName);
}

/// Which single pack/unpack step an export isolate should run.
enum ExportIsolateStep { unpackRsb, unpackRsg, packRsg, packRsb }

/// Message sent to [exportIsolateStepEntry]: the reply port plus the step
/// and its input/output paths. Only sendable plain data — never closures
/// or engine state, which `Isolate.spawn` would reject as unsendable.
typedef ExportIsolateStepRequest = (
  SendPort reply,
  ExportIsolateStep step,
  String input,
  String output,
);

/// Top-level isolate entry for a single export pipeline step.
///
/// Must stay a top-level function taking only sendable data: spawning a
/// closure instead captures engine state (Completers, isolate handles)
/// and fails with "Illegal argument in isolate message: object is
/// unsendable".
@pragma('vm:entry-point')
void exportIsolateStepEntry(ExportIsolateStepRequest request) {
  final (reply, step, input, output) = request;
  try {
    switch (step) {
      case ExportIsolateStep.unpackRsb:
        exportIsolateUnpackRsb((input, output));
      case ExportIsolateStep.unpackRsg:
        exportIsolateUnpackRsg((input, output));
      case ExportIsolateStep.packRsg:
        exportIsolatePackRsg((input, output));
      case ExportIsolateStep.packRsb:
        exportIsolatePackRsb((input, output));
    }
    // Null marks success; a String is the error message.
    reply.send(null);
  } catch (e) {
    reply.send(e.toString());
  }
}

/// `dart:io`-backed export engine. Heavy pack/unpack steps run in isolates
/// (which default to the native `IoSenIo` backend) owned by this engine, so
/// cancellation kills the running step immediately instead of waiting for it
/// to finish — the pipeline only writes into a temp directory until the very
/// last copy, so interrupting a step cannot corrupt the target archive.
class ExportEngineNative implements ExportEngine {
  bool _cancelled = false;
  Isolate? _activeIsolate;
  Completer<void> _cancelledSignal = Completer<void>();

  @override
  void cancelExport() {
    _cancelled = true;
    _activeIsolate?.kill(priority: Isolate.immediate);
    _activeIsolate = null;
    if (!_cancelledSignal.isCompleted) _cancelledSignal.complete();
  }

  @override
  void resetExportState() {
    _cancelled = false;
    if (_cancelledSignal.isCompleted) {
      _cancelledSignal = Completer<void>();
    }
  }

  @override
  bool get isCancelledByUser => _cancelled;

  void _throwIfCancelled() {
    if (_cancelled) throw const ExportCancelledException();
  }

  /// Runs one pack/unpack [step] (with its [input]/[output] paths) in an
  /// isolate owned by this engine. Unlike `compute`, the isolate handle is
  /// kept until the step finishes, so [cancelExport] can terminate a
  /// long-running step at once.
  ///
  /// The spawned isolate is a top-level function fed with plain sendable
  /// data — never a closure, which would capture this engine's Completer
  /// and make `Isolate.spawn` fail with "object is unsendable".
  Future<void> _runIsolateStep(
    ExportIsolateStep step,
    String input,
    String output,
  ) async {
    _throwIfCancelled();
    final port = ReceivePort();
    final completer = Completer<void>();
    port.listen((dynamic message) {
      if (completer.isCompleted) return;
      if (message is String) {
        // The entry reports failures as the error's string form.
        completer.completeError(Exception(message));
      } else {
        completer.complete();
      }
    });
    final isolate = await Isolate.spawn(exportIsolateStepEntry, (
      port.sendPort,
      step,
      input,
      output,
    ));
    if (_cancelled) {
      isolate.kill(priority: Isolate.immediate);
    }
    _activeIsolate = isolate;
    try {
      final finished = await Future.any([
        completer.future.then((_) => true),
        _cancelledSignal.future.then((_) => false),
      ]);
      if (!finished) throw const ExportCancelledException();
    } finally {
      if (identical(_activeIsolate, isolate)) _activeIsolate = null;
      isolate.kill(priority: Isolate.immediate);
      port.close();
    }
  }

  @override
  Future<bool> hasEligibleArchive(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return false;
    await for (final entity in rootDir.list(recursive: true)) {
      if (_isUnderPlugins(entity.path)) continue;
      if (entity is File && entity.path.endsWith('.rsb.smf')) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<List<ExportEntry>> listDirectory(
    String path, {
    required bool archiveStep,
  }) async {
    final dir = Directory(path);
    final items = await dir.list().toList();

    final filtered = items.where((item) {
      if (item is Directory) {
        return !isReservedLibraryFolderName(p.basename(item.path));
      }
      if (item is File) {
        final fileName = p.basename(item.path).toLowerCase();
        if (archiveStep) {
          return fileName.endsWith('.rsb.smf');
        }
        return fileName.endsWith('.json') || fileName.endsWith('.rton');
      }
      return false;
    }).toList();

    filtered.sort((a, b) {
      if (a is Directory && b is File) return -1;
      if (a is File && b is Directory) return 1;
      return p
          .basename(a.path)
          .toLowerCase()
          .compareTo(p.basename(b.path).toLowerCase());
    });

    return filtered
        .map(
          (e) => ExportEntry(
            name: p.basename(e.path),
            path: e.path,
            isDirectory: e is Directory,
          ),
        )
        .toList();
  }

  @override
  String parentDirectory(String path) => p.dirname(path);

  @override
  Future<void> performExport({
    required String archivePath,
    required Map<String, Uint8List> rtonLevels,
    required void Function(double progress, ExportPhase phase) onProgress,
  }) async {
    final tempDir = await Directory.systemTemp.createTemp('c_editor_export_');
    final tempPath = tempDir.path;

    try {
      _throwIfCancelled();
      onProgress(0.2, ExportPhase.unpackingRsb);
      final tempRsbPath = p.join(tempPath, 'temp.rsb');
      await File(archivePath).copy(tempRsbPath);

      final rsbUnpackDir = p.join(tempPath, 'rsb.bundle');
      await _runIsolateStep(
        ExportIsolateStep.unpackRsb,
        tempRsbPath,
        rsbUnpackDir,
      );
      _throwIfCancelled();

      onProgress(0.4, ExportPhase.unpackingRsg);
      final packetDir = Directory(p.join(rsbUnpackDir, 'packet'));
      if (!await packetDir.exists()) {
        final rsbFiles = Directory(rsbUnpackDir)
            .listSync(recursive: true)
            .map((e) => p.relative(e.path, from: rsbUnpackDir))
            .take(10)
            .join(', ');
        throw Exception(
          'Packet directory not found in RSB bundle. Contents: $rsbFiles',
        );
      }

      String? packagesRsgPath;
      await for (final entity in packetDir.list()) {
        if (entity is File &&
            p.basename(entity.path).toLowerCase() == 'packages.rsg') {
          packagesRsgPath = entity.path;
          break;
        }
      }
      if (packagesRsgPath == null) {
        throw Exception('Packages.rsg not found in archive.');
      }

      final rsgUnpackDir = p.join(tempPath, 'Packages.packet');
      final packagesRsgPathFinal = packagesRsgPath;
      await _runIsolateStep(
        ExportIsolateStep.unpackRsg,
        packagesRsgPathFinal,
        rsgUnpackDir,
      );
      _throwIfCancelled();

      onProgress(0.6, ExportPhase.injecting);
      injectRtonLevelsIntoPacket(rsgUnpackDir, rtonLevels);
      _throwIfCancelled();

      onProgress(0.7, ExportPhase.repackingRsg);
      await _runIsolateStep(
        ExportIsolateStep.packRsg,
        rsgUnpackDir,
        packagesRsgPathFinal,
      );
      _throwIfCancelled();

      onProgress(0.8, ExportPhase.repackingRsb);
      await _runIsolateStep(
        ExportIsolateStep.packRsb,
        rsbUnpackDir,
        tempRsbPath,
      );
      _throwIfCancelled();

      onProgress(0.9, ExportPhase.finalizing);
      await File(tempRsbPath).copy(archivePath);
    } finally {
      // Removing a full unpacked archive copy can take a while; do it in
      // the background so the UI leaves the progress screen immediately.
      unawaited(tempDir.delete(recursive: true).then((_) {}, onError: (_) {}));
    }
  }
}

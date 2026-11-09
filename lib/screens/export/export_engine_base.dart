import 'dart:typed_data';

/// A filesystem entry surfaced by an [ExportEngine], independent of the
/// underlying platform (`dart:io` on native, OPFS on web).
class ExportEntry {
  const ExportEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
  });

  final String name;
  final String path;
  final bool isDirectory;
}

/// Thrown by [ExportEngine.performExport] when the user cancels the run via
/// [ExportEngine.cancelExport]. The UI treats this as a cancellation rather than
/// an error.
class ExportCancelledException implements Exception {
  const ExportCancelledException();

  @override
  String toString() => 'ExportCancelledException';
}

/// Progress phases reported during an export run, mapped to localized strings
/// by the UI.
enum ExportPhase {
  creatingRton,
  unpackingRsb,
  unpackingRsg,
  injecting,
  repackingRsg,
  repackingRsb,
  finalizing,
}

/// Platform-specific backend for the export flow: archive discovery, folder
/// browsing, and the RSB/RSG pack pipeline.
abstract class ExportEngine {
  /// Recursively checks whether [rootPath] contains at least one `.rsb.smf`.
  Future<bool> hasEligibleArchive(String rootPath);

  /// Lists directories plus eligible files under [path]. When [archiveStep] is
  /// true only `.rsb.smf` files are returned; otherwise `.json`/`.rton` levels.
  Future<List<ExportEntry>> listDirectory(
    String path, {
    required bool archiveStep,
  });

  /// Returns the parent directory path for [path] in this engine's scheme.
  String parentDirectory(String path);

  /// Runs the full unpack -> inject -> repack pipeline, overwriting the archive
  /// at [archivePath] with [rtonLevels] injected. [onProgress] is called with a
  /// 0..1 fraction and the current [ExportPhase].
  Future<void> performExport({
    required String archivePath,
    required Map<String, Uint8List> rtonLevels,
    required void Function(double progress, ExportPhase phase) onProgress,
  });

  /// Requests cancellation of an in-flight [performExport]. On success the
  /// pending [performExport] future completes with an [ExportCancelledException]
  /// and the target archive is left untouched. Safe to call when nothing is
  /// running.
  void cancelExport();

  /// Clears any pending cancellation state before a new export run starts.
  ///
  /// The UI calls this at the very beginning of an export (before the level
  /// encoding stage), so a cancellation requested while the pipeline is not
  /// running yet still applies to the run about to start instead of being
  /// silently dropped.
  void resetExportState() {}

  /// True while a cancellation request is pending for this engine. The UI
  /// polls it during stages it runs on its own (e.g. level RTON encoding)
  /// to abort as early as possible.
  bool get isCancelledByUser => false;
}

import 'dart:async';
import 'dart:io';

import 'package:nice_downloader/nice_downloader.dart';
import 'package:path/path.dart' as p;

import 'releases_api.dart';

/// User cancelled an in-progress download.
class DownloadCanceledException implements Exception {
  @override
  String toString() => 'DownloadCanceledException';
}

/// Active segmented download that can be cancelled.
class NiceDownloadSession {
  NiceDownloadSession._({required DownloadTask task, required this.completed})
    : _task = task;

  final DownloadTask _task;

  /// Completes with the saved file, or throws on failure / cancel.
  final Future<File> completed;

  bool _cancelRequested = false;

  Future<void> cancel() async {
    _cancelRequested = true;
    await _task.cancel(deleteFile: true);
  }

  bool get wasCanceled => _cancelRequested;
}

/// Starts a segmented download into [directory]/[fileName].
Future<NiceDownloadSession> startNiceDownload({
  required String url,
  required String directory,
  required String fileName,
  void Function(DownloadProgress progress)? onProgress,
}) async {
  await Directory(directory).create(recursive: true);
  final destPath = p.join(directory, fileName);
  final existing = File(destPath);
  if (await existing.exists()) {
    await existing.delete();
  }

  final manager = DownloadManager(
    config: DownloadConfig(
      repository: InMemoryDownloadRepository(),
      // Fail fast on offline instead of waiting indefinitely.
      waitForConnection: false,
      segmentPlanner: const DefaultSegmentPlanner(maxSegments: 8),
      retryPolicy: const ExponentialBackoffRetryPolicy(maxRetries: 4),
    ),
  );

  final task = await manager.createDownload(
    url: url,
    directory: directory,
    fileName: fileName,
    headers: const {
      'User-Agent': 'C-Editor',
      'Accept': 'application/octet-stream',
    },
  );

  final done = Completer<void>();
  Object? error;
  var canceled = false;

  final sub = task.progressStream.listen((progress) {
    onProgress?.call(progress);
    if (progress.status == DownloadStatus.completed) {
      if (!done.isCompleted) done.complete();
    } else if (progress.status == DownloadStatus.canceled) {
      canceled = true;
      error = DownloadCanceledException();
      if (!done.isCompleted) done.complete();
    } else if (progress.status == DownloadStatus.failed) {
      error = progress.error ?? StateError('Download failed');
      if (!done.isCompleted) done.complete();
    }
  });

  final completed = () async {
    try {
      await task.start();
      await done.future;
      if (canceled || error is DownloadCanceledException) {
        throw DownloadCanceledException();
      }
      if (error != null) throw error!;
      final file = File(task.filePath ?? destPath);
      if (!await file.exists()) {
        throw StateError('Downloaded file missing: ${file.path}');
      }
      return file;
    } finally {
      await sub.cancel();
    }
  }();

  return NiceDownloadSession._(task: task, completed: completed);
}

/// Maps downloader / network failures to a short user-facing reason key.
enum DownloadErrorKind {
  noConnection,
  connectionLost,
  timeout,
  rateLimited,
  accessDenied,
  notFound,
  invalidResponse,
  storage,
  server,
  canceled,
  other,
}

DownloadErrorKind classifyDownloadError(Object error) {
  if (error is DownloadCanceledException) return DownloadErrorKind.canceled;
  if (error is NoConnectionException) return DownloadErrorKind.noConnection;
  if (error is ConnectionLostException) {
    return DownloadErrorKind.connectionLost;
  }
  if (error is SocketException) return DownloadErrorKind.noConnection;
  if (error is TimeoutException) return DownloadErrorKind.timeout;
  if (error is FileSystemException) return DownloadErrorKind.storage;
  if (error is FormatException) return DownloadErrorKind.invalidResponse;
  if (error is DynamicReleaseRequestException && error.rateLimited) {
    return DownloadErrorKind.rateLimited;
  }
  final statusCode = serverStatusCode(error);
  if (statusCode == 429) return DownloadErrorKind.rateLimited;
  if (statusCode == 401 || statusCode == 403) {
    return DownloadErrorKind.accessDenied;
  }
  if (statusCode == 404) return DownloadErrorKind.notFound;
  if (statusCode != null) return DownloadErrorKind.server;
  final text = '$error'.toLowerCase();
  if (text.contains('socket') ||
      text.contains('clientexception') ||
      text.contains('failed to fetch') ||
      text.contains('failed host lookup') ||
      text.contains('network is unreachable') ||
      text.contains('connection refused')) {
    return DownloadErrorKind.noConnection;
  }
  if (text.contains('connection') &&
      (text.contains('reset') ||
          text.contains('closed') ||
          text.contains('abort'))) {
    return DownloadErrorKind.connectionLost;
  }
  return DownloadErrorKind.other;
}

int? serverStatusCode(Object error) {
  if (error is ServerException) return error.statusCode;
  if (error is DynamicReleaseRequestException) return error.statusCode;
  return null;
}

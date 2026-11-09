import 'package:flutter/material.dart';

import 'package:c_editor/escape_override.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/widgets/editor_components.dart' show EditorOptionTile;
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/download.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/releases_api.dart';

/// Shared, platform-agnostic UI helpers for the dynamic-fetch plugin. Used by
/// both the native (`dart:io`) and web offer flows.

String formatDynamicBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
  return '${(mb / 1024).toStringAsFixed(2)} GB';
}

String localizeDynamicDownloadError(
  CPluginHost host,
  BuildContext context,
  Object error,
) {
  switch (classifyDownloadError(error)) {
    case DownloadErrorKind.canceled:
      return host.localize(context, 'dynamicCanceled', 'Download canceled.');
    case DownloadErrorKind.noConnection:
      return host.localize(
        context,
        'dynamicNoConnection',
        'Could not connect to GitHub. Check your network connection, then try again.',
      );
    case DownloadErrorKind.connectionLost:
      return host.localize(
        context,
        'dynamicConnectionLost',
        'The download connection was interrupted. Check your network connection, then try again.',
      );
    case DownloadErrorKind.timeout:
      return host.localize(
        context,
        'dynamicTimeout',
        'The connection timed out. Check your network connection, then try again.',
      );
    case DownloadErrorKind.rateLimited:
      return host.localize(
        context,
        'dynamicRateLimited',
        'GitHub has temporarily limited requests from your network. Wait and try again later, or switch networks.',
      );
    case DownloadErrorKind.accessDenied:
      return host.localize(
        context,
        'dynamicAccessDenied',
        'GitHub refused this request. Please try again later.',
      );
    case DownloadErrorKind.notFound:
      return host.localize(
        context,
        'dynamicNotFound',
        'This release or download is no longer available. Refresh the release list and choose another version.',
      );
    case DownloadErrorKind.invalidResponse:
      return host.localize(
        context,
        'dynamicInvalidResponse',
        'The server returned unexpected data. Please try again later.',
      );
    case DownloadErrorKind.storage:
      return host.localize(
        context,
        'dynamicStorageError',
        'Could not save the data package. Check workspace write permissions and free space, then try again.',
      );
    case DownloadErrorKind.server:
      final code = serverStatusCode(error);
      return host.localize(
        context,
        'dynamicServerError',
        'Server error${code != null ? ' ($code)' : ''}. Please try again later.',
        {'code': '${code ?? ''}'},
      );
    case DownloadErrorKind.other:
      return host.localize(
        context,
        'dynamicFetchError',
        'Could not download the data package. Check your network, workspace write permissions, and free space, then try again.',
      );
  }
}

/// Shows the GitHub release picker and returns the chosen option (or null).
Future<DynamicReleaseOption?> showDynamicReleasePicker(
  BuildContext context,
  CPluginHost host, {
  Future<List<DynamicReleaseOption>> Function()? loadReleases,
}) {
  return showDialog<DynamicReleaseOption>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => EscapeClosesModal(
      child: _ReleasePickerDialog(host: host, loadReleases: loadReleases),
    ),
  );
}

class _ReleasePickerDialog extends StatefulWidget {
  const _ReleasePickerDialog({required this.host, this.loadReleases});

  final CPluginHost host;
  final Future<List<DynamicReleaseOption>> Function()? loadReleases;

  @override
  State<_ReleasePickerDialog> createState() => _ReleasePickerDialogState();
}

class _ReleasePickerDialogState extends State<_ReleasePickerDialog> {
  late Future<List<DynamicReleaseOption>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<DynamicReleaseOption>> _load() async {
    if (widget.loadReleases != null) return widget.loadReleases!();
    final releases = Pvz2cDynamicReleases();
    try {
      return await releases.list();
    } finally {
      releases.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final host = widget.host;
    return FutureBuilder<List<DynamicReleaseOption>>(
      future: _future,
      builder: (context, snapshot) => AlertDialog(
        key: const ValueKey('dynamicReleasePickerDialog'),
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(host.localize(context, 'dynamicSelectTitle')),
        content: SizedBox(
          width: double.maxFinite,
          child: Builder(
            builder: (context) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                final message = localizeDynamicDownloadError(
                  host,
                  context,
                  snapshot.error!,
                );
                return Text(
                  message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                );
              }
              final items = snapshot.data ?? const [];
              if (items.isEmpty) {
                return Text(host.localize(context, 'dynamicEmpty'));
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    if (index > 0) const Divider(height: 1),
                    Builder(
                      builder: (context) {
                        final item = items[index];
                        final sizeLabel = item.sizeBytes > 0
                            ? formatDynamicBytes(item.sizeBytes)
                            : '';
                        return EditorOptionTile(
                          key: ValueKey('dynamicReleaseOption-${item.tagName}'),
                          leading: item.isLatest
                              ? const Icon(Icons.star, color: Colors.amber)
                              : const Icon(Icons.inventory_2_outlined),
                          title: Text(item.name),
                          subtitle: Text(
                            [
                              item.tagName,
                              if (sizeLabel.isNotEmpty) sizeLabel,
                              if (item.isLatest)
                                host.localize(context, 'dynamicLatestBadge'),
                            ].join(' · '),
                          ),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(host.localize(context, 'cancel', 'Cancel')),
          ),
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError)
            FilledButton(
              onPressed: () => setState(() {
                _future = _load();
              }),
              child: Text(host.localize(context, 'dynamicRetry', 'Retry')),
            ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:c_editor/escape_override.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/download.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/dynamic_fetch_ui.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/dynamic_offer_flow_web.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/releases_api.dart';
import 'package:c_editor/widgets/labeled_progress_bar.dart';
import 'package:path/path.dart' as p;

const _kDefaultDynamicFileName = 'dynamic.rsb.smf';

/// Ask whether to fetch an external dynamic, then pick a release and download.
Future<bool> runExternalDynamicOffer(
  BuildContext context, {
  required CPluginHost host,
  required String libraryPath,
  bool skipInitialPrompt = false,
}) async {
  if (kIsWeb) {
    return runExternalDynamicOfferWeb(
      context,
      host: host,
      libraryPath: libraryPath,
      skipInitialPrompt: skipInitialPrompt,
    );
  }
  if (!skipInitialPrompt) {
    final want = await showDialog<bool>(
      context: context,
      builder: (ctx) => EscapeClosesModal(
        child: AlertDialog(
          title: Text(host.localize(ctx, 'dynamicOfferTitle')),
          content: Text(host.localize(ctx, 'dynamicOfferBody')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(host.localize(ctx, 'dynamicOfferNo', 'No')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(host.localize(ctx, 'dynamicOfferYes', 'Yes')),
            ),
          ],
        ),
      ),
    );
    if (want != true || !context.mounted) return false;
  }

  final selected = await showDynamicReleasePicker(context, host);
  if (selected == null || !context.mounted) return false;

  final fileName = await _resolveDownloadFileName(
    context,
    host: host,
    libraryPath: libraryPath,
    preferredName: _kDefaultDynamicFileName,
  );
  if (fileName == null || !context.mounted) return false;

  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: _DownloadProgressDialog(
        host: host,
        option: selected,
        libraryPath: libraryPath,
        fileName: fileName,
      ),
    ),
  );
  return saved == true;
}

/// Returns a free file name, or `null` if the user cancels.
Future<String?> _resolveDownloadFileName(
  BuildContext context, {
  required CPluginHost host,
  required String libraryPath,
  required String preferredName,
}) async {
  final target = File(p.join(libraryPath, preferredName));
  if (!await target.exists()) return preferredName;
  if (!context.mounted) return null;

  final choice = await showDialog<_ConflictChoice>(
    context: context,
    builder: (ctx) => EscapeClosesModal(
      child: AlertDialog(
        title: Text(
          host.localize(ctx, 'dynamicExistsTitle', 'File already exists'),
        ),
        content: Text(
          host.localize(
            ctx,
            'dynamicExistsBody',
            '"{name}" is already in your workspace.\n\n'
                'Overwrite it, or save under a different name?',
            {'name': preferredName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_ConflictChoice.cancel),
            child: Text(host.localize(ctx, 'cancel', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_ConflictChoice.rename),
            child: Text(
              host.localize(ctx, 'dynamicExistsRename', 'Different name…'),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(_ConflictChoice.overwrite),
            child: Text(
              host.localize(ctx, 'dynamicExistsOverwrite', 'Overwrite'),
            ),
          ),
        ],
      ),
    ),
  );
  if (choice == null || choice == _ConflictChoice.cancel) return null;
  if (choice == _ConflictChoice.overwrite) return preferredName;
  if (!context.mounted) return null;

  return _promptAlternateFileName(
    context,
    host: host,
    libraryPath: libraryPath,
    preferredName: preferredName,
  );
}

Future<String?> _promptAlternateFileName(
  BuildContext context, {
  required CPluginHost host,
  required String libraryPath,
  required String preferredName,
}) async {
  final suggested = _suggestAlternateFileName(libraryPath, preferredName);
  final controller = TextEditingController(text: suggested);
  String? fieldError;

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return EscapeClosesModal(
        child: StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(
                host.localize(ctx, 'dynamicRenameTitle', 'Save as'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: host.localize(
                        ctx,
                        'dynamicRenameHint',
                        'File name',
                      ),
                      errorText: fieldError,
                    ),
                    onSubmitted: (_) {
                      final resolved = _validateAlternateFileName(
                        libraryPath: libraryPath,
                        raw: controller.text,
                        host: host,
                        context: ctx,
                      );
                      if (resolved.error != null) {
                        setLocal(() => fieldError = resolved.error);
                        return;
                      }
                      Navigator.of(ctx).pop(resolved.fileName);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(host.localize(ctx, 'cancel', 'Cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    final resolved = _validateAlternateFileName(
                      libraryPath: libraryPath,
                      raw: controller.text,
                      host: host,
                      context: ctx,
                    );
                    if (resolved.error != null) {
                      setLocal(() => fieldError = resolved.error);
                      return;
                    }
                    Navigator.of(ctx).pop(resolved.fileName);
                  },
                  child: Text(
                    host.localize(ctx, 'dynamicRenameConfirm', 'Save'),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
  controller.dispose();
  return result;
}

enum _ConflictChoice { overwrite, rename, cancel }

String _suggestAlternateFileName(String directory, String preferredName) {
  const ext = '.rsb.smf';
  var stem = preferredName;
  final lower = stem.toLowerCase();
  if (lower.endsWith(ext)) {
    stem = stem.substring(0, stem.length - ext.length);
  }
  for (var i = 2; i < 1000; i++) {
    final candidate = '${stem}_$i$ext';
    if (!File(p.join(directory, candidate)).existsSync()) return candidate;
  }
  return '${stem}_${DateTime.now().millisecondsSinceEpoch}$ext';
}

({String? fileName, String? error}) _validateAlternateFileName({
  required String libraryPath,
  required String raw,
  required CPluginHost host,
  required BuildContext context,
}) {
  var name = raw.trim();
  if (name.isEmpty) {
    return (
      fileName: null,
      error: host.localize(
        context,
        'dynamicRenameInvalid',
        'Enter a file name.',
      ),
    );
  }
  if (name.contains('/') ||
      name.contains('\\') ||
      name.contains('..') ||
      name == '.' ||
      name == '..') {
    return (
      fileName: null,
      error: host.localize(
        context,
        'dynamicRenameInvalid',
        'Enter a valid file name.',
      ),
    );
  }
  if (!name.toLowerCase().endsWith('.rsb.smf')) {
    name = '$name.rsb.smf';
  }
  if (File(p.join(libraryPath, name)).existsSync()) {
    return (
      fileName: null,
      error: host.localize(
        context,
        'dynamicRenameExists',
        'That file already exists. Choose another name.',
      ),
    );
  }
  return (fileName: name, error: null);
}

class _DownloadProgressDialog extends StatefulWidget {
  const _DownloadProgressDialog({
    required this.host,
    required this.option,
    required this.libraryPath,
    required this.fileName,
  });

  final CPluginHost host;
  final DynamicReleaseOption option;
  final String libraryPath;
  final String fileName;

  @override
  State<_DownloadProgressDialog> createState() =>
      _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double _percent = 0;
  String _status = '';
  String? _error;
  bool _done = false;
  bool _canceling = false;
  NiceDownloadSession? _session;
  late final bool Function() _escapeHandler;

  @override
  void initState() {
    super.initState();
    _escapeHandler = () {
      if (!mounted) return false;
      if (_done) {
        Navigator.of(context).pop(true);
        return true;
      }
      if (_error != null) {
        Navigator.of(context).pop(false);
        return true;
      }
      _confirmCancel();
      return true;
    };
    EscapeOverride.push(_escapeHandler);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    EscapeOverride.pop(_escapeHandler);
    super.dispose();
  }

  Future<void> _start() async {
    final host = widget.host;
    setState(() {
      _status = host.localize(context, 'dynamicDownloading');
      _error = null;
      _done = false;
      _canceling = false;
      _percent = 0;
    });
    try {
      final session = await startNiceDownload(
        url: widget.option.downloadUrl,
        directory: widget.libraryPath,
        fileName: widget.fileName,
        onProgress: (progress) {
          if (!mounted || _canceling) return;
          setState(() {
            _percent = progress.percent.clamp(0, 100) / 100.0;
            final speed = progress.readableSpeed;
            _status = [
              host.localize(context, 'dynamicDownloading'),
              if (progress.totalBytes > 0)
                '${progress.readableDownloaded} / ${progress.readableTotal}',
              if (speed != null) '$speed',
            ].join('\n');
          });
        },
      );
      if (!mounted) {
        await session.cancel();
        return;
      }
      _session = session;
      await session.completed;
      if (!mounted) return;
      setState(() {
        _done = true;
        _percent = 1;
        _status = host.localize(
          context,
          'dynamicDownloadDone',
          null,
          {'path': p.join(widget.libraryPath, widget.fileName)},
        );
      });
    } on DownloadCanceledException {
      if (mounted) Navigator.of(context).pop(false);
    } catch (e) {
      if (!mounted) return;
      if (_canceling) {
        Navigator.of(context).pop(false);
        return;
      }
      setState(() {
        _error = localizeDynamicDownloadError(host, context, e);
        _status = _error!;
      });
    } finally {
      _session = null;
    }
  }

  Future<void> _confirmCancel() async {
    if (_done || _canceling) return;
    final host = widget.host;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => EscapeClosesModal(
        child: AlertDialog(
          title: Text(
            host.localize(ctx, 'dynamicCancelTitle', 'Cancel download?'),
          ),
          content: Text(
            host.localize(
              ctx,
              'dynamicCancelBody',
              'Stop downloading and discard the partial file?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                host.localize(ctx, 'dynamicCancelKeep', 'Keep downloading'),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                host.localize(ctx, 'dynamicCancelConfirm', 'Cancel download'),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _canceling = true;
      _status = host.localize(context, 'dynamicCanceling', 'Canceling…');
    });
    final session = _session;
    if (session != null) {
      await session.cancel();
    } else if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final host = widget.host;
    return AlertDialog(
      title: Text(host.localize(context, 'dynamicDownloadTitle')),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.option.name),
            const SizedBox(height: 16),
            LabeledProgressBar(
              value: (_error != null || _canceling) ? null : _percent,
              color: Colors.green,
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 12),
            Text(
              _status,
              style: _error != null
                  ? TextStyle(color: Theme.of(context).colorScheme.error)
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        if (_done)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(host.localize(context, 'confirm', 'OK')),
          )
        else if (_error != null) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(host.localize(context, 'close', 'Close')),
          ),
          FilledButton(
            onPressed: _start,
            child: Text(host.localize(context, 'dynamicRetry', 'Retry')),
          ),
        ] else
          TextButton(
            onPressed: _canceling ? null : _confirmCancel,
            child: Text(host.localize(context, 'cancel', 'Cancel')),
          ),
      ],
    );
  }
}


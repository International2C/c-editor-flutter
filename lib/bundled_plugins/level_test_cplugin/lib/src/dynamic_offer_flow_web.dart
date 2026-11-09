import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:c_editor/escape_override.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/data/launch_external_url.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin//lib/src/dynamic_fetch_ui.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/releases_api.dart';

const _kDefaultDynamicFileName = 'dynamic.rsb.smf';

/// Web variant of the external-dynamic offer flow.
///
/// GitHub release asset URLs (and their CDN redirects) do not send CORS
/// headers, so the browser blocks an in-page `fetch`. Instead we open the
/// normal browser download, then import the chosen file into OPFS via
/// [LevelRepository].
Future<bool> runExternalDynamicOfferWeb(
  BuildContext context, {
  required CPluginHost host,
  required String libraryPath,
  bool skipInitialPrompt = false,
}) async {
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

  final fileName = await _resolveWebFileName(
    context,
    host: host,
    libraryPath: libraryPath,
    preferredName: _kDefaultDynamicFileName,
  );
  if (fileName == null || !context.mounted) return false;

  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => EscapeClosesModal(
      child: _WebBrowserDownloadDialog(
        host: host,
        option: selected,
        libraryPath: libraryPath,
        fileName: fileName,
      ),
    ),
  );
  return saved == true;
}

Future<String?> _resolveWebFileName(
  BuildContext context, {
  required CPluginHost host,
  required String libraryPath,
  required String preferredName,
}) async {
  final exists = await LevelRepository.fileExistsInDirectory(
    libraryPath,
    preferredName,
  );
  if (!exists) return preferredName;
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

  return _promptAlternateWebFileName(
    context,
    host: host,
    libraryPath: libraryPath,
    preferredName: preferredName,
  );
}

Future<String?> _promptAlternateWebFileName(
  BuildContext context, {
  required CPluginHost host,
  required String libraryPath,
  required String preferredName,
}) async {
  final suggested = await _suggestAlternateWebFileName(
    libraryPath,
    preferredName,
  );
  if (!context.mounted) return null;
  final controller = TextEditingController(text: suggested);
  String? fieldError;

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return EscapeClosesModal(
        child: StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> submit() async {
              final navigator = Navigator.of(ctx);
              final resolved = await _validateAlternateWebFileName(
                libraryPath: libraryPath,
                raw: controller.text,
                host: host,
                context: ctx,
              );
              if (resolved.error != null) {
                setLocal(() => fieldError = resolved.error);
                return;
              }
              navigator.pop(resolved.fileName);
            }

            return AlertDialog(
              title: Text(host.localize(ctx, 'dynamicRenameTitle', 'Save as')),
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
                    onSubmitted: (_) => submit(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(host.localize(ctx, 'cancel', 'Cancel')),
                ),
                FilledButton(
                  onPressed: submit,
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

Future<String> _suggestAlternateWebFileName(
  String libraryPath,
  String preferredName,
) async {
  const ext = '.rsb.smf';
  var stem = preferredName;
  final lower = stem.toLowerCase();
  if (lower.endsWith(ext)) {
    stem = stem.substring(0, stem.length - ext.length);
  }
  for (var i = 2; i < 1000; i++) {
    final candidate = '${stem}_$i$ext';
    if (!await LevelRepository.fileExistsInDirectory(libraryPath, candidate)) {
      return candidate;
    }
  }
  return '${stem}_${DateTime.now().millisecondsSinceEpoch}$ext';
}

Future<({String? fileName, String? error})> _validateAlternateWebFileName({
  required String libraryPath,
  required String raw,
  required CPluginHost host,
  required BuildContext context,
}) async {
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
  // Localize before the async gap so we don't touch context after `await`.
  final existsError = host.localize(
    context,
    'dynamicRenameExists',
    'That file already exists. Choose another name.',
  );
  if (await LevelRepository.fileExistsInDirectory(libraryPath, name)) {
    return (fileName: null, error: existsError);
  }
  return (fileName: name, error: null);
}

String _webStorageKey(String libraryPath, String fileName) {
  const prefix = 'web://';
  // Strip a leaked scheme from [fileName] (path.basename on Flutter web can
  // return "web://…" for virtual library paths).
  var leaf = fileName.replaceAll('\\', '/').trim();
  if (leaf.startsWith(prefix)) {
    leaf = leaf.substring(prefix.length);
  } else if (leaf.startsWith('web:/')) {
    leaf = leaf.substring('web:/'.length);
  }
  while (leaf.startsWith('/')) {
    leaf = leaf.substring(1);
  }
  if (leaf.isEmpty) return leaf;

  if (libraryPath == prefix || !libraryPath.startsWith(prefix)) {
    return leaf;
  }
  final rel = libraryPath.substring(prefix.length);
  if (rel.isEmpty) return leaf;
  return '$rel/$leaf';
}

class _WebBrowserDownloadDialog extends StatefulWidget {
  const _WebBrowserDownloadDialog({
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
  State<_WebBrowserDownloadDialog> createState() =>
      _WebBrowserDownloadDialogState();
}

class _WebBrowserDownloadDialogState extends State<_WebBrowserDownloadDialog> {
  bool _importing = false;
  String? _error;
  bool _done = false;
  bool _openedBrowser = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openBrowserDownload());
  }

  Future<void> _openBrowserDownload() async {
    final ok = await launchExternalUrl(
      widget.option.downloadUrl,
      mode: LaunchMode.platformDefault,
    );
    if (!mounted) return;
    setState(() {
      _openedBrowser = ok;
      if (!ok) {
        _error = widget.host.localize(
          context,
          'dynamicWebOpenFailed',
          'Could not open the download link. Allow browser pop-ups, or download manually from GitHub Releases.',
        );
      }
    });
  }

  Future<void> _pickAndImport() async {
    final host = widget.host;
    setState(() {
      _importing = true;
      _error = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: const ['smf'],
        dialogTitle: host.localize(
          context,
          'dynamicWebPickTitle',
          'Select downloaded dynamic.rsb.smf',
        ),
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) {
        setState(() => _importing = false);
        return;
      }
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        setState(() {
          _importing = false;
          _error = host.localize(
            context,
            'dynamicWebPickEmpty',
            'Could not read the selected file. Make sure the download has finished and select a readable .rsb.smf file again.',
          );
        });
        return;
      }

      final key = _webStorageKey(widget.libraryPath, widget.fileName);
      // `bytes` is already a Uint8List from the picker; pass it through so the
      // repository doesn't make another full copy of a large archive.
      final ok = await LevelRepository.prepareInternalCacheFromBytes(
        key,
        bytes,
      );
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _importing = false;
          _error = host.localize(
            context,
            'dynamicWebImportFailed',
            'Could not store the file in the workspace. Check free space and make sure the browser allows local storage, then try again.',
          );
        });
        return;
      }
      setState(() {
        _importing = false;
        _done = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _importing = false;
        _error = host.localize(
          context,
          'dynamicWebImportFailed',
          'Could not store the file in the workspace. Check free space and make sure the browser allows local storage, then try again.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final host = widget.host;
    final sizeLabel = widget.option.sizeBytes > 0
        ? formatDynamicBytes(widget.option.sizeBytes)
        : '';
    final sizeSuffix = sizeLabel.isNotEmpty ? ' ($sizeLabel)' : '';
    final body = _done
        ? host.localize(context, 'dynamicDownloadDone', null, {
            'path': widget.fileName,
          })
        : host.localize(
            context,
            'dynamicWebImportBody',
            '1. Let the browser finish downloading {asset}{size}.\n'
                '2. Click "Choose file" and select that download to add it '
                'to your workspace as {name}.',
            {
              'asset': widget.option.assetName,
              'size': sizeSuffix,
              'name': widget.fileName,
            },
          );

    return AlertDialog(
      title: Text(
        host.localize(
          context,
          _done ? 'dynamicDownloadTitle' : 'dynamicWebImportTitle',
          _done ? 'Downloading dynamic' : 'Import dynamic',
        ),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.option.name),
            const SizedBox(height: 12),
            Text(body),
            if (_importing) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_done)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(host.localize(context, 'confirm', 'OK')),
          )
        else ...[
          TextButton(
            onPressed: _importing
                ? null
                : () => Navigator.of(context).pop(false),
            child: Text(host.localize(context, 'cancel', 'Cancel')),
          ),
          TextButton(
            onPressed: _importing ? null : _openBrowserDownload,
            child: Text(
              host.localize(
                context,
                _openedBrowser ? 'dynamicWebOpenAgain' : 'dynamicWebOpen',
                _openedBrowser ? 'Open link again' : 'Open download',
              ),
            ),
          ),
          FilledButton(
            onPressed: _importing ? null : _pickAndImport,
            child: Text(
              host.localize(context, 'dynamicWebPick', 'Choose file'),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'preview_export_prefs.dart';

typedef PreviewFolderListing = Future<List<FileItem>> Function(String path);
typedef PreviewFolderCreation = Future<bool> Function(String path, String name);

/// Folder-only navigation over the same repository used by workspace Move.
class PreviewExportFolderPicker extends StatefulWidget {
  const PreviewExportFolderPicker({
    super.key,
    required this.workspacePath,
    required this.initialFolder,
    required this.t,
    this.listFolders = LevelRepository.getDirectoryContents,
    this.createFolder = LevelRepository.createDirectory,
  });

  final String workspacePath;
  final String initialFolder;
  final String Function(String key, [String? fallback]) t;
  final PreviewFolderListing listFolders;
  final PreviewFolderCreation createFolder;

  @override
  State<PreviewExportFolderPicker> createState() =>
      _PreviewExportFolderPickerState();
}

class _PreviewExportFolderPickerState extends State<PreviewExportFolderPicker> {
  final _segments = <String>[];
  List<FileItem> _folders = [];
  bool _loading = true;
  String? _error;

  String get _relative => _segments.isEmpty ? '.' : _segments.join('/');
  String get _currentPath =>
      previewExportDirectoryPath(widget.workspacePath, _relative);
  String _t(String key, [String? fallback]) => widget.t(key, fallback);

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<List<FileItem>> _read() async => (await widget.listFolders(
    _currentPath,
  )).where((item) => item.isDirectory).toList();

  Future<void> _loadInitial() async {
    try {
      _folders = await _read();
      final initial = PreviewExportPrefs.normalizeRelativeFolderPath(
        widget.initialFolder,
      );
      if (initial != '.') {
        for (final name in initial.split('/')) {
          if (!_folders.any((folder) => folder.name == name)) break;
          _segments.add(name);
          _folders = await _read();
        }
      }
    } catch (_) {
      _error = _t(
        'previewSettingsFolderLoadFailed',
        'Unable to open this folder.',
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final folders = await _read();
      if (!mounted) return;
      setState(() => _folders = folders);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = _t(
          'previewSettingsFolderLoadFailed',
          'Unable to open this folder.',
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _back() {
    if (_loading) return;
    if (_segments.isEmpty) {
      Navigator.pop(context);
      return;
    }
    _segments.removeLast();
    _load();
  }

  Future<void> _newFolder() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _PreviewNewFolderDialog(t: widget.t),
    );
    if (name == null || !mounted) return;
    setState(() => _loading = true);
    try {
      if (!await widget.createFolder(_currentPath, name)) {
        throw StateError('Folder could not be created');
      }
      if (!mounted) return;
      _segments.add(name);
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'previewSettingsFolderCreateFailed',
              'Unable to create this folder. It may already exist.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentFolder = _relative == '.'
        ? _t('previewSettingsWorkspaceRoot', 'Workspace')
        : _relative;
    return PopScope(
      canPop: _segments.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _loading ? null : _back,
            icon: const Icon(Icons.arrow_back),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          title: Text(
            _t('previewSettingsChooseFolder', 'Choose export folder'),
          ),
        ),
        body: ListView(
          key: const ValueKey('previewExportFoldersScroll'),
          children: [
            Container(
              key: const ValueKey('previewExportLocationBanner'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              // Match the workspace Move banner, rather than looking like a
              // selectable directory row. This banner is information only.
              color: theme.colorScheme.secondaryContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.folder_open,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _t(
                            'previewSettingsCurrentFolder',
                            'Currently in: {folder}',
                          ).replaceAll('{folder}', currentFolder),
                          key: const ValueKey('previewExportCurrentFolder'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _t(
                            'previewSettingsFolderPickerHint',
                            'Open a folder below or create a new one, then tap '
                                '"Select this folder" to use the folder shown '
                                'above for export.',
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer
                                .withAlpha(204),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(padding: const EdgeInsets.all(24), child: Text(_error!))
            else ...[
              if (_segments.isNotEmpty)
                ListTile(
                  key: const ValueKey('previewExportParentFolder'),
                  leading: const Icon(Icons.drive_folder_upload_outlined),
                  title: Text(
                    _t('previewSettingsParentFolder', 'Go to parent folder'),
                  ),
                  onTap: _back,
                ),
              for (final folder in _folders)
                Card(
                  child: ListTile(
                    key: ValueKey('previewExportFolder-${folder.name}'),
                    leading: Icon(
                      Icons.folder,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(folder.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _segments.add(folder.name);
                      _load();
                    },
                  ),
                ),
              if (_folders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_t('previewSettingsNoFolders', 'No subfolders')),
                ),
            ],
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('previewExportCreateFolder'),
                  onPressed: _loading ? null : _newFolder,
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: Text(_t('previewSettingsNewFolder', 'New folder')),
                ),
                FilledButton.icon(
                  key: const ValueKey('previewExportSelectFolder'),
                  onPressed: _loading || _error != null
                      ? null
                      : () => Navigator.pop(context, _relative),
                  icon: const Icon(Icons.check),
                  label: Text(
                    _t('previewSettingsSelectFolder', 'Select this folder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewNewFolderDialog extends StatefulWidget {
  const _PreviewNewFolderDialog({required this.t});
  final String Function(String key, [String? fallback]) t;

  @override
  State<_PreviewNewFolderDialog> createState() =>
      _PreviewNewFolderDialogState();
}

class _PreviewNewFolderDialogState extends State<_PreviewNewFolderDialog> {
  final _input = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = _input.text.trim();
    if (!isValidPreviewExportFolderName(value)) {
      setState(
        () => _validationError = widget.t(
          'previewSettingsFolderNameInvalid',
          'Enter a valid folder name.',
        ),
      );
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(widget.t('previewSettingsNewFolder', 'New folder')),
    content: TextField(
      key: const ValueKey('previewExportNewFolderName'),
      autofocus: true,
      controller: _input,
      onSubmitted: (_) => _confirm(),
      decoration: InputDecoration(
        labelText: widget.t('previewSettingsFolderName', 'Folder name'),
        errorText: _validationError,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
      FilledButton(
        onPressed: _confirm,
        child: Text(MaterialLocalizations.of(context).okButtonLabel),
      ),
    ],
  );
}

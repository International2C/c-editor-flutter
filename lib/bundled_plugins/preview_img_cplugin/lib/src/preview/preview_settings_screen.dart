import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_export_prefs.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'preview_export_folder_picker.dart';
import 'preview_toolbar_prefs.dart';

/// Preview export destination and generator toolbar presentation.
class PreviewSettingsScreen extends StatefulWidget {
  const PreviewSettingsScreen({super.key, required this.host});

  final CPluginHost host;

  @override
  State<PreviewSettingsScreen> createState() => _PreviewSettingsScreenState();
}

class _PreviewSettingsScreenState extends State<PreviewSettingsScreen> {
  String _folder = kDefaultPreviewExportFolder;
  PreviewToolbarStyle _toolbarStyle = PreviewToolbarStyle.full;
  bool _autosavePreviewImage = false;
  bool _loading = true;
  bool _saving = false;
  SettingsCubit? _settingsCubit;

  String _t(String key, [String? fallback]) =>
      widget.host.localize(context, key, fallback ?? key);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _settingsCubit = context.read<SettingsCubit?>();
    final name = await PreviewExportPrefs.getFolderName();
    final toolbarStyle = await PreviewToolbarPrefs.getStyle();
    final autosavePreviewImage =
        _settingsCubit?.state.autosaveTargets.contains(
          AutosaveTarget.previewImage,
        ) ??
        (await SharedPreferences.getInstance()).getBool(
          AutosaveTarget.previewImage.preferenceKey,
        ) ??
        false;
    if (!mounted) return;
    setState(() {
      _folder = name;
      _toolbarStyle = toolbarStyle;
      _autosavePreviewImage = autosavePreviewImage;
      _loading = false;
    });
  }

  Future<void> _chooseFolder() async {
    final workspace = await LevelRepository.getSavedFolderPath();
    if (!mounted) return;
    if (workspace == null || workspace.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'previewSettingsWorkspaceRequired',
              'Choose a workspace before selecting an export folder.',
            ),
          ),
        ),
      );
      return;
    }
    final folder = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewExportFolderPicker(
          workspacePath: workspace,
          initialFolder: _folder,
          t: _t,
        ),
      ),
    );
    if (folder != null && mounted) setState(() => _folder = folder);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await PreviewExportPrefs.setFolderPath(_folder);
      await PreviewToolbarPrefs.setStyle(_toolbarStyle);
      final settingsCubit = _settingsCubit;
      if (settingsCubit != null) {
        final targets = {...settingsCubit.state.autosaveTargets};
        if (_autosavePreviewImage) {
          targets.add(AutosaveTarget.previewImage);
        } else {
          targets.remove(AutosaveTarget.previewImage);
        }
        settingsCubit.setAutosaveTargets(targets);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
          AutosaveTarget.previewImage.preferenceKey,
          _autosavePreviewImage,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('previewSettingsSaved', 'Settings saved'))),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'previewSettingsSaveFailed',
                'Unable to save settings. Please try again.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('previewSettings', 'Preview Image Generator settings')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('previewSettingsChooseExportFolder'),
                  onPressed: _saving ? null : _chooseFolder,
                  icon: const Icon(Icons.folder_open),
                  label: Text(
                    '${_t('configExportFolder', _t('previewSettingsChooseFolder', 'Choose export folder'))}: ${_folder == '.' ? _t('previewSettingsWorkspaceRoot', 'Workspace') : _folder}',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  key: const ValueKey('previewSettingsFolderHint'),
                  _t(
                    'configExportFolderDescription',
                    _t(
                      'previewSettingsFolderHint',
                      'PNG previews are saved to this folder in your workspace.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  key: const ValueKey('previewSettingsAutosaveOnExit'),
                  value: _autosavePreviewImage,
                  onChanged: _saving
                      ? null
                      : (value) => setState(
                          () => _autosavePreviewImage = value ?? false,
                        ),
                  title: Text(
                    _t(
                      'previewSettingsAutosaveOnExit',
                      'Save the image automatically when leaving the preview generator',
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                Text(
                  _t(
                    'configToolbarStyle',
                    _t('previewSettingsToolbarStyle', 'Toolbar style'),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RadioGroup<PreviewToolbarStyle>(
                  groupValue: _toolbarStyle,
                  onChanged: (value) {
                    if (value != null && !_saving) {
                      setState(() => _toolbarStyle = value);
                    }
                  },
                  child: Column(
                    children: [
                      RadioListTile<PreviewToolbarStyle>(
                        key: const ValueKey('previewToolbarStyleCompact'),
                        value: PreviewToolbarStyle.compact,
                        title: Text(
                          _t(
                            'configToolbarStyleCompact',
                            _t('previewSettingsToolbarCompact', 'Compact'),
                          ),
                        ),
                        subtitle: Text(
                          _t(
                            'configToolbarStyleCompactDescription',
                            _t(
                              'previewSettingsToolbarCompactHint',
                              'Icon-only controls with tooltips; tool and add-element controls share one row.',
                            ),
                          ),
                        ),
                      ),
                      RadioListTile<PreviewToolbarStyle>(
                        key: const ValueKey('previewToolbarStyleFull'),
                        value: PreviewToolbarStyle.full,
                        title: Text(
                          _t(
                            'configToolbarStyleFull',
                            _t('previewSettingsToolbarFull', 'Full'),
                          ),
                        ),
                        subtitle: Text(
                          _t(
                            'configToolbarStyleFullDescription',
                            _t(
                              'previewSettingsToolbarFullHint',
                              'Show button labels and explanations below each function.',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_t('previewSettingsSave', 'Save')),
                ),
              ],
            ),
    );
  }
}

import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/interface_menu_config.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/widgets/app_ui_scale.dart';
import 'package:c_editor/widgets/dropdown_pointer_focus.dart';
import 'package:c_editor/widgets/locale_flag_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens the interface settings page without coupling callers to its route.
Future<void> showInterfaceSettingsScreen(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => const InterfaceSettingsScreen()),
  );
}

class InterfaceSettingsScreen extends StatefulWidget {
  const InterfaceSettingsScreen({super.key});

  @override
  State<InterfaceSettingsScreen> createState() =>
      _InterfaceSettingsScreenState();
}

class _InterfaceSettingsScreenState extends State<InterfaceSettingsScreen> {
  // Intentionally kept in memory only. This restores the position when the
  // page is reopened, but naturally resets after the app process is cleared.
  static double _sessionScrollOffset = 0;

  late final ScrollController _scrollController;
  InterfaceMenuSurface _selectedSurface = InterfaceMenuSurface.workspace;
  double? _pendingUiScale;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: _sessionScrollOffset,
    )..addListener(_rememberScrollOffset);
  }

  void _rememberScrollOffset() {
    if (_scrollController.hasClients) {
      _sessionScrollOffset = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    _rememberScrollOffset();
    _scrollController
      ..removeListener(_rememberScrollOffset)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pluginManager = PluginManager.isInitialized
        ? PluginManager.instance
        : null;

    Widget buildPage() {
      return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          _pendingUiScale ??= settings.uiScale;
          final preferenceSections = <Widget>[
            if (_showSettingOnPage(settings, InterfaceMenuActionIds.language))
              _buildLanguageSection(context, l10n, settings),
            if (_showSettingOnPage(settings, InterfaceMenuActionIds.theme))
              _buildThemeSection(context, l10n, settings),
            if (_showSettingOnPage(settings, InterfaceMenuActionIds.uiScale))
              _buildScaleSection(context, l10n, settings),
            if (_showSettingOnPage(settings, InterfaceMenuActionIds.autosave))
              _buildAutosaveSection(context, l10n, settings),
            _buildPopupPromptsSection(context, l10n, settings),
          ];
          return Scaffold(
            appBar: AppBar(title: Text(l10n.interfaceSettings)),
            body: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.right,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.sizeOf(context).width < 360 ? 8 : 16,
                  16,
                  MediaQuery.sizeOf(context).width < 360 ? 16 : 24,
                  40,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 880),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (
                          var index = 0;
                          index < preferenceSections.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(height: 12),
                          preferenceSections[index],
                        ],
                        const SizedBox(height: 24),
                        _buildMenuCustomization(context, l10n, settings),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    if (pluginManager == null) return buildPage();
    return ListenableBuilder(
      listenable: pluginManager,
      builder: (context, _) => buildPage(),
    );
  }

  bool _showSettingOnPage(SettingsState settings, String actionId) {
    return const [
      InterfaceMenuSurface.workspace,
      InterfaceMenuSurface.levelEditor,
    ].any(
      (surface) => settings
          .interfaceMenuActionsFor(surface)
          .any(
            (action) =>
                action.id == actionId &&
                action.placement == InterfaceMenuPlacement.settingsPage,
          ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    AppLocalizations l10n,
    SettingsState settings,
  ) {
    final languageCode = settings.locale.languageCode;
    final languages = <({String code, String label})>[
      (code: 'en', label: l10n.languageEnglish),
      (code: 'zh', label: l10n.languageChinese),
      (code: 'ru', label: l10n.languageRussian),
    ];

    return _SettingsSection(
      icon: Icons.language,
      title: l10n.language,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 520) {
            return RadioGroup<String>(
              groupValue: languageCode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().setLocale(Locale(value));
                }
              },
              child: Column(
                children: [
                  for (final language in languages)
                    RadioListTile<String>(
                      value: language.code,
                      secondary: LocaleFlagIcon(
                        language.code,
                        width: 28,
                        height: 19,
                      ),
                      title: Text(language.label),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            );
          }
          return SegmentedButton<String>(
            showSelectedIcon: false,
            expandedInsets: EdgeInsets.zero,
            segments: [
              for (final language in languages)
                ButtonSegment<String>(
                  value: language.code,
                  icon: LocaleFlagIcon(language.code, width: 24, height: 16),
                  label: Text(language.label),
                ),
            ],
            selected: {languageCode},
            onSelectionChanged: (selection) {
              context.read<SettingsCubit>().setLocale(Locale(selection.first));
            },
          );
        },
      ),
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    AppLocalizations l10n,
    SettingsState settings,
  ) {
    final theme = Theme.of(context);

    return _SettingsSection(
      icon: Icons.brightness_6_outlined,
      title: l10n.toggleTheme,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            final selector = SegmentedButton<ThemeMode>(
              key: const ValueKey('interfaceSettingsThemeSelector'),
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Semantics(
                    label: l10n.lightTheme,
                    child: const Icon(Icons.light_mode),
                  ),
                  label: compact ? null : Text(l10n.lightTheme),
                  tooltip: l10n.lightTheme,
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Semantics(
                    label: l10n.darkTheme,
                    child: const Icon(Icons.dark_mode),
                  ),
                  label: compact ? null : Text(l10n.darkTheme),
                  tooltip: l10n.darkTheme,
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) {
                context.read<SettingsCubit>().setThemeMode(selection.first);
              },
            );
            if (!compact) return selector;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.currentTheme(
                    settings.themeMode == ThemeMode.dark
                        ? l10n.darkTheme
                        : l10n.lightTheme,
                  ),
                ),
                const SizedBox(height: 8),
                selector,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScaleSection(
    BuildContext context,
    AppLocalizations l10n,
    SettingsState settings,
  ) {
    final scale = (_pendingUiScale ?? settings.uiScale).clamp(0.75, 1.5);

    void setScale(double value, {bool persist = false}) {
      setState(() => _pendingUiScale = value);
      if (persist) context.read<SettingsCubit>().setUiScale(value);
    }

    return _SettingsSection(
      icon: Icons.aspect_ratio,
      title: l10n.uiSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.currentScale((scale * 100).round().toString()),
            textAlign: TextAlign.center,
          ),
          Slider(
            key: const ValueKey('interfaceSettingsUiScaleSlider'),
            value: scale,
            min: 0.75,
            max: 1.5,
            divisions: 75,
            label: '${(scale * 100).round()}%',
            onChanged: setScale,
            onChangeEnd: (value) => setScale(value, persist: true),
          ),
          _ScalePresets(
            scale: scale,
            labels: [l10n.small, l10n.standard, l10n.large, l10n.ultra],
            onSelected: (value) => setScale(value, persist: true),
          ),
          const SizedBox(height: 16),
          _ScalePreview(scale: scale, l10n: l10n),
        ],
      ),
    );
  }

  Widget _buildAutosaveSection(
    BuildContext context,
    AppLocalizations l10n,
    SettingsState settings,
  ) {
    final visibleTargets = AutosaveTarget.values
        .where(
          (target) =>
              target != AutosaveTarget.previewImage ||
              PluginHostHooks.openPreviewImageGenerator != null,
        )
        .toList(growable: false);
    final selectedCount = visibleTargets
        .where(settings.autosaveTargets.contains)
        .length;
    final labels = <AutosaveTarget, String>{
      AutosaveTarget.level: l10n.autosaveSubtitle,
      AutosaveTarget.zombossAction: l10n.autosaveZombossAction,
      AutosaveTarget.portal: l10n.autosavePortal,
      AutosaveTarget.resilienceShield: l10n.autosaveResilienceShield,
      AutosaveTarget.previewImage: l10n.autosavePreviewImage,
    };

    void updateTargets(Set<AutosaveTarget> targets) {
      context.read<SettingsCubit>().setAutosaveTargets(targets);
    }

    return _SettingsSection(
      icon: Icons.save_outlined,
      title: l10n.autosave,
      child: Column(
        children: [
          CheckboxListTile(
            key: const ValueKey('interfaceSettingsAutosaveSelectAll'),
            tristate: true,
            value: selectedCount == 0
                ? false
                : selectedCount == visibleTargets.length
                ? true
                : null,
            onChanged: (_) {
              final next = {...settings.autosaveTargets};
              if (selectedCount == visibleTargets.length) {
                next.removeAll(visibleTargets);
              } else {
                next.addAll(visibleTargets);
              }
              updateTargets(next);
            },
            title: Text(l10n.selectAll),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 1),
          for (final target in visibleTargets)
            CheckboxListTile(
              key: ValueKey('interfaceSettingsAutosave_${target.name}'),
              value: settings.autosaveTargets.contains(target),
              onChanged: (selected) {
                final next = {...settings.autosaveTargets};
                selected == true ? next.add(target) : next.remove(target);
                updateTargets(next);
              },
              title: Text(labels[target]!),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildPopupPromptsSection(
    BuildContext context,
    AppLocalizations l10n,
    SettingsState settings,
  ) {
    return _SettingsSection(
      icon: Icons.notifications_outlined,
      title: l10n.popupPrompts,
      child: Column(
        children: [
          _ResponsiveSettingSwitch(
            key: const ValueKey('interfaceSettingsAliasPromptOnCreate'),
            value: settings.promptForAliasOnCreate,
            onChanged: context.read<SettingsCubit>().setPromptForAliasOnCreate,
            title: l10n.aliasPromptOnCreate,
            description: l10n.aliasPromptOnCreateDescription,
          ),
          const Divider(height: 24),
          _ResponsiveSettingSwitch(
            key: const ValueKey('interfaceSettingsCheckForUpdates'),
            value: settings.checkForUpdates,
            onChanged: context.read<SettingsCubit>().setCheckForUpdates,
            title: l10n.checkForUpdatesAutomatically,
            description: l10n.checkForUpdatesAutomaticallyDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCustomization(
    BuildContext context,
    AppLocalizations l10n,
    SettingsState settings,
  ) {
    final allActions = settings.interfaceMenuActionsFor(_selectedSurface);
    final actions = allActions
        .where((action) => _actionVisibleOnThisPlatform(action.id))
        .toList(growable: false);

    return _SettingsSection(
      icon: Icons.more_vert,
      title: l10n.menuCustomization,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.menuCustomizationDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _SurfaceSelector(
            selected: _selectedSurface,
            l10n: l10n,
            onSelected: (surface) {
              setState(() => _selectedSurface = surface);
            },
          ),
          const SizedBox(height: 12),
          Text(
            l10n.menuCustomizationDragHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            key: ValueKey('interfaceMenuViewport_${_selectedSurface.name}'),
            constraints: BoxConstraints(
              maxHeight: (MediaQuery.sizeOf(context).height * 0.65).clamp(
                320.0,
                720.0,
              ),
            ),
            child: ReorderableListView.builder(
              key: ValueKey('interfaceMenu_${_selectedSurface.name}'),
              shrinkWrap: true,
              primary: false,
              physics: const ClampingScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: actions.length,
              onReorderItem: (oldIndex, newIndex) {
                _reorderVisibleAction(
                  context,
                  allActions,
                  actions,
                  oldIndex,
                  newIndex,
                );
              },
              itemBuilder: (context, index) {
                final action = actions[index];
                return _MenuActionTile(
                  key: ValueKey('${_selectedSurface.name}_${action.id}'),
                  index: index,
                  icon: _actionIcon(action.id),
                  label: _actionLabel(action.id, l10n),
                  placement: action.placement,
                  toolbarLabel: l10n.menuPlacementToolbar,
                  overflowLabel: l10n.menuPlacementOverflow,
                  settingsPageLabel: l10n.menuPlacementSettingsPage,
                  allowSettingsPage: supportsInterfaceSettingsPagePlacement(
                    action.id,
                  ),
                  onPlacementChanged: (placement) {
                    context
                        .read<SettingsCubit>()
                        .setInterfaceMenuActionPlacement(
                          _selectedSurface,
                          action.id,
                          placement,
                        );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                context.read<SettingsCubit>().resetInterfaceMenuActions(
                  _selectedSurface,
                );
              },
              icon: const Icon(Icons.restore),
              label: Text(l10n.menuConfigurationReset),
            ),
          ),
        ],
      ),
    );
  }

  void _reorderVisibleAction(
    BuildContext context,
    List<InterfaceMenuActionPreference> allActions,
    List<InterfaceMenuActionPreference> visibleActions,
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex == newIndex) return;

    final visible = [...visibleActions];
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);

    // Preserve hidden platform-specific actions and replace only the visible
    // slots. This avoids losing the saved order when the same preferences are
    // later opened on a different platform.
    final iterator = visible.iterator;
    final visibleIds = visible.map((action) => action.id).toSet();
    final reordered = <InterfaceMenuActionPreference>[];
    for (final action in allActions) {
      if (visibleIds.contains(action.id)) {
        iterator.moveNext();
        reordered.add(iterator.current);
      } else {
        reordered.add(action);
      }
    }
    context.read<SettingsCubit>().setInterfaceMenuActions(
      _selectedSurface,
      reordered,
    );
  }

  bool _actionVisibleOnThisPlatform(String id) {
    return switch (id) {
      InterfaceMenuActionIds.refresh ||
      InterfaceMenuActionIds.switchFolder => !kIsWeb,
      InterfaceMenuActionIds.importFiles ||
      InterfaceMenuActionIds.importFolder ||
      InterfaceMenuActionIds.downloadAll => kIsWeb,
      _ => true,
    };
  }

  String _actionLabel(String id, AppLocalizations l10n) {
    return switch (id) {
      InterfaceMenuActionIds.language => l10n.language,
      InterfaceMenuActionIds.theme => l10n.toggleTheme,
      InterfaceMenuActionIds.uiScale => l10n.uiSize,
      InterfaceMenuActionIds.autosave => l10n.autosave,
      InterfaceMenuActionIds.interfaceSettings => l10n.interfaceSettings,
      InterfaceMenuActionIds.sort => l10n.sortByLabel,
      InterfaceMenuActionIds.refresh => l10n.refresh,
      InterfaceMenuActionIds.switchFolder => l10n.switchFolder,
      InterfaceMenuActionIds.importFiles => l10n.importFiles,
      InterfaceMenuActionIds.importFolder => l10n.importFolder,
      InterfaceMenuActionIds.downloadAll => l10n.downloadAllLevels,
      InterfaceMenuActionIds.clearCache => l10n.clearCache,
      InterfaceMenuActionIds.plugins => l10n.pluginsTitle,
      InterfaceMenuActionIds.about => l10n.aboutSoftware,
      InterfaceMenuActionIds.viewJson => l10n.tooltipJsonViewer,
      InterfaceMenuActionIds.levelOverview => l10n.levelOverview,
      InterfaceMenuActionIds.toggleJsonView => l10n.tooltipToggleObjectView,
      InterfaceMenuActionIds.copyJson => l10n.tooltipCopyJson,
      InterfaceMenuActionIds.clearUnused => l10n.tooltipClearUnused,
      InterfaceMenuActionIds.editJson => l10n.tooltipEdit,
      _ => id,
    };
  }

  IconData _actionIcon(String id) {
    return switch (id) {
      InterfaceMenuActionIds.language => Icons.language,
      InterfaceMenuActionIds.theme => Icons.brightness_6_outlined,
      InterfaceMenuActionIds.uiScale => Icons.aspect_ratio,
      InterfaceMenuActionIds.autosave => Icons.save_outlined,
      InterfaceMenuActionIds.interfaceSettings => Icons.tune,
      InterfaceMenuActionIds.sort => Icons.sort,
      InterfaceMenuActionIds.refresh => Icons.refresh,
      InterfaceMenuActionIds.switchFolder => Icons.folder_open,
      InterfaceMenuActionIds.importFiles => Icons.file_open,
      InterfaceMenuActionIds.importFolder => Icons.drive_folder_upload_outlined,
      InterfaceMenuActionIds.downloadAll => Icons.download,
      InterfaceMenuActionIds.clearCache => Icons.delete_outline,
      InterfaceMenuActionIds.plugins => Icons.extension,
      InterfaceMenuActionIds.about => Icons.info_outline,
      InterfaceMenuActionIds.viewJson => Icons.code,
      InterfaceMenuActionIds.levelOverview => Icons.visibility,
      InterfaceMenuActionIds.toggleJsonView => Icons.data_object,
      InterfaceMenuActionIds.copyJson => Icons.copy,
      InterfaceMenuActionIds.clearUnused => Icons.cleaning_services,
      InterfaceMenuActionIds.editJson => Icons.edit,
      _ => Icons.more_horiz,
    };
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: EdgeInsets.all(constraints.maxWidth < 320 ? 10 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveSettingSwitch extends StatelessWidget {
  const _ResponsiveSettingSwitch({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 360) {
          return SwitchListTile.adaptive(
            value: value,
            onChanged: onChanged,
            title: Text(title),
            subtitle: Text(description),
            contentPadding: EdgeInsets.zero,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Switch.adaptive(value: value, onChanged: onChanged),
              ],
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScalePresets extends StatelessWidget {
  const _ScalePresets({
    required this.scale,
    required this.labels,
    required this.onSelected,
  });

  static const _values = [0.75, 1.0, 1.25, 1.5];
  final double scale;
  final List<String> labels;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < _values.length; index++)
          ChoiceChip(
            label: Text(labels[index]),
            selected: (scale - _values[index]).abs() < 0.0001,
            onSelected: (_) => onSelected(_values[index]),
          ),
      ],
    );
  }
}

class _ScalePreview extends StatelessWidget {
  const _ScalePreview({required this.scale, required this.l10n});

  final double scale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inheritedScale = AppUiScale.of(context);
    final localScale = scale / (inheritedScale <= 0 ? 1 : inheritedScale);
    return Container(
      key: const ValueKey('interfaceSettingsUiScalePreview'),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.uiScalePreview,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              // Relayout at the draft zoom before painting it, matching the
              // full-width module list used by the level settings screen.
              final logicalWidth = constraints.maxWidth / localScale;
              return FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  key: const ValueKey('interfaceSettingsPreviewLayout'),
                  width: logicalWidth,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: Size(
                        logicalWidth,
                        MediaQuery.sizeOf(context).height,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final objClass in const [
                          'SeedBankProperties',
                          'SunDropperProperties',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Builder(
                              builder: (context) {
                                final meta = ModuleRegistry.getMetadata(
                                  objClass,
                                );
                                return LevelSettingsModuleTile(
                                  info: ModuleUIInfo(
                                    rtid: '',
                                    alias: meta.defaultAlias,
                                    objClass: objClass,
                                    friendlyName: meta.getTitle(context),
                                    description: meta.getDescription(context),
                                    icon: meta.icon,
                                    assetIconPath: meta.assetIconPath,
                                    isCore: true,
                                    canEdit: false,
                                  ),
                                  isCore: true,
                                  reorderIndex: 0,
                                  removeTooltip: l10n.removeModule,
                                  preview: true,
                                  onDelete: () {},
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SurfaceSelector extends StatelessWidget {
  const _SurfaceSelector({
    required this.selected,
    required this.l10n,
    required this.onSelected,
  });

  final InterfaceMenuSurface selected;
  final AppLocalizations l10n;
  final ValueChanged<InterfaceMenuSurface> onSelected;

  String _label(InterfaceMenuSurface surface) => switch (surface) {
    InterfaceMenuSurface.workspace => l10n.menuSurfaceWorkspace,
    InterfaceMenuSurface.levelEditor => l10n.menuSurfaceLevelEditor,
    InterfaceMenuSurface.jsonViewer => l10n.menuSurfaceJsonViewer,
  };

  IconData _icon(InterfaceMenuSurface surface) => switch (surface) {
    InterfaceMenuSurface.workspace => Icons.folder_copy_outlined,
    InterfaceMenuSurface.levelEditor => Icons.edit_note,
    InterfaceMenuSurface.jsonViewer => Icons.data_object,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return DropdownPointerFocus(
            builder: (context, focusNode) =>
                DropdownButtonFormField<InterfaceMenuSurface>(
                  focusNode: focusNode,
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final surface in InterfaceMenuSurface.values)
                      DropdownMenuItem<InterfaceMenuSurface>(
                        value: surface,
                        child: Row(
                          children: [
                            Icon(_icon(surface)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _label(surface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) onSelected(value);
                  },
                ),
          );
        }
        return SegmentedButton<InterfaceMenuSurface>(
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          segments: [
            for (final surface in InterfaceMenuSurface.values)
              ButtonSegment<InterfaceMenuSurface>(
                value: surface,
                icon: Icon(_icon(surface)),
                label: Text(_label(surface)),
              ),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => onSelected(selection.first),
        );
      },
    );
  }
}

class _MenuActionTile extends StatelessWidget {
  const _MenuActionTile({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.placement,
    required this.toolbarLabel,
    required this.overflowLabel,
    required this.settingsPageLabel,
    required this.allowSettingsPage,
    required this.onPlacementChanged,
  });

  final int index;
  final IconData icon;
  final String label;
  final InterfaceMenuPlacement placement;
  final String toolbarLabel;
  final String overflowLabel;
  final String settingsPageLabel;
  final bool allowSettingsPage;
  final ValueChanged<InterfaceMenuPlacement> onPlacementChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 680;
            final placementControl = SizedBox(
              key: const ValueKey('interfaceMenuPlacementControl'),
              width: stacked ? double.infinity : 320,
              child: _PlacementControl(
                placement: placement,
                toolbarLabel: toolbarLabel,
                overflowLabel: overflowLabel,
                settingsPageLabel: settingsPageLabel,
                allowSettingsPage: allowSettingsPage,
                onChanged: onPlacementChanged,
                compact: stacked || allowSettingsPage,
              ),
            );
            final title = Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.drag_indicator),
                  ),
                ),
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [title, const SizedBox(height: 6), placementControl],
              );
            }
            return Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: 12),
                placementControl,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlacementControl extends StatelessWidget {
  const _PlacementControl({
    required this.placement,
    required this.toolbarLabel,
    required this.overflowLabel,
    required this.settingsPageLabel,
    required this.allowSettingsPage,
    required this.onChanged,
    required this.compact,
  });

  final InterfaceMenuPlacement placement;
  final String toolbarLabel;
  final String overflowLabel;
  final String settingsPageLabel;
  final bool allowSettingsPage;
  final ValueChanged<InterfaceMenuPlacement> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: ShapeDecoration(
          shape: StadiumBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownPointerFocus(
            builder: (context, focusNode) =>
                DropdownButton<InterfaceMenuPlacement>(
                  focusNode: focusNode,
                  value: placement,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: InterfaceMenuPlacement.toolbar,
                      child: Row(
                        children: [
                          const Icon(Icons.push_pin_outlined, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              toolbarLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: InterfaceMenuPlacement.overflow,
                      child: Row(
                        children: [
                          const Icon(Icons.more_vert, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              overflowLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (allowSettingsPage)
                      DropdownMenuItem(
                        value: InterfaceMenuPlacement.settingsPage,
                        child: Row(
                          children: [
                            const Icon(Icons.tune, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                settingsPageLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) onChanged(value);
                  },
                ),
          ),
        ),
      );
    }
    return SegmentedButton<InterfaceMenuPlacement>(
      showSelectedIcon: false,
      expandedInsets: EdgeInsets.zero,
      segments: [
        ButtonSegment(
          value: InterfaceMenuPlacement.toolbar,
          icon: const Icon(Icons.push_pin_outlined),
          label: Text(toolbarLabel),
        ),
        ButtonSegment(
          value: InterfaceMenuPlacement.overflow,
          icon: const Icon(Icons.more_vert),
          label: Text(overflowLabel),
        ),
        if (allowSettingsPage)
          ButtonSegment(
            value: InterfaceMenuPlacement.settingsPage,
            icon: const Icon(Icons.tune),
            label: Text(settingsPageLabel),
          ),
      ],
      selected: {placement},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

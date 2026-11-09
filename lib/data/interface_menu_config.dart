import 'package:equatable/equatable.dart';

/// App bars whose built-in actions can be arranged independently.
enum InterfaceMenuSurface { workspace, levelEditor, jsonViewer }

/// Where an action is presented.
///
/// [settingsPage] is available only to the global interface preferences
/// (language, theme, UI scale and autosave). It removes their shortcut from
/// the selected app bar and keeps the corresponding control on the Interface
/// Settings page instead.
enum InterfaceMenuPlacement { toolbar, overflow, settingsPage }

const interfaceSettingsPageActionIds = <String>{
  InterfaceMenuActionIds.language,
  InterfaceMenuActionIds.theme,
  InterfaceMenuActionIds.uiScale,
  InterfaceMenuActionIds.autosave,
};

bool supportsInterfaceSettingsPagePlacement(String actionId) =>
    interfaceSettingsPageActionIds.contains(actionId);

final class InterfaceMenuActionPreference extends Equatable {
  const InterfaceMenuActionPreference({
    required this.id,
    required this.placement,
  });

  final String id;
  final InterfaceMenuPlacement placement;

  InterfaceMenuActionPreference copyWith({InterfaceMenuPlacement? placement}) {
    return InterfaceMenuActionPreference(
      id: id,
      placement: placement ?? this.placement,
    );
  }

  @override
  List<Object> get props => [id, placement];
}

abstract final class InterfaceMenuActionIds {
  static const language = 'lang';
  static const theme = 'theme';
  static const uiScale = 'ui';
  static const autosave = 'autosave';
  static const interfaceSettings = 'interface_settings';

  static const sort = 'sort';
  static const refresh = 'refresh';
  static const switchFolder = 'switch_folder';
  static const importFiles = 'import_files';
  static const importFolder = 'import_folder';
  static const downloadAll = 'download_all';
  static const clearCache = 'cache';
  static const plugins = 'plugins';
  static const about = 'about';
  static const levelTestingMod = 'level_testing_mod';

  static const viewJson = 'json';
  static const levelOverview = 'level_overview';

  static const toggleJsonView = 'toggle_view';
  static const copyJson = 'copy';
  static const clearUnused = 'clear_unused';
  static const editJson = 'edit';
}

const _workspaceDefaults = <InterfaceMenuActionPreference>[
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.sort,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.refresh,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.switchFolder,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.importFiles,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.importFolder,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.downloadAll,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.language,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.theme,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.uiScale,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.clearCache,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.interfaceSettings,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.plugins,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.about,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.levelTestingMod,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.autosave,
    placement: InterfaceMenuPlacement.settingsPage,
  ),
];

const _levelEditorDefaults = <InterfaceMenuActionPreference>[
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.language,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.theme,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.uiScale,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.autosave,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.viewJson,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.interfaceSettings,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.levelOverview,
    placement: InterfaceMenuPlacement.overflow,
  ),
];

const _jsonViewerDefaults = <InterfaceMenuActionPreference>[
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.toggleJsonView,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.copyJson,
    placement: InterfaceMenuPlacement.toolbar,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.clearUnused,
    placement: InterfaceMenuPlacement.overflow,
  ),
  InterfaceMenuActionPreference(
    id: InterfaceMenuActionIds.editJson,
    placement: InterfaceMenuPlacement.overflow,
  ),
];

List<InterfaceMenuActionPreference> defaultInterfaceMenuActions(
  InterfaceMenuSurface surface,
) {
  final defaults = switch (surface) {
    InterfaceMenuSurface.workspace => _workspaceDefaults,
    InterfaceMenuSurface.levelEditor => _levelEditorDefaults,
    InterfaceMenuSurface.jsonViewer => _jsonViewerDefaults,
  };
  return List<InterfaceMenuActionPreference>.unmodifiable(defaults);
}

String interfaceMenuPreferenceKey(InterfaceMenuSurface surface) =>
    'interface_menu_${surface.name}_v1';

/// Reads a saved list while retaining newly added actions and dropping stale
/// or duplicate entries.
List<InterfaceMenuActionPreference> decodeInterfaceMenuActions(
  InterfaceMenuSurface surface,
  List<String>? encoded,
) {
  final defaults = defaultInterfaceMenuActions(surface);
  if (encoded == null || encoded.isEmpty) return defaults;

  final defaultById = {for (final item in defaults) item.id: item};
  final seen = <String>{};
  final result = <InterfaceMenuActionPreference>[];
  for (final value in encoded) {
    final separator = value.lastIndexOf('|');
    if (separator <= 0 || separator == value.length - 1) continue;
    final id = value.substring(0, separator);
    if (!defaultById.containsKey(id) || !seen.add(id)) continue;
    final placementName = value.substring(separator + 1);
    final decodedPlacement = placementName == 'settings'
        ? const [InterfaceMenuPlacement.overflow]
        : InterfaceMenuPlacement.values.where(
            (candidate) => candidate.name == placementName,
          );
    final placement = decodedPlacement.isEmpty
        ? defaultById[id]!.placement
        : decodedPlacement.first;
    result.add(
      InterfaceMenuActionPreference(
        id: id,
        placement:
            placement == InterfaceMenuPlacement.settingsPage &&
                !supportsInterfaceSettingsPagePlacement(id)
            ? defaultById[id]!.placement
            : placement,
      ),
    );
  }
  for (final item in defaults) {
    if (seen.add(item.id)) result.add(item);
  }
  return List<InterfaceMenuActionPreference>.unmodifiable(result);
}

List<String> encodeInterfaceMenuActions(
  List<InterfaceMenuActionPreference> actions,
) => actions
    .map((action) => '${action.id}|${action.placement.name}')
    .toList(growable: false);

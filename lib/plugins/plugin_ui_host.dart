import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/widgets/editor_components.dart'
    show EditorPopupMenuTile;

/// Opens a plugin-contributed UI element as a full-screen route.
void openPluginUiElement(BuildContext context, PluginUiElement element) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => element.builder(context)),
  );
}

/// AppBar icon buttons for [CPluginUiSlots.editorAppBar].
List<Widget> pluginEditorAppBarActions(BuildContext context) {
  if (!PluginManager.isInitialized) return const [];
  final registry = PluginManager.instance.screenRegistry;
  final actions = registry.editorActionsForSlot(CPluginUiSlots.editorAppBar);
  final elements = registry.elementsForSlot(CPluginUiSlots.editorAppBar);

  return [
    for (final action in actions)
      IconButton(
        icon: Icon(action.icon),
        tooltip: action.titleBuilder(context),
        onPressed: () => action.onActivate(context),
      ),
    for (final element in elements)
      IconButton(
        icon: Icon(element.icon),
        tooltip: element.resolvedTitle(context),
        onPressed: () => openPluginUiElement(context, element),
      ),
  ];
}

/// Overflow [PopupMenuItem]s for a given plugin UI [slot].
List<PopupMenuEntry<String>> pluginOverflowMenuItems({
  required BuildContext context,
  required String slot,
  required String valuePrefix,
  Set<String> excludedElementKeys = const {},
}) {
  if (!PluginManager.isInitialized) return const [];
  final registry = PluginManager.instance.screenRegistry;
  final actions = registry.editorActionsForSlot(slot);
  final elements = registry.elementsForSlot(slot);
  if (actions.isEmpty && elements.isEmpty) return const [];

  return [
    for (final action in actions)
      PopupMenuItem<String>(
        value: '$valuePrefix${action.key}',
        child: EditorPopupMenuTile(
          leading: Icon(action.icon),
          title: Text(action.titleBuilder(context)),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    for (final element in elements)
      if (!excludedElementKeys.contains(element.key))
        PopupMenuItem<String>(
          value: '$valuePrefix${element.key}',
          child: EditorPopupMenuTile(
            leading: Icon(element.icon),
            title: Text(element.resolvedTitle(context)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
  ];
}

/// Resolves an overflow menu selection that uses [valuePrefix].
bool handlePluginOverflowSelection(
  BuildContext context, {
  required String value,
  required String valuePrefix,
  required String slot,
}) {
  if (!value.startsWith(valuePrefix)) return false;
  if (!PluginManager.isInitialized) return false;
  final key = value.substring(valuePrefix.length);
  final registry = PluginManager.instance.screenRegistry;

  final actionMatch = registry
      .editorActionsForSlot(slot)
      .where((e) => e.key == key);
  if (actionMatch.isNotEmpty) {
    actionMatch.first.onActivate(context);
    return true;
  }

  final elementMatch = registry
      .elementsForSlot(slot)
      .where((e) => e.key == key);
  if (elementMatch.isEmpty) return false;
  openPluginUiElement(context, elementMatch.first);
  return true;
}

/// Level-list file overflow items contributed by plugins.
List<PopupMenuEntry<String>> pluginLevelFileMenuItems({
  required BuildContext context,
  required String fileName,
  required String valuePrefix,
}) {
  if (!PluginManager.isInitialized) return const [];
  final actions = PluginManager.instance.screenRegistry.levelFileActionsFor(
    fileName,
  );
  if (actions.isEmpty) return const [];
  return [
    for (final action in actions)
      PopupMenuItem<String>(
        value: '$valuePrefix${action.key}',
        child: EditorPopupMenuTile(
          leading: Icon(action.icon, size: 22),
          title: Text(action.titleBuilder(context)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
  ];
}

/// Handles a level-file menu selection from [pluginLevelFileMenuItems].
bool handlePluginLevelFileSelection(
  BuildContext context, {
  required String value,
  required String valuePrefix,
  required String fileName,
  required String filePath,
}) {
  if (!value.startsWith(valuePrefix)) return false;
  if (!PluginManager.isInitialized) return false;
  final key = value.substring(valuePrefix.length);
  final match = PluginManager.instance.screenRegistry
      .levelFileActionsFor(fileName)
      .where((e) => e.key == key);
  if (match.isEmpty) return false;
  match.first.onActivate(context, fileName, filePath);
  return true;
}

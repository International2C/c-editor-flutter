import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/registration.dart'
    show kLevelTestingModPluginId;
import 'package:c_editor/data/interface_menu_config.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';

/// Resolves configurable workspace entries from the active plugin registry.
/// Keeping the preference separate from registration preserves the chosen
/// order and placement when its plugin is disabled and enabled again.
PluginUiElement? workspacePluginMenuElement(String actionId) {
  if (actionId != InterfaceMenuActionIds.levelTestingMod ||
      !PluginManager.isInitialized) {
    return null;
  }
  final activeRegistry = PluginManager.instance.screenRegistry;
  for (final element in activeRegistry.elementsForSlot(
    CPluginUiSlots.levelListOverflow,
  )) {
    if (element.pluginId == kLevelTestingModPluginId &&
        element.id == 'level_testing_mod_overflow') {
      return element;
    }
  }
  return null;
}

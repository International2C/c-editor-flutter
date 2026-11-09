import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/registration.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/registration.dart';
import 'package:c_editor/data/interface_menu_config.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugins/interface_menu_plugin_actions.dart';
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/screens/interface_settings_screen.dart';
import 'package:c_editor/screens/level_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'level testing entry follows saved workspace placement and its plugin gate',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 1800);
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        'locale': 'zh',
        'theme_mode': 'light',
        'ui_scale': 1.0,
      });
      final preferences = await SharedPreferences.getInstance();
      final settings = SettingsCubit(preferences);
      addTearDown(settings.close);
      final manager = (await tester.runAsync(
        () => PluginManager.init(preferences),
      ))!;
      final l10n = lookupAppLocalizations(const Locale('zh'));
      const id = InterfaceMenuActionIds.levelTestingMod;

      Future<void> pumpPage(Widget page) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: settings,
            child: MaterialApp(
              locale: const Locale('zh'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: page,
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      Widget workspace() => LevelListScreen(
        onLevelClick: (_, _, _, _, _) {},
        onAboutClick: () {},
        onPluginsClick: () {},
        onLanguageTap: (_) {},
      );

      // This action belongs to the level-testing plugin, independently of
      // whether the separate preview-image plugin is enabled.
      await tester.runAsync(
        () => manager.setEnabled(kLevelPreviewPluginId, false),
      );
      expect(workspacePluginMenuElement(id), isNotNull);
      expect(
        settings.state
            .interfaceMenuActionsFor(InterfaceMenuSurface.workspace)
            .singleWhere((action) => action.id == id)
            .placement,
        InterfaceMenuPlacement.overflow,
      );
      await pumpPage(const InterfaceSettingsScreen());
      final tile = find.byKey(const ValueKey('workspace_level_testing_mod'));
      await tester.ensureVisible(
        find.byKey(const ValueKey('interfaceMenuViewport_workspace')),
      );
      await tester.scrollUntilVisible(
        tile,
        250,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('interfaceMenu_workspace')),
          matching: find.byType(Scrollable),
        ),
      );
      expect(
        find.descendant(of: tile, matching: find.text('关卡测试包')),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: tile,
          matching: find.text(l10n.menuPlacementToolbar),
        ),
      );
      await tester.pumpAndSettle();

      final restored = SettingsCubit(preferences);
      addTearDown(restored.close);
      expect(
        restored.state
            .interfaceMenuActionsFor(InterfaceMenuSurface.workspace)
            .singleWhere((action) => action.id == id)
            .placement,
        InterfaceMenuPlacement.toolbar,
      );
      await pumpPage(workspace());
      expect(
        find.byKey(const ValueKey('workspaceToolbarAction_level_testing_mod')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('workspaceOverflowMenu')));
      await tester.pumpAndSettle();
      expect(
        find.text('关卡测试包'),
        findsNothing,
        reason: 'the plugin must not inject a duplicate overflow entry',
      );
      Navigator.of(
        tester.element(find.byKey(const ValueKey('workspaceOverflowMenu'))),
      ).pop();
      await tester.pumpAndSettle();

      settings.setInterfaceMenuActionPlacement(
        InterfaceMenuSurface.workspace,
        id,
        InterfaceMenuPlacement.overflow,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('workspaceToolbarAction_level_testing_mod')),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('workspaceOverflowMenu')));
      await tester.pumpAndSettle();
      expect(find.text('关卡测试包'), findsOneWidget);
      Navigator.of(
        tester.element(find.byKey(const ValueKey('workspaceOverflowMenu'))),
      ).pop();
      await tester.pumpAndSettle();

      await tester.runAsync(
        () => manager.setEnabled(kLevelTestingModPluginId, false),
      );
      await tester.pumpAndSettle();
      expect(workspacePluginMenuElement(id), isNull);
      await tester.tap(find.byKey(const ValueKey('workspaceOverflowMenu')));
      await tester.pumpAndSettle();
      expect(find.text('关卡测试包'), findsNothing);
      Navigator.of(
        tester.element(find.byKey(const ValueKey('workspaceOverflowMenu'))),
      ).pop();
      await tester.pumpAndSettle();
      await pumpPage(const InterfaceSettingsScreen());
      expect(tile, findsNothing);

      await tester.runAsync(
        () => manager.setEnabled(kLevelTestingModPluginId, true),
      );
      await tester.pumpAndSettle();
      expect(workspacePluginMenuElement(id), isNotNull);
      expect(
        settings.state
            .interfaceMenuActionsFor(InterfaceMenuSurface.workspace)
            .singleWhere((action) => action.id == id)
            .placement,
        InterfaceMenuPlacement.overflow,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

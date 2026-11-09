import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/interface_menu_config.dart';
import 'package:c_editor/utils/document_lang.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('document language helper is a no-op off web', () {
    setDocumentLanguage('zh');
    setDocumentLanguage('ru');
  });

  test('setLocale persists the in-app language', () async {
    SharedPreferences.setMockInitialValues({
      'locale': 'en',
      'theme_mode': 'light',
    });
    final prefs = await SharedPreferences.getInstance();
    final cubit = SettingsCubit(prefs);
    addTearDown(cubit.close);

    cubit.setLocale(const Locale('zh'));
    expect(cubit.state.locale.languageCode, 'zh');
    expect(prefs.getString('locale'), 'zh');

    cubit.setLocale(const Locale('ru'));
    expect(cubit.state.locale.languageCode, 'ru');
    expect(prefs.getString('locale'), 'ru');
  });

  test(
    'automatic update checks default on and persist when disabled',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = SettingsCubit(prefs);
      expect(cubit.state.checkForUpdates, isTrue);
      cubit.setCheckForUpdates(false);
      expect(cubit.state.checkForUpdates, isFalse);
      expect(
        prefs.getBool(SettingsCubit.checkForUpdatesPreferenceKey),
        isFalse,
      );
      final restored = SettingsCubit(prefs);
      addTearDown(restored.close);
      await cubit.close();
      expect(restored.state.checkForUpdates, isFalse);
    },
  );

  test('alias prompt on create is disabled by default and persists', () async {
    SharedPreferences.setMockInitialValues({
      'locale': 'en',
      'theme_mode': 'light',
    });
    final prefs = await SharedPreferences.getInstance();
    final cubit = SettingsCubit(prefs);

    expect(cubit.state.promptForAliasOnCreate, isFalse);
    cubit.setPromptForAliasOnCreate(true);
    expect(cubit.state.promptForAliasOnCreate, isTrue);
    expect(
      prefs.getBool(SettingsCubit.promptForAliasOnCreatePreferenceKey),
      isTrue,
    );

    final restored = SettingsCubit(prefs);
    addTearDown(restored.close);
    await cubit.close();
    expect(restored.state.promptForAliasOnCreate, isTrue);
  });

  test(
    'interface action defaults use independent workspace and editor layouts',
    () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = SettingsCubit(await SharedPreferences.getInstance());
      addTearDown(cubit.close);

      final workspace = cubit.state.interfaceMenuActionsFor(
        InterfaceMenuSurface.workspace,
      );
      expect(
        workspace
            .where(
              (action) => action.placement == InterfaceMenuPlacement.toolbar,
            )
            .map((action) => action.id),
        const [
          InterfaceMenuActionIds.sort,
          InterfaceMenuActionIds.refresh,
          InterfaceMenuActionIds.switchFolder,
          InterfaceMenuActionIds.importFiles,
          InterfaceMenuActionIds.importFolder,
          InterfaceMenuActionIds.downloadAll,
        ],
      );
      expect(
        workspace
            .singleWhere(
              (action) => action.id == InterfaceMenuActionIds.autosave,
            )
            .placement,
        InterfaceMenuPlacement.settingsPage,
      );
      for (final surface in const [InterfaceMenuSurface.levelEditor]) {
        final actions = cubit.state.interfaceMenuActionsFor(surface);
        expect(actions.take(3).map((action) => action.id), const [
          InterfaceMenuActionIds.language,
          InterfaceMenuActionIds.theme,
          InterfaceMenuActionIds.uiScale,
        ], reason: surface.name);
        expect(
          actions.take(3).map((action) => action.placement),
          everyElement(InterfaceMenuPlacement.toolbar),
          reason: surface.name,
        );
        expect(
          actions
              .singleWhere(
                (action) => action.id == InterfaceMenuActionIds.autosave,
              )
              .placement,
          InterfaceMenuPlacement.overflow,
          reason: surface.name,
        );
      }

      expect(
        cubit.state
            .interfaceMenuActionsFor(InterfaceMenuSurface.levelEditor)
            .where(
              (action) => action.placement == InterfaceMenuPlacement.toolbar,
            )
            .map((action) => action.id),
        const [
          InterfaceMenuActionIds.language,
          InterfaceMenuActionIds.theme,
          InterfaceMenuActionIds.uiScale,
        ],
      );

      expect(
        cubit.state
            .interfaceMenuActionsFor(InterfaceMenuSurface.jsonViewer)
            .map((action) => (action.id, action.placement)),
        const [
          (
            InterfaceMenuActionIds.toggleJsonView,
            InterfaceMenuPlacement.toolbar,
          ),
          (InterfaceMenuActionIds.copyJson, InterfaceMenuPlacement.toolbar),
          (InterfaceMenuActionIds.clearUnused, InterfaceMenuPlacement.overflow),
          (InterfaceMenuActionIds.editJson, InterfaceMenuPlacement.overflow),
        ],
      );
    },
  );

  test(
    'each interface action surface persists order and placement independently',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = SettingsCubit(prefs);

      final themeIndex = cubit.state
          .interfaceMenuActionsFor(InterfaceMenuSurface.workspace)
          .indexWhere((action) => action.id == InterfaceMenuActionIds.theme);
      cubit.reorderInterfaceMenuAction(
        InterfaceMenuSurface.workspace,
        themeIndex,
        0,
      );
      cubit.setInterfaceMenuActionPlacement(
        InterfaceMenuSurface.workspace,
        InterfaceMenuActionIds.theme,
        InterfaceMenuPlacement.overflow,
      );
      cubit.reorderInterfaceMenuAction(InterfaceMenuSurface.levelEditor, 3, 0);
      cubit.setInterfaceMenuActionPlacement(
        InterfaceMenuSurface.levelEditor,
        InterfaceMenuActionIds.autosave,
        InterfaceMenuPlacement.toolbar,
      );
      cubit.reorderInterfaceMenuAction(InterfaceMenuSurface.jsonViewer, 3, 0);
      cubit.setInterfaceMenuActionPlacement(
        InterfaceMenuSurface.jsonViewer,
        InterfaceMenuActionIds.editJson,
        InterfaceMenuPlacement.toolbar,
      );

      expect(
        prefs
            .getStringList(
              interfaceMenuPreferenceKey(InterfaceMenuSurface.workspace),
            )
            ?.first,
        '${InterfaceMenuActionIds.theme}|overflow',
      );
      expect(
        prefs
            .getStringList(
              interfaceMenuPreferenceKey(InterfaceMenuSurface.levelEditor),
            )
            ?.first,
        '${InterfaceMenuActionIds.autosave}|toolbar',
      );
      expect(
        prefs
            .getStringList(
              interfaceMenuPreferenceKey(InterfaceMenuSurface.jsonViewer),
            )
            ?.first,
        '${InterfaceMenuActionIds.editJson}|toolbar',
      );

      final restored = SettingsCubit(prefs);
      addTearDown(restored.close);
      await cubit.close();

      final workspace = restored.state.interfaceMenuActionsFor(
        InterfaceMenuSurface.workspace,
      );
      final editor = restored.state.interfaceMenuActionsFor(
        InterfaceMenuSurface.levelEditor,
      );
      final json = restored.state.interfaceMenuActionsFor(
        InterfaceMenuSurface.jsonViewer,
      );
      expect(workspace.first.id, InterfaceMenuActionIds.theme);
      expect(workspace.first.placement, InterfaceMenuPlacement.overflow);
      expect(editor.first.id, InterfaceMenuActionIds.autosave);
      expect(editor.first.placement, InterfaceMenuPlacement.toolbar);
      expect(json.first.id, InterfaceMenuActionIds.editJson);
      expect(json.first.placement, InterfaceMenuPlacement.toolbar);

      expect(
        workspace.where(
          (action) => action.id == InterfaceMenuActionIds.editJson,
        ),
        isEmpty,
      );
      expect(
        editor
            .where((action) => action.id == InterfaceMenuActionIds.theme)
            .single
            .placement,
        InterfaceMenuPlacement.toolbar,
      );
      expect(
        json.where((action) => action.id == InterfaceMenuActionIds.autosave),
        isEmpty,
      );
    },
  );

  test(
    'saved interface actions discard unknown and duplicate ids and fill gaps',
    () async {
      SharedPreferences.setMockInitialValues({
        interfaceMenuPreferenceKey(InterfaceMenuSurface.workspace): <String>[
          '${InterfaceMenuActionIds.theme}|overflow',
          'removed_action|toolbar',
          '${InterfaceMenuActionIds.theme}|toolbar',
          '${InterfaceMenuActionIds.uiScale}|unknown_placement',
          'malformed',
          '${InterfaceMenuActionIds.autosave}|settings',
        ],
      });
      final cubit = SettingsCubit(await SharedPreferences.getInstance());
      addTearDown(cubit.close);
      final actions = cubit.state.interfaceMenuActionsFor(
        InterfaceMenuSurface.workspace,
      );

      expect(actions.first.id, InterfaceMenuActionIds.theme);
      expect(actions.first.placement, InterfaceMenuPlacement.overflow);
      expect(
        actions.where((action) => action.id == InterfaceMenuActionIds.theme),
        hasLength(1),
      );
      expect(actions.where((action) => action.id == 'removed_action'), isEmpty);
      expect(
        actions
            .singleWhere(
              (action) => action.id == InterfaceMenuActionIds.uiScale,
            )
            .placement,
        InterfaceMenuPlacement.overflow,
      );
      expect(
        actions
            .singleWhere(
              (action) => action.id == InterfaceMenuActionIds.autosave,
            )
            .placement,
        InterfaceMenuPlacement.overflow,
      );
      expect(
        actions.map((action) => action.id).toSet(),
        defaultInterfaceMenuActions(
          InterfaceMenuSurface.workspace,
        ).map((action) => action.id).toSet(),
      );
    },
  );

  test('settings-page placement is limited to the four global settings', () {
    final workspace =
        decodeInterfaceMenuActions(InterfaceMenuSurface.workspace, const [
          '${InterfaceMenuActionIds.language}|settingsPage',
          '${InterfaceMenuActionIds.sort}|settingsPage',
        ]);

    expect(
      workspace
          .singleWhere((action) => action.id == InterfaceMenuActionIds.language)
          .placement,
      InterfaceMenuPlacement.settingsPage,
    );
    expect(
      workspace
          .singleWhere((action) => action.id == InterfaceMenuActionIds.sort)
          .placement,
      InterfaceMenuPlacement.toolbar,
    );
  });
}

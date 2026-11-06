import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/interface_menu_config.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/interface_settings_screen.dart';
import 'package:c_editor/widgets/app_ui_scale.dart';
import 'package:c_editor/widgets/app_ui_scaler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsCubit settings;
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'locale': 'en',
      'theme_mode': 'light',
      'ui_scale': 1.0,
    });
    preferences = await SharedPreferences.getInstance();
    settings = SettingsCubit(preferences);
  });

  tearDown(() async {
    await settings.close();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    Size size = const Size(1000, 1400),
    Locale locale = const Locale('en'),
    double? appScale,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider.value(
        value: settings,
        child: AppUiScale(
          scale: 1,
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: appScale == null
                ? null
                : (context, child) => AppUiScaler(
                    scale: appScale,
                    applyCompactViewportScale: true,
                    wrapMessenger: false,
                    child: child!,
                  ),
            home: const InterfaceSettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'narrow scaled layouts separate theme labels and module content',
    (tester) async {
      for (final id in interfaceSettingsPageActionIds) {
        settings.setInterfaceMenuActionPlacement(
          InterfaceMenuSurface.workspace,
          id,
          InterfaceMenuPlacement.settingsPage,
        );
      }
      settings.setUiScale(1.5);
      for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await pumpScreen(
          tester,
          size: const Size(320, 1400),
          locale: locale,
          appScale: 1.5,
        );
        final l10n = lookupAppLocalizations(locale);
        final selector = tester.widget<SegmentedButton<ThemeMode>>(
          find.byType(SegmentedButton<ThemeMode>),
        );
        expect(
          selector.segments.every((segment) => segment.label == null),
          isTrue,
        );
        expect(find.text(l10n.currentTheme(l10n.lightTheme)), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const ValueKey('interfaceSettingsThemeSelector')),
        );
        expect(
          tester
              .getSize(
                find.byKey(const ValueKey('interfaceSettingsThemeSelector')),
              )
              .height,
          lessThan(90),
        );
        final preview = find.byKey(
          const ValueKey('interfaceSettingsUiScalePreview'),
        );
        final layout = find.byKey(
          const ValueKey('interfaceSettingsPreviewLayout'),
        );
        await tester.ensureVisible(preview);
        await tester.pumpAndSettle();
        final outerRect = tester.getRect(preview);
        final contentRect = tester.getRect(layout);
        expect(contentRect.left, greaterThanOrEqualTo(outerRect.left));
        expect(contentRect.right, lessThanOrEqualTo(outerRect.right));
        expect(contentRect.bottom, lessThanOrEqualTo(outerRect.bottom));
        expect(
          tester.getSize(find.text('SeedBank')).height,
          lessThan(36),
          reason: 'the alias stays on one line instead of a narrow text column',
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('shows the four settings areas and a live draft scale preview', (
    tester,
  ) async {
    for (final id in interfaceSettingsPageActionIds) {
      settings.setInterfaceMenuActionPlacement(
        InterfaceMenuSurface.workspace,
        id,
        InterfaceMenuPlacement.settingsPage,
      );
    }
    await pumpScreen(tester);
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(l10n.menuCustomization, 'Feature display');
    expect(
      l10n.menuCustomizationDescription,
      contains('When space is limited'),
    );
    expect(find.text(l10n.language), findsWidgets);
    expect(find.text(l10n.toggleTheme), findsWidgets);
    expect(find.text(l10n.uiSize), findsWidgets);
    expect(find.text(l10n.autosave), findsWidgets);
    expect(find.text(l10n.menuCustomization), findsOneWidget);
    expect(find.text(l10n.aliasPromptOnCreate), findsWidgets);
    expect(find.text(l10n.popupPrompts), findsOneWidget);

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
    expect(scrollbar.thumbVisibility, isTrue);
    expect(scrollbar.scrollbarOrientation, ScrollbarOrientation.right);

    await tester.ensureVisible(find.text(l10n.languageChinese));
    await tester.tap(find.text(l10n.languageChinese));
    await tester.pump();
    expect(settings.state.locale, const Locale('zh'));
    expect(preferences.getString('locale'), 'zh');

    await tester.ensureVisible(find.text(l10n.darkTheme));
    await tester.tap(find.text(l10n.darkTheme));
    await tester.pump();
    expect(settings.state.themeMode, ThemeMode.dark);
    expect(preferences.getString('theme_mode'), 'dark');

    final autosave = find.byKey(
      const ValueKey('interfaceSettingsAutosave_level'),
    );
    await tester.ensureVisible(autosave);
    await tester.tap(autosave);
    await tester.pump();
    expect(settings.state.autosaveTargets, contains(AutosaveTarget.level));
    expect(preferences.getBool(AutosaveTarget.level.preferenceKey), isTrue);

    final aliasPrompt = find.byKey(
      const ValueKey('interfaceSettingsAliasPromptOnCreate'),
    );
    await tester.ensureVisible(aliasPrompt);
    await tester.tap(aliasPrompt);
    await tester.pump();
    expect(settings.state.promptForAliasOnCreate, isTrue);
    expect(
      preferences.getBool(SettingsCubit.promptForAliasOnCreatePreferenceKey),
      isTrue,
    );

    final updatePrompt = find.byKey(
      const ValueKey('interfaceSettingsCheckForUpdates'),
    );
    expect(settings.state.checkForUpdates, isTrue);
    await tester.ensureVisible(updatePrompt);
    await tester.tap(updatePrompt);
    await tester.pump();
    expect(settings.state.checkForUpdates, isFalse);

    final slider = find.byKey(const ValueKey('interfaceSettingsUiScaleSlider'));
    await tester.ensureVisible(slider);
    final previewLayout = find.byKey(
      const ValueKey('interfaceSettingsPreviewLayout'),
    );
    final initialPreviewWidth = tester.widget<SizedBox>(previewLayout).width!;
    final gesture = await tester.startGesture(tester.getCenter(slider));
    await gesture.moveBy(const Offset(160, 0));
    await tester.pump();
    final draftPreviewWidth = tester.widget<SizedBox>(previewLayout).width!;
    expect(draftPreviewWidth, lessThan(initialPreviewWidth));
    expect(settings.state.uiScale, 1.0, reason: 'dragging only changes draft');

    await gesture.up();
    await tester.pump();
    expect(settings.state.uiScale, greaterThan(1.0));
    expect(preferences.getDouble('ui_scale'), settings.state.uiScale);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'global setting sections appear only when either app bar keeps them here',
    (tester) async {
      await pumpScreen(tester);

      expect(
        find.byKey(const ValueKey('interfaceSettingsUiScaleSlider')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('interfaceSettingsAutosaveSelectAll')),
        findsOneWidget,
      );

      settings.setInterfaceMenuActionPlacement(
        InterfaceMenuSurface.workspace,
        InterfaceMenuActionIds.uiScale,
        InterfaceMenuPlacement.settingsPage,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('interfaceSettingsUiScaleSlider')),
        findsOneWidget,
      );

      settings.setInterfaceMenuActionPlacement(
        InterfaceMenuSurface.levelEditor,
        InterfaceMenuActionIds.uiScale,
        InterfaceMenuPlacement.settingsPage,
      );
      settings.setInterfaceMenuActionPlacement(
        InterfaceMenuSurface.workspace,
        InterfaceMenuActionIds.uiScale,
        InterfaceMenuPlacement.toolbar,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('interfaceSettingsUiScaleSlider')),
        findsOneWidget,
      );

      settings.setInterfaceMenuActionPlacement(
        InterfaceMenuSurface.levelEditor,
        InterfaceMenuActionIds.uiScale,
        InterfaceMenuPlacement.overflow,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('interfaceSettingsUiScaleSlider')),
        findsNothing,
      );
    },
  );

  testWidgets('menu action can be moved directly to the end of the list', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(700, 700));
    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.ensureVisible(find.text(l10n.menuCustomization));
    await tester.pumpAndSettle();

    final viewport = find.byKey(
      const ValueKey('interfaceMenuViewport_workspace'),
    );
    final listFinder = find.byKey(const ValueKey('interfaceMenu_workspace'));
    expect(viewport, findsOneWidget);
    expect(tester.getSize(viewport).height, lessThanOrEqualTo(455));

    final list = tester.widget<ReorderableListView>(listFinder);
    expect(list.physics, isA<ClampingScrollPhysics>());
    final firstId = settings.state
        .interfaceMenuActionsFor(InterfaceMenuSurface.workspace)
        .first
        .id;

    list.onReorderItem!(0, list.itemCount - 1);
    await tester.pumpAndSettle();

    expect(
      settings.state
          .interfaceMenuActionsFor(InterfaceMenuSurface.workspace)
          .last
          .id,
      firstId,
    );
  });

  testWidgets('customizes all three top-right action surfaces independently', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l10n = lookupAppLocalizations(const Locale('en'));
    final customization = find.text(l10n.menuCustomization);
    await tester.ensureVisible(customization);
    await tester.pumpAndSettle();

    expect(find.text(l10n.menuSurfaceWorkspace), findsOneWidget);
    expect(find.text(l10n.menuSurfaceLevelEditor), findsOneWidget);
    expect(find.text(l10n.menuSurfaceJsonViewer), findsOneWidget);
    expect(
      find.byKey(const ValueKey('interfaceMenu_workspace')),
      findsOneWidget,
    );

    final sortPlacement = find.descendant(
      of: find.byKey(const ValueKey('workspace_sort')),
      matching: find.byKey(const ValueKey('interfaceMenuPlacementControl')),
    );
    final languagePlacement = find.descendant(
      of: find.byKey(const ValueKey('workspace_lang')),
      matching: find.byKey(const ValueKey('interfaceMenuPlacementControl')),
    );
    expect(
      tester.getRect(sortPlacement).right,
      closeTo(tester.getRect(languagePlacement).right, 0.1),
    );
    expect(
      tester.getSize(sortPlacement).width,
      tester.getSize(languagePlacement).width,
      reason: 'wide two- and three-option controls share the same right column',
    );

    final workspaceList = tester.widget<ReorderableListView>(
      find.byKey(const ValueKey('interfaceMenu_workspace')),
    );
    workspaceList.onReorderItem!(0, 1);
    await tester.pump();
    expect(
      settings.state
          .interfaceMenuActionsFor(InterfaceMenuSurface.workspace)
          .first
          .id,
      InterfaceMenuActionIds.refresh,
    );

    final workspaceLanguage = find.byKey(const ValueKey('workspace_lang'));
    await tester.ensureVisible(workspaceLanguage);
    await tester.tap(
      find.descendant(
        of: workspaceLanguage,
        matching: find.byType(DropdownButton<InterfaceMenuPlacement>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.menuPlacementOverflow).last);
    await tester.pumpAndSettle();
    expect(
      settings.state
          .interfaceMenuActionsFor(InterfaceMenuSurface.workspace)
          .singleWhere((action) => action.id == InterfaceMenuActionIds.language)
          .placement,
      InterfaceMenuPlacement.overflow,
    );

    await tester.ensureVisible(find.text(l10n.menuSurfaceLevelEditor));
    await tester.tap(find.text(l10n.menuSurfaceLevelEditor));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('interfaceMenu_levelEditor')),
      findsOneWidget,
    );
    expect(
      settings.state
          .interfaceMenuActionsFor(InterfaceMenuSurface.levelEditor)
          .singleWhere((action) => action.id == InterfaceMenuActionIds.language)
          .placement,
      InterfaceMenuPlacement.toolbar,
      reason: 'the workspace placement must not leak into the editor',
    );
    final editorAutosave = find.byKey(const ValueKey('levelEditor_autosave'));
    await tester.ensureVisible(editorAutosave);
    await tester.tap(
      find.descendant(
        of: editorAutosave,
        matching: find.byType(DropdownButton<InterfaceMenuPlacement>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.menuPlacementToolbar).last);
    await tester.pumpAndSettle();
    expect(
      settings.state
          .interfaceMenuActionsFor(InterfaceMenuSurface.levelEditor)
          .singleWhere((action) => action.id == InterfaceMenuActionIds.autosave)
          .placement,
      InterfaceMenuPlacement.toolbar,
    );

    await tester.ensureVisible(find.text(l10n.menuSurfaceJsonViewer));
    await tester.tap(find.text(l10n.menuSurfaceJsonViewer));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('interfaceMenu_jsonViewer')),
      findsOneWidget,
    );
    final jsonEdit = find.byKey(const ValueKey('jsonViewer_edit'));
    await tester.ensureVisible(jsonEdit);
    await tester.tap(
      find.descendant(
        of: jsonEdit,
        matching: find.text(l10n.menuPlacementToolbar),
      ),
    );
    await tester.pump();
    expect(
      settings.state
          .interfaceMenuActionsFor(InterfaceMenuSurface.jsonViewer)
          .singleWhere((action) => action.id == InterfaceMenuActionIds.editJson)
          .placement,
      InterfaceMenuPlacement.toolbar,
    );

    expect(
      settings.state
          .interfaceMenuActionsFor(InterfaceMenuSurface.workspace)
          .singleWhere((action) => action.id == InterfaceMenuActionIds.autosave)
          .placement,
      InterfaceMenuPlacement.settingsPage,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('restores scroll offset in memory without persisting it', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(800, 640));
    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView).first,
    );
    final controller = scrollView.controller!;
    controller.jumpTo(0);
    await tester.pump();
    controller.jumpTo(500);
    await tester.pump();
    final rememberedOffset = controller.offset;
    expect(rememberedOffset, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(
      preferences.getKeys().where((key) => key.contains('scroll')),
      isEmpty,
    );

    await pumpScreen(tester, size: const Size(800, 640));
    final restored = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView).first,
    );
    expect(restored.controller!.offset, closeTo(rememberedOffset, 0.1));
    expect(tester.takeException(), isNull);
  });
}

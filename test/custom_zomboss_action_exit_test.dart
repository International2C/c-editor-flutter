import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/others/custom_portal_properties_screen.dart';
import 'package:c_editor/screens/editor/others/custom_resilience_shield_editor_screen.dart';
import 'package:c_editor/screens/editor/others/custom_zomboss_mech_action_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _catalog = ZombossMechCatalogEntry(
  id: 'ExitPromptMech',
  icon: 'unknown.webp',
  defaultPhaseCount: 1,
  variations: [],
  editableInstance: 'exit_prompt_mech',
  editableInstancePropsName: 'ExitPromptProps',
  actions: [
    ZombossMechObjclassGroup(
      objclass: 'ExitPromptActionDefinition',
      tag: 'attack',
      fields: [],
      implementations: {
        'ExitPromptAction': {'Weight': 10},
      },
    ),
  ],
  properties: [],
);

void main() {
  testWidgets(
    'custom autosave retains invalid edits and an unrelated setting does not bypass confirmation',
    (tester) async {
      SharedPreferences.setMockInitialValues({'autosave': true});
      final settings = SettingsCubit(await SharedPreferences.getInstance());
      addTearDown(settings.close);
      final level = PvzLevelFile(objects: []);
      await tester.pumpWidget(
        BlocProvider.value(
          value: settings,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CustomResilienceShieldEditorScreen(levelFile: level),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsOneWidget);
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();
      settings.setAutosaveTargets({AutosaveTarget.resilienceShield});
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(CustomResilienceShieldEditorScreen), findsOneWidget);
      expect(level.objects, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(find.byType(TextFormField).first, 'ValidShield');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(CustomResilienceShieldEditorScreen), findsNothing);
      expect(level.objects, isNotEmpty);
      AppMessage.hide();
      expect(tester.takeException(), isNull);
    },
  );

  tearDown(AppMessage.hide);
  for (final target in [
    AutosaveTarget.zombossAction,
    AutosaveTarget.portal,
    AutosaveTarget.resilienceShield,
  ]) {
    testWidgets(
      '${target.name}: back saves and returns the edited object without prompting',
      (tester) async {
        SharedPreferences.setMockInitialValues({target.preferenceKey: true});
        final cubit = SettingsCubit(await SharedPreferences.getInstance());
        addTearDown(cubit.close);
        final level = PvzLevelFile(objects: []);
        final messages = <String>[];
        void recordMessage() {
          final message = AppMessage.controller.message;
          if (message != null) messages.add(message);
        }

        AppMessage.controller.addListener(recordMessage);
        addTearDown(() => AppMessage.controller.removeListener(recordMessage));
        String? returned;
        final screen = switch (target) {
          AutosaveTarget.zombossAction => CustomZombossMechActionEditorScreen(
            catalog: _catalog,
            levelFile: level,
          ),
          AutosaveTarget.portal => CustomPortalPropertiesScreen(
            levelFile: level,
            basePortalType: 'egypt',
          ),
          _ => CustomResilienceShieldEditorScreen(levelFile: level),
        };
        await tester.pumpWidget(
          BlocProvider.value(
            value: cubit,
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      returned = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(builder: (_) => screen),
                      );
                    },
                    child: const Text('Open editor'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open editor'));
        await tester.pumpAndSettle();
        if (target == AutosaveTarget.zombossAction) {
          await tester.enterText(
            find.byType(TextFormField).first,
            'AutoSavedAction',
          );
        }
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Open editor'), findsOneWidget);
        expect(level.objects, isNotEmpty);
        expect(returned, isNotEmpty);
        expect(messages, contains('Automatically saved'));
        expect(tester.takeException(), isNull);
        AppMessage.hide();
      },
    );
  }

  testWidgets('top-left exit closes an untouched new custom action', (
    tester,
  ) async {
    final level = PvzLevelFile(objects: []);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => CustomZombossMechActionEditorScreen(
                  catalog: _catalog,
                  levelFile: level,
                ),
              ),
            ),
            child: const Text('Open editor'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    final actionSaveIcon = tester.widget<Icon>(find.byIcon(Icons.save));
    expect(
      actionSaveIcon.color,
      tester.widget<AppBar>(find.byType(AppBar)).foregroundColor,
    );
    expect(find.byTooltip('Save'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved changes'), findsNothing);
    expect(find.text('Open editor'), findsOneWidget);
    expect(level.objects, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('top-left exit still prompts after editing a custom action', (
    tester,
  ) async {
    final level = PvzLevelFile(objects: []);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => CustomZombossMechActionEditorScreen(
                  catalog: _catalog,
                  levelFile: level,
                ),
              ),
            ),
            child: const Text('Open editor'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'EditedAction');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(find.text('Save before leaving?'), findsOneWidget);
    final dialog = find.byType(AlertDialog);
    await tester.tap(
      find.descendant(of: dialog, matching: find.text('Discard')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open editor'), findsOneWidget);
    expect(level.objects, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('top-left exit closes an untouched existing custom action', (
    tester,
  ) async {
    final action = PvzObject(
      aliases: const ['ExistingAction'],
      objClass: 'ExitPromptActionDefinition',
      objData: const <String, dynamic>{'Weight': 10},
    );
    final level = PvzLevelFile(objects: [action]);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => CustomZombossMechActionEditorScreen(
                  catalog: _catalog,
                  levelFile: level,
                  existingRtid: 'RTID(ExistingAction@CurrentLevel)',
                ),
              ),
            ),
            child: const Text('Open existing editor'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open existing editor'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved changes'), findsNothing);
    expect(find.text('Open existing editor'), findsOneWidget);
    expect(level.objects, hasLength(1));
    expect(level.objects.single.objData, const <String, dynamic>{'Weight': 10});
    expect(tester.takeException(), isNull);
  });

  testWidgets('top-left exit can save the custom portal', (tester) async {
    final level = PvzLevelFile(objects: []);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push<String?>(
              context,
              MaterialPageRoute(
                builder: (_) => CustomPortalPropertiesScreen(
                  levelFile: level,
                  basePortalType: 'egypt',
                ),
              ),
            ),
            child: const Text('Open portal editor'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open portal editor'));
    await tester.pumpAndSettle();
    final portalSaveIcon = tester.widget<Icon>(find.byIcon(Icons.save));
    expect(
      portalSaveIcon.color,
      Theme.of(tester.element(find.byIcon(Icons.save))).colorScheme.primary,
    );
    expect(find.byTooltip('Save'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(find.text('Save before leaving?'), findsOneWidget);
    final dialog = find.byType(AlertDialog);
    await tester.tap(find.descendant(of: dialog, matching: find.text('Save')));
    await tester.pumpAndSettle();

    expect(find.text('Open portal editor'), findsOneWidget);
    expect(
      level.objects.where(
        (object) => object.objClass == 'GridItemZombiePortalProps',
      ),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom shield exit asks whether to save changes', (
    tester,
  ) async {
    final level = PvzLevelFile(objects: []);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CustomResilienceShieldEditorScreen(levelFile: level),
              ),
            ),
            child: const Text('Open shield editor'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open shield editor'));
    await tester.pumpAndSettle();

    final saveFinder = find.byIcon(Icons.save);
    final saveIcon = tester.widget<Icon>(saveFinder);
    expect(
      saveIcon.color,
      Theme.of(tester.element(saveFinder)).colorScheme.primary,
    );
    expect(find.byTooltip('Save'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(find.text('Save before leaving?'), findsOneWidget);
    final dialog = find.byType(AlertDialog);
    await tester.tap(
      find.descendant(of: dialog, matching: find.text('Discard')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open shield editor'), findsOneWidget);
    expect(level.objects, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

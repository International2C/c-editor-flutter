import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/autosave_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migrates the level setting without enabling other autosaves', () async {
    SharedPreferences.setMockInitialValues({'autosave': true});
    final prefs = await SharedPreferences.getInstance();
    final cubit = SettingsCubit(prefs);
    addTearDown(cubit.close);
    expect(cubit.state.autosaveTargets, {AutosaveTarget.level});
    final targets = {AutosaveTarget.previewImage, AutosaveTarget.portal};
    cubit.setAutosaveTargets(targets);
    targets.clear();
    expect(cubit.state.autosave, isFalse);
    expect(cubit.state.hasAutosave, isTrue);
    final restored = SettingsCubit(prefs);
    addTearDown(restored.close);
    expect(restored.state.autosaveTargets, {
      AutosaveTarget.previewImage,
      AutosaveTarget.portal,
    });
    cubit.setAutosave(true);
    expect(cubit.state.autosaveTargets, {
      AutosaveTarget.level,
      AutosaveTarget.previewImage,
      AutosaveTarget.portal,
    });
  });

  for (final language in ['zh', 'en', 'ru']) {
    testWidgets(
      '$language: selection applies only on confirm and scrolls on small screens',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({'autosave': true});
        final cubit = SettingsCubit(await SharedPreferences.getInstance());
        addTearDown(cubit.close);
        final l10n = lookupAppLocalizations(Locale(language));
        await tester.pumpWidget(
          BlocProvider.value(
            value: cubit,
            child: MaterialApp(
              locale: Locale(language),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.5)),
                child: child!,
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => showAutosaveSettingsDialog(context),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );
        final all = find.byKey(const ValueKey('autosaveSelectAll'));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.widget<CheckboxListTile>(all).value, isNull);
        await tester.tap(all);
        await tester.pump();
        await tester.tap(find.widgetWithText(TextButton, l10n.autosaveExit));
        await tester.pumpAndSettle();
        expect(cubit.state.autosaveTargets, {AutosaveTarget.level});

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(all);
        await tester.pump();
        final preview = find.byKey(const ValueKey('autosave_previewImage'));
        await tester.ensureVisible(preview);
        await tester.tap(preview);
        await tester.pump();
        await tester.tap(find.widgetWithText(FilledButton, l10n.confirm));
        await tester.pumpAndSettle();
        expect(
          cubit.state.autosaveTargets,
          AutosaveTarget.values
              .where((t) => t != AutosaveTarget.previewImage)
              .toSet(),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(all);
        await tester.pump();
        expect(tester.widget<CheckboxListTile>(all).value, isTrue);
        await tester.tap(all);
        await tester.pump();
        await tester.tap(find.widgetWithText(FilledButton, l10n.confirm));
        await tester.pumpAndSettle();
        expect(cubit.state.autosaveTargets, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

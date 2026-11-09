import 'dart:convert';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/json_viewer_screen.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(AppMessage.hide);

  Future<AppLocalizations> openEditor(
    WidgetTester tester,
    PvzLevelFile level, {
    required Future<void> Function(String, PvzLevelFile) save,
    bool autosave = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autosave', autosave);
    final settings = SettingsCubit(prefs);
    addTearDown(settings.close);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: settings,
          child: JsonViewerScreen(
            fileName: 'test.json',
            filePath: 'test.json',
            levelFile: level,
            onBack: () {},
            saveLevel: save,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(JsonViewerScreen)),
    )!;
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.tooltipEdit));
    await tester.pumpAndSettle();
    return l10n;
  }

  Finder editorText() => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.maxLines == null,
  );

  testWidgets('JSON exit respects level autosave and keeps failed edits', (
    tester,
  ) async {
    var fail = true;
    var saves = 0;
    await openEditor(
      tester,
      PvzLevelFile(objects: []),
      autosave: true,
      save: (_, _) async {
        saves++;
        if (fail) throw StateError('disk full');
      },
    );
    const invalidText = '{ unfinished';
    await tester.enterText(editorText(), invalidText);
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(
      tester.widget<TextField>(editorText()).controller!.text,
      invalidText,
    );
    const validText = '{"version":2,"objects":[]}';
    await tester.enterText(editorText(), validText);
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(saves, 1);
    expect(tester.widget<TextField>(editorText()).controller!.text, validText);
    expect(find.byKey(const ValueKey('jsonDiscardEditsDialog')), findsNothing);
    fail = false;
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(saves, 2);
    expect(editorText(), findsNothing);
  });

  testWidgets(
    'canceling JSON edits requires confirmation and preserves text on Stay',
    (tester) async {
      final l10n = await openEditor(
        tester,
        PvzLevelFile(objects: []),
        save: (_, _) async {},
      );
      const text = '{ invalid unfinished JSON';
      await tester.enterText(editorText(), text);
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('jsonDiscardEditsDialog')),
        findsOneWidget,
      );
      await tester.tap(find.text(l10n.stayInEditor));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(editorText()).controller!.text, text);
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.discard));
      await tester.pumpAndSettle();
      expect(editorText(), findsNothing);
    },
  );

  testWidgets('JSON syntax errors show a localized position and keep edits', (
    tester,
  ) async {
    var saves = 0;
    final level = PvzLevelFile(objects: []);
    final l10n = await openEditor(tester, level, save: (_, _) async => saves++);
    const text = '{\n "objects": [}\n}';
    await tester.enterText(editorText(), text);
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(saves, 0);
    expect(find.text(l10n.jsonEditSyntaxErrorAt('2', '14')), findsOneWidget);
    expect(tester.widget<TextField>(editorText()).controller!.text, text);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a JSON root without objects cannot silently erase the level', (
    tester,
  ) async {
    var saves = 0;
    final original = PvzObject(objClass: 'TestClass', objData: {});
    final level = PvzLevelFile(objects: [original]);
    final l10n = await openEditor(tester, level, save: (_, _) async => saves++);
    await tester.enterText(editorText(), '{}');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(saves, 0);
    expect(level.objects.single, same(original));
    expect(find.text(l10n.jsonEditStructureError), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed JSON write preserves the level and can be retried', (
    tester,
  ) async {
    var failWrite = true;
    var saves = 0;
    var saved = false;
    final original = PvzObject(
      objClass: 'TestClass',
      objData: {'Value': 'old'},
    );
    final level = PvzLevelFile(objects: [original]);
    final l10n = await openEditor(
      tester,
      level,
      save: (_, value) async {
        saves++;
        expect(value.version, 4);
        expect(value.objects.single.objData['Value'], 'new');
        if (failWrite) throw StateError('untranslated private diagnostics');
        saved = true;
      },
    );
    final text = jsonEncode({
      'version': 4,
      'objects': [
        {
          'objclass': 'TestClass',
          'objdata': {'Value': 'new'},
        },
      ],
    });
    await tester.enterText(editorText(), text);
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(saved, isFalse);
    expect(level.version, 1);
    expect(level.objects.single, same(original));
    expect(tester.widget<TextField>(editorText()).controller!.text, text);
    expect(find.text(l10n.jsonEditSaveError), findsOneWidget);
    expect(find.textContaining('private diagnostics'), findsNothing);

    failWrite = false;
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    expect(saved, isTrue);
    expect(saves, 2);
    expect(level.version, 4);
    expect(level.objects.single.objData['Value'], 'new');
    expect(find.byIcon(Icons.save), findsNothing);
    expect(tester.takeException(), isNull);
    AppMessage.hide();
  });
}

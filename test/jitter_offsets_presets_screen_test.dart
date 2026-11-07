import 'package:c_editor/data/jitter_offsets_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/others/jitter_offsets_presets_screen.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildScreen(PvzLevelFile level, {VoidCallback? onChanged}) {
    return MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: JitterOffsetsPresetsScreen(
        levelFile: level,
        onChanged: onChanged ?? () {},
        onBack: () {},
      ),
    );
  }

  test('preset validity only requires a positive random offset bound', () {
    expect(
      JitterOffsetsUtils.isDataValid(
        ZombieJitterOffsetsData(offsetIncrement: 0, randomJitter: 1),
      ),
      isTrue,
    );
    expect(
      JitterOffsetsUtils.isDataValid(
        ZombieJitterOffsetsData(offsetIncrement: -1, randomJitter: 1),
      ),
      isTrue,
    );
    expect(
      JitterOffsetsUtils.isDataValid(
        ZombieJitterOffsetsData(offsetIncrement: 0, randomJitter: 0),
      ),
      isFalse,
    );
    expect(
      JitterOffsetsUtils.isDataValid(
        ZombieJitterOffsetsData(offsetIncrement: 0, randomJitter: -1),
      ),
      isFalse,
    );
  });

  testWidgets('creates unique presets with defaults and edits both values', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['Offsets'],
          objClass: 'SomeOtherObject',
          objData: <String, dynamic>{},
        ),
      ],
    );
    var changed = 0;

    await tester.pumpWidget(buildScreen(level, onChanged: () => changed++));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Offset'));
    await tester.pumpAndSettle();

    final presets = JitterOffsetsUtils.listPresets(level);
    expect(presets, hasLength(1));
    expect(presets.single.aliases, ['Offsets1']);
    expect(
      presets.single.objData,
      containsPair('ZombieSpawningOffsetIncrement', 80),
    );
    expect(
      presets.single.objData,
      containsPair('ZombieSpawningRandomJitter', 30),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '24');
    await tester.enterText(find.byType(TextFormField).at(1), '3');
    await tester.pump();

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final pageTheme = Theme.of(tester.element(find.byType(AppBar)));
    expect(appBar.backgroundColor, pageTheme.colorScheme.secondary);
    for (var index = 0; index < 2; index++) {
      final decorator = tester.widget<InputDecorator>(
        find.descendant(
          of: find.byType(TextFormField).at(index),
          matching: find.byType(InputDecorator),
        ),
      );
      expect(
        decorator.decoration.floatingLabelStyle?.color,
        pageTheme.colorScheme.onSurface,
      );
    }

    expect(
      presets.single.objData,
      containsPair('ZombieSpawningOffsetIncrement', 24),
    );
    expect(
      presets.single.objData,
      containsPair('ZombieSpawningRandomJitter', 3),
    );
    expect(changed, greaterThanOrEqualTo(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('wave timeline entry follows themed hint colors and typography', (
    tester,
  ) async {
    final level = PvzLevelFile(objects: []);

    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: WaveTimelineTab(
              levelFile: level,
              parsed: ParsedLevelData(
                waveManager: WaveManagerData(waveCount: 0, waves: []),
                objectMap: const {},
              ),
              onChanged: () {},
              onEditEvent: (_, _) async {},
              onAddEvent: (_) {},
              onEditWaveManagerSettings: () {},
              onEditJitterOffsets: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final title = find.text('Spawn Position Offset Presets');
      final card = find.ancestor(of: title, matching: find.byType(Card)).first;
      final theme = Theme.of(tester.element(title));
      final onCard = brightness == Brightness.dark
          ? Colors.white
          : Colors.black87;
      expect(
        tester.widget<Card>(card).color,
        brightness == Brightness.dark
            ? theme.colorScheme.secondary
            : Colors.blue.shade100,
      );
      expect(tester.widget<Text>(title).style?.color, onCard);
      expect(
        tester.widget<Text>(title).style?.fontSize,
        theme.textTheme.bodyMedium?.fontSize,
      );
      expect(tester.widget<Icon>(find.byIcon(Icons.speed)).color, onCard);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('renames references with the keyboard open and blocks deletion', (
    tester,
  ) async {
    final preset = PvzObject(
      aliases: ['Offsets'],
      objClass: JitterOffsetsUtils.objectClass,
      objData: ZombieJitterOffsetsData().toJson(),
    );
    final event = PvzObject(
      aliases: ['Wave1Event1'],
      objClass: 'SpawnZombiesJitteredWaveActionProps',
      objData: <String, dynamic>{'JitterOffsets': 'RTID(Offsets@CurrentLevel)'},
    );
    final level = PvzLevelFile(objects: [preset, event]);

    await tester.pumpWidget(buildScreen(level));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
    await tester.pumpAndSettle();
    final dialog = find.byType(AlertDialog);
    final field = find.descendant(
      of: dialog,
      matching: find.byType(TextFormField),
    );
    final confirm = find.widgetWithText(FilledButton, 'Confirm');
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 500);
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(field);
    await tester.enterText(field, '');
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(preset.aliases?.first, 'Offsets');
    final validation = find.text('Alias cannot be empty');
    await tester.ensureVisible(validation);
    await tester.pumpAndSettle();
    expect(validation.hitTestable(), findsOneWidget);
    expect(
      tester.getBottomRight(validation).dy,
      lessThanOrEqualTo(tester.getTopLeft(confirm).dy),
    );
    expect(tester.getBottomRight(confirm).dy, lessThanOrEqualTo(280));
    await tester.enterText(field, 'FastOffsets');
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    tester.view.reset();
    await tester.pumpAndSettle();

    expect(preset.aliases?.first, 'FastOffsets');
    expect(
      (event.objData as Map)['JitterOffsets'],
      'RTID(FastOffsets@CurrentLevel)',
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Cannot Delete'), findsOneWidget);
    expect(find.textContaining('Wave1Event1'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(level.objects, contains(preset));
  });

  testWidgets('referencing event names are underlined navigation links', (
    tester,
  ) async {
    final preset = PvzObject(
      aliases: ['Offsets'],
      objClass: JitterOffsetsUtils.objectClass,
      objData: ZombieJitterOffsetsData().toJson(),
    );
    final event = PvzObject(
      aliases: ['Wave1Event1'],
      objClass: 'SpawnZombiesJitteredWaveActionProps',
      objData: <String, dynamic>{'JitterOffsets': 'RTID(Offsets@CurrentLevel)'},
    );
    final level = PvzLevelFile(objects: [preset, event]);
    String? selectedEventRtid;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  selectedEventRtid = await Navigator.push<String>(
                    context,
                    MaterialPageRoute<String>(
                      builder: (screenContext) => JitterOffsetsPresetsScreen(
                        levelFile: level,
                        onChanged: () {},
                        onBack: () => Navigator.pop(screenContext),
                      ),
                    ),
                  );
                },
                child: const Text('Open presets'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open presets'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    final eventLink = find.text('Wave1Event1');
    expect(eventLink, findsOneWidget);
    expect(
      tester.widget<Text>(eventLink).style?.decoration,
      TextDecoration.underline,
    );

    await tester.tap(eventLink);
    await tester.pumpAndSettle();
    expect(selectedEventRtid, 'RTID(Wave1Event1@CurrentLevel)');
    expect(find.text('Spawn Position Offset Presets'), findsNothing);
    expect(find.text('Open presets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejects spaces and Chinese characters in preset aliases', (
    tester,
  ) async {
    final preset = PvzObject(
      aliases: ['Offsets'],
      objClass: JitterOffsetsUtils.objectClass,
      objData: ZombieJitterOffsetsData().toJson(),
    );
    final level = PvzLevelFile(objects: [preset]);

    await tester.pumpWidget(buildScreen(level));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
    await tester.pumpAndSettle();

    expect(
      find.text('Alias (English letters only; no spaces)'),
      findsOneWidget,
    );
    final aliasField = find.byType(TextFormField).last;
    await tester.enterText(aliasField, 'Fast Offsets');
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    expect(find.text('Alias cannot contain spaces'), findsOneWidget);
    expect(preset.aliases?.first, 'Offsets');

    await tester.enterText(aliasField, ' FastOffsets');
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    expect(find.text('Alias cannot contain spaces'), findsOneWidget);
    expect(preset.aliases?.first, 'Offsets');

    await tester.enterText(aliasField, 'Fast　Offsets');
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    expect(find.text('Alias cannot contain spaces'), findsOneWidget);
    expect(preset.aliases?.first, 'Offsets');

    await tester.enterText(aliasField, '偏移预设');
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    expect(
      find.text('Alias cannot contain Chinese characters'),
      findsOneWidget,
    );
    expect(preset.aliases?.first, 'Offsets');

    await tester.enterText(
      aliasField,
      'Offsets${String.fromCharCode(0x20000)}',
    );
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    expect(
      find.text('Alias cannot contain Chinese characters'),
      findsOneWidget,
    );
    expect(preset.aliases?.first, 'Offsets');

    await tester.enterText(aliasField, 'Offsets_2');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(preset.aliases?.first, 'Offsets_2');
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accepts negative increments but rejects non-positive bounds', (
    tester,
  ) async {
    final preset = PvzObject(
      aliases: ['Offsets'],
      objClass: JitterOffsetsUtils.objectClass,
      objData: ZombieJitterOffsetsData().toJson(),
    );
    final level = PvzLevelFile(objects: [preset]);

    await tester.pumpWidget(buildScreen(level));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '-1');
    await tester.pump();
    expect(preset.objData, containsPair('ZombieSpawningOffsetIncrement', -1));
    expect(
      find.text(
        'A non-negative integer is recommended. Negative values may be converted into abnormally large offsets and prevent normal entry onto the lawn.',
      ),
      findsOneWidget,
    );

    await tester.enterText(fields.at(1), '0');
    await tester.pump();
    expect(preset.objData, containsPair('ZombieSpawningRandomJitter', 30));
    final jitterInputDecorator = find.descendant(
      of: fields.at(1),
      matching: find.byType(InputDecorator),
    );
    expect(
      tester
          .widget<InputDecorator>(jitterInputDecorator)
          .decoration
          .errorMaxLines,
      8,
    );
    expect(
      find.text(
        'Enter a positive integer. Zero or a negative value does not disable the random offset and may produce an abnormally large horizontal position, preventing zombies from entering the lawn normally.',
      ),
      findsOneWidget,
    );

    await tester.enterText(fields.at(1), '-3');
    await tester.pump();
    expect(preset.objData, containsPair('ZombieSpawningRandomJitter', 30));
    expect(
      find.text(
        'Enter a positive integer. Zero or a negative value does not disable the random offset and may produce an abnormally large horizontal position, preventing zombies from entering the lawn normally.',
      ),
      findsOneWidget,
    );

    await tester.enterText(fields.at(0), '0');
    await tester.enterText(fields.at(1), '3');
    await tester.pump();
    expect(preset.objData, containsPair('ZombieSpawningOffsetIncrement', 0));
    expect(preset.objData, containsPair('ZombieSpawningRandomJitter', 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows warnings for imported invalid preset values', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['UnsafeOffsets'],
          objClass: JitterOffsetsUtils.objectClass,
          objData: <String, dynamic>{
            'ZombieSpawningOffsetIncrement': 80,
            'ZombieSpawningRandomJitter': -3,
          },
        ),
      ],
    );

    await tester.pumpWidget(buildScreen(level));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Enter a positive integer. Zero or a negative value does not disable the random offset and may produce an abnormally large horizontal position, preventing zombies from entering the lawn normally.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('deletes an unreferenced preset after confirmation', (
    tester,
  ) async {
    final preset = PvzObject(
      aliases: ['Offsets'],
      objClass: JitterOffsetsUtils.objectClass,
      objData: ZombieJitterOffsetsData().toJson(),
    );
    final level = PvzLevelFile(objects: [preset]);

    await tester.pumpWidget(buildScreen(level));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete Preset?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(JitterOffsetsUtils.listPresets(level), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('help includes preset guidance and fixed-offset explanation', (
    tester,
  ) async {
    final level = PvzLevelFile(objects: []);

    await tester.pumpWidget(buildScreen(level));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    Finder dialogTextContaining(String text) =>
        find.descendant(of: dialog, matching: find.textContaining(text));
    final sectionTitles = tester
        .widgetList<Text>(
          find.descendant(of: dialog, matching: find.byType(Text)),
        )
        .map((text) => text.data)
        .whereType<String>()
        .where((text) => text.startsWith('• '))
        .toList();
    expect(sectionTitles, [
      '• Overview',
      '• Instructions',
      '• Parameters',
      '• Batch-index fixed offset',
    ]);
    expect(dialogTextContaining('default parameters'), findsOneWidget);
    expect(
      dialogTextContaining(
        'They apply to the zombie lists in Basic Spawner and Underwater Spawner',
      ),
      findsOneWidget,
    );
    expect(dialogTextContaining('natural spawn'), findsNothing);
    expect(dialogTextContaining('A preset can be shared'), findsOneWidget);
    expect(
      dialogTextContaining(
        'The actual value ranges from 0 through the entered value minus 1',
      ),
      findsOneWidget,
    );
    expect(
      dialogTextContaining(
        'Facing left, usually entering from the right side of the lawn',
      ),
      findsOneWidget,
    );
    expect(
      dialogTextContaining('moves the spawn position right'),
      findsOneWidget,
    );
    expect(
      dialogTextContaining('Facing right, usually entering from the left side'),
      findsOneWidget,
    );
    expect(dialogTextContaining('moves it left'), findsOneWidget);
    expect(
      dialogTextContaining('not the vertical distance between rows'),
      findsOneWidget,
    );
    expect(
      dialogTextContaining('without affecting sea creatures'),
      findsOneWidget,
    );
    expect(dialogTextContaining('0–9, 20–29, and 40–49'), findsOneWidget);
    expect(dialogTextContaining('Direction'), findsNothing);
    expect(dialogTextContaining('ZombieSpawnPattern'), findsNothing);
    expect(dialogTextContaining('FixedOffset'), findsNothing);
    expect(dialogTextContaining('RowStartOffset'), findsNothing);
    expect(dialogTextContaining('RowBetweenOffset'), findsNothing);
    expect(dialogTextContaining('BaseX'), findsNothing);
    expect(dialogTextContaining('×'), findsNothing);
    expect(
      dialogTextContaining('8.5, and 17 from their own base positions'),
      findsOneWidget,
    );
    expect(dialogTextContaining('global index in the event'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remains usable on a narrow screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['Offsets'],
          objClass: JitterOffsetsUtils.objectClass,
          objData: ZombieJitterOffsetsData().toJson(),
        ),
      ],
    );
    await tester.pumpWidget(buildScreen(level));
    await tester.pumpAndSettle();

    expect(find.text('Offsets'), findsOneWidget);
    expect(find.text('Add Offset'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

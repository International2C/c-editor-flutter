import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wave number strip opens event management on narrow desktop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(480, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const alias = 'Wave1Event';
    final event = PvzObject(
      aliases: const [alias],
      objClass: 'SpawnZombiesJitteredWaveActionProps',
      objData: const <String, dynamic>{'Zombies': <dynamic>[]},
    );
    final waveManager = WaveManagerData(
      waveCount: 1,
      waves: [
        [RtidParser.build(alias, 'CurrentLevel')],
      ],
    );
    final level = PvzLevelFile(objects: [event]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: WaveTimelineTab(
            levelFile: level,
            parsed: ParsedLevelData(
              waveManager: waveManager,
              objectMap: {alias: event},
            ),
            onChanged: () {},
            onEditEvent: (_, _) async {},
            onAddEvent: (_) {},
            onEditWaveManagerSettings: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    final waveNumberStrip = find.byKey(
      const ValueKey('waveTimelineWaveNumberTap-1'),
    );
    await tester.scrollUntilVisible(waveNumberStrip, 300);
    await tester.tap(waveNumberStrip);
    await tester.pumpAndSettle();

    expect(find.text('Wave 1 events'), findsOneWidget);
    expect(find.text('Add event'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('event actions stack and remain scrollable with scaled text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const alias = 'HamsterStormEvent0';
    final event = PvzObject(
      aliases: const [alias],
      objClass: 'HamsterZombieSpawnerProps',
      objData: const <String, dynamic>{},
    );
    final waveManager = WaveManagerData(
      waveCount: 1,
      waves: [
        [RtidParser.build(alias, 'CurrentLevel')],
      ],
    );
    final level = PvzLevelFile(objects: [event]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: const TextScaler.linear(1.6)),
              child: Scaffold(
                body: WaveTimelineTab(
                  levelFile: level,
                  parsed: ParsedLevelData(
                    waveManager: waveManager,
                    objectMap: {alias: event},
                  ),
                  onChanged: () {},
                  onEditEvent: (_, _) async {},
                  onAddEvent: (_) {},
                  onEditWaveManagerSettings: () {},
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final waveNumberStrip = find.byKey(
      const ValueKey('waveTimelineWaveNumberTap-1'),
    );
    await tester.scrollUntilVisible(waveNumberStrip, 300);
    await tester.tap(waveNumberStrip);
    await tester.pumpAndSettle();
    await tester.tap(find.text(alias).last);
    await tester.pumpAndSettle();

    final rename = find.byKey(const ValueKey('waveEventRenameButton'));
    final copy = find.byKey(const ValueKey('waveEventCopyButton'));
    final move = find.byKey(const ValueKey('waveEventMoveButton'));
    expect(tester.getSize(rename).width, greaterThan(250));
    expect(tester.getSize(copy).width, greaterThan(250));
    expect(tester.getSize(move).width, greaterThan(250));
    expect(
      tester.getRect(copy).top,
      greaterThanOrEqualTo(tester.getRect(rename).bottom),
    );
    expect(
      tester.getRect(move).top,
      greaterThanOrEqualTo(tester.getRect(copy).bottom),
    );

    final remove = find.byKey(const ValueKey('waveEventRemoveButton'));
    await tester.ensureVisible(remove);
    await tester.pumpAndSettle();
    expect(remove, findsOneWidget);
    expect(remove.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('event actions stay in one row when wide enough', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const alias = 'HamsterStormEvent0';
    final event = PvzObject(
      aliases: const [alias],
      objClass: 'HamsterZombieSpawnerProps',
      objData: const <String, dynamic>{},
    );
    final waveManager = WaveManagerData(
      waveCount: 1,
      waves: [
        [RtidParser.build(alias, 'CurrentLevel')],
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: const TextScaler.linear(1.6)),
              child: Scaffold(
                body: WaveTimelineTab(
                  levelFile: PvzLevelFile(objects: [event]),
                  parsed: ParsedLevelData(
                    waveManager: waveManager,
                    objectMap: {alias: event},
                  ),
                  onChanged: () {},
                  onEditEvent: (_, _) async {},
                  onAddEvent: (_) {},
                  onEditWaveManagerSettings: () {},
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final waveNumberStrip = find.byKey(
      const ValueKey('waveTimelineWaveNumberTap-1'),
    );
    await tester.scrollUntilVisible(waveNumberStrip, 300);
    await tester.tap(waveNumberStrip);
    await tester.pumpAndSettle();
    await tester.tap(find.text(alias).last);
    await tester.pumpAndSettle();

    final rename = find.byKey(const ValueKey('waveEventRenameButton'));
    final copy = find.byKey(const ValueKey('waveEventCopyButton'));
    final move = find.byKey(const ValueKey('waveEventMoveButton'));
    expect(tester.getRect(rename).top, tester.getRect(copy).top);
    expect(tester.getRect(copy).top, tester.getRect(move).top);
    expect(tester.getRect(rename).right, lessThan(tester.getRect(copy).left));
    expect(tester.getRect(copy).right, lessThan(tester.getRect(move).left));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'empty wave number remains visible and manage actions stack when narrow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final waveManager = WaveManagerData(
        waveCount: 1,
        waves: const [<String>[]],
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: WaveTimelineTab(
              levelFile: PvzLevelFile(objects: const []),
              parsed: ParsedLevelData(
                waveManager: waveManager,
                objectMap: const {},
              ),
              onChanged: () {},
              onEditEvent: (_, _) async {},
              onAddEvent: (_) {},
              onEditWaveManagerSettings: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final waveNumberStrip = find.byKey(
        const ValueKey('waveTimelineWaveNumberTap-1'),
      );
      await tester.scrollUntilVisible(waveNumberStrip, 300);
      final waveNumber = find.text('1');
      expect(waveNumber, findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
      expect(tester.getSize(waveNumber).height, greaterThanOrEqualTo(16));
      expect(
        tester.getRect(waveNumberStrip).contains(tester.getCenter(waveNumber)),
        isTrue,
      );

      await tester.tap(waveNumberStrip);
      await tester.pumpAndSettle();

      final add = find.byKey(const ValueKey('waveManageAddEventButton'));
      final reuse = find.byKey(const ValueKey('waveManageReuseEventButton'));
      expect(add, findsOneWidget);
      expect(reuse, findsOneWidget);
      expect(
        tester.getRect(reuse).top,
        greaterThan(tester.getRect(add).bottom),
      );
      expect(tester.getSize(add).width, greaterThan(250));
      expect(tester.getSize(reuse).width, greaterThan(250));
      expect(tester.getSize(find.text('Add event')).height, lessThan(30));
      expect(tester.getSize(find.text('Reuse event')).height, lessThan(30));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'renaming from event sheet passes the new rtid to edit properties',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      const oldAlias = 'Wave2ModConveyor0';
      const newAlias = 'Wave2ModConveyorRenamed';
      final event = PvzObject(
        aliases: [oldAlias],
        objClass: 'ModifyConveyorWaveActionProps',
        objData: <String, dynamic>{},
      );
      final waveManager = WaveManagerData(
        waveCount: 1,
        waves: [
          [RtidParser.build(oldAlias, 'CurrentLevel')],
        ],
      );
      final objectMap = <String, PvzObject>{oldAlias: event};
      final editedRtids = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: WaveTimelineTab(
              levelFile: PvzLevelFile(
                objects: [
                  event,
                  PvzObject(
                    aliases: const ['WaveManager'],
                    objClass: 'WaveManagerProperties',
                    objData: waveManager.toJson(),
                  ),
                ],
              ),
              parsed: ParsedLevelData(
                waveManager: waveManager,
                objectMap: objectMap,
              ),
              onChanged: () {},
              onEditEvent: (rtid, _) async {
                editedRtids.add(rtid);
              },
              onAddEvent: (_) {},
              onEditWaveManagerSettings: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(oldAlias).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('waveEventRenameButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, newAlias);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(objectMap.containsKey(newAlias), isTrue);
      expect(objectMap.containsKey(oldAlias), isFalse);
      expect(find.textContaining(newAlias), findsWidgets);

      await tester.tap(find.text('Edit properties'));
      await tester.pumpAndSettle();

      expect(editedRtids, [RtidParser.build(newAlias, 'CurrentLevel')]);
      expect(tester.takeException(), isNull);
    },
  );
}

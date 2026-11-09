import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _eventAlias = 'HamsterStorm';

Future<WaveManagerData> _pumpTimeline(
  WidgetTester tester, {
  required double width,
  required double textScale,
  bool withEvent = false,
  int waveCount = 1,
}) async {
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final event = PvzObject(
    aliases: const [_eventAlias],
    objClass: 'HamsterZombieSpawnerProps',
    objData: const <String, dynamic>{},
  );
  final wm = WaveManagerData(
    waveCount: waveCount,
    waves: [
      for (var index = 0; index < waveCount; index++)
        withEvent && index == 0
            ? [RtidParser.build(_eventAlias, 'CurrentLevel')]
            : <String>[],
    ],
  );
  final modules = [
    PvzObject(
      aliases: const ['RadiationMeteor'],
      objClass: 'RadiationMeteorModuleProperties',
      objData: RadiationMeteorModulePropertiesData(
        spawnSchedule: [
          for (var index = 0; index < waveCount; index++)
            RadiationMeteorSpawnData(wave: index),
        ],
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['LunarMineVein'],
      objClass: 'LunarMineVeinModuleProperties',
      objData: LunarMineVeinModulePropertiesData(
        placements: [
          for (var index = 0; index < waveCount; index++)
            LunarMineVeinPlacementData(emergenceWave: index + 1),
        ],
      ).toJson(),
    ),
  ];
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: WaveTimelineTab(
          levelFile: PvzLevelFile(objects: [...modules, if (withEvent) event]),
          parsed: ParsedLevelData(
            waveManager: wm,
            objectMap: {if (withEvent) _eventAlias: event},
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
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('waveTimelineWaveNumberTap-1')),
    300,
  );
  await tester.pumpAndSettle();
  return wm;
}

Finder _meteorBadge(int wave) =>
    find.byKey(ValueKey('waveTimelineExpectation-$wave-1'));

void _expectReadableBadge(WidgetTester tester, int wave) {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final badge = _meteorBadge(wave);
  final label = find.descendant(
    of: badge,
    matching: find.text(l10n.radiationMeteorModuleExpectationLabel),
  );
  expect(label, findsOneWidget);
  final text = tester.widget<Text>(label);
  expect(text.softWrap, isTrue);
  expect(text.maxLines, isNull);
  expect(text.overflow, isNot(TextOverflow.ellipsis));
  expect(tester.getSize(badge).width, lessThanOrEqualTo(260));
  expect(tester.getSize(label).width, greaterThan(110));
}

void main() {
  testWidgets(
    'light offset preset card uses a pale background and left-aligned header and description',
    (tester) async {
      await _pumpTimeline(tester, width: 400, textScale: 1);
      final l10n = lookupAppLocalizations(const Locale('en'));
      final title = find.text(l10n.waveTimelineJitterOffsetsTitle);
      await tester.ensureVisible(title);
      await tester.pumpAndSettle();
      final card = find.ancestor(of: title, matching: find.byType(Card)).first;
      final icon = find.descendant(
        of: card,
        matching: find.byIcon(Icons.speed),
      );
      final description = find.descendant(
        of: card,
        matching: find.text(l10n.waveTimelineJitterOffsetsNone),
      );
      expect(tester.widget<Card>(card).color, Colors.blue.shade100);
      expect(tester.widget<Text>(title).style?.color, Colors.black87);
      expect(
        tester.getTopLeft(description).dx,
        closeTo(tester.getTopLeft(icon).dx, .1),
      );
      expect(
        tester.getCenter(icon).dy,
        closeTo(tester.getCenter(title).dy, .1),
      );
      expect(tester.takeException(), isNull);
    },
  );
  for (final width in [320.0, 360.0, 480.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'empty wave and long module badges stay readable at width $width / scale $scale',
        (tester) async {
          await _pumpTimeline(tester, width: width, textScale: scale);
          final emptyHint = find.byKey(
            const ValueKey('waveTimelineEmptyHint-1'),
          );
          final target = find.byKey(const ValueKey('waveTimelineDropTarget-1'));
          final actions = find.byKey(
            const ValueKey('waveTimelineModuleActions-1'),
          );
          expect(
            tester.getSize(emptyHint).width,
            greaterThanOrEqualTo(width - 61),
          );
          expect(
            tester.getRect(actions).top,
            greaterThanOrEqualTo(tester.getRect(target).bottom + 8),
          );
          _expectReadableBadge(tester, 1);
          final numberStrip = find.byKey(
            const ValueKey('waveTimelineWaveNumberTap-1'),
          );
          final number = find.descendant(
            of: numberStrip,
            matching: find.text('1'),
          );
          expect(number, findsOneWidget);
          expect(find.byIcon(Icons.flag), findsOneWidget);
          expect(
            tester.getRect(numberStrip).contains(tester.getCenter(number)),
            isTrue,
          );
          await tester.tap(numberStrip);
          await tester.pumpAndSettle();
          expect(find.text('Wave 1 events'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('waveManageAddEventButton')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'nonempty narrow wave keeps its event area readable with long badges at scale $scale',
      (tester) async {
        await _pumpTimeline(
          tester,
          width: 320,
          textScale: scale,
          withEvent: true,
        );
        final target = find.byKey(const ValueKey('waveTimelineDropTarget-1'));
        expect(tester.getSize(target).width, 268);
        _expectReadableBadge(tester, 1);
        final actions = find.byKey(
          const ValueKey('waveTimelineModuleActions-1'),
        );
        expect(
          tester.getRect(actions).top,
          greaterThan(tester.getRect(target).bottom),
        );
        await tester.tap(find.text(_eventAlias).first);
        await tester.pumpAndSettle();
        expect(find.text('Edit properties'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('wide timeline keeps bounded module badges to the right', (
    tester,
  ) async {
    await _pumpTimeline(tester, width: 1200, textScale: 1);
    final target = find.byKey(const ValueKey('waveTimelineDropTarget-1'));
    final actions = find.byKey(const ValueKey('waveTimelineModuleActions-1'));
    expect(
      tester.getRect(actions).left,
      greaterThanOrEqualTo(tester.getRect(target).right + 8),
    );
    expect(tester.getSize(target).width, greaterThan(500));
    _expectReadableBadge(tester, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long module badges do not intercept cross-wave event drops', (
    tester,
  ) async {
    final wm = await _pumpTimeline(
      tester,
      width: 360,
      textScale: 1,
      withEvent: true,
      waveCount: 2,
    );
    final target = find.byKey(const ValueKey('waveTimelineDropTarget-2'));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(_eventAlias).first),
      kind: PointerDeviceKind.touch,
    );
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(wm.waves[0], isEmpty);
    expect(wm.waves[1], [RtidParser.build(_eventAlias, 'CurrentLevel')]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrapped meteor badge still opens its module preview', (
    tester,
  ) async {
    await _pumpTimeline(tester, width: 320, textScale: 1);
    await tester.tap(_meteorBadge(1));
    await tester.pumpAndSettle();
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(
      find.text(
        '${l10n.waveLabel} 1 - ${l10n.radiationMeteorModuleExpectationLabel}',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

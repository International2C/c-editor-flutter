import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openSheet(
  WidgetTester tester, {
  required Size size,
  int eventCount = 10,
  List<String?>? eventClasses,
  Locale locale = const Locale('en'),
  double textScale = 1,
  double bottomSafeArea = 0,
  ThemeData? theme,
  void Function(int)? onAddEvent,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final notifier = ValueNotifier<({int waveIndex, String? rtid})?>(null);
  addTearDown(notifier.dispose);
  final aliases = List.generate(
    eventClasses?.length ?? eventCount,
    (i) => 'Wave1Event$i',
  );
  final events = [
    for (final (i, alias) in aliases.indexed)
      if (eventClasses == null || eventClasses[i] != null)
        PvzObject(
          aliases: [alias],
          objClass: eventClasses?[i] ?? 'SpawnZombiesJitteredWaveActionProps',
          objData: const <String, dynamic>{'Zombies': <dynamic>[]},
        ),
  ];
  final wm = WaveManagerData(
    waveCount: 1,
    waves: [
      aliases.map((alias) => RtidParser.build(alias, 'CurrentLevel')).toList(),
    ],
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          padding: EdgeInsets.only(bottom: bottomSafeArea),
          viewPadding: EdgeInsets.only(bottom: bottomSafeArea),
        ),
        child: child!,
      ),
      home: Scaffold(
        body: WaveTimelineTab(
          levelFile: PvzLevelFile(objects: events),
          parsed: ParsedLevelData(
            waveManager: wm,
            objectMap: {
              for (final event in events) event.aliases!.first: event,
            },
          ),
          onChanged: () {},
          onEditEvent: (_, _) async {},
          onAddEvent: onAddEvent ?? (_) {},
          onEditWaveManagerSettings: () {},
          openWaveSheetNotifier: notifier,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  notifier.value = (waveIndex: 1, rtid: null);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('wave sheet localizes known, unknown, and missing events', (
    tester,
  ) async {
    await _openSheet(
      tester,
      size: const Size(420, 900),
      locale: const Locale('zh'),
      eventClasses: const [
        'SpawnZombiesJitteredWaveActionProps',
        'UnsupportedWaveActionProps',
        null,
      ],
    );
    expect(find.text('普通出怪'), findsOneWidget);
    expect(find.text('未知事件'), findsOneWidget);
    expect(find.text('无效事件'), findsOneWidget);
    expect(find.text('Unknown event'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('portrait sheet starts with two complete events and can expand', (
    tester,
  ) async {
    await _openSheet(tester, size: const Size(360, 800));
    final list = find.byKey(const ValueKey('waveManageEventList'));
    final listRect = tester.getRect(list);
    for (var i = 0; i < 2; i++) {
      final card = tester.getRect(find.byKey(ValueKey('waveManageEvent-$i')));
      expect(card.top, greaterThanOrEqualTo(listRect.top));
      expect(card.bottom, lessThanOrEqualTo(listRect.bottom));
    }
    final sheet = find.byKey(const ValueKey('waveManageSheet'));
    final initialHeight = tester.getSize(sheet).height;
    expect(initialHeight, greaterThan(800 * 0.65));
    await tester.drag(list, const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(tester.getSize(sheet).height, greaterThan(initialHeight));
    await tester.drag(list, const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('waveManageEvent-9')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text keeps portrait events and action labels readable', (
    tester,
  ) async {
    await _openSheet(tester, size: const Size(360, 900), textScale: 1.4);
    final listRect = tester.getRect(
      find.byKey(const ValueKey('waveManageEventList')),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('waveManageEvent-1'))).bottom,
      lessThanOrEqualTo(listRect.bottom),
    );
    final add = find.byKey(const ValueKey('waveManageAddEventButton'));
    final reuse = find.byKey(const ValueKey('waveManageReuseEventButton'));
    expect(tester.getRect(reuse).top, greaterThan(tester.getRect(add).bottom));
    expect(tester.getSize(find.text('Add event')).height, lessThan(40));
    expect(tester.getSize(find.text('Reuse event')).height, lessThan(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('equal-width actions account for custom button theme', (
    tester,
  ) async {
    const buttonTextStyle = TextStyle(fontSize: 18, letterSpacing: 0);
    final painter = TextPainter(
      text: const TextSpan(text: 'Reuse event', style: buttonTextStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    // Each half is just too narrow for the longer label even though the sum
    // of both required label widths would fit an unequal-width row.
    final windowWidth = (painter.width + 56 + 18 + 8) * 2 + 8 + 32 - 1;
    await _openSheet(
      tester,
      size: Size(windowWidth, 900),
      theme: ThemeData(
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: buttonTextStyle,
            iconSize: 18,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          ),
        ),
      ),
    );
    final add = find.byKey(const ValueKey('waveManageAddEventButton'));
    final reuse = find.byKey(const ValueKey('waveManageReuseEventButton'));
    expect(tester.getRect(reuse).top, greaterThan(tester.getRect(add).bottom));
    expect(tester.getSize(find.text('Reuse event')).height, lessThan(30));
    expect(tester.takeException(), isNull);
  });

  testWidgets('short sheet scrolls all content without squeezing events', (
    tester,
  ) async {
    int? addedWave;
    await _openSheet(
      tester,
      size: const Size(360, 300),
      eventCount: 2,
      onAddEvent: (wave) => addedWave = wave,
    );
    final scroll = find.byKey(const ValueKey('waveManageSheetScroll'));
    expect(scroll, findsOneWidget);
    final firstCard = tester.getRect(
      find.byKey(const ValueKey('waveManageEvent-0')),
    );
    expect(firstCard.height, greaterThanOrEqualTo(72));
    expect(firstCard.bottom, lessThanOrEqualTo(tester.getRect(scroll).bottom));
    final add = find.byKey(const ValueKey('waveManageAddEventButton'));
    await tester.scrollUntilVisible(
      add,
      100,
      scrollable: find.descendant(
        of: scroll,
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(addedWave, 1);
    expect(find.byKey(const ValueKey('waveManageSheet')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty wave keeps a smaller initial sheet and readable actions', (
    tester,
  ) async {
    await _openSheet(tester, size: const Size(360, 800), eventCount: 0);
    expect(find.text('Empty wave'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('waveManageSheet'))).height,
      lessThan(800 * 0.65),
    );
    expect(tester.getSize(find.text('Add event')).height, lessThan(30));
    expect(tester.getSize(find.text('Reuse event')).height, lessThan(30));
    expect(tester.takeException(), isNull);
  });

  for (final scenario in [
    (size: const Size(360, 800), textScale: 1.0, safeArea: 0.0),
    (size: const Size(360, 900), textScale: 1.8, safeArea: 0.0),
    (size: const Size(360, 900), textScale: 1.4, safeArea: 34.0),
    (size: const Size(900, 800), textScale: 1.0, safeArea: 0.0),
  ]) {
    testWidgets('empty wave footer stays at the bottom ${scenario.size} '
        'scale ${scenario.textScale} safe area ${scenario.safeArea}', (
      tester,
    ) async {
      await _openSheet(
        tester,
        size: scenario.size,
        eventCount: 0,
        textScale: scenario.textScale,
        bottomSafeArea: scenario.safeArea,
      );
      final sheet = tester.getRect(
        find.byKey(const ValueKey('waveManageSheet')),
      );
      final delete = tester.getRect(
        find.byKey(const ValueKey('waveManageDeleteWaveButton')),
      );
      expect(
        sheet.bottom - delete.bottom,
        closeTo(24 + scenario.safeArea, 1),
        reason: 'Unused sheet height belongs above the actions, not below.',
      );
      expect(delete.bottom, lessThanOrEqualTo(scenario.size.height));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('short empty wave can scroll its footer to the bottom', (
    tester,
  ) async {
    await _openSheet(
      tester,
      size: const Size(360, 300),
      eventCount: 0,
      textScale: 1.4,
    );
    final scroll = find.byKey(const ValueKey('waveManageSheetScroll'));
    expect(scroll, findsOneWidget);
    final delete = find.byKey(const ValueKey('waveManageDeleteWaveButton'));
    await tester.drag(scroll, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(scroll).bottom - tester.getRect(delete).bottom,
      closeTo(0, 1),
    );
    expect(delete.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide window keeps add and reuse actions on the same row', (
    tester,
  ) async {
    await _openSheet(tester, size: const Size(900, 800), eventCount: 2);
    final add = tester.getRect(
      find.byKey(const ValueKey('waveManageAddEventButton')),
    );
    final reuse = tester.getRect(
      find.byKey(const ValueKey('waveManageReuseEventButton')),
    );
    expect(add.top, reuse.top);
    expect(add.right, lessThan(reuse.left));
    expect(tester.takeException(), isNull);
  });
}

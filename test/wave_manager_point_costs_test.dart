import 'package:c_editor/data/level_escalation_runtime.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/module_open_hint.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/modules/wave_manager_module_screen.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:c_editor/widgets/persistent_scrollbar_scroll_behavior.dart';
import 'package:c_editor/widgets/wave_flag_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PvzLevelFile _level() => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: const ['NewWaves'],
      objClass: 'WaveManagerModuleProperties',
      objData: WaveManagerModuleData(
        waveManagerProps: 'RTID(Waves@CurrentLevel)',
        dynamicZombies: [
          DynamicZombieGroup(
            startingPoints: 1000,
            zombiePool: const [
              'RTID(tutorial@ZombieTypes)',
              'RTID(tutorial_armor1@ZombieTypes)',
              'RTID(tutorial_armor2@ZombieTypes)',
            ],
            zombieLevel: const [1, 2, 3],
          ),
        ],
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['Waves'],
      objClass: 'WaveManagerProperties',
      objData: WaveManagerData(
        flagWaveInterval: 10,
        waveCount: 5,
        waves: List.generate(5, (_) => <String>[]),
      ).toJson(),
    ),
  ],
);

Widget _app(Locale locale, Widget child, {double textScale = 1}) => MaterialApp(
  locale: locale,
  scrollBehavior: const PersistentScrollbarScrollBehavior(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(body: child),
);

Future<void> _openPointExpectation(
  WidgetTester tester,
  Locale locale, {
  PvzLevelFile? level,
  double textScale = 1,
  OpenModuleCallback? onOpenModule,
}) async {
  final file = level ?? _level();
  await tester.pumpWidget(
    _app(
      locale,
      WaveTimelineTab(
        levelFile: file,
        parsed: LevelParser.parseLevel(file),
        onChanged: () {},
        onEditEvent: (_, _) async {},
        onAddEvent: (_) {},
        onEditWaveManagerSettings: () {},
        onOpenModule: onOpenModule,
      ),
      textScale: textScale,
    ),
  );
  await tester.pumpAndSettle();
  final points = find.byKey(const ValueKey('waveTimelineExpectation-4-0'));
  await tester.scrollUntilVisible(
    points,
    250,
    scrollable: find
        .descendant(
          of: find.byType(WaveTimelineTab),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  expect(points.hitTestable(), findsOneWidget);
  await tester.tap(points);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ZombiePropertiesRepository.init(),
      ZombieRepository().init(),
      ResourceNames.ensureLoaded(),
    ]);
  });

  test('Chinese point-spawn preview uses the expected title and unit', () {
    final zh = lookupAppLocalizations(const Locale('zh'));
    expect(zh.expectation, '点数出怪预览');
    expect(zh.pointSpawnExpectedCount('3.50'), '3.50只');
  });

  for (final language in ['zh', 'en', 'ru']) {
    final locale = Locale(language);
    testWidgets(
      'wave manager shows each variant cost before its level $language',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 1000);
        addTearDown(tester.view.reset);
        final level = _level();
        final l10n = lookupAppLocalizations(locale);
        await tester.pumpWidget(
          _app(
            locale,
            WaveManagerModuleScreen(
              rtid: 'RTID(NewWaves@CurrentLevel)',
              levelFile: level,
              onChanged: () {},
              onBack: () {},
              onRequestZombieSelection: (_) {},
              onOpenWaveTimeline: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        final ruler = find.byType(WaveFlagStrip);
        final pointSettings = find.text(l10n.pointSettings);
        final startingWave = find.text(l10n.startingWave);
        expect(
          tester.getRect(pointSettings).bottom,
          lessThanOrEqualTo(tester.getRect(ruler).top),
        );
        expect(
          tester.getRect(ruler).bottom,
          lessThan(tester.getRect(startingWave).top),
        );

        for (var i = 0; i < 3; i++) {
          final row = find.byKey(ValueKey('waveManagerZombiePoolDetails-$i'));
          final cost = find.descendant(
            of: row,
            matching: find.text(l10n.zombiePointCost([100, 200, 400][i])),
          );
          final levelLabel = find.descendant(
            of: row,
            matching: find.text(l10n.levelFormat(i + 1)),
          );
          expect(cost, findsOneWidget);
          expect(
            tester.getRect(cost).bottom,
            lessThanOrEqualTo(tester.getRect(levelLabel).top),
          );
        }

        final pointSpawningSwitch = find.byType(Switch);
        await tester.ensureVisible(pointSpawningSwitch);
        await tester.pumpAndSettle();
        await tester.tap(pointSpawningSwitch);
        await tester.pumpAndSettle();
        expect(pointSettings, findsNothing);
        expect(ruler, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('point expectation shows costs under codenames $language', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 1000);
      addTearDown(tester.view.reset);
      final l10n = lookupAppLocalizations(locale);
      await _openPointExpectation(tester, locale);

      expect(
        find.text('${l10n.customZombieWaveItem(4)} ${l10n.expectation}'),
        findsOneWidget,
      );
      for (final entry in const {
        'tutorial': 100,
        'tutorial_armor1': 200,
        'tutorial_armor2': 400,
      }.entries) {
        final cost = find.text(l10n.zombiePointCost(entry.value));
        final codename = find.text(entry.key);
        expect(cost, findsOneWidget);
        expect(
          tester.getRect(cost).top,
          greaterThanOrEqualTo(tester.getRect(codename).bottom),
        );
        final expectedCount = find.byKey(
          ValueKey('wavePointExpectationCount-${entry.key}'),
        );
        expect(expectedCount, findsOneWidget);
        expect(
          tester.getRect(expectedCount).left,
          greaterThan(tester.getRect(cost).right),
        );
        if (language == 'zh') {
          expect(tester.widget<Text>(expectedCount).data, endsWith('只'));
        }
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('narrow point expectation stacks counts below readable costs', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 1000);
    addTearDown(tester.view.reset);
    const locale = Locale('zh');
    final l10n = lookupAppLocalizations(locale);
    await _openPointExpectation(tester, locale, textScale: 1.3);

    final cost = find.text(l10n.zombiePointCost(200));
    final codename = find.text('tutorial_armor1');
    final count = find.byKey(
      const ValueKey('wavePointExpectationCount-tutorial_armor1'),
    );
    expect(
      tester.widget<Text>(codename).overflow,
      isNot(TextOverflow.ellipsis),
    );
    expect(tester.getRect(count).left, closeTo(tester.getRect(cost).left, 1));
    expect(tester.getRect(count).top, greaterThan(tester.getRect(cost).bottom));
    expect(tester.getSize(cost).width, greaterThan(100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('escalation point preview opens the active escalation module', (
    tester,
  ) async {
    const locale = Locale('en');
    final level = _level();
    level.objects.insertAll(0, [
      PvzObject(
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData(
          modules: [
            'RTID(EscalationRef@CurrentLevel)',
            'RTID(NewWaves@CurrentLevel)',
          ],
        ).toJson(),
      ),
      PvzObject(
        aliases: ['UnusedEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData().toJson(),
      ),
      PvzObject(
        aliases: ['ActiveEscalation', 'EscalationRef'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData(
          startingPoints: 1000,
          waveManagerProps: 'RTID(Waves@CurrentLevel)',
          zombiePool: ['RTID(tutorial_armor2@ZombieTypes)'],
        ).toJson(),
      ),
    ]);
    String? openedModule;
    await _openPointExpectation(
      tester,
      locale,
      level: level,
      onOpenModule: (rtid, {hint}) => openedModule = rtid,
    );
    expect(find.text('tutorial_armor2'), findsOneWidget);
    expect(find.text('tutorial_armor1'), findsNothing);

    final l10n = lookupAppLocalizations(locale);
    await tester.tap(find.widgetWithText(FilledButton, l10n.openModuleSettings));
    await tester.pumpAndSettle();
    expect(openedModule, 'RTID(ActiveEscalation@CurrentLevel)');
    expect(
      LevelEscalationRuntime.resolve(
        level,
        escalationAlias: 'ActiveEscalation',
      ).isEffective,
      isTrue,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('short point preview keeps both actions below its scroll area', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.reset);
    const locale = Locale('ru');
    final l10n = lookupAppLocalizations(locale);
    String? openedModule;
    await _openPointExpectation(
      tester,
      locale,
      textScale: 1.4,
      onOpenModule: (rtid, {hint}) => openedModule = rtid,
    );
    tester.view.physicalSize = const Size(360, 350);
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    final list = find.descendant(of: dialog, matching: find.byType(ListView));
    final settings = find.widgetWithText(FilledButton, l10n.openModuleSettings);
    final close = find.widgetWithText(TextButton, l10n.close);
    expect(tester.takeException(), isNull);
    expect(
      find.descendant(of: list, matching: find.byType(Scrollbar)),
      findsOneWidget,
    );
    final listBounds = tester.getRect(list);
    final settingsBounds = tester.getRect(settings);
    final closeBounds = tester.getRect(close);
    expect(listBounds.bottom, lessThanOrEqualTo(settingsBounds.top));
    expect(listBounds.bottom, lessThanOrEqualTo(closeBounds.top));

    final scrollable = find.descendant(
      of: list,
      matching: find.byType(Scrollable),
    );
    final lastRow = find.byKey(
      const ValueKey('wavePointExpectationCount-tutorial_armor2'),
    );
    await tester.scrollUntilVisible(lastRow, 70, scrollable: scrollable);
    await tester.pumpAndSettle();
    expect(listBounds.contains(tester.getCenter(lastRow)), isTrue);
    expect(tester.getRect(settings), settingsBounds);
    expect(tester.getRect(close), closeBounds);
    expect(close.hitTestable(), findsOneWidget);
    await tester.tap(settings);
    await tester.pumpAndSettle();
    expect(openedModule, 'RTID(NewWaves@CurrentLevel)');
    expect(dialog, findsNothing);
    expect(tester.takeException(), isNull);
  });
}

import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/modules/wave_manager_module_screen.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
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

Widget _app(Locale locale, Widget child) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

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
      final level = _level();
      final l10n = lookupAppLocalizations(locale);
      await tester.pumpWidget(
        _app(
          locale,
          WaveTimelineTab(
            levelFile: level,
            parsed: LevelParser.parseLevel(level),
            onChanged: () {},
            onEditEvent: (_, _) async {},
            onAddEvent: (_) {},
            onEditWaveManagerSettings: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final points = find.byKey(const ValueKey('waveTimelineExpectation-4-0'));
      await tester.ensureVisible(points);
      await tester.tap(points);
      await tester.pumpAndSettle();

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
        if (language == 'zh') {
          expect(tester.widget<Text>(expectedCount).data, endsWith('只'));
        }
      }
      expect(tester.takeException(), isNull);
    });
  }
}

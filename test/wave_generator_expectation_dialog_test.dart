import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/zombie_count_simulation.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/wave_generator_expectation_dialog.dart';
import 'package:c_editor/widgets/zombie_count_estimate_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ZombiePropertiesRepository.init);

  test('collapsed percentile range keeps the simulated average', () {
    final l10n = lookupAppLocalizations(const Locale('zh'));
    expect(formatEstimatedCount(2), '2');
    expect(
      zombieCountEstimateText(
        l10n,
        const ZombieCountEstimate(average: 2.1, minimum: 2, maximum: 2),
        scope: ZombieCountEstimateScope.allWaves,
      ),
      '全部波次合计：约2.1只',
    );
    expect(
      zombieCountEstimateText(
        l10n,
        const ZombieCountEstimate(average: 30.1, minimum: 27, maximum: 33),
        scope: ZombieCountEstimateScope.allWaves,
      ),
      '全部波次合计：约30.1只（常见范围：27只–33只）',
    );
  });

  testWidgets(
    'random-spawn preview remains readable on narrow screens without fixed-spawn summary',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = WaveGeneratorPropertiesData(
        waveSpendingPoints: 100,
        addToZombiePool: [WaveGeneratorPoolEntryData(type: 'tutorial')],
        waves: [
          WaveGeneratorWaveData(
            disableRandomSpawns: false,
            zombies: [WaveGeneratorZombieEntryData(type: 'tutorial', row: '1')],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showWaveGeneratorExpectationDialog(
                  context,
                  data: data,
                  waveIndex: 1,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('第1波随机出怪预览'), findsOneWidget);
      expect(find.textContaining('固定出怪：'), findsNothing);
      expect(find.byTooltip('关闭'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'collapsed count ranges and zombie metrics stay readable with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = WaveGeneratorPropertiesData(
        waveSpendingPoints: 200,
        addToZombiePool: [
          WaveGeneratorPoolEntryData(
            type: 'RTID(tutorial@ZombieTypes)',
            cost: 100,
            weight: 4000,
          ),
        ],
        waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showWaveGeneratorExpectationDialog(
                  context,
                  data: data,
                  waveIndex: 1,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Average random spawns: about 2'), findsOneWidget);
      expect(find.text('Common count range: 2–2'), findsNothing);
      expect(find.text('All waves combined: about 2'), findsOneWidget);

      final note = find.byKey(
        const ValueKey('waveGeneratorExpectationPoolNote'),
      );
      await tester.scrollUntilVisible(
        note,
        200,
        maxScrolls: 20,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(note).data,
        contains('repeatedly simulating weighted selections'),
      );

      final cost = find.byKey(
        const ValueKey('waveGeneratorExpectationCostWeight'),
      );
      await tester.scrollUntilVisible(
        cost,
        200,
        maxScrolls: 20,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      final costText = tester.widget<Text>(cost);
      final averageText = tester.widget<Text>(
        find.byKey(const ValueKey('waveGeneratorExpectationAverageCount')),
      );
      expect(costText.data, 'Cost 100 · Weight 4000');
      expect(costText.maxLines, isNull);
      expect(costText.overflow, isNull);
      expect(averageText.data, 'Average 2.00');
      expect(averageText.maxLines, isNull);
      expect(averageText.overflow, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a no-data pool zombie does not hide the remaining preview rows',
    (tester) async {
      final data = WaveGeneratorPropertiesData(
        waveSpendingPoints: 400,
        addToZombiePool: [
          WaveGeneratorPoolEntryData(type: 'RTID(tutorial@ZombieTypes)'),
          WaveGeneratorPoolEntryData(type: 'RTID(my_custom@CurrentLevel)'),
        ],
        waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showWaveGeneratorExpectationDialog(
                  context,
                  data: data,
                  waveIndex: 1,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // The custom zombie is only reported as missing data…
      expect(find.textContaining('my_custom'), findsWidgets);
      expect(
        find.textContaining('Random-spawn preview unavailable'),
        findsNothing,
      );
      // …while the bundled zombie still gets a preview row.
      expect(find.text('tutorial'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('preview rows with a 0.00 average for this wave are hidden', (
    tester,
  ) async {
    final data = WaveGeneratorPropertiesData(
      waveSpendingPoints: 100,
      addToZombiePool: [
        // Costs 400: never affordable with a 100 point budget.
        WaveGeneratorPoolEntryData(type: 'RTID(modern_balloon@ZombieTypes)'),
      ],
      waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showWaveGeneratorExpectationDialog(
                context,
                data: data,
                waveIndex: 1,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('modern_balloon'), findsNothing);
    expect(
      find.text(
        "This wave's zombie pool has no zombies eligible for random "
        'spawning.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero-weight zombies get a separate warning and no row', (
    tester,
  ) async {
    final data = WaveGeneratorPropertiesData(
      waveSpendingPoints: 100,
      addToZombiePool: [
        WaveGeneratorPoolEntryData(type: 'RTID(mummy_flag@ZombieTypes)'),
      ],
      waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showWaveGeneratorExpectationDialog(
                context,
                data: data,
                waveIndex: 1,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('随机出怪权重为 0'), findsOneWidget);
    expect(find.textContaining('mummy_flag'), findsOneWidget);
    expect(find.text('mummy_flag'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

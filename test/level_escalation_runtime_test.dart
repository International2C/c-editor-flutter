import 'package:c_editor/data/level_escalation_runtime.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/plant_food_discovery.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/wave_manager_settings_screen.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:c_editor/widgets/wave_flag_strip.dart';
import 'package:c_editor/widgets/wave_number_label.dart';
import 'package:flutter/material.dart';

void main() {
  PvzLevelFile buildLevel({
    bool escalationAfterManager = false,
    bool managerHasIndependentProps = false,
    int escalationContainerWaveCount = 2,
  }) {
    const escalationRtid = 'RTID(Escalation@CurrentLevel)';
    const managerModuleRtid = 'RTID(ManagerModule@CurrentLevel)';
    final modules = escalationAfterManager
        ? <String>[managerModuleRtid, escalationRtid]
        : <String>[escalationRtid, managerModuleRtid];
    return PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: {'Modules': modules},
        ),
        PvzObject(
          aliases: const ['Escalation'],
          objClass: 'LevelEscalationModuleProperties',
          objData: LevelEscalationModuleData(
            flagCount: 3,
            wavesPerFlag: 4,
            plantfoodToSpawnCount: 5,
            waveManagerProps: 'RTID(EscalationWaves@CurrentLevel)',
          ).toJson(),
        ),
        PvzObject(
          aliases: const ['EscalationWaves'],
          objClass: 'WaveManagerProperties',
          objData: WaveManagerData(
            waveCount: escalationContainerWaveCount,
            flagWaveInterval: 10,
            waves: List.generate(
              escalationContainerWaveCount,
              (_) => <String>[],
            ),
          ).toJson(),
        ),
        PvzObject(
          aliases: const ['ManagerModule'],
          objClass: 'WaveManagerModuleProperties',
          objData: WaveManagerModuleData(
            waveManagerProps: managerHasIndependentProps
                ? 'RTID(ManagerWaves@CurrentLevel)'
                : null,
          ).toJson(),
        ),
        if (managerHasIndependentProps)
          PvzObject(
            aliases: const ['ManagerWaves'],
            objClass: 'WaveManagerProperties',
            objData: WaveManagerData(
              waveCount: 2,
              flagWaveInterval: 10,
              waves: [<String>[], <String>[]],
            ).toJson(),
          ),
      ],
    );
  }

  test('runner-only Wave Manager does not overwrite escalation', () {
    final after = LevelEscalationRuntime.resolve(
      buildLevel(escalationAfterManager: true),
    );
    final before = LevelEscalationRuntime.resolve(
      buildLevel(escalationAfterManager: false),
    );

    expect(after.order, LevelEscalationModuleOrder.afterWaveManager);
    expect(after.isEffective, isTrue);
    expect(after.hasCompetingWaveManagerProps, isFalse);
    expect(before.order, LevelEscalationModuleOrder.beforeWaveManager);
    expect(before.isEffective, isTrue);
    expect(before.hasCompetingWaveManagerProps, isFalse);
  });

  test('only different valid configurations compete by module order', () {
    final managerWins = LevelEscalationRuntime.resolve(
      buildLevel(managerHasIndependentProps: true),
    );
    final escalationWins = LevelEscalationRuntime.resolve(
      buildLevel(
        escalationAfterManager: true,
        managerHasIndependentProps: true,
      ),
    );

    expect(managerWins.hasCompetingWaveManagerProps, isTrue);
    expect(managerWins.isEffective, isFalse);
    expect(
      managerWins.effectiveWaveManagerProps,
      'RTID(ManagerWaves@CurrentLevel)',
    );
    expect(escalationWins.hasCompetingWaveManagerProps, isTrue);
    expect(escalationWins.isEffective, isTrue);
    expect(
      escalationWins.effectiveWaveManagerProps,
      'RTID(EscalationWaves@CurrentLevel)',
    );
  });

  test('effective wave count follows the runtime padding rule', () {
    final runtime = LevelEscalationRuntime.resolve(buildLevel());
    final shortManager = WaveManagerData(
      waveCount: 2,
      waves: [<String>[], <String>[]],
    );
    final longManager = WaveManagerData(
      waveCount: 15,
      waves: List.generate(15, (_) => <String>[]),
    );

    expect(runtime.effectiveWaveCount(shortManager), 12);
    expect(runtime.effectiveWaveCount(longManager), 15);
  });

  test('Plant Food is placed before flags, then randomly', () {
    final runtime = LevelEscalationRuntime.resolve(buildLevel());

    expect(runtime.fixedPlantFoodAtWave(3), 1);
    expect(runtime.fixedPlantFoodAtWave(7), 1);
    expect(runtime.fixedPlantFoodAtWave(11), 1);
    expect(runtime.fixedPlantFoodAtWave(4), 0);
    expect(runtime.randomPlantFoodCount, 2);
  });

  test(
    'level overview counts Plant Food unless an independent config wins',
    () {
      final effective = buildLevel();
      final overwritten = buildLevel(managerHasIndependentProps: true);

      expect(
        PlantFoodDiscovery.calculateTotalPlantFood(
          effective,
          LevelParser.parseLevel(effective),
        ),
        5,
      );
      expect(
        PlantFoodDiscovery.calculateTotalPlantFood(
          overwritten,
          LevelParser.parseLevel(overwritten),
        ),
        0,
      );
    },
  );

  testWidgets('wave timeline follows the effective configuration', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 1000);
    addTearDown(tester.view.reset);

    Future<void> pumpTimeline(PvzLevelFile level) => tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: WaveTimelineTab(
            levelFile: level,
            parsed: LevelParser.parseLevel(level),
            onChanged: () {},
            onEditEvent: (_, _) async {},
            onAddEvent: (_) {},
            onEditWaveManagerSettings: () {},
          ),
        ),
      ),
    );

    Finder wave(int number) => find.byWidgetPredicate(
      (widget) => widget is WaveNumberLabel && widget.waveNumber == number,
    );

    await pumpTimeline(buildLevel());
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: wave(4), matching: find.byIcon(Icons.flag)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: wave(2), matching: find.byIcon(Icons.flag)),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      wave(12),
      400,
      maxScrolls: 20,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(wave(12), findsOneWidget);

    await pumpTimeline(buildLevel(managerHasIndependentProps: true));
    await tester.pumpAndSettle();
    expect(wave(12), findsNothing);
    expect(wave(2), findsOneWidget);
    expect(
      find.descendant(of: wave(2), matching: find.byIcon(Icons.flag)),
      findsOneWidget,
    );

    await pumpTimeline(
      buildLevel(
        escalationAfterManager: true,
        managerHasIndependentProps: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      wave(12),
      400,
      maxScrolls: 20,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(wave(12), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('container settings show the runtime flag interval override', (
    tester,
  ) async {
    const locale = Locale('zh');
    final l10n = lookupAppLocalizations(locale);
    Future<void> pumpSettings(PvzLevelFile level, {String? alias}) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WaveManagerSettingsScreen(
            key: ValueKey(level),
            levelFile: level,
            waveManagerAlias:
                alias ?? LevelParser.parseLevel(level).waveManagerAlias,
            hasConveyor: false,
            onChanged: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    final level = buildLevel();
    await pumpSettings(level);
    final field = find.byType(TextField).first;
    final hint = find.text(l10n.waveManagerFlagIntervalOverridden(4));
    WaveFlagStrip ruler() => tester.widget(find.byType(WaveFlagStrip));
    expect(tester.widget<TextField>(field).controller!.text, '10');
    expect(
      tester.getTopLeft(hint).dy,
      greaterThan(tester.getBottomLeft(field).dy),
    );
    expect(ruler().waveCount, 12);
    expect(ruler().isFlagWave(4), isTrue);
    expect(ruler().isFlagWave(10), isFalse);

    await tester.enterText(field, '6');
    await tester.pumpAndSettle();
    expect(LevelParser.parseLevel(level).waveManager!.flagWaveInterval, 6);
    expect(hint, findsOneWidget);
    expect(ruler().isFlagWave(4), isTrue);
    expect(ruler().isFlagWave(6), isFalse);

    await pumpSettings(buildLevel(escalationContainerWaveCount: 13));
    expect(ruler().waveCount, 13);
    expect(ruler().isFlagWave(12), isTrue);
    expect(ruler().isFlagWave(13), isFalse);

    await pumpSettings(buildLevel(managerHasIndependentProps: true));
    expect(hint, findsNothing);
    expect(ruler().waveCount, 2);

    await pumpSettings(
      buildLevel(
        escalationAfterManager: true,
        managerHasIndependentProps: true,
      ),
      alias: 'ManagerWaves',
    );
    expect(hint, findsNothing);
    expect(ruler().waveCount, 2);
    expect(tester.takeException(), isNull);
  });
}

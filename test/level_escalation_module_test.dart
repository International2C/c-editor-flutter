import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/level_escalation_module_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ZombiePropertiesRepository.init);

  test('LevelEscalationModuleData round-trips the reference payload', () {
    const json = <String, dynamic>{
      'FlagCount': 3,
      'PlantfoodToSpawnCount': 4,
      'PointIncrementPerWave': 75,
      'StartingPoints': 100,
      'WaveManagerProps': 'RTID(WaveManagerProps@CurrentLevel)',
      'WavesPerFlag': 4,
      'ZombiePool': [
        'RTID(pirate@ZombieTypes)',
        'RTID(pirate_armor2@ZombieTypes)',
        'RTID(pirate_armor1@ZombieTypes)',
        'RTID(barrelroller@ZombieTypes)',
      ],
    };

    final data = LevelEscalationModuleData.fromJson(json);
    expect(data.flagCount, 3);
    expect(data.wavesPerFlag, 4);
    expect(data.startingPoints, 100);
    expect(data.pointIncrementPerWave, 75);
    expect(data.plantfoodToSpawnCount, 4);
    expect(data.waveManagerProps, 'RTID(WaveManagerProps@CurrentLevel)');
    expect(data.zombiePool, hasLength(4));
    expect(data.totalWaves, 12);
    expect(data.toJson(), json);
  });

  test('Chinese escalation summary and overview use the updated wording', () {
    final zh = lookupAppLocalizations(const Locale('zh'));
    expect(
      zh.moduleDesc_LevelEscalationModuleProperties,
      '从首波开始统一规划随机出怪，可为随机生成的僵尸分配能量豆',
    );
    expect(
      zh.levelEscalationModuleHelpOverviewBody,
      '递进出怪模块需要与「波次管理器」配合使用。关卡载入时，它会以所关联的'
      '「波次容器 (WaveManagerProperties)」为基础，保留其中已有的固定出怪、其他波次事件，'
      '以及首波延迟、刷新血线、屏蔽旗帜僵尸等设置，再按自身参数，从第1波开始生成随机出怪'
      '并为部分随机僵尸分配能量豆，最后由波次管理器运行。',
    );
  });

  group('LevelEscalationModuleScreen', () {
    Widget wrap(PvzLevelFile level) {
      return MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LevelEscalationModuleScreen(
          rtid: 'RTID(LevelEscalation@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      );
    }

    PvzLevelFile buildLevel({
      String? propsAlias = 'WaveManagerProps',
      String? moduleRef = 'RTID(WaveManagerProps@CurrentLevel)',
    }) {
      final module = PvzObject(
        aliases: const ['LevelEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData(
          waveManagerProps: moduleRef,
          zombiePool: const ['RTID(pirate@ZombieTypes)'],
        ).toJson(),
      );
      final objects = <PvzObject>[module];
      if (propsAlias != null) {
        objects.add(
          PvzObject(
            aliases: [propsAlias],
            objClass: 'WaveManagerProperties',
            objData: <String, dynamic>{},
          ),
        );
      }
      objects.addAll([
        PvzObject(
          aliases: const ['NewWaves'],
          objClass: 'WaveManagerModuleProperties',
          objData: WaveManagerModuleData().toJson(),
        ),
        PvzObject(
          aliases: const ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: LevelDefinitionData(
            modules: const [
              'RTID(LevelEscalation@CurrentLevel)',
              'RTID(NewWaves@CurrentLevel)',
            ],
          ).toJson(),
        ),
      ]);
      return PvzLevelFile(objects: objects);
    }

    testWidgets('editing flag count writes objdata', (tester) async {
      final level = buildLevel();
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      final flagField = find.widgetWithText(TextField, '3');
      await tester.enterText(flagField, '5');
      await tester.pumpAndSettle();

      final obj = level.objects.first;
      final data = Map<String, dynamic>.from(obj.objData as Map);
      expect(data['FlagCount'], 5);
      expect(data['WavesPerFlag'], 4);
      expect(data['ZombiePool'], ['RTID(pirate@ZombieTypes)']);
      expect(find.textContaining('Total escalation waves'), findsNothing);
    });

    testWidgets('invalid parameter ranges show red field errors', (
      tester,
    ) async {
      final level = buildLevel();
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      TextField field(String key) => tester.widget<TextField>(
        find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(TextField),
        ),
      );

      final flagFinder = find.descendant(
        of: find.byKey(const ValueKey('levelEscalationFlagCountField')),
        matching: find.byType(TextField),
      );
      final wavesFinder = find.descendant(
        of: find.byKey(const ValueKey('levelEscalationWavesPerFlagField')),
        matching: find.byType(TextField),
      );
      final plantfoodFinder = find.descendant(
        of: find.byKey(const ValueKey('levelEscalationPlantfoodCountField')),
        matching: find.byType(TextField),
      );

      await tester.enterText(flagFinder, '1.5');
      await tester.pump();
      expect(
        field('levelEscalationFlagCountField').decoration?.errorText,
        'Flag count must be a positive integer.',
      );

      await tester.enterText(wavesFinder, '1');
      await tester.pump();
      expect(
        field('levelEscalationWavesPerFlagField').decoration?.errorText,
        contains('Waves per flag must be at least 2'),
      );

      await tester.enterText(plantfoodFinder, '0');
      await tester.pump();
      expect(
        field('levelEscalationWavesPerFlagField').decoration?.errorText,
        isNull,
      );

      await tester.enterText(plantfoodFinder, '-1');
      await tester.pump();
      expect(
        field('levelEscalationPlantfoodCountField').decoration?.errorText,
        'Plant Food count must be a non-negative integer.',
      );
    });

    testWidgets('dangling WaveManagerProps shows repair button', (
      tester,
    ) async {
      final level = buildLevel(
        propsAlias: 'WaveManagerPropsWeek1',
        moduleRef: 'RTID(WaveManagerPropsOld@CurrentLevel)',
      );
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      final fixFinder = find.byKey(
        const ValueKey('levelEscalationPropsFixButton'),
      );
      expect(fixFinder, findsOneWidget);

      await tester.tap(fixFinder);
      await tester.pumpAndSettle();

      final obj = level.objects.first;
      final repaired = LevelEscalationModuleData.fromJson(
        Map<String, dynamic>.from(obj.objData as Map),
      );
      expect(
        repaired.waveManagerProps,
        'RTID(WaveManagerPropsWeek1@CurrentLevel)',
      );
      expect(fixFinder, findsNothing);
    });

    testWidgets('renders zombie pool entries', (tester) async {
      final level = buildLevel();
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('levelEscalationZombie-0')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('predict button opens the point prediction dialog', (
      tester,
    ) async {
      final level = buildLevel();
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      final button = find.byKey(const ValueKey('levelEscalationPredictButton'));
      expect(button, findsOneWidget);

      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(
        find.descendant(of: dialog, matching: find.text('Point prediction')),
        findsOneWidget,
      );
      // Defaults to the last wave (12), which is a flag wave.
      expect(
        find.descendant(of: dialog, matching: find.textContaining('Wave 12')),
        findsWidgets,
      );
      expect(
        find.byKey(const ValueKey('levelEscalationPredictWave-1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('levelEscalationPredictWave-1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: dialog, matching: find.textContaining('Wave 1')),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('predict dialog lists flag carriers and hides no-data '
        'zombies', (tester) async {
      final module = PvzObject(
        aliases: const ['LevelEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData(
          waveManagerProps: 'RTID(WaveManagerProps@CurrentLevel)',
          zombiePool: const [
            'RTID(pirate@ZombieTypes)',
            'RTID(pirate_flag@ZombieTypes)',
            'RTID(my_custom@CurrentLevel)',
          ],
        ).toJson(),
      );
      final level = PvzLevelFile(
        objects: [
          module,
          PvzObject(
            aliases: const ['WaveManagerProps'],
            objClass: 'WaveManagerProperties',
            objData: <String, dynamic>{},
          ),
        ],
      );
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      final button = find.byKey(const ValueKey('levelEscalationPredictButton'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      // The Weight = 0 flag carrier is a normal prediction row; only the
      // custom zombie without point cost data is reported and hidden.
      expect(find.text('pirate_flag'), findsOneWidget);
      expect(find.text('my_custom'), findsNothing);
      expect(find.textContaining('not counted'), findsOneWidget);
      expect(find.textContaining('my_custom'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('predict dialog hides rows that are 0.00 for the wave', (
      tester,
    ) async {
      final module = PvzObject(
        aliases: const ['LevelEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData(
          waveManagerProps: 'RTID(WaveManagerProps@CurrentLevel)',
          // One wave, 75 points after the flag multiplier: a cost-100 pirate
          // never fits, so its row must be hidden.
          flagCount: 1,
          wavesPerFlag: 1,
          startingPoints: 30,
          pointIncrementPerWave: 0,
          zombiePool: const ['RTID(pirate@ZombieTypes)'],
        ).toJson(),
      );
      final level = PvzLevelFile(
        objects: [
          module,
          PvzObject(
            aliases: const ['WaveManagerProps'],
            objClass: 'WaveManagerProperties',
            objData: <String, dynamic>{},
          ),
        ],
      );
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      final button = find.byKey(const ValueKey('levelEscalationPredictButton'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('pirate'), findsNothing);
      expect(
        find.text(
          'This wave does not have enough points to select and spawn any '
          'zombie from the pool.',
        ),
        findsOneWidget,
      );
      expect(find.text('No dynamic zombies'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('add wave timeline creates missing wave manager objects', (
      tester,
    ) async {
      final module = PvzObject(
        aliases: const ['LevelEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData(
          waveManagerProps: 'RTID(WaveManagerProps@CurrentLevel)',
        ).toJson(),
      );
      final levelDef = PvzObject(
        aliases: const ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData(
          modules: const ['RTID(LevelEscalation@CurrentLevel)'],
        ).toJson(),
      );
      final level = PvzLevelFile(objects: [levelDef, module]);
      var structureChanged = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LevelEscalationModuleScreen(
            rtid: 'RTID(LevelEscalation@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onStructureChanged: () => structureChanged = true,
            onBack: () {},
            onRequestZombieSelection: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = find.byKey(
        const ValueKey('levelEscalationAddWaveTimelineButton'),
      );
      expect(button, findsOneWidget);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      final props = level.objects
          .where((o) => o.objClass == 'WaveManagerProperties')
          .toList();
      expect(props, hasLength(1));
      expect(props.single.aliases, ['WaveManagerProps']);

      final wmm = level.objects
          .where((o) => o.objClass == 'WaveManagerModuleProperties')
          .toList();
      expect(wmm, hasLength(1));
      expect(wmm.single.aliases, ['NewWaves']);

      final wmmData = WaveManagerModuleData.fromJson(
        Map<String, dynamic>.from(wmm.single.objData as Map),
      );
      expect(wmmData.waveManagerProps, isNull);
      expect(wmmData.dynamicZombies, isEmpty);

      final def = LevelDefinitionData.fromJson(
        Map<String, dynamic>.from(levelDef.objData as Map),
      );
      expect(def.modules, <String>[
        'RTID(LevelEscalation@CurrentLevel)',
        'RTID(NewWaves@CurrentLevel)',
      ]);

      final repaired = LevelEscalationModuleData.fromJson(
        Map<String, dynamic>.from(module.objData as Map),
      );
      expect(repaired.waveManagerProps, 'RTID(WaveManagerProps@CurrentLevel)');
      expect(structureChanged, isTrue);
      // Card is valid now, so the add button is gone.
      expect(button, findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('linked wave configuration can add its missing runner', (
      tester,
    ) async {
      final level = buildLevel();
      level.objects.removeWhere(
        (object) => object.objClass == 'WaveManagerModuleProperties',
      );

      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Wave Manager module that runs waves is missing'),
        findsOneWidget,
      );
      final button = find.byKey(
        const ValueKey('levelEscalationAddWaveTimelineButton'),
      );
      expect(button, findsOneWidget);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      final runners = level.objects
          .where((object) => object.objClass == 'WaveManagerModuleProperties')
          .toList();
      expect(runners, hasLength(1));
      final runner = WaveManagerModuleData.fromJson(
        Map<String, dynamic>.from(runners.single.objData as Map),
      );
      expect(runner.waveManagerProps, isNull);
      expect(button, findsNothing);
    });

    testWidgets('add wave timeline preserves an existing runner config', (
      tester,
    ) async {
      final module = PvzObject(
        aliases: const ['LevelEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData().toJson(),
      );
      final runner = PvzObject(
        aliases: const ['ExistingWaves'],
        objClass: 'WaveManagerModuleProperties',
        objData: WaveManagerModuleData(
          waveManagerProps: 'RTID(OtherWaves@CurrentLevel)',
          manualStartup: true,
        ).toJson(),
      );
      final levelDef = PvzObject(
        aliases: const ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData(
          modules: const [
            'RTID(LevelEscalation@CurrentLevel)',
            'RTID(ExistingWaves@CurrentLevel)',
          ],
        ).toJson(),
      );
      final level = PvzLevelFile(objects: [levelDef, module, runner]);

      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();
      final button = find.byKey(
        const ValueKey('levelEscalationAddWaveTimelineButton'),
      );
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      final runnerData = WaveManagerModuleData.fromJson(
        Map<String, dynamic>.from(runner.objData as Map),
      );
      expect(runnerData.waveManagerProps, 'RTID(OtherWaves@CurrentLevel)');
      expect(runnerData.manualStartup, isTrue);
      expect(
        LevelEscalationModuleData.fromJson(
          Map<String, dynamic>.from(module.objData as Map),
        ).waveManagerProps,
        'RTID(WaveManagerProps@CurrentLevel)',
      );
    });

    testWidgets('add wave timeline ignores an unreferenced wave manager', (
      tester,
    ) async {
      final module = PvzObject(
        aliases: const ['LevelEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData().toJson(),
      );
      final orphan = PvzObject(
        aliases: const ['OrphanWaves'],
        objClass: 'WaveManagerModuleProperties',
        objData: WaveManagerModuleData(
          waveManagerProps: 'RTID(OtherWaves@CurrentLevel)',
          manualStartup: true,
        ).toJson(),
      );
      final levelDef = PvzObject(
        aliases: const ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData(
          modules: const ['RTID(LevelEscalation@CurrentLevel)'],
        ).toJson(),
      );
      final level = PvzLevelFile(objects: [levelDef, module, orphan]);

      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();
      final button = find.byKey(
        const ValueKey('levelEscalationAddWaveTimelineButton'),
      );
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      final runners = level.objects
          .where((object) => object.objClass == 'WaveManagerModuleProperties')
          .toList();
      expect(runners, hasLength(2));
      final added = runners.singleWhere(
        (object) => object.aliases?.contains('NewWaves') == true,
      );
      expect(
        WaveManagerModuleData.fromJson(
          Map<String, dynamic>.from(added.objData as Map),
        ).waveManagerProps,
        isNull,
      );
      expect(
        WaveManagerModuleData.fromJson(
          Map<String, dynamic>.from(orphan.objData as Map),
        ).waveManagerProps,
        'RTID(OtherWaves@CurrentLevel)',
      );
      final definition = LevelDefinitionData.fromJson(
        Map<String, dynamic>.from(levelDef.objData as Map),
      );
      expect(definition.modules, const [
        'RTID(LevelEscalation@CurrentLevel)',
        'RTID(NewWaves@CurrentLevel)',
      ]);
      expect(
        definition.modules,
        isNot(contains('RTID(OrphanWaves@CurrentLevel)')),
      );
    });

    testWidgets('help dialog states that zombies always spawn at level 1', (
      tester,
    ) async {
      final level = buildLevel();
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      expect(find.text('• Zombie pool'), findsOneWidget);
      expect(find.textContaining('always spawn at level 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

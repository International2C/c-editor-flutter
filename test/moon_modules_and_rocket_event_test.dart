import 'dart:io';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/grid_item_discovery.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/registry/object_order_registry.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/app_localizations_en.dart';
import 'package:c_editor/l10n/app_localizations_ru.dart';
import 'package:c_editor/l10n/app_localizations_zh.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/modules/moon_life_support_system_screen.dart';
import 'package:c_editor/screens/editor/events/rocket_landing_event_screen.dart';
import 'package:c_editor/screens/editor/events/spawn_grave_stones_event_screen.dart';
import 'package:c_editor/screens/editor/modules/radiation_meteor_module_screen.dart';
import 'package:c_editor/widgets/grid_override_placement_grid.dart';
import 'package:c_editor/widgets/editor_components.dart' show GridItemIcon;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await GridItemRepository.init();
    await ResourceNames.ensureLoaded();
  });

  test('moon rocket follows the Atlantis seashell in the common list', () {
    final items = GridItemRepository.getAll()
        .map((item) => item.typeName)
        .toList();
    final shellIndex = items.indexOf('atlantis_shell');
    final rocketIndex = items.indexOf('rocket_landing');

    expect(shellIndex, greaterThanOrEqualTo(0));
    expect(rocketIndex, shellIndex + 1);
  });

  group('Moon Base module models', () {
    test('reads the LevelModules life support definition', () {
      final data = MoonLifeSupportSystemPropertiesData.fromJson({
        'InitialCapacity': 10,
        'BufferOverloadRatio': 2.0,
        'PenaltyCountdown': 5.0,
        'PlantImmunityList': {
          'List': ['cosmoss', 'doomshroom'],
          'ListType': 'blacklist',
        },
        'ResourceGroupNames': ['ZombieArchmageGroup', 'LunarLifeSupport'],
      });

      expect(data.initialCapacity, 10);
      expect(data.bufferOverloadRatio, 2.0);
      expect(data.penaltyCountdown, 5.0);
      expect(data.plantImmunityList.plants, ['cosmoss', 'doomshroom']);
      expect(data.plantImmunityList.listType, 'blacklist');
      expect(data.toJson()['PlantImmunityList'], {
        'List': ['cosmoss', 'doomshroom'],
        'ListType': 'blacklist',
      });

      final defaults = MoonLifeSupportSystemPropertiesData();
      expect(defaults.plantImmunityList.plants, contains('cherry_bomb'));
      expect(defaults.plantImmunityList.plants, isNot(contains('cherrybomb')));
      expect(
        () => defaults.plantImmunityList.plants.remove('cosmoss'),
        returnsNormally,
      );
    });

    test('round-trips the sample Lunar Terminal and vein data', () {
      final terminal = LunarTerminalModulePropertiesData.fromJson({
        'CollectorCooldown': 20,
      });
      final veins = LunarMineVeinModulePropertiesData.fromJson({
        'VeinPlacements': [
          {'GridX': 4, 'GridY': 2, 'EmergenceWave': 4},
          {'GridX': 6, 'GridY': 3, 'EmergenceWave': 12},
        ],
      });

      expect(terminal.collectorCooldown, 20);
      expect(terminal.toJson()['CollectorCooldown'], 20.0);
      expect(veins.placements, hasLength(2));
      expect(veins.placements.first.emergenceWave, 4);
      expect(veins.toJson()['VeinPlacements'], [
        {
          'TypeName': 'lunar_mine_vein',
          'GridX': 4,
          'GridY': 2,
          'EmergenceWave': 4,
        },
        {
          'TypeName': 'lunar_mine_vein',
          'GridX': 6,
          'GridY': 3,
          'EmergenceWave': 12,
        },
      ]);
    });

    test('round-trips the sample radioactive meteor schedule', () {
      final data = RadiationMeteorModulePropertiesData.fromJson({
        'ResourceGroupNames': ['Radiation_meteorite_group'],
        'WarningDuration': 5,
        'PollutionInterval': 5,
        'MiningDurationRequired': 5,
        'PowerRewardOnDestroy': 4,
        'SpawnSchedule': [
          {'Wave': 5, 'GridX': 8, 'GridY': 2},
          {'Wave': 10, 'GridX': 7, 'GridY': 3},
          {'Wave': 14, 'GridX': 5, 'GridY': 2},
        ],
      });

      expect(data.spawnSchedule.map((entry) => entry.wave), [5, 10, 14]);
      expect(data.powerRewardOnDestroy, 4);
      expect((data.toJson()['SpawnSchedule'] as List).last, {
        'Wave': 14,
        'GridX': 5,
        'GridY': 2,
      });
    });
  });

  group('Rocket landing event', () {
    test('new events keep the fixed non-editable landing flags', () {
      final json = SpawnRocketLandingWaveActionPropsData().toJson();
      expect(json['DisplacePlants'], isFalse);
      expect(json['IgnoreGraveStone'], isTrue);
    });

    test('round-trips the sample Wave 5 event', () {
      final data = SpawnRocketLandingWaveActionPropsData.fromJson({
        'RocketPool': [
          {'Type': 'RTID(rocket_landing@GridItemTypes)', 'Count': 1},
        ],
        'SpawnPositionsPool': [
          {'mX': 8, 'mY': 0},
          {'mX': 8, 'mY': 4},
        ],
        'SpawnCount': 1,
        'SpawnInterval': 3,
        'DisplacePlants': false,
        'IgnoreGraveStone': true,
      });

      expect(data.rocketPool.single.type, 'RTID(rocket_landing@GridItemTypes)');
      expect(data.spawnPositionsPool, hasLength(2));
      expect(data.spawnPositionsPool.last.mx, 8);
      expect(data.spawnPositionsPool.last.my, 4);
      expect(data.ignoreGraveStone, isTrue);
      expect(data.toJson()['SpawnPositionsPool'], [
        {'mX': 8, 'mY': 0},
        {'mX': 8, 'mY': 4},
      ]);
    });
  });

  group('Moon Base registries and assets', () {
    test('registers all four modules with the expected aliases', () {
      expect(
        ModuleRegistry.getMetadata(
          'MoonLifeSupportSystemProperties',
        ).defaultAlias,
        'MoonLifeSupportSystemModule',
      );
      expect(
        ModuleRegistry.getMetadata(
          'MoonLifeSupportSystemProperties',
        ).defaultSource,
        'LevelModules',
      );
      expect(
        ModuleRegistry.getMetadata(
          'LunarTerminalModuleProperties',
        ).defaultAlias,
        'LunarTerminalModule',
      );
      expect(
        ModuleRegistry.getMetadata(
          'LunarMineVeinModuleProperties',
        ).defaultAlias,
        'ExampleLunarMineVeins',
      );
      expect(
        ModuleRegistry.getMetadata(
          'RadiationMeteorModuleProperties',
        ).defaultAlias,
        'RadiationMeteorModule',
      );
    });

    test('keeps the requested module categories and ordering', () {
      final moduleKeys = ModuleRegistry.registry.keys.toList();
      final renai = moduleKeys.indexOf('RenaiModuleProperties');
      final veins = moduleKeys.indexOf('LunarMineVeinModuleProperties');
      final heian = moduleKeys.indexOf('HeianWindModuleProperties');
      final whale = moduleKeys.indexOf('SpermWhaleModuleProperties');
      final life = moduleKeys.indexOf('MoonLifeSupportSystemProperties');
      final terminal = moduleKeys.indexOf('LunarTerminalModuleProperties');
      final meteor = moduleKeys.indexOf('RadiationMeteorModuleProperties');

      expect(
        ModuleRegistry.getMetadata('LunarMineVeinModuleProperties').category,
        ModuleCategory.scene,
      );
      for (final objClass in [
        'MoonLifeSupportSystemProperties',
        'LunarTerminalModuleProperties',
        'RadiationMeteorModuleProperties',
      ]) {
        expect(
          ModuleRegistry.getMetadata(objClass).category,
          ModuleCategory.gimmick,
          reason: objClass,
        );
      }
      expect(veins, renai + 1);
      expect(whale, heian + 1);
      expect(life, whale + 1);
      expect(terminal, life + 1);
      expect(meteor, terminal + 1);

      expect(
        ObjectOrderRegistry.getPriority('LunarMineVeinModuleProperties'),
        ObjectOrderRegistry.getPriority('RenaiModuleProperties') + 1,
      );
      expect(
        ObjectOrderRegistry.getPriority('SpermWhaleModuleProperties'),
        ObjectOrderRegistry.getPriority('HeianWindModuleProperties') + 1,
      );
      expect(
        ObjectOrderRegistry.getPriority('MoonLifeSupportSystemProperties'),
        ObjectOrderRegistry.getPriority('SpermWhaleModuleProperties') + 1,
      );
      expect(
        ObjectOrderRegistry.getPriority('LunarTerminalModuleProperties'),
        ObjectOrderRegistry.getPriority('MoonLifeSupportSystemProperties') + 1,
      );
      expect(
        ObjectOrderRegistry.getPriority('RadiationMeteorModuleProperties'),
        ObjectOrderRegistry.getPriority('LunarTerminalModuleProperties') + 1,
      );
    });

    test(
      'uses Flutter list icons while keeping placement artwork available',
      () {
        final event = EventRegistry.getByObjClass(
          'SpawnRocketLandingWaveActionProps',
        );
        expect(event, isNotNull);
        expect(event!.defaultAlias, 'Rocket');
        expect(event.category, EventCategory.gridItemSpawn);
        expect(event.assetIconPath, isNull);
        expect(
          ModuleRegistry.getMetadata(
            'LunarMineVeinModuleProperties',
          ).assetIconPath,
          isNull,
        );
        expect(
          ModuleRegistry.getMetadata(
            'RadiationMeteorModuleProperties',
          ).assetIconPath,
          isNull,
        );

        for (final path in [
          'assets/images/griditems/lunar_mine_vein.webp',
          'assets/images/griditems/radiation_meteor_ore.webp',
          'assets/images/griditems/rocket_landing.webp',
        ]) {
          expect(File(path).existsSync(), isTrue, reason: path);
        }

        final events = EventRegistry.getAll();
        final shellIndex = events.indexWhere(
          (entry) => entry.defaultObjClass == 'ZombieAtlantisShellActionProps',
        );
        final rocketIndex = events.indexWhere(
          (entry) =>
              entry.defaultObjClass == 'SpawnRocketLandingWaveActionProps',
        );
        expect(rocketIndex, shellIndex + 1);
        expect(
          ObjectOrderRegistry.getPriority('SpawnRocketLandingWaveActionProps'),
          ObjectOrderRegistry.getPriority('ZombieAtlantisShellActionProps') + 1,
        );
      },
    );

    test('keeps the requested CollectorCooldown and position labels', () {
      expect(
        AppLocalizationsZh().lunarTerminalCollectorCooldown,
        '机器人部署冷却 (CollectorCooldown，单位：秒)',
      );
      expect(
        AppLocalizationsZh().positionPoolSpawnPositions,
        '候选位置池 (SpawnPositionsPool)',
      );
      expect(AppLocalizationsZh().radiationMeteorWave, '波次 (Wave，从0开始计数)');
      expect(
        AppLocalizationsZh().radiationMeteorHelpWave,
        contains('第1波降落填0，第2波降落填1'),
      );
    });

    test('keeps English and Russian rocket position labels localized', () {
      expect(
        AppLocalizationsEn().positionPoolSpawnPositions,
        'Position pool (SpawnPositionsPool)',
      );
      expect(
        AppLocalizationsRu().positionPoolSpawnPositions,
        'Пул позиций (SpawnPositionsPool)',
      );
    });
  });

  testWidgets('life support custom switch creates a CurrentLevel copy', (
    tester,
  ) async {
    final levelDef = LevelDefinitionData(
      modules: ['RTID(MoonLifeSupportSystemModule@LevelModules)'],
    );
    final levelFile = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: levelDef.toJson(),
        ),
      ],
    );
    String? toggledRtid;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MoonLifeSupportSystemScreen(
          rtid: 'RTID(MoonLifeSupportSystemModule@LevelModules)',
          levelFile: levelFile,
          levelDef: levelDef,
          onChanged: () {},
          onBack: () {},
          onRequestPlantSelection: (_, _) {},
          onModeToggled: (rtid) => toggledRtid = rtid,
        ),
      ),
    );

    expect(find.byType(Switch), findsOneWidget);
    expect(find.textContaining('InitialCapacity'), findsNothing);
    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(toggledRtid, 'RTID(MoonLifeSupportSystemModule@CurrentLevel)');
    expect(levelDef.modules, [
      'RTID(MoonLifeSupportSystemModule@CurrentLevel)',
    ]);
    final copy = levelFile.objects.singleWhere(
      (object) => object.objClass == 'MoonLifeSupportSystemProperties',
    );
    expect(copy.objData['InitialCapacity'], 10);
    expect(copy.objData['PlantImmunityList']['List'], contains('cosmoss'));
  });

  testWidgets('rocket Count is positive-only and writes both JSON fields', (
    tester,
  ) async {
    final event = PvzObject(
      aliases: const ['Rocket'],
      objClass: 'SpawnRocketLandingWaveActionProps',
      objData: const <String, dynamic>{
        'RocketPool': [
          {'Type': 'RTID(rocket_landing@GridItemTypes)', 'Count': 2},
        ],
        'SpawnPositionsPool': [
          {'mX': 0, 'mY': 0},
        ],
        'SpawnCount': 2,
        'SpawnInterval': 3,
        'DisplacePlants': false,
        'IgnoreGraveStone': true,
      },
    );
    final level = PvzLevelFile(objects: [event]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RocketLandingEventScreen(
          rtid: 'RTID(Rocket@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('rocketLandingPositionPreviewGrid')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Moon Rocket'), findsOneWidget);
    expect(find.text('rocket_landing'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is GridItemIcon && widget.typeName == 'rocket_landing',
      ),
      findsOneWidget,
    );
    expect(find.byType(SwitchListTile), findsNothing);
    final countField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Count',
    );
    expect(countField, findsOneWidget);

    await tester.enterText(countField, '0');
    await tester.pump();
    expect(tester.widget<TextField>(countField).controller!.text, '2');
    await tester.enterText(countField, '3.5');
    await tester.pump();
    expect(tester.widget<TextField>(countField).controller!.text, '2');

    await tester.enterText(countField, '4');
    await tester.pump();
    final json = Map<String, dynamic>.from(event.objData as Map);
    expect(json['SpawnCount'], 4);
    expect((json['RocketPool'] as List).single['Count'], 4);
  });

  testWidgets('Chinese rocket Count label moves above on a narrow layout', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(340, 900);
    addTearDown(tester.view.reset);
    final event = PvzObject(
      aliases: const ['RocketZh'],
      objClass: 'SpawnRocketLandingWaveActionProps',
      objData: SpawnRocketLandingWaveActionPropsData().toJson(),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RocketLandingEventScreen(
          rtid: 'RTID(RocketZh@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [event]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final countField = find.byKey(const ValueKey('rocketLandingCountField'));
    expect(countField, findsOneWidget);
    expect(tester.getSize(countField).width, greaterThanOrEqualTo(160));
    expect(tester.widget<TextField>(countField).decoration?.labelText, isNull);
    final externalLabel = find.text('数量 (Count)');
    expect(externalLabel, findsOneWidget);
    expect(
      tester.getRect(externalLabel).bottom,
      lessThanOrEqualTo(tester.getRect(countField).top),
    );
    expect(tester.takeException(), isNull);
  });

  test('level overview classifies rockets as grid items, not zombies', () {
    final rocketEvent = PvzObject(
      aliases: const ['Rocket'],
      objClass: 'SpawnRocketLandingWaveActionProps',
      objData: SpawnRocketLandingWaveActionPropsData().toJson(),
    );
    final obstacleEvent = PvzObject(
      aliases: const ['ObstacleEvent'],
      objClass: 'SpawnModernPortalsWaveActionProps',
      objData: const <String, dynamic>{'Type': 'RTID(cosmoss@GridItemTypes)'},
    );
    final waveManager = PvzObject(
      aliases: const ['WaveManager'],
      objClass: 'WaveManagerProperties',
      objData: WaveManagerData(
        waves: const [
          ['RTID(Rocket@CurrentLevel)', 'RTID(ObstacleEvent@CurrentLevel)'],
        ],
      ).toJson(),
    );
    final level = PvzLevelFile(
      objects: [rocketEvent, obstacleEvent, waveManager],
    );
    final parsed = LevelParser.parseLevel(level);

    final zombies = ZombieDiscovery.discoverZombies(level, parsed);
    final gridItems = GridItemDiscovery.discoverGridItems(level);

    expect(zombies, isNot(contains('rocket_landing')));
    expect(zombies, isNot(contains('cosmoss')));
    expect(gridItems, contains('rocket_landing'));
    expect(
      GridItemRepository.getIconPath('rocket_landing'),
      'assets/images/griditems/rocket_landing.webp',
    );
  });

  testWidgets('gravestone event shows canonical Egypt name and integer Count', (
    tester,
  ) async {
    final event = PvzObject(
      aliases: const ['GravestoneSpawn'],
      objClass: 'SpawnGravestonesWaveActionProps',
      objData: const <String, dynamic>{
        'GravestonePool': [
          {'Type': 'RTID(gravestone@GridItemTypes)', 'Count': 2},
        ],
        'SpawnPositionsPool': <dynamic>[],
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SpawnGraveStonesEventScreen(
          rtid: 'RTID(GravestoneSpawn@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [event]),
          onChanged: () {},
          onBack: () {},
          onRequestGridItemSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ancient Egypt tombstone'), findsOneWidget);
    expect(find.text('gravestone_egypt'), findsOneWidget);
    final countField = find.byType(TextFormField);
    expect(countField, findsOneWidget);
    await tester.enterText(countField, '0');
    await tester.pump();
    final editable = find.descendant(
      of: countField,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(editable).controller.text, '2');
  });

  testWidgets('new meteor groups map Group 1 and Group 2 to waves 0 and 1', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final module = PvzObject(
      aliases: const ['RadiationMeteorModule'],
      objClass: 'RadiationMeteorModuleProperties',
      objData: const <String, dynamic>{'SpawnSchedule': []},
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RadiationMeteorModuleScreen(
          rtid: 'RTID(RadiationMeteorModule@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [module]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final gridFinder = find.byType(GridOverridePlacementGrid);
    expect(find.byKey(const ValueKey('meteor-wave-0')), findsOneWidget);
    var grid = tester.widget<GridOverridePlacementGrid>(gridFinder);
    var rect = tester.getRect(gridFinder);
    await tester.tapAt(
      Offset(
        rect.left + rect.width / grid.gridCols / 2,
        rect.top + rect.height / grid.gridRows / 2,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('addGridOverrideWaveGroup')));
    await tester.pumpAndSettle();
    expect(find.text('Group 2'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('meteor-wave-1')), findsOneWidget);
    grid = tester.widget<GridOverridePlacementGrid>(gridFinder);
    rect = tester.getRect(gridFinder);
    await tester.tapAt(
      Offset(
        rect.left + rect.width / grid.gridCols / 2,
        rect.top + rect.height / grid.gridRows / 2,
      ),
    );
    await tester.pump();

    final schedule = (module.objData['SpawnSchedule'] as List)
        .where((entry) => entry['GridX'] == 0 && entry['GridY'] == 0)
        .map((entry) => entry['Wave'])
        .toList();
    expect(schedule, [0, 1]);
  });
}

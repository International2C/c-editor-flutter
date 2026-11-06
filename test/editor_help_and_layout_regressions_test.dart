import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/json_viewer_screen.dart';
import 'package:c_editor/screens/editor/events/dino_event_screen.dart';
import 'package:c_editor/screens/editor/events/frost_wind_event_screen.dart';
import 'package:c_editor/screens/editor/events/spawn_grave_stones_event_screen.dart';
import 'package:c_editor/screens/editor/events/storm_event_screen.dart';
import 'package:c_editor/screens/editor/modules/bowling_minigame_screen.dart';
import 'package:c_editor/screens/editor/modules/bomb_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/increased_cost_module_screen.dart';
import 'package:c_editor/screens/editor/modules/mechanism_plank_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/roof_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/seed_bank_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/tunnel_defend_module_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  test('roof lawn detection recognizes only RoofStageProperties', () {
    final levelDef = LevelDefinitionData(
      stageModule: 'RTID(TestStage@CurrentLevel)',
    );
    final roofLevel = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['TestStage'],
          objClass: 'RoofStageProperties',
          objData: const {},
        ),
      ],
    );
    final ordinaryLevel = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['TestStage'],
          objClass: 'StageModuleProperties',
          objData: const {},
        ),
      ],
    );

    expect(LevelParser.isRoofLawn(levelDef, roofLevel), isTrue);
    expect(LevelParser.isRoofLawn(levelDef, ordinaryLevel), isFalse);
  });

  test('storm zombies serialize level 0 by default', () {
    expect(StormZombieData(type: 'RTID(zombie@ZombieTypes)').toJson(), {
      'Type': 'RTID(zombie@ZombieTypes)',
      'Level': 0,
    });
    expect(
      StormZombieData.fromJson({'Type': 'RTID(zombie@ZombieTypes)'}).level,
      0,
    );
  });

  for (final testCase
      in <({Locale locale, String title, bool isEvent, String expected})>[
        (
          locale: const Locale('en'),
          title: 'Dino Summon',
          isEvent: true,
          expected: 'Dino Summon event',
        ),
        (
          locale: const Locale('en'),
          title: 'Manhole Pipeline',
          isEvent: false,
          expected: 'Manhole Pipeline module',
        ),
        (
          locale: const Locale('zh'),
          title: '事件类型：恐龙召唤',
          isEvent: true,
          expected: '恐龙召唤事件说明',
        ),
        (
          locale: const Locale('zh'),
          title: '事件：泡泡雨',
          isEvent: true,
          expected: '泡泡雨事件说明',
        ),
        (
          locale: const Locale('zh'),
          title: '复兴时代模块',
          isEvent: false,
          expected: '复兴时代模块说明',
        ),
      ]) {
    testWidgets('standardizes ${testCase.expected}', (tester) async {
      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showEditorHelpDialog(
                context,
                title: testCase.title,
                isEvent: testCase.isEvent,
                sections: const [
                  HelpSectionData(title: 'Overview', body: 'Body'),
                ],
              ),
              child: const Text('Open'),
            ),
          ),
          locale: testCase.locale,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text(testCase.expected), findsOneWidget);
      expect(
        tester.widget<Text>(find.text(testCase.expected)).textAlign,
        TextAlign.start,
      );
      expect(tester.widget<Text>(find.text('Body')).textAlign, TextAlign.start);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Seed Bank help uses five structured sections', (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        SeedBankPropertiesScreen(
          rtid: 'RTID(SeedBank@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
          onRequestPlantSelection:
              (
                _, {
                excludeIds,
                initialSelectedIds,
                blockRealmExclusiveInChooser = false,
                blockHiddenPlantsInChooser = false,
                allowDuplicateSelection = false,
              }) {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    for (final title in [
      '• Overview',
      '• Whitelist and blacklist',
      '• I, Zombie mode',
      '• Slot occupancy',
      '• Advanced gameplay',
    ]) {
      expect(find.descendant(of: dialog, matching: find.text(title)), findsOne);
    }
    expect(find.text('Seed Bank module'), findsOneWidget);
    final overviewTitle = tester.widget<Text>(find.text('• Overview'));
    expect(
      overviewTitle.style?.color,
      Theme.of(tester.element(dialog)).colorScheme.primary,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Seed Bank selection mode chips keep a gap when wrapped', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _localizedApp(
        SeedBankPropertiesScreen(
          rtid: 'RTID(SeedBank@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
          onRequestPlantSelection:
              (
                _, {
                excludeIds,
                initialSelectedIds,
                blockRealmExclusiveInChooser = false,
                blockHiddenPlantsInChooser = false,
                allowDuplicateSelection = false,
              }) {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pump();

    final chooser = find.byKey(const ValueKey('seedBankChooserModeChip'));
    final preset = find.byKey(const ValueKey('seedBankPresetModeChip'));
    expect(chooser, findsOneWidget);
    expect(preset, findsOneWidget);
    expect(
      tester.getTopLeft(preset).dy - tester.getBottomLeft(chooser).dy,
      greaterThanOrEqualTo(8),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Seed Bank reorder hint sits above the drag handle', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['SeedBank'],
          objClass: 'SeedBankProperties',
          objData: SeedBankData(presetPlantList: ['peashooter']).toJson(),
        ),
      ],
    );
    await tester.pumpWidget(
      _localizedApp(
        SeedBankPropertiesScreen(
          rtid: 'RTID(SeedBank@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          onRequestPlantSelection:
              (
                _, {
                excludeIds,
                initialSelectedIds,
                blockRealmExclusiveInChooser = false,
                blockHiddenPlantsInChooser = false,
                allowDuplicateSelection = false,
              }) {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pump();

    final hint = find.byKey(const ValueKey('presetPlantListReorderHint'));
    final handle = find.byIcon(Icons.drag_indicator);
    expect(hint, findsOneWidget);
    expect((tester.widget<Text>(hint).data ?? '').endsWith('.'), isFalse);
    expect(
      tester.getBottomLeft(hint).dy,
      lessThan(tester.getTopLeft(handle).dy),
    );
    expect(
      find.textContaining('Plants available at start Long press'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Seed Bank preset rows grow instead of overlapping the next list',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 1000);
      addTearDown(tester.view.reset);

      const longPlantId =
          'a_very_long_preset_plant_identifier_that_needs_multiple_lines';
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: ['SeedBank'],
            objClass: 'SeedBankProperties',
            objData: SeedBankData(presetPlantList: [longPlantId]).toJson(),
          ),
        ],
      );
      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(textScaler: const TextScaler.linear(1.6)),
                child: SeedBankPropertiesScreen(
                  rtid: 'RTID(SeedBank@CurrentLevel)',
                  levelFile: level,
                  onChanged: () {},
                  onBack: () {},
                  onRequestPlantSelection:
                      (
                        _, {
                        excludeIds,
                        initialSelectedIds,
                        blockRealmExclusiveInChooser = false,
                        blockHiddenPlantsInChooser = false,
                        allowDuplicateSelection = false,
                      }) {},
                  onRequestZombieSelection: (_) {},
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final presetRow = find.byKey(
        const ValueKey('preset-resource-0-$longPlantId'),
      );
      final whiteListHeading = find.text('White list (WhiteList)');
      expect(presetRow, findsOneWidget);
      expect(whiteListHeading, findsOneWidget);
      expect(
        tester.getRect(presetRow).bottom,
        lessThanOrEqualTo(tester.getRect(whiteListHeading).top),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Dino summon help omits the dinosaur type section', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        DinoEventScreen(
          rtid: 'RTID(DinoTimeEvent@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(find.text('Dino Summon event'), findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('• Dinosaur type')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bowling uses a stepper and a red foul-line preview', (
    tester,
  ) async {
    final level = PvzLevelFile(objects: []);
    await tester.pumpWidget(
      _localizedApp(
        BowlingMinigameScreen(
          rtid: 'RTID(BowlingMinigame@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    final stepper = find.byKey(const ValueKey('bowlingFoulLineStepper'));
    expect(stepper, findsOneWidget);
    expect(
      find.byKey(const ValueKey('bowlingFoulLinePreviewLine')),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(of: stepper, matching: find.byIcon(Icons.add)),
    );
    await tester.pump();

    expect((level.objects.single.objData as Map)['BowlingFoulLine'], 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Powder-keg rows use steppers and share the overview preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final initialObjData = <String, dynamic>{
      'FlameSpeed': 0.25,
      'FuseLengths': <dynamic>[8.0, 8.0, 8, 8, 8],
    };
    final cubit = EditorCubit(fileName: 'bomb.json', filePath: '')
      ..applyLevelFile(
        PvzLevelFile(
          objects: [
            PvzObject(
              aliases: const ['Bombs'],
              objClass: 'BombProperties',
              objData: initialObjData,
            ),
          ],
        ),
        markDirty: false,
      );
    addTearDown(cubit.close);
    final level = cubit.state.levelFile!;

    await tester.pumpWidget(
      _localizedApp(
        BombPropertiesScreen(
          rtid: 'RTID(Bombs@CurrentLevel)',
          levelFile: level,
          onChanged: cubit.markDirty,
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    final flameSpeedField = tester.widget<TextField>(
      find.byKey(const ValueKey('bombFlameSpeedField')),
    );
    expect(flameSpeedField.decoration?.labelText, isNull);
    expect(find.text('Fuse Burn Speed (FlameSpeed)'), findsOneWidget);
    expect(find.text('Fuse Lengths (FuseLengths)'), findsOneWidget);
    expect(find.text('Fuse Length'), findsNothing);

    final firstStepper = find.byKey(const ValueKey('bombFuseLengthStepper-0'));
    expect(firstStepper, findsOneWidget);
    expect(
      find.byKey(const ValueKey('bombFuseLengthPreviewGrid')),
      findsOneWidget,
    );
    final previewGrid = find.descendant(
      of: find.byKey(const ValueKey('bombFuseLengthPreviewGrid')),
      matching: find.byType(GridView),
    );
    expect(previewGrid, findsOneWidget);
    expect(
      tester.getSize(previewGrid).width,
      lessThanOrEqualTo(
        EditorItemCardLayout.gridPreviewMaxWidth(tester.element(firstStepper)),
      ),
    );
    expect(
      find.byKey(const ValueKey('explosiveBarrelFuse-0-7')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('explosiveBarrelFuse-1-7')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('explosiveBarrelFuse-0-8')), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('bombFuseLengthPreviewGrid')),
    );
    await tester.pumpAndSettle();
    for (var row = 0; row < 5; row++) {
      expect(
        find.byKey(ValueKey('explosiveBarrelFuse-$row-0')),
        findsOneWidget,
      );
    }
    expect(cubit.state.hasChanges, isFalse);

    await tester.ensureVisible(firstStepper);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bombFuseLengthIncrease-0')));
    await tester.pump();

    final module = level.objects.firstWhere(
      (object) => object.objClass == 'BombProperties',
    );
    expect((module.objData as Map)['FuseLengths'].first, '9');
    expect(cubit.state.hasChanges, isTrue);
    expect(
      find.byKey(const ValueKey('explosiveBarrelFuse-0-8')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('bombFuseLengthDecrease-0')));
    await tester.pump();
    expect(
      (module.objData as Map)['FuseLengths'],
      initialObjData['FuseLengths'],
    );
    expect(cubit.state.hasChanges, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Connected minecart uses gray steppers above its notice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['MechanismPlank'],
          objClass: 'MechanismPlankProperties',
          objData: {
            'MechanismGearsRect': {'mHeight': 5, 'mWidth': 4, 'mX': 0, 'mY': 0},
            'MechanismPlankRows': ['0', '4'],
          },
        ),
      ],
    );

    await tester.pumpWidget(
      _localizedApp(
        MechanismPlankPropertiesScreen(
          rtid: 'RTID(MechanismPlank@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    for (final key in const [
      ValueKey('mechanismPlankStartColumnStepper'),
      ValueKey('mechanismPlankTrackLengthStepper'),
    ]) {
      final stepper = find.byKey(key);
      expect(stepper, findsOneWidget);
      final expectedColor = Theme.of(
        tester.element(stepper),
      ).colorScheme.surfaceContainerHighest;
      final grayContainers = tester
          .widgetList<Container>(
            find.descendant(of: stepper, matching: find.byType(Container)),
          )
          .where(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).color == expectedColor,
          );
      expect(grayContainers, isNotEmpty);
    }

    final preview = find.byKey(const ValueKey('mechanismPlankPreviewGrid'));
    final notice = find.byKey(const ValueKey('mechanismPlankEditNoticeCard'));
    expect(preview, findsOneWidget);
    expect(notice, findsOneWidget);
    expect(
      tester.getTopLeft(preview).dy,
      lessThan(tester.getTopLeft(notice).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chinese Bowling help uses the beach bowling title', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        BowlingMinigameScreen(
          rtid: 'RTID(BowlingMinigame@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
        locale: const Locale('zh'),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('沙滩保龄球模块说明'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Inflation module separates parameters and limitation notice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _localizedApp(
        IncreasedCostModuleScreen(
          rtid: 'RTID(IncreasedCostModule@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
        locale: const Locale('zh'),
      ),
    );
    await tester.pump();

    final parameters = find.byKey(const ValueKey('inflationParametersCard'));
    final limitation = find.byKey(const ValueKey('inflationLimitationCard'));
    expect(parameters, findsOneWidget);
    expect(limitation, findsOneWidget);
    expect(
      find.descendant(of: parameters, matching: find.text('膨胀参数')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: parameters,
        matching: find.text('最大增长次数 (MaxIncreasedCount)'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: parameters,
        matching: find.textContaining('目前游戏只能读取默认值10次'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: limitation,
        matching: find.text('由于模块本身的问题，目前更改最大增长次数设置暂时无效，游戏只能读取默认值10次。'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Inflation help contains overview and parameter description', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        IncreasedCostModuleScreen(
          rtid: 'RTID(IncreasedCostModule@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
        locale: const Locale('zh'),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('通货膨胀模块说明'), findsOneWidget);
    expect(find.text('• 简要介绍'), findsOneWidget);
    expect(find.text('• 参数说明'), findsOneWidget);
    expect(find.textContaining('每次种植植物后，该植物的阳光消耗会增加'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Underwater Bowling offsets the range and preview by one', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: LevelDefinitionData(
            stageModule: 'RTID(DeepseaStage@CurrentLevel)',
          ).toJson(),
        ),
        PvzObject(
          aliases: ['DeepseaStage'],
          objClass: 'DeepseaStageProperties',
          objData: <String, dynamic>{},
        ),
      ],
    );
    await tester.pumpWidget(
      _localizedApp(
        BowlingMinigameScreen(
          rtid: 'RTID(BowlingMinigame@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    final stepper = find.byKey(const ValueKey('bowlingFoulLineStepper'));
    final remove = find.descendant(
      of: stepper,
      matching: find.byIcon(Icons.remove),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(remove);
      await tester.pump();
    }

    final module = level.objects.firstWhere(
      (object) => object.objClass == 'BowlingMinigameProperties',
    );
    expect((module.objData as Map)['BowlingFoulLine'], 0);
    final grid = find.byKey(const ValueKey('bowlingFoulLinePreviewGrid'));
    final line = find.byKey(const ValueKey('bowlingFoulLinePreviewLine'));
    expect(
      tester.getCenter(line).dx,
      closeTo(
        tester.getTopLeft(grid).dx + tester.getSize(grid).width / 10,
        0.1,
      ),
    );

    await tester.tap(remove);
    await tester.pump();
    expect((module.objData as Map)['BowlingFoulLine'], -1);
    expect(
      tester.getTopLeft(line).dx,
      closeTo(tester.getTopLeft(grid).dx, 0.1),
    );

    for (var i = 0; i < 10; i++) {
      await tester.tap(
        find.descendant(of: stepper, matching: find.byIcon(Icons.add)),
      );
      await tester.pump();
    }
    expect((module.objData as Map)['BowlingFoulLine'], 9);
    final addButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.descendant(of: stepper, matching: find.byIcon(Icons.add)),
        matching: find.byType(IconButton),
      ),
    );
    expect(addButton.onPressed, isNull);

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.textContaining('automatically adds 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Storm title describes carried zombies and aligns with section', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['Storm'],
          objClass: 'StormZombieSpawnerProps',
          objData: StormZombieSpawnerPropsData(
            zombies: [
              StormZombieData(type: 'RTID(zombie@ZombieTypes)', level: 0),
            ],
          ).toJson(),
        ),
      ],
    );

    await tester.pumpWidget(
      _localizedApp(
        StormEventScreen(
          rtid: 'RTID(Storm@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
        locale: const Locale('zh'),
      ),
    );
    await tester.pump();

    final sectionTitle = find.text('生成参数');
    final zombieTitle = find.text('携带的僵尸（共1个）');
    expect(sectionTitle, findsOneWidget);
    expect(zombieTitle, findsOneWidget);
    expect(
      tester.getTopLeft(zombieTitle).dx,
      closeTo(tester.getTopLeft(sectionTitle).dx, 0.1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('gravestone position preview uses compact mobile grid sizing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _localizedApp(
        SpawnGraveStonesEventScreen(
          rtid: 'RTID(Gravestones@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
          onRequestGridItemSelection: (_) {},
        ),
      ),
    );
    await tester.pump();

    final grid = find.byKey(
      const ValueKey('spawnGravestonesPositionPreviewGrid'),
    );
    expect(grid, findsOneWidget);
    final size = tester.getSize(grid);
    expect(size.width, lessThanOrEqualTo(252.1));
    expect(size.width / size.height, closeTo(9 / 5, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Frost wind rows and direction controls stay grouped', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        FrostWindEventScreen(
          rtid: 'RTID(FrostWind@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.byKey(const ValueKey('frostWindRowStepper-0')), findsOneWidget);
    final direction = find.byKey(const ValueKey('frostWindDirection-0'));
    expect(direction, findsOneWidget);
    expect(
      find.descendant(of: direction, matching: find.text('Direction')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tunnel layout preview is horizontally centered', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _localizedApp(
        TunnelDefendModuleScreen(
          rtid: 'RTID(SouDaCheTunnelDefendDefault@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    final center = find.byKey(const ValueKey('tunnelLayoutPreviewCenter'));
    final preview = find
        .descendant(of: center, matching: find.byType(AspectRatio))
        .first;
    expect(tester.getCenter(preview).dx, closeTo(500, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'roof pots use steppers, warn on non-roof lawns, and fill narrow previews',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final levelDef = LevelDefinitionData(
        stageModule: 'RTID(TestStage@CurrentLevel)',
      );
      final roofModule = PvzObject(
        aliases: const ['RoofProps'],
        objClass: 'RoofProperties',
        objData: RoofPropertiesData().toJson(),
      );
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['TestStage'],
            objClass: 'StageModuleProperties',
            objData: const {},
          ),
          roofModule,
        ],
      );

      await tester.pumpWidget(
        _localizedApp(
          Theme(
            data: ThemeData(platform: TargetPlatform.windows),
            child: RoofPropertiesScreen(
              rtid: 'RTID(RoofProps@CurrentLevel)',
              levelFile: level,
              levelDef: levelDef,
              onChanged: () {},
              onBack: () {},
            ),
          ),
          locale: const Locale('zh'),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('roofLawnMismatchWarning')),
        findsOneWidget,
      );
      expect(find.textContaining('当前地图类型并非屋顶地图'), findsOneWidget);
      final startStepper = find.byKey(
        const ValueKey('roofFlowerPotStartColumnStepper'),
      );
      expect(startStepper, findsOneWidget);
      expect(
        find.descendant(of: startStepper, matching: find.byType(TextField)),
        findsNothing,
      );
      await tester.tap(
        find.descendant(
          of: startStepper,
          matching: find.byKey(const ValueKey('increase')),
        ),
      );
      await tester.pump();
      expect(
        RoofPropertiesData.fromJson(
          Map<String, dynamic>.from(roofModule.objData as Map),
        ).flowerPotStartColumn,
        1,
      );

      final preview = find.byKey(const ValueKey('roofFlowerPotPreviewGrid'));
      expect(tester.getSize(preview).width, greaterThanOrEqualTo(280));
      expect(tester.takeException(), isNull);
    },
  );

  for (final alias in ['TunnelDefend', 'SouDaCheTunnelDefendDefault']) {
    testWidgets('$alias preview fills narrow desktop width', (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _localizedApp(
          Theme(
            data: ThemeData(platform: TargetPlatform.windows),
            child: TunnelDefendModuleScreen(
              rtid: 'RTID($alias@CurrentLevel)',
              levelFile: PvzLevelFile(objects: []),
              onChanged: () {},
              onBack: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final center = find.byKey(const ValueKey('tunnelLayoutPreviewCenter'));
      final preview = find
          .descendant(of: center, matching: find.byType(AspectRatio))
          .first;
      expect(tester.getSize(preview).width, greaterThanOrEqualTo(320));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tunnel settings fields do not use gray fills', (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        TunnelDefendModuleScreen(
          rtid: 'RTID(TunnelDefend@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    final preset = tester.widget<InputDecorator>(
      find.byKey(const ValueKey('tunnelTileStylePresetField')),
    );
    final interval = tester.widget<TextField>(
      find.byKey(const ValueKey('tunnelSequenceIntervalField')),
    );
    expect(preset.decoration.filled, isFalse);
    expect(interval.decoration?.filled, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving JSON immediately refreshes the plain-text view', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['TestObject'],
          objClass: 'TestClass',
          objData: {'Value': 'before'},
        ),
      ],
    );
    await tester.pumpWidget(
      _localizedApp(
        JsonViewerScreen(
          fileName: 'test.json',
          filePath: 'test.json',
          levelFile: level,
          onBack: () {},
          saveLevel: (_, _) async {},
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('before'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final editor = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.controller?.text.contains('"objects"') == true,
    );
    expect(editor, findsOneWidget);
    await tester.enterText(
      editor,
      '{"objects":[{"aliases":["TestObject"],"objclass":"TestClass","objdata":{"Value":"after"}}],"version":1}',
    );
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(find.textContaining('after'), findsOneWidget);
    expect(find.textContaining('before'), findsNothing);
    AppMessage.hide();
    expect(tester.takeException(), isNull);
  });
}

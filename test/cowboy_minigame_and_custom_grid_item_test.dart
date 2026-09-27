import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/cowboy_minigame_utils.dart';
import 'package:c_editor/data/grid_item_discovery.dart';
import 'package:c_editor/data/level_validator.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/screens/level_overview/level_overview_widgets.dart'
    as level_preview;
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/conveyor_seedbank_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/initial_grid_item_entry_screen.dart';
import 'package:c_editor/screens/editor/modules/protect_grid_item_challenge_screen.dart';
import 'package:c_editor/screens/select/grid_item_selection_screen.dart';
import 'package:c_editor/screens/select/module_selection_screen.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PvzObject _memoPropertySheet() => PvzObject(
  aliases: ['GridItemGravestoneDefaultMemo'],
  objClass: 'GridItemGravestonePropertySheet',
  objData: {
    'Hitpoints': 700,
    'GridItemLevelStats': [
      {'HitPointsLevel': 1},
      {'HitPointsLevel': 2},
    ],
  },
);

GridItemInfo _memoPreset() => GridItemInfo(
  typeName: 'gravestone_tutorial',
  gameTypeName: 'gravestone_egypt_memo',
  gridItemTypeAlias: 'gravestone_memo',
  exclusivePresetGroup: 'gravestone_egypt_memo',
  category: GridItemCategory.scene,
  icon: 'gravestone_tutorial.webp',
  source: GridItemSource.custom,
  companionObjects: [_memoPropertySheet()],
);

GridItemInfo _armrackPreset() => const GridItemInfo(
  typeName: 'armrack',
  category: GridItemCategory.scene,
  source: GridItemSource.custom,
);

PvzLevelFile _levelWithModernGravestoneResourceGroup([
  List<PvzObject> objects = const [],
]) => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: const ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        stageModule: 'RTID(TestModernStage@CurrentLevel)',
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['TestModernStage'],
      objClass: 'ModernStageProperties',
      objData: const {
        'ResourceGroupNames': ['Modern_Gravestone'],
      },
    ),
    ...objects,
  ],
);

Widget _localizedApp(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  setUp(GridItemRepository.staticItems.clear);
  tearDown(GridItemRepository.staticItems.clear);

  test('Not OK Corral is ordered between Last Stand and Bombs', () {
    final modules = ModuleRegistry.getAllModules();
    final lastStand = modules.indexWhere(
      (module) => module.objClass == 'LastStandMinigameProperties',
    );
    final cowboy = modules.indexWhere(
      (module) => module.objClass == CowboyMinigameUtils.moduleObjClass,
    );
    final bombs = modules.indexWhere(
      (module) => module.objClass == 'BombProperties',
    );

    expect(cowboy, lastStand + 1);
    expect(bombs, cowboy + 1);
    expect(modules[cowboy].category, ModuleCategory.mode);
  });

  test('Chinese module description emphasizes planting before the wave', () {
    final arb =
        jsonDecode(File('assets/l10n/app_zh.arb').readAsStringSync())
            as Map<String, dynamic>;
    expect(arb['moduleDesc_CowboyMinigameProperties'], '每种植一个传送带植物，才开始一波僵尸进攻');
    expect(
      arb['cowboyMinigameBeginStringHint'],
      '添加围栏之战模块后，会自动在传送带模块中启用“手动生成卡片”开关。',
    );
    expect(
      arb['cowboyMinigameHelpBeginStringBody'] as String,
      isNot(contains('不显示文本')),
    );
  });

  testWidgets('Not OK Corral does not require the standard intro module', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: LevelDefinitionData(
            modules: const ['RTID(CowboyMinigame@CurrentLevel)'],
          ).toJson(),
        ),
        PvzObject(
          aliases: const ['CowboyMinigame'],
          objClass: CowboyMinigameUtils.moduleObjClass,
          objData: const <String, dynamic>{},
        ),
      ],
    );
    late List<ValidationIssue> issues;

    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) {
            issues = LevelValidator.validate(context, level);
            return const SizedBox.shrink();
          },
        ),
        locale: const Locale('zh'),
      ),
    );
    await tester.pump();

    final missing = issues.singleWhere((issue) => issue.title == '缺失模块');
    expect(missing.bulletPoints, isNot(contains('转场动画')));
  });

  test('Cowboy data matches both official reference shapes', () {
    final challenge = CowboyMinigamePropertiesData.fromJson({
      'BeginString': CowboyMinigamePropertiesData.defaultBeginString,
    });
    final pvz1 = CowboyMinigamePropertiesData.fromJson({
      'BeginString': '',
      'ShowTutorial': true,
    });

    expect(challenge.beginString, '[COWBOY_MINIGAME_TUTORIAL_1]');
    expect(challenge.showTutorial, isFalse);
    expect(pvz1.beginString, isEmpty);
    expect(pvz1.showTutorial, isTrue);
    expect(pvz1.toJson(), {'BeginString': '', 'ShowTutorial': true});
  });

  test('enabling Not OK Corral updates conveyor without losing fields', () {
    final conveyor = PvzObject(
      aliases: ['Conveyor'],
      objClass: CowboyMinigameUtils.conveyorObjClass,
      objData: {
        'InitialPlantList': [
          {'PlantType': 'peashooter'},
        ],
        'SpeedConditions': [
          {'MaxPackets': 0, 'Speed': 100},
        ],
      },
    );
    final level = PvzLevelFile(objects: [conveyor]);

    expect(CowboyMinigameUtils.enableManualPacketSpawning(level), isTrue);
    expect((conveyor.objData as Map)['ManualPacketSpawning'], isTrue);
    expect((conveyor.objData as Map)['InitialPlantList'], isNotEmpty);
    expect(CowboyMinigameUtils.enableManualPacketSpawning(level), isFalse);

    expect(CowboyMinigameUtils.removeManualPacketSpawning(level), isTrue);
    expect(conveyor.objData, isNot(contains('ManualPacketSpawning')));
    expect((conveyor.objData as Map)['InitialPlantList'], isNotEmpty);
    expect(CowboyMinigameUtils.removeManualPacketSpawning(level), isFalse);
  });

  testWidgets('conveyor keeps the automatic field without exposing a switch', (
    tester,
  ) async {
    final conveyor = PvzObject(
      aliases: ['Conveyor'],
      objClass: CowboyMinigameUtils.conveyorObjClass,
      objData: {
        'InitialPlantList': <dynamic>[],
        'DropDelayConditions': <dynamic>[],
        'SpeedConditions': <dynamic>[],
        'ManualPacketSpawning': true,
      },
    );
    final level = PvzLevelFile(objects: [conveyor]);

    await tester.pumpWidget(
      _localizedApp(
        ConveyorSeedBankPropertiesScreen(
          rtid: 'RTID(Conveyor@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          onRequestPlantSelection: (_) {},
          onRequestToolSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Manual packet spawning'), findsNothing);
    expect(conveyor.objData['ManualPacketSpawning'], isTrue);
  });

  test('custom grid item recognition requires an exact preset object', () {
    GridItemRepository.staticItems.add(_memoPreset());
    final level = PvzLevelFile(objects: []);

    expect(
      GridItemRepository.isRecognizedCustomGridItem(
        'gravestone_tutorial',
        level,
      ),
      isFalse,
    );
    expect(
      GridItemRepository.ensureCustomGridItemInLevel(
        'gravestone_tutorial',
        level,
      ),
      isTrue,
    );
    expect(level.objects, hasLength(1));
    expect(
      GridItemRepository.isValidForLevel('gravestone_egypt_memo', level),
      isTrue,
    );
    expect(
      GridItemRepository.buildGridItemTypeRtid('gravestone_egypt_memo', level),
      'RTID(gravestone_memo@GridItemTypes)',
    );
    expect(
      GridItemRepository.buildGridItemTypeRtid('gravestone_tutorial', level),
      'RTID(gravestone_memo@GridItemTypes)',
    );
    expect(
      GridItemRepository.getByTypeName('gravestone_memo')?.actualTypeName,
      'gravestone_egypt_memo',
    );
    expect(
      GridItemRepository.toGameTypeName('gravestone_tutorial'),
      'gravestone_egypt_memo',
    );

    (level.objects.single.objData as Map)['Hitpoints'] = 701;
    expect(
      GridItemRepository.isValidForLevel('gravestone_egypt_memo', level),
      isFalse,
    );
  });

  test('custom tombstone preset can replace conflicting properties', () {
    GridItemRepository.staticItems.add(_memoPreset());
    final conflictingSheet = _memoPropertySheet();
    (conflictingSheet.objData as Map)['Hitpoints'] = 701;
    final placement = PvzObject(
      aliases: ['InitialGridItems'],
      objClass: 'InitialGridItemProperties',
      objData: {
        'InitialGridItemPlacements': [
          {'GridX': 2, 'GridY': 1, 'TypeName': 'gravestone_egypt_memo'},
        ],
      },
    );
    final level = PvzLevelFile(objects: [conflictingSheet, placement]);

    expect(
      GridItemRepository.hasConflictingExclusivePreset(
        'gravestone_tutorial',
        level,
      ),
      isTrue,
    );
    expect(
      GridItemRepository.displayTypeNameForLevel(
        'gravestone_egypt_memo',
        level,
      ),
      isNull,
    );
    expect(
      GridItemRepository.replaceExclusivePreset('gravestone_tutorial', level),
      isTrue,
    );
    expect(
      GridItemRepository.displayTypeNameForLevel(
        'gravestone_egypt_memo',
        level,
      ),
      'gravestone_egypt_memo',
    );
    final replacedSheet = level.objects.singleWhere(
      (object) =>
          object.aliases?.contains('GridItemGravestoneDefaultMemo') == true,
    );
    expect((replacedSheet.objData as Map)['Hitpoints'], 700);
    expect(level.objects, contains(placement));
  });

  test('level overview uses the tombstone preset display codename', () {
    GridItemRepository.staticItems.add(_memoPreset());
    final level = PvzLevelFile(
      objects: [
        _memoPropertySheet(),
        PvzObject(
          aliases: ['InitialGridItems'],
          objClass: 'InitialGridItemProperties',
          objData: {
            'InitialGridItemPlacements': [
              {'GridX': 2, 'GridY': 1, 'TypeName': 'gravestone_egypt_memo'},
            ],
          },
        ),
      ],
    );

    expect(GridItemDiscovery.discoverGridItems(level), {
      'gravestone_egypt_memo',
    });
  });

  test('random weapon stand uses the same strict preset recognition', () {
    final template = PvzObject(
      aliases: ['armrack'],
      objClass: 'GridItemType',
      objData: {
        'TypeName': 'armrack',
        'GridItemClass': 'GridItemArmrack',
        'Properties': 'RTID(GridItemArmrackDefault@PropertySheets)',
      },
    );
    GridItemRepository.staticItems.add(
      GridItemInfo(
        typeName: 'armrack',
        category: GridItemCategory.scene,
        source: GridItemSource.custom,
        gridItemType: template,
      ),
    );
    final level = PvzLevelFile(
      objects: [
        PvzObject.fromJson(
          jsonDecode(jsonEncode(template.toJson())) as Map<String, dynamic>,
        ),
      ],
    );

    expect(GridItemRepository.isValidForLevel('armrack', level), isTrue);
    (level.objects.single.objData as Map)['GridItemClass'] = 'WrongClass';
    expect(GridItemRepository.isValidForLevel('armrack', level), isFalse);
  });

  testWidgets('missing conveyor greys the module and opens dependency prompt', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(const ModuleSelectionScreen(existingObjClasses: {})),
    );
    await tester.enterText(find.byType(TextField).first, 'Not OK Corral');
    await tester.pumpAndSettle();

    final title = find.text('Not OK Corral').first;
    expect(title, findsOneWidget);
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: title, matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, 0.6);

    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(
      find.text('To select this module, add the "Conveyor Belt" module first.'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('custom grid item card has a green badge and adds its preset', (
    tester,
  ) async {
    GridItemRepository.staticItems.add(_memoPreset());
    final level = _levelWithModernGravestoneResourceGroup();
    String? selected;

    await tester.pumpWidget(
      _localizedApp(
        GridItemSelectionScreen(
          filterMode: GridItemFilterMode.all,
          levelFile: level,
          onGridItemSelected: (value) => selected = value,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CustomResourceBadge), findsOneWidget);
    final badge = tester.widget<CustomResourceBadge>(
      find.byType(CustomResourceBadge),
    );
    expect(badge.color, const Color(0xFF2E7D32));

    await tester.tap(find.text('gravestone_egypt_memo').first);
    await tester.pump();
    expect(selected, 'gravestone_egypt_memo');
    expect(
      level.objects
          .singleWhere(
            (object) =>
                object.aliases?.contains('GridItemGravestoneDefaultMemo') ==
                true,
          )
          .aliases,
      ['GridItemGravestoneDefaultMemo'],
    );
    expect(
      _containsExactString(level.toJson(), 'gravestone_tutorial'),
      isFalse,
    );
  });

  testWidgets('unknown custom grid item keeps its codename as the card title', (
    tester,
  ) async {
    GridItemRepository.staticItems.add(_memoPreset());
    final conflictingSheet = _memoPropertySheet();
    conflictingSheet.objData['Hitpoints'] = 701;
    final level = PvzLevelFile(
      objects: [
        conflictingSheet,
        PvzObject(
          aliases: ['InitialGridItems'],
          objClass: 'InitialGridItemProperties',
          objData: {
            'InitialGridItemPlacements': [
              {'GridX': 0, 'GridY': 0, 'TypeName': 'gravestone_egypt_memo'},
            ],
          },
        ),
      ],
    );

    await tester.pumpWidget(
      _localizedApp(
        InitialGridItemEntryScreen(
          rtid: 'RTID(InitialGridItems@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
        locale: const Locale('zh'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('gravestone_egypt_memo'), findsOneWidget);
    expect(find.text('未知'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is GridItemIcon && widget.typeName == '__unknown__',
      ),
      findsWidgets,
    );
  });

  testWidgets(
    'Chinese property labels use ASCII parentheses around codenames',
    (tester) async {
      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) =>
                Text(localizedPropertyLabel(context, '显示教程对话', 'ShowTutorial')),
          ),
          locale: const Locale('zh'),
        ),
      );

      expect(find.text('显示教程对话 (ShowTutorial)'), findsOneWidget);
      expect(find.text('显示教程对话（ShowTutorial）'), findsNothing);
    },
  );

  testWidgets(
    'custom grid item badge is limited to the list beside the placement grid',
    (tester) async {
      GridItemRepository.staticItems.add(_memoPreset());
      final initialGridItems = PvzObject(
        aliases: ['InitialGridItems'],
        objClass: 'InitialGridItemProperties',
        objData: {
          'InitialGridItemPlacements': [
            {'GridX': 0, 'GridY': 0, 'TypeName': 'gravestone_egypt_memo'},
          ],
        },
      );
      final level = PvzLevelFile(
        objects: [_memoPropertySheet(), initialGridItems],
      );

      await tester.pumpWidget(
        _localizedApp(
          InitialGridItemEntryScreen(
            rtid: 'RTID(InitialGridItems@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GridItemIcon), findsWidgets);
      expect(find.byType(CustomResourceBadge), findsOneWidget);
    },
  );

  testWidgets(
    'level overview badges preset list icons but not concrete grid icons',
    (tester) async {
      GridItemRepository.staticItems.add(_memoPreset());

      await tester.pumpWidget(
        _localizedApp(
          const Column(
            children: [
              level_preview.GridItemIcon(id: 'gravestone_egypt_memo', size: 40),
              level_preview.GridItemIcon(
                id: 'gravestone_egypt_memo',
                size: 40,
                isGrid: true,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomResourceBadge), findsOneWidget);
    },
  );

  testWidgets(
    'protect-item selection keeps the preset badge and module prompt',
    (tester) async {
      GridItemRepository.staticItems.add(_armrackPreset());
      final protect = PvzObject(
        aliases: ['ProtectGridItems'],
        objClass: 'ProtectTheGridItemChallengeProperties',
        objData: ProtectTheGridItemChallengePropertiesData().toJson(),
      );
      final level = PvzLevelFile(objects: [protect]);
      String? addedModule;

      await tester.pumpWidget(
        _localizedApp(
          ProtectGridItemChallengeScreen(
            rtid: 'RTID(ProtectGridItems@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
            onAddModule: (objClass) => addedModule = objClass,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.byType(CustomResourceBadge), findsOneWidget);

      await tester.tap(find.text('armrack').first);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(addedModule, isNull);

      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();
      expect(addedModule, 'ArmrackProperties');
      expect(find.byType(CustomResourceBadge), findsOneWidget);
    },
  );

  testWidgets('conflicting custom tombstone asks before replacing it', (
    tester,
  ) async {
    GridItemRepository.staticItems.add(_memoPreset());
    final conflictingSheet = _memoPropertySheet();
    (conflictingSheet.objData as Map)['Hitpoints'] = 701;
    final level = _levelWithModernGravestoneResourceGroup([conflictingSheet]);
    String? selected;

    await tester.pumpWidget(
      _localizedApp(
        GridItemSelectionScreen(
          filterMode: GridItemFilterMode.all,
          levelFile: level,
          onGridItemSelected: (value) => selected = value,
          onBack: () {},
        ),
        locale: const Locale('zh'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('gravestone_egypt_memo').first);
    await tester.pumpAndSettle();
    expect(
      find.text('一关中只能添加一种自定义墓碑。是否将关卡中原本的自定义墓碑替换为「gravestone_egypt_memo」？'),
      findsOneWidget,
    );
    expect(selected, isNull);

    await tester.tap(find.text('替换'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(selected, 'gravestone_egypt_memo');
    final replacedSheet = level.objects.singleWhere(
      (object) =>
          object.aliases?.contains('GridItemGravestoneDefaultMemo') == true,
    );
    expect((replacedSheet.objData as Map)['Hitpoints'], 700);
    expect(
      _containsExactString(level.toJson(), 'gravestone_tutorial'),
      isFalse,
    );
  });

  testWidgets(
    'missing Modern_Gravestone prompt takes priority over replacement',
    (tester) async {
      GridItemRepository.staticItems.add(_memoPreset());
      final conflictingSheet = _memoPropertySheet();
      conflictingSheet.objData['Hitpoints'] = 701;
      final level = PvzLevelFile(objects: [conflictingSheet]);
      var openedCustomStages = false;

      await tester.pumpWidget(
        _localizedApp(
          GridItemSelectionScreen(
            filterMode: GridItemFilterMode.all,
            levelFile: level,
            onGridItemSelected: (_) {},
            onBack: () {},
            onOpenCustomStageSelection: () async {
              openedCustomStages = true;
            },
          ),
          locale: const Locale('zh'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('gravestone_egypt_memo').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Modern_Gravestone'), findsOneWidget);
      expect(find.textContaining('只能添加一种自定义墓碑'), findsNothing);
      expect(conflictingSheet.objData['Hitpoints'], 701);

      await tester.tap(find.text('前往自定义地图'));
      await tester.pumpAndSettle();
      expect(openedCustomStages, isTrue);
      expect(conflictingSheet.objData['Hitpoints'], 701);
    },
  );

  testWidgets('grid item and add cards use the same height', (tester) async {
    GridItemRepository.staticItems.add(_memoPreset());
    final level = _levelWithModernGravestoneResourceGroup([
      _memoPropertySheet(),
      PvzObject(
        aliases: const ['InitialGridItems'],
        objClass: 'InitialGridItemProperties',
        objData: const {
          'InitialGridItemPlacements': [
            {'GridX': 0, 'GridY': 0, 'TypeName': 'gravestone_egypt_memo'},
          ],
        },
      ),
    ]);

    await tester.pumpWidget(
      _localizedApp(
        InitialGridItemEntryScreen(
          rtid: 'RTID(InitialGridItems@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final itemCard = find.ancestor(
      of: find.byType(PresetAwareGridItemIcon).first,
      matching: find.byType(Card),
    );
    expect(
      tester.getSize(itemCard.first).height,
      tester.getSize(find.byType(AddItemCard)).height,
    );
  });

  testWidgets('preset grid items screen exposes the module alias field', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['InitialGridItems'],
          objClass: 'InitialGridItemProperties',
          objData: const {
            'InitialGridItemPlacements': <Map<String, dynamic>>[],
          },
        ),
      ],
    );

    await tester.pumpWidget(
      _localizedApp(
        InitialGridItemEntryScreen(
          rtid: 'RTID(InitialGridItems@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alias (English letters only; no spaces)'), findsOneWidget);
    expect(find.text('InitialGridItems'), findsOneWidget);
  });
}

bool _containsExactString(dynamic value, String target) {
  if (value is String) return value == target;
  if (value is Map) {
    return value.entries.any(
      (entry) =>
          _containsExactString(entry.key, target) ||
          _containsExactString(entry.value, target),
    );
  }
  if (value is Iterable) {
    return value.any((entry) => _containsExactString(entry, target));
  }
  return false;
}

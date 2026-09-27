import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/module_instance_display_name.dart';
import 'package:c_editor/data/module_instance_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PvzObject _module(String alias, String objClass, int marker) => PvzObject(
  aliases: [alias],
  objClass: objClass,
  objData: {'Marker': marker},
);

void main() {
  const battleClass = 'ZombossBattleModuleProperties';
  const lastStandClass = 'ZombossLastStandMinigameProperties';

  test('both Boss module registrations allow compact numbered duplicates', () {
    for (final objClass in [battleClass, lastStandClass]) {
      final metadata = ModuleRegistry.getMetadata(objClass);
      expect(metadata.allowMultiple, isTrue);
      expect(metadata.duplicateAliasNumberSeparator, isEmpty);
    }
  });

  test('display numbering is dynamic and independent per Boss module type', () {
    expect(
      moduleInstanceDisplayName(
        baseName: 'Mech Zomboss Battle',
        objClass: battleClass,
        instanceCount: 1,
        instanceIndex: 0,
      ),
      'Mech Zomboss Battle',
    );
    expect(
      moduleInstanceDisplayName(
        baseName: 'Mech Zomboss Battle',
        objClass: battleClass,
        instanceCount: 2,
        instanceIndex: 1,
      ),
      'Mech Zomboss Battle 2',
    );
    expect(
      moduleInstanceDisplayName(
        baseName: 'Zomboss Last Stand',
        objClass: lastStandClass,
        instanceCount: 1,
        instanceIndex: 0,
      ),
      'Zomboss Last Stand',
    );
  });

  test('each referenced Boss instance receives its own editor tab', () async {
    final levelDef = LevelDefinitionData(
      modules: [
        'RTID(ZombossBattle1@CurrentLevel)',
        'RTID(ZombossBattle2@CurrentLevel)',
        'RTID(ZombossLastStand1@CurrentLevel)',
        'RTID(ZombossLastStand2@CurrentLevel)',
        'RTID(ZombossLastStand3@CurrentLevel)',
      ],
    );
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: levelDef.toJson(),
        ),
        _module('ZombossBattle1', battleClass, 1),
        _module('ZombossBattle2', battleClass, 2),
        _module('ZombossLastStand1', lastStandClass, 1),
        _module('ZombossLastStand2', lastStandClass, 2),
        _module('ZombossLastStand3', lastStandClass, 3),
      ],
    );
    final cubit = EditorCubit(fileName: 'boss.json', filePath: '');
    addTearDown(cubit.close);

    cubit.applyLevelFile(level, markDirty: false);

    expect(
      cubit.state.availableTabs.where(
        (tab) => tab == EditorTabType.zombossMech,
      ),
      hasLength(2),
    );
    expect(
      cubit.state.availableTabs.where(
        (tab) => tab == EditorTabType.zombossBattle,
      ),
      hasLength(3),
    );
  });

  test('find, edit, copy, and delete operate on one concrete Battle RTID', () {
    final intro = _module(
      'ZombossRobotIntro',
      'ZombossBattleIntroProperties',
      0,
    );
    final battle1 = _module('ZombossBattle1', battleClass, 1);
    final battle2 = _module('ZombossBattle2', battleClass, 2);
    final battle3 = _module('ZombossBattle3', battleClass, 3);
    final battle4 = _module('ZombossBattle4', battleClass, 4);
    final levelDef = LevelDefinitionData(
      modules: [
        'RTID(ZombossRobotIntro@CurrentLevel)',
        'RTID(ZombossBattle1@CurrentLevel)',
        'RTID(ZombossBattle2@CurrentLevel)',
        'RTID(ZombossBattle3@CurrentLevel)',
        'RTID(ZombossBattle4@CurrentLevel)',
      ],
    );
    final levelFile = PvzLevelFile(
      objects: [intro, battle1, battle2, battle3, battle4],
    );

    final selected = ModuleInstanceUtils.findCurrentLevelObject(
      levelFile: levelFile,
      rtid: 'RTID(ZombossBattle3@CurrentLevel)',
      expectedObjClass: battleClass,
    );
    expect(selected, same(battle3));
    (selected!.objData as Map<String, dynamic>)['Marker'] = 30;
    expect(battle1.objData['Marker'], 1);
    expect(battle2.objData['Marker'], 2);
    expect(battle4.objData['Marker'], 4);

    final duplicateRtid = ModuleInstanceUtils.duplicateCurrentLevelModule(
      levelFile: levelFile,
      levelDef: levelDef,
      rtid: 'RTID(ZombossBattle2@CurrentLevel)',
      metadata: ModuleRegistry.getMetadata(battleClass),
    );
    expect(duplicateRtid, isNotNull);
    expect(levelDef.modules[3], duplicateRtid);
    expect(
      levelFile.objects.where((o) => o.objClass == battleClass),
      hasLength(5),
    );
    expect(
      levelFile.objects.where(
        (o) => o.objClass == 'ZombossBattleIntroProperties',
      ),
      hasLength(1),
    );

    final duplicate = ModuleInstanceUtils.findCurrentLevelObject(
      levelFile: levelFile,
      rtid: duplicateRtid!,
      expectedObjClass: battleClass,
    )!;
    duplicate.objData['Marker'] = 200;
    expect(battle2.objData['Marker'], 2, reason: 'copy must be deep');

    final removed = ModuleInstanceUtils.removeModule(
      levelFile: levelFile,
      levelDef: levelDef,
      rtid: 'RTID(ZombossBattle2@CurrentLevel)',
    );
    expect(removed, same(battle2));
    expect(levelFile.objects, containsAll([battle1, battle3, battle4]));
    expect(
      levelDef.modules,
      isNot(contains('RTID(ZombossBattle2@CurrentLevel)')),
    );
  });

  test('three Last Stands and four Battles survive save and reload', () {
    final levelDef = LevelDefinitionData(
      modules: [
        for (var i = 1; i <= 3; i++) 'RTID(ZombossLastStand$i@CurrentLevel)',
        'RTID(ZombossRobotIntro@CurrentLevel)',
        for (var i = 1; i <= 4; i++) 'RTID(ZombossBattle$i@CurrentLevel)',
      ],
    );
    final original = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: levelDef.toJson(),
        ),
        for (var i = 1; i <= 3; i++)
          _module('ZombossLastStand$i', lastStandClass, i),
        _module('ZombossRobotIntro', 'ZombossBattleIntroProperties', 0),
        for (var i = 1; i <= 4; i++) _module('ZombossBattle$i', battleClass, i),
        PvzObject(
          aliases: ['ZombieZombossMech_Egypt_Memo_Props'],
          objClass: 'ZombieZombossMechEgyptProps',
          objData: {'SquashZombies': true, 'SquashGridItems': false},
        ),
      ],
    );

    final reloaded = PvzLevelFile.fromJson(original.toJson());
    final parsed = LevelParser.parseLevel(reloaded);
    expect(
      reloaded.objects.where((o) => o.objClass == lastStandClass),
      hasLength(3),
    );
    expect(
      reloaded.objects.where((o) => o.objClass == battleClass),
      hasLength(4),
    );
    expect(
      reloaded.objects.where(
        (o) => o.objClass == 'ZombossBattleIntroProperties',
      ),
      hasLength(1),
    );
    expect(parsed.levelDef!.modules, levelDef.modules);
    final props = parsed.objectMap['ZombieZombossMech_Egypt_Memo_Props']!;
    expect(props.objData['SquashZombies'], isTrue);
    expect(props.objData['SquashGridItems'], isFalse);
  });

  testWidgets('module list numbers siblings and restores the single title', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 1200);
    addTearDown(tester.view.reset);
    final levelDef = LevelDefinitionData(
      modules: [
        'RTID(ZombossBattle1@CurrentLevel)',
        'RTID(ZombossLastStand1@CurrentLevel)',
        'RTID(ZombossBattle2@CurrentLevel)',
      ],
    );
    final objectMap = <String, PvzObject>{
      'ZombossBattle1': _module('ZombossBattle1', battleClass, 1),
      'ZombossBattle2': _module('ZombossBattle2', battleClass, 2),
      'ZombossLastStand1': _module('ZombossLastStand1', lastStandClass, 1),
    };

    Widget app() => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: LevelSettingsTab(
          levelDef: levelDef,
          objectMap: objectMap,
          onEditBasicInfo: () {},
          onEditModule: (_) {},
          onRemoveModule: (_) {},
          onReorderModules:
              ({
                required isCoreSection,
                required oldIndex,
                required newIndex,
              }) {},
          onNavigateToAddModule: () {},
        ),
      ),
    );

    await tester.pumpWidget(app());
    await tester.pump();
    expect(find.text('Zomboss Mech Battle 1 (ZombossBattle1)'), findsOneWidget);
    expect(find.text('Zomboss Mech Battle 2 (ZombossBattle2)'), findsOneWidget);
    expect(
      find.text('Non-mech Zomboss Battle (ZombossLastStand1)'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.copy_outlined), findsNothing);

    levelDef.modules.remove('RTID(ZombossBattle2@CurrentLevel)');
    objectMap.remove('ZombossBattle2');
    await tester.pumpWidget(app());
    await tester.pump();
    expect(find.text('Zomboss Mech Battle (ZombossBattle1)'), findsOneWidget);
    expect(find.textContaining('Zomboss Mech Battle 1'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

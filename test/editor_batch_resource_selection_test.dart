import 'dart:async';
import 'dart:convert';

import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/events/modify_conveyor_event_screen.dart';
import 'package:c_editor/screens/editor/modules/conveyor_seedbank_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/wave_manager_module_screen.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:c_editor/screens/editor_screen.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ReadyEditorCubit extends EditorCubit {
  _ReadyEditorCubit(PvzLevelFile level)
    : super(fileName: 'batch.json', filePath: 'batch.json') {
    emit(
      EditorState(
        levelFile: level,
        parsedData: LevelParser.parseLevel(level),
        availableTabs: const [EditorTabType.settings, EditorTabType.timeline],
        isLoading: false,
      ),
    );
  }
}

PvzLevelFile _level() => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: const ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        modules: const [
          'RTID(Conveyor@CurrentLevel)',
          'RTID(NewWaves@CurrentLevel)',
        ],
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['Conveyor'],
      objClass: 'ConveyorSeedBankProperties',
      objData: ConveyorBeltData(
        initialPlantList: [],
        dropDelayConditions: [DropDelayConditionData(delay: 3)],
        speedConditions: [SpeedConditionData(speed: 100)],
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['NewWaves'],
      objClass: 'WaveManagerModuleProperties',
      objData: WaveManagerModuleData(
        waveManagerProps: 'RTID(Waves@CurrentLevel)',
        dynamicZombies: [
          DynamicZombieGroup(
            startingPoints: 100,
            zombiePool: ['RTID(tutorial_armor2@ZombieTypes)'],
            zombieLevel: [3],
          ),
        ],
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['Waves'],
      objClass: 'WaveManagerProperties',
      objData: WaveManagerData(
        waveCount: 1,
        waves: const [
          ['RTID(ModifyConveyor@CurrentLevel)'],
        ],
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['ModifyConveyor'],
      objClass: 'ModifyConveyorWaveActionProps',
      objData: ModifyConveyorWaveActionData().toJson(),
    ),
  ],
);

PvzObject _object(PvzLevelFile level, String alias) => level.objects
    .singleWhere((object) => object.aliases?.contains(alias) == true);

Future<_ReadyEditorCubit> _pumpEditor(
  WidgetTester tester,
  PvzLevelFile level,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 1100);
  addTearDown(tester.view.reset);
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsCubit(prefs);
  final editor = _ReadyEditorCubit(level);
  addTearDown(settings.close);
  addTearDown(editor.close);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<EditorCubit>.value(value: editor),
        BlocProvider<SettingsCubit>.value(value: settings),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EditorScreen(
          onBack: () {},
          onRegisterBackHandler: (_) {},
          onLanguageTap: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return editor;
}

Future<void> _openModule(WidgetTester tester, String alias) async {
  final settings = tester.widget<LevelSettingsTab>(
    find.byType(LevelSettingsTab),
  );
  settings.onEditModule('RTID($alias@CurrentLevel)');
  await tester.pumpAndSettle();
}

Future<void> _tapAddPlant(WidgetTester tester) async {
  final add = find
      .widgetWithText(
        OutlinedButton,
        lookupAppLocalizations(const Locale('en')).addPlantConveyor,
      )
      .first;
  await tester.ensureVisible(add);
  await tester.tap(add);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ReferenceRepository.init(),
      PlantRepository().init(),
      ZombieRepository().init(),
      ZombiePropertiesRepository.init(),
      ResourceNames.ensureLoaded(),
    ]);
  });

  testWidgets(
    'conveyor add opens multi-select and appends the confirmed batch',
    (tester) async {
      final level = _level();
      final editor = await _pumpEditor(tester, level);
      await _openModule(tester, 'Conveyor');
      await _tapAddPlant(tester);
      final selector = tester.widget<PlantSelectionScreen>(
        find.byType(PlantSelectionScreen),
      );
      expect(selector.isMultiSelect, isTrue);
      selector.onMultiPlantSelected!(['peashooter', 'sunflower']);
      await tester.pumpAndSettle();

      final conveyor = ConveyorBeltData.fromJson(
        Map<String, dynamic>.from(_object(level, 'Conveyor').objData as Map),
      );
      expect(conveyor.initialPlantList.map((entry) => entry.plantType), [
        'peashooter',
        'sunflower',
      ]);
      expect(find.byType(PlantSelectionScreen), findsNothing);
      expect(find.byType(ConveyorSeedBankPropertiesScreen), findsOneWidget);
      expect(editor.state.hasChanges, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('point pool batch rejects elites once and aligns levels', (
    tester,
  ) async {
    final level = _level();
    final editor = await _pumpEditor(tester, level);
    await _openModule(tester, 'NewWaves');
    final add = find.widgetWithText(TextButton, 'Add');
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    final selector = tester.widget<ZombieSelectionScreen>(
      find.byType(ZombieSelectionScreen),
    );
    expect(selector.multiSelect, isTrue);
    expect(selector.pointSpawnOnly, isTrue);
    final elites = ZombieRepository().allZombies
        .where((zombie) => ZombieRepository().isElite(zombie.id))
        .take(2)
        .map((zombie) => zombie.id)
        .toList();
    expect(elites, hasLength(2));
    selector.onMultiZombieSelected!([...elites, 'tutorial', 'tutorial_armor1']);
    await tester.pumpAndSettle();

    final group = WaveManagerModuleData.fromJson(
      Map<String, dynamic>.from(_object(level, 'NewWaves').objData as Map),
    ).dynamicZombies.single;
    expect(group.zombiePool, [
      'RTID(tutorial_armor2@ZombieTypes)',
      'RTID(tutorial@ZombieTypes)',
      'RTID(tutorial_armor1@ZombieTypes)',
    ]);
    expect(group.zombieLevel, [3, 1, 1]);
    expect(find.byType(ZombieSelectionScreen), findsNothing);
    expect(find.byType(WaveManagerModuleScreen), findsOneWidget);
    expect(find.text('Elite zombies are not allowed here'), findsOneWidget);
    expect(editor.state.hasChanges, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final module in ['Conveyor', 'NewWaves']) {
    testWidgets('canceling $module batch selection leaves level unchanged', (
      tester,
    ) async {
      final level = _level();
      final editor = await _pumpEditor(tester, level);
      await _openModule(tester, module);
      final before = jsonEncode(level.toJson());
      if (module == 'Conveyor') {
        await _tapAddPlant(tester);
        tester
            .widget<PlantSelectionScreen>(find.byType(PlantSelectionScreen))
            .onBack();
      } else {
        final add = find.widgetWithText(TextButton, 'Add');
        await tester.ensureVisible(add);
        await tester.tap(add);
        await tester.pumpAndSettle();
        tester
            .widget<ZombieSelectionScreen>(find.byType(ZombieSelectionScreen))
            .onBack();
      }
      await tester.pumpAndSettle();
      expect(jsonEncode(level.toJson()), before);
      expect(editor.state.hasChanges, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('modify conveyor batch returns without stacking entry dialogs', (
    tester,
  ) async {
    final level = _level();
    await _pumpEditor(tester, level);
    await tester.tap(find.widgetWithText(Tab, 'Wave Timeline'));
    await tester.pumpAndSettle();
    final timeline = tester.widget<WaveTimelineTab>(
      find.byType(WaveTimelineTab),
    );
    unawaited(timeline.onEditEvent('RTID(ModifyConveyor@CurrentLevel)', 1));
    await tester.pumpAndSettle();
    expect(find.byType(ModifyConveyorEventScreen), findsOneWidget);
    await _tapAddPlant(tester);
    final selector = tester.widget<PlantSelectionScreen>(
      find.byType(PlantSelectionScreen),
    );
    expect(selector.isMultiSelect, isTrue);
    selector.onMultiPlantSelected!(['peashooter', 'sunflower']);
    await tester.pumpAndSettle();

    final data = ModifyConveyorWaveActionData.fromJson(
      Map<String, dynamic>.from(
        _object(level, 'ModifyConveyor').objData as Map,
      ),
    );
    expect(data.addList.map((entry) => entry.type), [
      'RTID(peashooter@PlantTypes)',
      'RTID(sunflower@PlantTypes)',
    ]);
    expect(find.byType(PlantSelectionScreen), findsNothing);
    expect(find.byType(ModifyConveyorEventScreen), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

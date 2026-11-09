import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PvzObject _object(
  String alias,
  String objClass,
  Map<String, dynamic> objData,
) => PvzObject(aliases: [alias], objClass: objClass, objData: objData);

PvzLevelFile _level({
  required List<String> moduleAliases,
  required List<PvzObject> objects,
  bool disablePeavine = false,
}) => PvzLevelFile(
  objects: [
    PvzObject(
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        disablePeavine: disablePeavine ? true : null,
        modules: [
          for (final alias in moduleAliases) 'RTID($alias@CurrentLevel)',
        ],
      ).toJson(),
    ),
    ...objects,
  ],
);

bool _detectsPea(PvzLevelFile level) =>
    LevelIssueContext.fromLevel(level).hasEnabledPeaPlant;

Future<Set<String>> _issueIds(WidgetTester tester, PvzLevelFile level) async {
  var ids = <String>{};
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          ids = {
            for (final issue in LevelIssueRegistry.forLevel(context, level))
              issue.id,
          };
          return const SizedBox();
        },
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  return ids;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ReferenceRepository.init(),
      PlantRepository().init(),
      ResourceNames.ensureLoaded(),
    ]);
  });

  test('PlantTypes Attribute.Tags is the authoritative pea classification', () {
    final repository = PlantRepository();
    expect(repository.hasPlantAttributeTag('peashooter', 'pea'), isTrue);
    expect(repository.hasPlantAttributeTag('sunflower', 'pea'), isFalse);
    expect(
      repository.getPlantInfoById('peashooter')!.hasAttributeTag('pea'),
      isTrue,
    );
  });
  testWidgets(
    'unrestricted affected plants follow Plants.json rather than translated names',
    (tester) async {
      final level = _level(
        moduleAliases: ['SeedBank'],
        objects: [
          _object('SeedBank', 'SeedBankProperties', {
            'SelectionMethod': 'chooser',
          }),
        ],
      );
      late LevelIssue warning;
      late List<String> names;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              warning = LevelIssueRegistry.forLevel(context, level).singleWhere(
                (i) => i.id == kPeaSymbiosisDisableRecommendedIssueId,
              );
              final ids = LevelIssueContext.fromLevel(level).enabledPeaPlantIds;
              names = PlantRepository().allPlants
                  .where((p) => ids.contains(p.id))
                  .map((p) => ResourceNames.lookup(context, p.name))
                  .toSet()
                  .toList();
              return const SizedBox();
            },
          ),
        ),
      );
      expect(names.first, 'Peashooter');
      expect(warning.bulletPoints, [
        lookupAppLocalizations(
          const Locale('en'),
        ).peaSymbiosisAffectedPlants(names.join(', ')),
      ]);
    },
  );

  test('bundled templates with usable pea plants disable Pea Symbiosis', () {
    final templateDirectory = Directory('assets/reference/template');
    final templatesWithPeaPlants = <String>[];

    for (final file in templateDirectory.listSync().whereType<File>()) {
      final decoded = jsonDecode(file.readAsStringSync());
      final level = PvzLevelFile.fromJson(
        Map<String, dynamic>.from(decoded as Map),
      );
      final context = LevelIssueContext.fromLevel(level);
      if (!context.hasEnabledPeaPlant) continue;

      final filename = file.uri.pathSegments.last;
      templatesWithPeaPlants.add(filename);
      expect(
        context.levelDef?.disablePeavine,
        isTrue,
        reason: '$filename allows pea plants and must disable Pea Symbiosis.',
      );
    }

    templatesWithPeaPlants.sort();
    expect(
      templatesWithPeaPlants,
      containsAll(<String>[
        '2_chooser_example.json',
        '4_last_stand_example.json',
      ]),
    );
  });

  test('chooser respects whitelist and blacklist', () {
    PvzLevelFile chooser(SeedBankData data) => _level(
      moduleAliases: const ['SeedBank'],
      objects: [_object('SeedBank', 'SeedBankProperties', data.toJson())],
    );

    expect(_detectsPea(chooser(SeedBankData())), isTrue);
    expect(
      _detectsPea(
        chooser(
          SeedBankData(
            selectionMethod: 'chooser',
            plantWhiteList: const ['sunflower'],
          ),
        ),
      ),
      isFalse,
    );
    expect(
      _detectsPea(
        chooser(
          SeedBankData(
            selectionMethod: 'chooser',
            plantWhiteList: const ['peashooter'],
            plantBlackList: const ['peashooter'],
          ),
        ),
      ),
      isFalse,
    );

    final allPeaPlants = PlantRepository().allPlants
        .where((plant) => plant.hasAttributeTag('pea'))
        .map((plant) => plant.id)
        .toList();
    expect(allPeaPlants, isNotEmpty);
    expect(
      _detectsPea(
        chooser(
          SeedBankData(
            selectionMethod: 'chooser',
            plantBlackList: allPeaPlants,
          ),
        ),
      ),
      isFalse,
    );
  });

  test('preset ignores zombie and grid-item seed-bank modes', () {
    PvzLevelFile preset(SeedBankData data) => _level(
      moduleAliases: const ['SeedBank'],
      objects: [_object('SeedBank', 'SeedBankProperties', data.toJson())],
    );

    expect(
      _detectsPea(
        preset(
          SeedBankData(
            selectionMethod: 'preset',
            presetPlantList: const ['peashooter'],
          ),
        ),
      ),
      isTrue,
    );
    expect(
      _detectsPea(
        preset(
          SeedBankData(
            selectionMethod: 'preset',
            presetPlantList: const ['peashooter'],
            plantBlackList: const ['peashooter'],
          ),
        ),
      ),
      isFalse,
    );
    for (final data in [
      SeedBankData(
        selectionMethod: 'preset',
        presetPlantList: const ['peashooter'],
        zombieMode: true,
      ),
      SeedBankData(
        selectionMethod: 'preset',
        presetPlantList: const ['peashooter'],
        gridItemMode: true,
      ),
      SeedBankData(
        selectionMethod: 'preset',
        presetPlantList: const ['peashooter', 'FrozenChillyPepper'],
      ),
    ]) {
      expect(_detectsPea(preset(data)), isFalse);
    }
  });

  test('active conveyor and seed rain modules expose pea plants', () {
    final conveyor = _object('Conveyor', 'ConveyorSeedBankProperties', {
      'InitialPlantList': [
        {'PlantType': 'peashooter'},
      ],
    });
    final rain = _object('Rain', 'SeedRainProperties', {
      'SeedRains': [
        {'PlantTypeName': 'RTID(repeater@PlantTypes)'},
      ],
    });

    expect(
      _detectsPea(
        _level(moduleAliases: const ['Conveyor'], objects: [conveyor, rain]),
      ),
      isTrue,
    );
    expect(
      LevelIssueContext.fromLevel(
        _level(moduleAliases: const ['Conveyor'], objects: [conveyor, rain]),
      ).enabledPeaPlantIds,
      {'peashooter'},
    );
    expect(
      _detectsPea(
        _level(moduleAliases: const ['Rain'], objects: [conveyor, rain]),
      ),
      isTrue,
    );
  });

  test('SpawnPlantName is followed only through mounted module references', () {
    PvzObject event(String alias, String plant) =>
        _object(alias, 'SpawnZombiesJitteredWaveActionProps', {
          'SpawnPlantName': [plant],
        });
    final waveModule = _object('WaveModule', 'WaveManagerModuleProperties', {
      'WaveManagerProps': 'RTID(Waves@CurrentLevel)',
    });
    final waves = _object('Waves', 'WaveManagerProperties', {
      'Waves': [
        ['RTID(AttachedEvent@CurrentLevel)'],
      ],
    });
    final objects = [
      waveModule,
      waves,
      event('AttachedEvent', 'peashooter'),
      event('OrphanEvent', 'repeater'),
    ];

    expect(
      _detectsPea(
        _level(moduleAliases: const ['WaveModule'], objects: objects),
      ),
      isTrue,
    );
    waves.objData = {
      'Waves': [
        ['RTID(NonPeaEvent@CurrentLevel)'],
      ],
    };
    objects.add(event('NonPeaEvent', 'sunflower'));
    expect(
      _detectsPea(
        _level(moduleAliases: const ['WaveModule'], objects: objects),
      ),
      isFalse,
      reason: 'Unreferenced wave actions must not affect the warning.',
    );
  });

  test('orphan conveyor module is ignored', () {
    final orphan = _object('OrphanConveyor', 'ConveyorSeedBankProperties', {
      'InitialPlantList': [
        {'PlantType': 'peashooter'},
      ],
    });
    expect(
      _detectsPea(_level(moduleAliases: const [], objects: [orphan])),
      isFalse,
    );
  });

  testWidgets('warning rule is yellow-severity and obeys DisablePeavine', (
    tester,
  ) async {
    PvzLevelFile level({required bool disabled}) => _level(
      moduleAliases: const ['Conveyor'],
      disablePeavine: disabled,
      objects: [
        _object('Conveyor', 'ConveyorSeedBankProperties', {
          'InitialPlantList': [
            {'PlantType': 'peashooter'},
          ],
        }),
      ],
    );

    final enabledLevel = level(disabled: false);
    expect(
      await _issueIds(tester, enabledLevel),
      contains(kPeaSymbiosisDisableRecommendedIssueId),
    );
    late LevelIssue warning;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            warning = LevelIssueRegistry.forLevel(context, enabledLevel)
                .singleWhere(
                  (issue) => issue.id == kPeaSymbiosisDisableRecommendedIssueId,
                );
            return const SizedBox();
          },
        ),
      ),
    );
    expect(warning.severity, LevelIssueSeverity.warning);
    expect(warning.title, '建议禁用豆藤共生');
    expect(warning.message, contains('建议前往「关卡基本信息」，禁用豆藤共生。'));
    expect(warning.message, isNot(contains('pea')));
    expect(warning.bulletPoints, ['涉及植物：豌豆射手']);
    expect(
      await _issueIds(tester, level(disabled: true)),
      isNot(contains(kPeaSymbiosisDisableRecommendedIssueId)),
    );
  });

  testWidgets('level settings uses ARB copy and lists triggering plants', (
    tester,
  ) async {
    final conveyor = _object('Conveyor', 'ConveyorSeedBankProperties', {
      'InitialPlantList': [
        {'PlantType': 'peashooter'},
        {'PlantType': 'repeater'},
        {'PlantType': 'sunflower'},
      ],
    });
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LevelSettingsTab(
            levelDef: LevelDefinitionData(
              modules: const ['RTID(Conveyor@CurrentLevel)'],
            ),
            objectMap: {'Conveyor': conveyor},
            onEditBasicInfo: _noop,
            onEditModule: _noopString,
            onRemoveModule: _noopString,
            onReorderModules: _noopReorder,
            onNavigateToAddModule: _noop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('建议禁用豆藤共生'), findsOneWidget);
    expect(find.textContaining('检测到本关可以使用以下豌豆类植物'), findsOneWidget);
    expect(find.text('• 涉及植物：豌豆射手、双重射手'), findsOneWidget);
    expect(find.text('• 豌豆射手'), findsNothing);
    expect(find.text('• 双重射手'), findsNothing);
    expect(find.textContaining('pea'), findsNothing);
    expect(find.text('• 向日葵'), findsNothing);
  });
}

void _noop() {}

void _noopString(String _) {}

void _noopReorder({
  required bool isCoreSection,
  required int oldIndex,
  required int newIndex,
}) {}

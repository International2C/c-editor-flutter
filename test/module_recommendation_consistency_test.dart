import 'dart:convert';

import 'package:c_editor/data/glacier_module_presets.dart';
import 'package:c_editor/data/level_validator.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PvzLevelFile _level(
  Set<String> active, {
  Set<String> inactive = const {},
  String stage = 'EgyptStage',
  Map<String, Map<String, dynamic>> data = const {},
}) => PvzLevelFile(
  objects: [
    PvzObject(
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        stageModule: 'RTID($stage@LevelModules)',
        modules: [for (final cls in active) 'RTID($cls@CurrentLevel)'],
      ).toJson(),
    ),
    for (final cls in {...active, ...inactive})
      PvzObject(aliases: [cls], objClass: cls, objData: data[cls] ?? {}),
  ],
);

List<String> _recommendations(BuildContext context, PvzLevelFile level) => [
  for (final issue in LevelIssueRegistry.forLevel(context, level))
    if (issue.id == 'missingEssentials') ...issue.bulletPoints,
];

Set<String> _issueIds(BuildContext context, PvzLevelFile level) => {
  for (final issue in LevelIssueRegistry.forLevel(context, level)) issue.id,
};

Future<void> _withContext(
  WidgetTester tester,
  String language,
  void Function(BuildContext) check,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          check(context);
          return const SizedBox();
        },
      ),
    ),
  );
  expect(tester.takeException(), isNull);
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

  testWidgets(
    'plant dependency prompt resolves stock aliases and active local modules',
    (tester) async {
      const module = 'PVZ1CopycatsModuleProperties';
      const plant = 'minigame_imitater';
      for (final source in ['LevelModules', 'CurrentLevel', 'inactive']) {
        final level = _level(
          {if (source == 'CurrentLevel') module},
          inactive: {module},
        );
        if (source == 'LevelModules') {
          level.objects.first.objData['Modules'] = [
            'RTID(PVZ1CopycatsModule@LevelModules)',
          ];
        }
        String? selected;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PlantSelectionScreen(
              key: ValueKey(source),
              stateBucketId: 'dependency-$source',
              levelFile: level,
              onPlantSelected: (id) => selected = id,
              onAddModule: (_) => fail('The test must not add a module.'),
              onBack: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, plant);
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('plantSelectionIcon-$plant')),
        );
        await tester.pumpAndSettle();
        expect(selected, source == 'inactive' ? isNull : plant);
        expect(
          find.byType(AlertDialog),
          source == 'inactive' ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  for (final language in ['zh', 'en', 'ru']) {
    testWidgets('$language: recommendations avoid known module conflicts', (
      tester,
    ) async {
      await _withContext(tester, language, (context) {
        for (final (active, excluded) in <(Set<String>, String)>[
          ({'LawnMowerProperties'}, 'CustomLevelModuleProperties'),
          ({'MoonExpertProperties'}, 'CustomLevelModuleProperties'),
          (
            {'LastStandMinigameProperties', 'ConveyorSeedBankProperties'},
            'SeedBankProperties',
          ),
          (
            {'EvilDaveProperties', 'ConveyorSeedBankProperties'},
            'SeedBankProperties',
          ),
          (
            {'EvilDaveProperties', 'RoofProperties'},
            'InitialPlantEntryProperties',
          ),
          (
            {'ZombossBattleModuleProperties', 'StandardLevelIntroProperties'},
            'ZombossBattleIntroProperties',
          ),
          (
            {
              'VaseBreakerArcadeModuleProperties',
              'StandardLevelIntroProperties',
            },
            'VaseBreakerPresetProperties',
          ),
          ({'CustomWinConProperties'}, 'ZombiesDeadWinConProperties'),
        ]) {
          final level = _level(active);
          expect(
            _recommendations(context, level),
            isNot(
              contains(ModuleRegistry.getMetadata(excluded).getTitle(context)),
            ),
            reason: active.join(', '),
          );
        }
        // Ordinary levels and compatible dependencies must still be advised.
        for (final (active, expected) in <(Set<String>, String)>[
          ({}, 'CustomLevelModuleProperties'),
          ({}, 'ZombiesDeadWinConProperties'),
          ({'LastStandMinigameProperties'}, 'SeedBankProperties'),
          ({'EvilDaveProperties'}, 'InitialPlantEntryProperties'),
          ({'ZombossBattleModuleProperties'}, 'ZombossBattleIntroProperties'),
          (
            {'VaseBreakerArcadeModuleProperties'},
            'VaseBreakerPresetProperties',
          ),
          ({'OakTrainIntroProperties'}, 'OakTrainProperties'),
        ]) {
          expect(
            _recommendations(context, _level(active)),
            contains(ModuleRegistry.getMetadata(expected).getTitle(context)),
          );
        }
      });
    });

    testWidgets(
      '$language: special intros and inactive objects are distinguished',
      (tester) async {
        await _withContext(tester, language, (context) {
          final l10n = AppLocalizations.of(context)!;
          for (final cls in [
            'VaseBreakerPresetProperties',
            'VaseBreakerArcadeModuleProperties',
            'VaseBreakerFlowModuleProperties',
            'LastStandMinigameProperties',
            'CowboyMinigameProperties',
            'SingleHandedProperties',
            'IntroSingleHandedProperties',
            'OakTrainIntroProperties',
            'ZombossBattleModuleProperties',
            'ZombossBattleIntroProperties',
            'ZombossLastStandMinigameProperties',
            'CamelMinigameProperties',
          ]) {
            expect(
              _recommendations(context, _level({cls})),
              isNot(contains(l10n.moduleTitle_StandardLevelIntroProperties)),
              reason: cls,
            );
            expect(
              _recommendations(context, _level({}, inactive: {cls})),
              contains(l10n.moduleTitle_StandardLevelIntroProperties),
              reason: 'Unlinked $cls must not change the active gameplay.',
            );
          }
          const essentials = {
            'CustomLevelModuleProperties',
            'ZombiesDeadWinConProperties',
            'ZombiesAteYourBrainsProperties',
            'StandardLevelIntroProperties',
          };
          expect(_recommendations(context, _level(essentials)), isEmpty);
          expect(
            _recommendations(context, _level({}, inactive: essentials)),
            unorderedEquals([
              for (final cls in essentials)
                ModuleRegistry.getMetadata(cls).getTitle(context),
            ]),
          );
          final stock = _level({});
          stock.objects.first.objData['Modules'] = [
            for (final cls in essentials)
              'RTID(${ModuleRegistry.getMetadata(cls).defaultAlias}@LevelModules)',
          ];
          expect(_recommendations(context, stock), isEmpty);
          stock.objects.first.objData['Modules'] = [
            'RTID(StandardIntro@ZombieTypes)',
          ];
          expect(
            _recommendations(context, stock),
            contains(l10n.moduleTitle_StandardLevelIntroProperties),
          );
        });
      },
    );

    testWidgets(
      '$language: tile recommendations do not suggest incompatible companions',
      (tester) async {
        await _withContext(tester, language, (context) {
          for (final stage in ['UnchartedMausoleumStage', 'SouDaCheStage']) {
            final recommendation = stage == 'SouDaCheStage'
                ? 'recommendedExpeditionTiles'
                : 'recommendedTunnelDefend';
            expect(
              _issueIds(context, _level({}, stage: stage)),
              contains(recommendation),
            );
            final otherTiles = _level(
              {'TunnelDefendModuleProperties'},
              stage: stage,
              data: {
                'TunnelDefendModuleProperties': {
                  'BrickMapIndex': stage == 'SouDaCheStage' ? 1 : 3,
                },
              },
            );
            expect(
              _issueIds(context, otherTiles),
              isNot(contains(recommendation)),
            );
            // An unlinked alternative must not hide the useful recommendation.
            otherTiles.objects.first.objData['Modules'] = <String>[];
            expect(_issueIds(context, otherTiles), contains(recommendation));
          }
          final both = _level({
            'TunnelDefendModuleProperties',
          }, stage: 'SouDaCheStage');
          both.objects.add(
            PvzObject(
              aliases: ['Expedition'],
              objClass: 'TunnelDefendModuleProperties',
              objData: {'BrickMapIndex': 3},
            ),
          );
          both.objects.first.objData['Modules'].add(
            'RTID(Expedition@CurrentLevel)',
          );
          expect(
            _issueIds(context, both),
            contains('tunnelExpeditionCompatibilityWarning'),
          );
          final underwater = _level({}, stage: 'DeepseaStage');
          underwater.objects.first.objData['StageModule'] =
              'RTID(CustomStage@CurrentLevel)';
          underwater.objects.add(
            PvzObject(
              aliases: ['CustomStage'],
              objClass: 'DeepseaStageProperties',
              objData: {'BackgroundImagePrefix': 'IMAGE_BACKGROUNDS_SOUDACHE'},
            ),
          );
          expect(
            _issueIds(context, underwater),
            isNot(contains('recommendedExpeditionTiles')),
          );
        });
      },
    );

    testWidgets(
      '$language: glacier warnings inspect active battles instead of leftover objects',
      (tester) async {
        await _withContext(tester, language, (context) {
          const glacier = 'GlacierModuleProperties';
          const battle = 'ZombossBattleModuleProperties';
          const compatibility = 'glacierModuleCompatibilityWarning';
          const underwater = 'glacierModuleUnderwaterWarning';
          const puzzle = 'iceAgePlantPuzzleWarning';
          for (final glacierActive in [false, true]) {
            for (final battleActive in [false, true]) {
              final level = _level(
                {if (glacierActive) glacier, if (battleActive) battle},
                inactive: {glacier, battle},
                stage: 'DeepseaStage',
                data: {
                  battle: {
                    'ZombossMechType':
                        GlacierModulePresets.plantPuzzleVariation,
                  },
                },
              );
              final before = jsonEncode(level.toJson());
              final ids = _issueIds(context, level);
              expect(
                ids.contains(compatibility),
                glacierActive && !battleActive,
              );
              expect(ids.contains(underwater), glacierActive);
              expect(ids.contains(puzzle), glacierActive && battleActive);
              expect(jsonEncode(level.toJson()), before);
            }
          }
          // The first battle is not necessarily the active one (or the Ice Age one).
          final multiple = _level(
            {glacier, battle},
            data: {
              battle: {'ZombossMechType': 'zombossmech_pirate'},
            },
          );
          multiple.objects.add(
            PvzObject(
              aliases: ['IceAgeBattle'],
              objClass: battle,
              objData: {
                'ZombossMechType': GlacierModulePresets.plantPuzzleVariation,
              },
            ),
          );
          multiple.objects.first.objData['Modules'].add(
            'RTID(IceAgeBattle@CurrentLevel)',
          );
          expect(_issueIds(context, multiple), isNot(contains(compatibility)));
          expect(_issueIds(context, multiple), contains(puzzle));
          final l10n = AppLocalizations.of(context)!;
          expect(
            LevelValidator.validate(
              context,
              multiple,
            ).map((issue) => issue.message),
            contains(l10n.iceAgePlantPuzzleVariationWarning),
          );
        });
      },
    );
  }
}

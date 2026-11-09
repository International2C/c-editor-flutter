import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/challenge_resource_l10n.dart';
import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _copy =
    <
      String,
      ({
        String plants,
        String zombies,
        String conveyor,
        String lawn,
        String musicModule,
        String musicType,
      })
    >{
      'en': (
        plants: 'Preset plants',
        zombies: 'Preset zombies',
        conveyor: 'Conveyor plants',
        lawn: 'Lawn',
        musicModule: 'Ancient Egypt',
        musicType: 'Ancient Egypt - Ultimate Battle',
      ),
      'zh': (
        plants: '预选植物',
        zombies: '预选僵尸',
        conveyor: '传送带植物',
        lawn: '地图',
        musicModule: '神秘埃及',
        musicType: '神秘埃及-终“僵”之战 / Ultimate Battle',
      ),
      'ru': (
        plants: 'Предустановленные растения',
        zombies: 'Предустановленные зомби',
        conveyor: 'Растения конвейера',
        lawn: 'Поле',
        musicModule: 'Древний Египет',
        musicType: 'Древний Египет — решающая битва',
      ),
    };

const _listCopy =
    <
      String,
      ({
        String white,
        String black,
        String plants,
        String zombies,
        String chooser,
      })
    >{
      'en': (
        white: 'Whitelist',
        black: 'Blacklist',
        plants: 'Plant blacklist',
        zombies: 'Zombie whitelist',
        chooser: 'Choose your seeds',
      ),
      'zh': (
        white: '白名单',
        black: '黑名单',
        plants: '植物黑名单',
        zombies: '僵尸白名单',
        chooser: '自选种子',
      ),
      'ru': (
        white: 'Белый список',
        black: 'Чёрный список',
        plants: 'Чёрный список растений',
        zombies: 'Белый список зомби',
        chooser: 'Выбор семян',
      ),
    };

PvzLevelFile _level({required bool zombieMode}) => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: const ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        stageModule: 'RTID(EgyptStage@LevelModules)',
        musicType: 'MiniGame_A',
        modules: const [
          'RTID(SeedBank@CurrentLevel)',
          'RTID(Conveyor@CurrentLevel)',
          'RTID(SeedRain@CurrentLevel)',
          'RTID(Copycats@CurrentLevel)',
        ],
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['SeedBank'],
      objClass: 'SeedBankProperties',
      objData: {
        'SelectionMethod': 'preset',
        'ZombieMode': zombieMode,
        'PresetPlantList': [zombieMode ? 'tutorial' : 'peashooter'],
        'WhiteList': [zombieMode ? 'tutorial' : 'sunflower'],
        'BlackList': [zombieMode ? 'tutorial' : 'wallnut'],
      },
    ),
    PvzObject(
      aliases: const ['Conveyor'],
      objClass: 'ConveyorSeedBankProperties',
      objData: {
        'Plants': [
          {'PlantType': 'sunflower'},
        ],
      },
    ),
    PvzObject(
      aliases: const ['SeedRain'],
      objClass: 'SeedRainProperties',
      objData: SeedRainPropertiesData(
        seedRains: [SeedRainItem(plantTypeName: 'wallnut')],
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['Copycats'],
      objClass: 'PVZ1CopycatsModuleProperties',
      objData: PVZ1CopycatsModulePropertiesData(
        plantBlackList: ['peashooter'],
        zombieWhiteList: ['tutorial'],
      ).toJson(),
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ReferenceRepository.init(),
      PlantRepository().init(),
      ZombieRepository().init(),
      GridItemRepository.init(),
      StageRepository.init(),
      MusicSuffixCatalog.init(),
      ResourceNames.ensureLoaded(),
      ZombossMechRepository.ensureLoaded(),
      ZombossBattleRepository.init(),
    ]);
  });

  test('overview labels are distinct from technical editor field copy', () {
    const editorDescriptions = {
      'en': 'Plants pre-selected at the start',
      'zh': '开局自带的植物',
      'ru': 'Растения в начале',
    };
    for (final entry in _copy.entries) {
      final l10n = lookupAppLocalizations(Locale(entry.key));
      final copy = entry.value;
      expect(l10n.overviewPresetPlants, copy.plants);
      expect(l10n.overviewPresetZombies, copy.zombies);
      expect(l10n.overviewConveyorPlants, copy.conveyor);
      expect(l10n.overviewLawn, copy.lawn);
      expect(l10n.presetPlants, contains('(PresetPlantList)'));
      expect(l10n.plantsAvailableAtStart, editorDescriptions[entry.key]);
    }
  });

  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets(
      'challenge overview localizes states and professions in $locale',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final level = _level(zombieMode: false);
        level.objects.addAll([
          PvzObject(
            aliases: ['Challenges'],
            objClass: 'StarChallengeModuleProperties',
            objData: {
              'Challenges': [
                [
                  'RTID(Conditions@CurrentLevel)',
                  'RTID(Profession@CurrentLevel)',
                ],
              ],
            },
          ),
          PvzObject(
            aliases: ['Conditions'],
            objClass: 'ApplyZombieConditionsChallengeProps',
            objData: {
              'NumZombieConditionsToApply': 6,
              'ConditionToInflict': [
                'stun',
                'freeze',
                'future_unknown_condition',
              ],
            },
          ),
          PvzObject(
            aliases: ['Profession'],
            objClass: 'StarChallengeDisablePlantProps',
            objData: {'Profession': 'warrior'},
          ),
        ]);
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LevelOverviewDialog(
              levelFile: level,
              parsed: LevelParser.parseLevel(level),
              fileName: 'challenge.json',
              onClose: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(LevelOverviewDialog));
        final profession = ChallengeResourceL10n.profession(context, 'warrior');
        final professionTitle = ChallengeResourceL10n.title(
          context,
          'StarChallengeDisablePlantProps',
        );
        expect(find.text('$professionTitle ($profession)'), findsOneWidget);
        final title = find.text(
          ChallengeResourceL10n.title(
            context,
            'ApplyZombieConditionsChallengeProps',
          ),
        );
        await tester.ensureVisible(title);
        await tester.tap(title);
        await tester.pumpAndSettle();
        for (final id in ['stun', 'freeze']) {
          final localized = ResourceNames.lookupWithLocale(
            locale,
            'zombieCondition_$id',
          );
          expect(localized, isNot('zombieCondition_$id'));
          expect(find.text(localized), findsOneWidget);
          expect(find.text(id), findsOneWidget);
        }
        expect(find.text('future_unknown_condition'), findsOneWidget);
        expect(
          find.text('zombieCondition_future_unknown_condition'),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final entry in _copy.entries) {
    for (final zombieMode in [false, true]) {
      testWidgets(
        '${entry.key} overview distinguishes ${zombieMode ? 'zombie' : 'plant'} '
        'seed slots, conveyor and seed rain',
        (tester) async {
          tester.view.physicalSize = const Size(900, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final locale = Locale(entry.key);
          final level = _level(zombieMode: zombieMode);
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(platform: TargetPlatform.iOS),
              home: LevelOverviewDialog(
                levelFile: level,
                parsed: LevelParser.parseLevel(level),
                fileName: 'overview-copy.json',
                onClose: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();

          final copy = entry.value;
          final lists = _listCopy[entry.key]!;
          expect(
            find.text(zombieMode ? copy.zombies : copy.plants),
            findsOneWidget,
          );
          expect(
            find.text(zombieMode ? copy.plants : copy.zombies),
            findsNothing,
          );
          expect(find.text(copy.conveyor), findsOneWidget);
          expect(find.text(lists.white), findsOneWidget);
          expect(find.text(lists.black), findsOneWidget);
          expect(find.text(lists.plants), findsOneWidget);
          expect(find.text(lists.zombies), findsOneWidget);
          expect(
            find.text(lookupAppLocalizations(locale).rainContent),
            findsOneWidget,
          );
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Text &&
                  (widget.data?.startsWith('${copy.lawn}: ') ?? false),
            ),
            findsOneWidget,
          );
          expect(
            find.text(
              '${lookupAppLocalizations(locale).musicSuffix}: '
              '${copy.musicModule}',
            ),
            findsOneWidget,
          );
          expect(
            find.text(
              '${lookupAppLocalizations(locale).musicType}: ${copy.musicType}',
            ),
            findsOneWidget,
          );
          expect(find.textContaining('PresetPlantList'), findsNothing);
          expect(find.textContaining('(WhiteList)'), findsNothing);
          expect(find.textContaining('(BlackList)'), findsNothing);
          expect(find.textContaining('(PlantBlackList)'), findsNothing);
          expect(find.textContaining('(ZombieWhiteList)'), findsNothing);
          expect(
            find.text(lookupAppLocalizations(locale).plantsAvailableAtStart),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      '${entry.key} overview names unconfigured music tracks after their module',
      (tester) async {
        tester.view.physicalSize = const Size(900, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final locale = Locale(entry.key);
        final moduleName = ResourceNames.lookupWithLocale(
          entry.key,
          'musicSuffix_BGMe',
        );
        for (final track in const ['MainPath', 'MiniGame_A', 'MiniGame_B']) {
          final level = PvzLevelFile(
            objects: [
              PvzObject(
                aliases: const ['LevelDefinition'],
                objClass: 'LevelDefinition',
                objData: LevelDefinitionData(
                  stageModule: 'RTID(FallbackMusicStage@CurrentLevel)',
                  musicType: track,
                ).toJson(),
              ),
              PvzObject(
                aliases: const ['FallbackMusicStage'],
                objClass: 'ModernStageProperties',
                objData: const {
                  'MusicSuffix': 'BGMe',
                  'ResourceGroupNames': <String>[],
                  'GroupsToUnloadForAds': <String>[],
                },
              ),
            ],
          );
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(platform: TargetPlatform.iOS),
              home: LevelOverviewDialog(
                key: ValueKey(track),
                levelFile: level,
                parsed: LevelParser.parseLevel(level),
                fileName: 'overview-music-fallback.json',
                onClose: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text(
              '${lookupAppLocalizations(locale).musicType}: '
              '$moduleName',
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      '${entry.key} overview shows a seed chooser without field names',
      (tester) async {
        tester.view.physicalSize = const Size(900, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final level = PvzLevelFile(
          objects: [
            PvzObject(
              aliases: const ['LevelDefinition'],
              objClass: 'LevelDefinition',
              objData: LevelDefinitionData(
                stageModule: 'RTID(EgyptStage@LevelModules)',
                modules: const ['RTID(SeedBank@CurrentLevel)'],
              ).toJson(),
            ),
            PvzObject(
              aliases: const ['SeedBank'],
              objClass: 'SeedBankProperties',
              objData: const {'SelectionMethod': 'chooser'},
            ),
          ],
        );
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(entry.key),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: LevelOverviewDialog(
              levelFile: level,
              parsed: LevelParser.parseLevel(level),
              fileName: 'overview-chooser.json',
              onClose: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(_listCopy[entry.key]!.chooser), findsOneWidget);
        expect(find.textContaining('(Chooser)'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

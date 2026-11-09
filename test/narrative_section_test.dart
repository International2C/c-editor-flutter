import 'dart:io';

import 'package:c_editor/data/narrative_catalog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(NarrativeCatalog.clearCacheForTesting);

  test(
    'every dialogue belongs to exactly one ordered picker section',
    () async {
      const expectedSectionOrder = <NarrativeSectionId>[
        NarrativeSectionId.tutorialYard,
        NarrativeSectionId.ancientEgypt,
        NarrativeSectionId.pirateSeas,
        NarrativeSectionId.wildWest,
        NarrativeSectionId.kongfuWorld,
        NarrativeSectionId.farFuture,
        NarrativeSectionId.darkAges,
        NarrativeSectionId.bigWaveBeach,
        NarrativeSectionId.frostbiteCaves,
        NarrativeSectionId.skyCity,
        NarrativeSectionId.lostCity,
        NarrativeSectionId.neonMixtapeTour,
        NarrativeSectionId.jurassicMarsh,
        NarrativeSectionId.modernDay,
        NarrativeSectionId.steamAges,
        NarrativeSectionId.renaissanceAges,
        NarrativeSectionId.heianAges,
        NarrativeSectionId.underwaterWorld,
        NarrativeSectionId.moonBase,
        NarrativeSectionId.memoryImport,
        NarrativeSectionId.memorySeason27,
        NarrativeSectionId.memorySeason28,
        NarrativeSectionId.memorySeason29,
        NarrativeSectionId.memorySeason30,
        NarrativeSectionId.memorySeason31,
        NarrativeSectionId.memorySeason32,
        NarrativeSectionId.secretRealm,
        NarrativeSectionId.twoPlayerDuel,
        NarrativeSectionId.pennysPursuit,
        NarrativeSectionId.endlessModes,
        NarrativeSectionId.pvpMode,
        NarrativeSectionId.cardClash,
        NarrativeSectionId.plantEncounter,
        NarrativeSectionId.travelLog,
        NarrativeSectionId.zenGarden,
        NarrativeSectionId.pinataParty,
        NarrativeSectionId.systemTutorials,
      ];
      const expectedCounts = <NarrativeSectionId, int>{
        NarrativeSectionId.tutorialYard: 2,
        NarrativeSectionId.ancientEgypt: 46,
        NarrativeSectionId.pirateSeas: 22,
        NarrativeSectionId.wildWest: 24,
        NarrativeSectionId.kongfuWorld: 13,
        NarrativeSectionId.farFuture: 17,
        NarrativeSectionId.darkAges: 13,
        NarrativeSectionId.bigWaveBeach: 13,
        NarrativeSectionId.frostbiteCaves: 15,
        NarrativeSectionId.skyCity: 14,
        NarrativeSectionId.lostCity: 11,
        NarrativeSectionId.neonMixtapeTour: 11,
        NarrativeSectionId.jurassicMarsh: 13,
        NarrativeSectionId.modernDay: 22,
        NarrativeSectionId.steamAges: 8,
        NarrativeSectionId.renaissanceAges: 8,
        NarrativeSectionId.heianAges: 10,
        NarrativeSectionId.underwaterWorld: 20,
        NarrativeSectionId.moonBase: 20,
        NarrativeSectionId.memoryImport: 3,
        NarrativeSectionId.memorySeason27: 16,
        NarrativeSectionId.memorySeason28: 16,
        NarrativeSectionId.memorySeason29: 16,
        NarrativeSectionId.memorySeason30: 15,
        NarrativeSectionId.memorySeason31: 15,
        NarrativeSectionId.memorySeason32: 15,
        NarrativeSectionId.secretRealm: 31,
        NarrativeSectionId.twoPlayerDuel: 3,
        NarrativeSectionId.pennysPursuit: 2,
        NarrativeSectionId.endlessModes: 24,
        NarrativeSectionId.pvpMode: 23,
        NarrativeSectionId.cardClash: 4,
        NarrativeSectionId.plantEncounter: 19,
        NarrativeSectionId.travelLog: 22,
        NarrativeSectionId.zenGarden: 4,
        NarrativeSectionId.pinataParty: 9,
        NarrativeSectionId.systemTutorials: 130,
      };
      const expectedCategoryCounts = <NarrativeCategory, int>{
        NarrativeCategory.mainWorlds: 302,
        NarrativeCategory.memoryLane: 96,
        NarrativeCategory.otherModes: 141,
        NarrativeCategory.systemTutorials: 130,
      };

      for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
        final catalog = await NarrativeCatalog.load(locale);
        final sections = catalog.sectionsForCategory(NarrativeCategory.all);
        expect(sections.map((section) => section.id), expectedSectionOrder);

        final grouped = <NarrativeEntry>[];
        for (final section in sections) {
          final entries = catalog.entriesForSection(section.id);
          expect(entries, hasLength(expectedCounts[section.id]!));
          expect(File(section.iconAsset).existsSync(), isTrue);
          for (final entry in entries) {
            expect(catalog.sectionForEntry(entry).id, section.id);
            expect(catalog.displayCategory(entry), section.category);
            expect(catalog.displayIcon(entry), section.iconAsset);
          }
          grouped.addAll(entries);
        }

        expect(grouped, hasLength(catalog.dialogues.length));
        expect(grouped.toSet(), hasLength(catalog.dialogues.length));
        expect(grouped.toSet(), containsAll(catalog.dialogues));
        for (final expected in expectedCategoryCounts.entries) {
          final entries = catalog.forCategory(expected.key);
          expect(entries, hasLength(expected.value));
          expect(
            entries.every(
              (entry) => catalog.displayCategory(entry) == expected.key,
            ),
            isTrue,
          );
        }
      }
    },
  );

  test(
    'mode tutorials lead their sections and secret realms use release order',
    () async {
      final catalog = await NarrativeCatalog.load(const Locale('zh'));

      const leadingTutorials = <NarrativeSectionId, String>{
        NarrativeSectionId.memoryImport: 'TUTORIAL_PVZ1_INTRO',
        NarrativeSectionId.secretRealm: 'TUTORIAL_PVZ2_UNCHARTED_MODE_INTRO',
        NarrativeSectionId.pvpMode: 'TUTORIAL_PVP_INTRO',
        NarrativeSectionId.twoPlayerDuel: 'TUTORIAL_NEW_PVP_INTRO',
        NarrativeSectionId.pennysPursuit: 'TUTORIAL_RIFT_INTRO',
        NarrativeSectionId.cardClash: 'TUTORIAL_CARD_GAME_INTRO',
        NarrativeSectionId.travelLog: 'TUTORIAL_TRAVELLOG_INTRO',
      };
      for (final entry in leadingTutorials.entries) {
        expect(catalog.entriesForSection(entry.key).first.groupId, entry.value);
      }

      final secretRealm = catalog.entriesForSection(
        NarrativeSectionId.secretRealm,
      );
      final releaseBuckets = secretRealm
          .map((entry) => _secretRealmReleaseBucket(entry.groupId))
          .toList();
      expect(releaseBuckets, orderedEquals([...releaseBuckets]..sort()));
    },
  );

  test('endless mode and numbered siblings use their intended order', () async {
    const endlessOrder = <String>[
      'DANGER_ROOM_TUTORIAL',
      'DANGER_ROOM_INTROWRAPUP',
      'DANGER_ROOM_POWER',
      'DANGER_ROOM_SUCCESS',
      'DANGER_ROOM_FAILURE',
      'DANGER_ROOM_LAWNMOWER_SUCCESS',
      'DANGER_ROOM_INTRO_EGYPT',
      'DANGER_ROOM_INTRO_PIRATE',
      'DANGER_ROOM_INTRO_COWBOY',
      'DANGER_ROOM_INTRO_FUTURE',
      'DANGER_ROOM_INTRO_DARK',
      'DANGER_ROOM_INTRO_BEACH',
      'DANGER_ROOM_INTRO_ICEAGE',
      'DANGER_ROOM_INTRO_LOSTCITY',
      'DANGER_ROOM_INTRO_EIGHTIES',
      'DANGER_ROOM_INTRO_DINO',
      'DANGER_ROOM_INTRO_MODERN',
      'DANGER_ROOM_INTRO_FESTIVAL',
      'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_ONE',
      'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_TWO',
      'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_THREE',
      'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_FOUR',
      'NEW_DANGER_ROOM_INTRO',
      'DANGERROOM_SELECT_TUTORIAL',
    ];
    const electricCurrantOrder = <String>[
      'EPIC_QUEST_ELECTRICCURRANT_1_INTRO',
      'EPIC_QUEST_ELECTRICCURRANT_2_INTRO',
      'EPIC_QUEST_ELECTRICCURRANT_4_INTRO',
      'EPIC_QUEST_ELECTRICCURRANT_5_INTRO',
      'EPIC_QUEST_ELECTRICCURRANT_6_INTRO',
      'EPIC_QUEST_ELECTRICCURRANT_9_INTRO',
      'EPIC_QUEST_ELECTRICCURRANT_10_INTRO',
      'EPIC_QUEST_ELECTRICCURRANT_10_OUTRO',
    ];
    const epicQuestSeriesOrder = <String>[
      'GOLDBLOOM',
      'BEGHOULED_BLITZ_001',
      'ELECTRICCURRANT',
      'GEMJAM',
    ];

    for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
      final catalog = await NarrativeCatalog.load(locale);
      expect(
        catalog
            .entriesForSection(NarrativeSectionId.endlessModes)
            .map((entry) => entry.groupId),
        endlessOrder,
      );
      for (final entries in [
        catalog.entriesForSection(NarrativeSectionId.travelLog),
        catalog.forCategory(NarrativeCategory.otherModes),
        catalog.forCategory(NarrativeCategory.all),
      ]) {
        expect(
          entries
              .where(
                (entry) =>
                    entry.groupId.startsWith('EPIC_QUEST_ELECTRICCURRANT_'),
              )
              .map((entry) => entry.groupId),
          electricCurrantOrder,
        );
      }
      final epicQuestSeries = catalog
          .entriesForSection(NarrativeSectionId.travelLog)
          .where((entry) => entry.groupId.startsWith('EPIC_QUEST_'))
          .map((entry) {
            final id = entry.groupId;
            if (id.startsWith('EPIC_QUEST_GOLDBLOOM_')) return 'GOLDBLOOM';
            if (id.startsWith('EPIC_QUEST_BEGHOULED_BLITZ_')) {
              return 'BEGHOULED_BLITZ_001';
            }
            if (id.startsWith('EPIC_QUEST_ELECTRICCURRANT_')) {
              return 'ELECTRICCURRANT';
            }
            if (id.startsWith('EPIC_QUEST_GEMJAM_')) return 'GEMJAM';
            return id;
          })
          .toSet()
          .toList(growable: false);
      expect(epicQuestSeries, epicQuestSeriesOrder);
      for (final section in catalog.sectionsForCategory(
        NarrativeCategory.all,
      )) {
        if (section.category == NarrativeCategory.mainWorlds) continue;
        final siblingGroups = <String, List<NarrativeEntry>>{};
        for (final entry in catalog.entriesForSection(section.id)) {
          siblingGroups
              .putIfAbsent(_naturalTestShape(entry.groupId), () => [])
              .add(entry);
        }
        for (final siblings in siblingGroups.values.where(
          (entries) => entries.length > 1,
        )) {
          for (var index = 1; index < siblings.length; index++) {
            expect(
              _compareNaturalTestIds(
                siblings[index - 1].groupId,
                siblings[index].groupId,
              ),
              lessThanOrEqualTo(0),
              reason:
                  '${section.id.name}: ${siblings[index - 1].groupId} must precede ${siblings[index].groupId}',
            );
          }
        }
      }
      expect(
        catalog.sectionForEntry(catalog.dialogues.first).iconAsset,
        'assets/images/round_icons/Stage_Modern.webp',
      );
      expect(
        catalog.dialogues
            .expand((entry) => entry.lines)
            .map((line) => line.key),
        isNot(
          anyOf(
            contains('GRAVITY_TUTORIAL_PLANT_COSMICSAUCER'),
            contains('ARENA_TUTORIAL_PLANT_PEASHOOTER'),
          ),
        ),
      );
    }

    final zh = await NarrativeCatalog.load(const Locale('zh'));
    expect(
      zh.strings.sectionLabel(
        zh.sectionsForCategory(NarrativeCategory.memoryLane).first,
      ),
      '引入剧情',
    );
    expect(zh.findByValue('DANGER_ROOM_TUTORIAL')?.title, '无尽地带 - 初始植物选择');
    expect(zh.findByValue('DANGER_ROOM_INTROWRAPUP')?.title, '无尽地带 - 植物选择完成');
    expect(zh.findByValue('DANGER_ROOM_SUCCESS')?.title, '无尽地带 - 过关成功');
    expect(zh.findByValue('DANGER_ROOM_FAILURE')?.title, '无尽地带 - 过关失败');
  });

  test('Egypt and Zen Garden follow their narrative progression', () async {
    const egyptOrder = <String>[
      'FRESHINTRO_EGYPT_DAY1',
      'FRESHINTRO_ZOMBIE_INTRO',
      'FRESHINTRO_PLANTFOOD_INTRO',
      'FRESHINTRO_END_INTRO',
      'EAT_PLANTFOOD_INTRO',
      'USE_PLANTFOOD_INTRO',
      'EGYPT_ICE_INTRO',
      'EGYPT_STANDSTORM_INTRO',
      'EGYPT_CAMEL_INTRO',
      'TUTORIAL_EGYPT6_INTRO',
      'EAT_PLANTFOOD1_INTRO',
      'USE_PLANTFOOD1_INTRO',
      'LEGACY_NUMBERED_SEQUENCE_EGYPT_DAY7',
      'TUTORIAL_EGYPT8_INTRO',
      'EGYPT_TOMB_INTRO',
      'EGYPT_ZOMBIENOTE',
      'EGYPT_INTRO_ZOMBOSS',
      'EGYPT_OUTRO_ZOMBOSS',
      'EGYPT_INTRO_FIRSTLEVEL',
      'LEGACY_NUMBERED_SEQUENCE_EGYPT_DAY1_PLANTFOOD_TUTORIAL',
      'LEGACY_NUMBERED_SEQUENCE_EGYPT_DAY1_PLANTFOOD_FOLLOWUP',
      'LEGACY_NUMBERED_SEQUENCE_EGYPT_DAY1_PLANT_EATEN_PROMPT',
      'EGYPT_WORLDMAP_INTRO',
      'EGYPT_INTRO_GARGANTUAR',
      'EGYPT_OUTRO_GARGANTUAR',
      'EGYPT_OUTRO_DANGER_ROOM_KEY',
      'BUY_POWERUPS',
      'EGYPT_CHALLENGE_MINIGAME_B',
      'WORLDMAP_PLANTGJ_INTRO',
      'EGYPT_CHALLENGE_LASTSTAND_A',
      'EGYPT_CHALLENGE_CONVEYOR_INTRO',
      'EGYPT_CHALLENGE_CONVEYOR_OUTRO',
      'EGYPT_INTRO_LASTLEVEL',
      'EGYPT_OUTRO_LASTTLEVEL',
      'EGYPT_CHALLENGE_MINIGAME_C',
      'EGYPT_CHALLENGE_PRESET_A',
      'EGYPT_CHALLENGE_PRESET_B',
      'EGYPT_CHALLENGE_PRESET_C',
      'EGYPT_CHALLENGE_PROTECTPLANTS_A',
      'EGYPT_CHALLENGE_PROTECTPLANTS_B',
      'EGYPT_CHALLENGE_PROTECTPLANTS_C',
      'EGYPT_CHALLENGE_LASTSTAND_B',
      'EGYPT_CHALLENGE_LASTSTAND_C',
      'EGYPT_CHALLENGE_MINIGAME_A',
      'EYGPT_INTRO_ZOMBOSS',
      'EYGPT_OUTRO_ZOMBOSS',
    ];
    const zenGardenOrder = <String>[
      'ZEN_GARDEN_MARIGOLD_TUTORIAL_WELCOME',
      'ZEN_GARDEN_MARIGOLD_TUTORIAL_SPEED_UP',
      'ZEN_GARDEN_INTRO_TUTORIAL_SPEED_UP',
      'ZEN_GARDEN_INTRO_TUTORIAL_WELCOME',
    ];

    for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
      final catalog = await NarrativeCatalog.load(locale);
      expect(
        catalog
            .entriesForSection(NarrativeSectionId.ancientEgypt)
            .map((entry) => entry.groupId),
        egyptOrder,
      );
      expect(
        catalog
            .entriesForSection(NarrativeSectionId.zenGarden)
            .map((entry) => entry.groupId),
        zenGardenOrder,
      );
    }
  });

  test('other main worlds follow day and gameplay order', () async {
    const expectedOrders = <NarrativeSectionId, List<String>>{
      NarrativeSectionId.pirateSeas: [
        'PIRATE_INTRO_FIRSTLEVEL',
        'PIRATE_WORLDMAP_INTRO',
        'PIRATE_CHALLENGE_PRESET_A',
        'LEGACY_NUMBERED_SEQUENCE_PIRATE_DAY3',
        'PIRATE_OUTRO_DANGER_ROOM_KEY',
        'PIRATE_ZOMBIENOTE',
        'PIRATE_INTRO_GARGANTUAR',
        'PIRATE_OUTRO_GARGANTUAR',
        'PIRATE_CHALLENGE_MINIGAME_A',
        'PIRATE_CHALLENGE_PROTECTPLANTS_A',
        'PIRATE_CHALLENGE_LASTSTAND_A',
        'PIRATE_INTRO_ZOMBOSS',
        'PIRATE_OUTRO_ZOMBOSS',
        'PIRATE_OUTRO_LASTTLEVEL',
        'PIRATE_CHALLENGE_LASTSTAND_B',
        'PIRATE_CHALLENGE_LASTSTAND_C',
        'PIRATE_CHALLENGE_MINIGAME_B',
        'PIRATE_CHALLENGE_MINIGAME_C',
        'PIRATE_CHALLENGE_PRESET_B',
        'PIRATE_CHALLENGE_PRESET_C',
        'PIRATE_CHALLENGE_PROTECTPLANTS_B',
        'PIRATE_CHALLENGE_PROTECTPLANTS_C',
      ],
      NarrativeSectionId.darkAges: [
        'DARK_INTRO_FIRSTLEVEL',
        'DARK_INTRO_HYPNOSHROOM',
        'DARK_INTRO_FUMESHROOM',
        'DARK_INTRO_EVILPOTIONS',
        'DARK_ZOMBIENOTE',
        'DARK_INTRO_GARGANTUAR',
        'DARK_OUTRO_DANGER_ROOM_KEY',
        'DARK_INTRO_PEANUT',
        'DARK_INTRO_MAGNETSHROOM',
        'DARK_INTRO_ZOMBOSS',
        'DARK_OUTRO_ZOMBOSS',
        'DARK_HYPNOSHROOM_INTRO',
        'DARK_INTRO_SUNSHROOM_CHAT',
      ],
      NarrativeSectionId.kongfuWorld: [
        'KONGFU_INTRO_FIRSTLEVEL',
        'KONGFU_INTRO_KONGFU_LEVEL6',
        'KONGFU_INTRO_KONGFU_LEVEL9',
        'KONGFU_CHALLENGE_LASTSTAND_A',
        'KONGFU_INTRO_KONGFU_LEVEL32',
        'KONGFU_INTRO_KONGFU_LEVEL31',
        'KONGFU_INTRO_KONGFU_LEVEL33',
        'KONGFU_INTRO_KONGFU_LEVEL34',
        'KONGFU_INTRO_KONGFU_LEVEL35',
        'KONGFU_INTRO_KONGFU_LEVEL36',
        'KONGFU_INTRO_KONGFU_LEVEL14',
        'KONGFU_INTRO_KONGFU_LEVEL15',
        'KONGFU_OUTRO_KONGFU_LEVEL15',
      ],
      NarrativeSectionId.skyCity: [
        'SKYCITY_FIRSTLEVEL_INTRO',
        'CANNON_USE_INTRO',
        'CANNON_USE_END_INTRO',
        'POOYAN_CHOOSING',
        'POOYAN_CHOOSED',
        'POOYAN_ZOMBIE_GARGANTUAR',
        'BESIEGE_INTRO',
        'BOX_INTRO',
        'BOX_PLANTED_INTRO',
        'BOX_SHOVELED_INTRO',
        'SHOWREGINSKY_INTRO',
        'SHOWSHIPHEALTH_INTRO',
        'SHOWTHUNDER_INTRO',
        'PLANTTHUNDER_INTRO',
      ],
      NarrativeSectionId.neonMixtapeTour: [
        'EIGHTIES_1_INTRO',
        'EIGHTIES_2_INTRO',
        'EIGHTIES_3_INTRO',
        'EIGHTIES_15_OUTRO',
        'EIGHTIES_16_INTRO',
        'EIGHTIES_17_INTRO',
        'EIGHTIES_OUTRO_DANGER_ROOM_KEY',
        'EIGHTIES_22_INTRO',
        'EIGHTIES_32_INTRO',
        'EIGHTIES_32_OUTRO',
        'EIGHTIES_26_INTRO',
      ],
    };

    for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
      final catalog = await NarrativeCatalog.load(locale);
      for (final expected in expectedOrders.entries) {
        expect(
          catalog.entriesForSection(expected.key).map((entry) => entry.groupId),
          expected.value,
          reason: '${locale.languageCode}: ${expected.key.name}',
        );
      }
    }
  });

  test('all other main-world day labels stay in ascending order', () async {
    final catalog = await NarrativeCatalog.load(const Locale('zh'));
    final dayPattern = RegExp(r'第(\d+)[天夜]');
    final standaloneLegacyPattern = RegExp(r'(?:（|，)旧版(?:[），·])');

    for (final section in catalog.sectionsForCategory(
      NarrativeCategory.mainWorlds,
    )) {
      if (section.id == NarrativeSectionId.ancientEgypt) continue;
      final entries = catalog.entriesForSection(section.id);
      var previousDay = -1;
      var reachedUnusedTail = false;

      for (final entry in entries) {
        final title = entry.title;
        final unused = title.contains('未使用');
        if (reachedUnusedTail) {
          expect(
            unused,
            isTrue,
            reason: '${section.id.name}: unused dialogue must stay last',
          );
        }
        if (unused) {
          reachedUnusedTail = true;
          continue;
        }
        if (standaloneLegacyPattern.hasMatch(title)) continue;

        final match = dayPattern.firstMatch(title);
        if (match == null) continue;
        final day = int.parse(match.group(1)!);
        expect(
          day,
          greaterThanOrEqualTo(previousDay),
          reason: '${section.id.name}: $title follows day $previousDay',
        );
        previousDay = day;
      }
    }
  });
}

int _secretRealmReleaseBucket(String id) {
  if (id == 'TUTORIAL_PVZ2_UNCHARTED_MODE_INTRO') return 0;
  if (id == 'ANNIVERSARY_UNCHARTED_EVENT_TUTORIAL' ||
      id.startsWith('HALLOWEEN_')) {
    return 2;
  }
  if (id.startsWith('CHILDRENSDAY_')) return 4;
  if (id.startsWith('SPECIAL_UNCHARTED_')) return 5;
  if (id.startsWith('CHRISTMAS_202512_') ||
      id.startsWith('ICEAGE_UNCHARTED_') ||
      id.startsWith('UNCHARTED_ICEAGE_')) {
    return 7;
  }
  if (id.startsWith('SPRING_FESTIVAL_2024_')) return 8;
  if (id.startsWith('ARBORDAY_')) return 9;
  if (id.startsWith('NEEDFORSPEED_')) return 10;
  if (id.startsWith('NO42_') || id.startsWith('UNCHARTED_NO42_')) return 11;
  if (id.startsWith('MAUSOLEUM_')) return 15;
  if (id.startsWith('ARENA_')) return 16;
  return 99;
}

String _naturalTestShape(String value) => value
    .replaceFirst(RegExp(r'_(INTRO|OUTRO)$'), '_PHASE')
    .replaceAll(RegExp(r'\d+'), '#');

int _compareNaturalTestIds(String a, String b) {
  final numberPattern = RegExp(r'\d+');
  final aNumbers = numberPattern
      .allMatches(a)
      .map((match) => int.parse(match.group(0)!))
      .toList(growable: false);
  final bNumbers = numberPattern
      .allMatches(b)
      .map((match) => int.parse(match.group(0)!))
      .toList(growable: false);
  for (
    var index = 0;
    index < aNumbers.length && index < bNumbers.length;
    index++
  ) {
    final result = aNumbers[index].compareTo(bNumbers[index]);
    if (result != 0) return result;
  }
  final lengthResult = aNumbers.length.compareTo(bNumbers.length);
  if (lengthResult != 0) return lengthResult;
  int phase(String value) => value.endsWith('_INTRO')
      ? 0
      : value.endsWith('_OUTRO')
      ? 1
      : 2;
  return phase(a).compareTo(phase(b));
}

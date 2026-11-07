import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/screens/select/narrative_preview_screen.dart';
import 'package:c_editor/screens/select/narrative_selection_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(NarrativeCatalog.clearCacheForTesting);

  test(
    'dialogue search matches phrases across strikethrough formatting',
    () async {
      final catalog = await NarrativeCatalog.load(const Locale('en'));
      final results = searchNarratives(
        catalog,
        NarrativeCategory.all,
        'crazy brilliant',
      );
      expect(
        results.byContent.any(
          (entry) => entry.lines.any(
            (line) => line.key == 'NARRATIVE_TRANS_GENOSIS_OPEN_TUTORIAL_2',
          ),
        ),
        isTrue,
      );
    },
  );

  test('dialogue search ignores color controls in Chinese text', () async {
    final catalog = await NarrativeCatalog.load(const Locale('zh'));
    final results = searchNarratives(
      catalog,
      NarrativeCategory.all,
      '前所未有的4 阶僵尸终于被我研制出来了',
    );
    expect(
      results.byContent.map((entry) => entry.groupId),
      contains('ZOMBIE_INTRO_LEVEL4'),
    );
    expect(
      searchNarratives(catalog, NarrativeCategory.all, '^oldclr').isEmpty,
      isTrue,
    );
  });

  test(
    'three locale catalogues stay structurally aligned and exclude Heroes',
    () async {
      final zh = await NarrativeCatalog.load(const Locale('zh'));
      final en = await NarrativeCatalog.load(const Locale('en'));
      final ru = await NarrativeCatalog.load(const Locale('ru'));

      for (final catalog in [zh, en, ru]) {
        expect(catalog.dialogues, hasLength(669));
        expect(
          catalog.dialogues.where((entry) => entry.selectable),
          hasLength(668),
        );
        expect(
          catalog.dialogues.any(
            (entry) =>
                entry.number.startsWith('4.7.') ||
                entry.groupId.startsWith('HEROES_EVENT_'),
          ),
          isFalse,
        );
        expect(
          catalog.forCategory(NarrativeCategory.mainWorlds),
          hasLength(302),
        );
        expect(
          catalog.forCategory(NarrativeCategory.memoryLane),
          hasLength(96),
        );
        expect(
          catalog.forCategory(NarrativeCategory.otherModes),
          hasLength(141),
        );
        expect(
          catalog.forCategory(NarrativeCategory.systemTutorials),
          hasLength(130),
        );
        expect(
          catalog.dialogues
              .expand((entry) => entry.lines)
              .any(
                (line) => line.key.contains('重复项') || line.key.contains('源行'),
              ),
          isFalse,
          reason: 'Source-audit metadata must not leak into localized data.',
        );
      }

      List<String> structure(NarrativeCatalog catalog) => catalog.dialogues
          .map(
            (entry) => [
              entry.value.runtimeType,
              entry.value,
              entry.groupId,
              entry.number,
              entry.category.name,
              entry.iconAsset,
              entry.selectable,
              for (final line in entry.lines)
                '${line.key}/${line.kind.name}/${line.npc}',
            ].join('|'),
          )
          .toList(growable: false);

      expect(structure(en), structure(zh));
      expect(structure(ru), structure(zh));
      expect(en.strings.keys, zh.strings.keys);
      expect(ru.strings.keys, zh.strings.keys);
      expect(zh.strings.keys, isNot(contains('peaWarningTitle')));
      expect(zh.strings.keys, isNot(contains('peaWarning')));
      expect(
        zh.dialogues.any((entry) => entry.number.startsWith('3.6.')),
        isTrue,
        reason: 'Memory Lane Season 32 is part of the complete safe catalogue.',
      );
    },
  );

  test('annotated dialogue titles stay aligned across locales', () async {
    final catalogs = <String, NarrativeCatalog>{
      'zh': await NarrativeCatalog.load(const Locale('zh')),
      'en': await NarrativeCatalog.load(const Locale('en')),
      'ru': await NarrativeCatalog.load(const Locale('ru')),
    };
    const expectedTitles = <String, Map<String, String>>{
      'DINO_23_INTRO': {
        'zh': '恐龙危机 - 第23天（国际版，原始土豆地雷介绍）',
        'en':
            'Jurassic Marsh - Day 23 (International, Primal Potato Mine Introduction)',
        'ru':
            'Юрское Болото — день 23 (международная версия, представление: Первобытная Картофельная Мина)',
      },
      'UNCHARTED_ICEAGE_INTRO_ZOMBOSS_HUNTER': {
        'zh': '冰河再临 - 第4天（精英猎人僵尸介绍）',
        'en':
            'Frostbite Caves Resurgence - Day 4 (Elite Hunter Zombie Introduction)',
        'ru':
            'Замороженные Пещеры (реалм) — день 4 (представление: Элитный охотник)',
      },
      'UNCHARTED_ICEAGE_INTRO_ZOMBOSS_WEASELHOARDER': {
        'zh': '冰河再临 - 第6天（精英冰鼬介绍）',
        'en':
            'Frostbite Caves Resurgence - Day 6 (Elite Ice Weasel Introduction)',
        'ru':
            'Замороженные Пещеры (реалм) — день 6 (представление: Элитная ласка)',
      },
      'UNCHARTED_ICEAGE_INTRO_ZOMBOSS_CHIEF': {
        'zh': '冰河再临 - 第8天（精英冰风酋长僵尸介绍）',
        'en':
            'Frostbite Caves Resurgence - Day 8 (Elite Chief Ice Wind Zombie Introduction)',
        'ru':
            'Замороженные Пещеры (реалм) — день 8 (представление: Элитный шеф ледяных ветров)',
      },
      'MAUSOLEUM_2_INTRO': {
        'zh': '地宫遗迹 - 第2天（坑道介绍 1）',
        'en': 'Underground Palace Ruins - Day 2 (Pathways Introduction 1)',
        'ru':
            'Руины Подземного дворца — день 2 (представление: Тоннели Подземного Дворца 1)',
      },
      'MAUSOLEUM_3_INTRO': {
        'zh': '地宫遗迹 - 第3天（坑道介绍 2）',
        'en': 'Underground Palace Ruins - Day 3 (Pathways Introduction 2)',
        'ru':
            'Руины Подземного дворца — день 3 (представление: Тоннели Подземного Дворца 2)',
      },
      'MAUSOLEUM_5_INTRO': {
        'zh': '地宫遗迹 - 第5天（弓箭手僵尸、秘境胡萝卜导弹车介绍）',
        'en':
            'Underground Palace Ruins - Day 5 (Archer Zombie and Secret Realm Carrotillery Introduction)',
        'ru':
            'Руины Подземного дворца — день 5 (представление: Зомби-лучник и Морковортиллерия из параллельной вселенной)',
      },
      'MAUSOLEUM_7_INTRO': {
        'zh': '地宫遗迹 - 第7天（秦俑、魔藤介绍）',
        'en':
            'Underground Palace Ruins - Day 7 (Terracotta Warriors and Magic Vine Introduction)',
        'ru':
            'Руины Подземного дворца — день 7 (представление: Терракотовая армия и Магическая Лоза)',
      },
      'MAUSOLEUM_10_INTRO': {
        'zh': '地宫遗迹 - 第10天（僵王战）',
        'en': 'Underground Palace Ruins - Day 10 (Zomboss Battle)',
        'ru': 'Руины Подземного дворца — день 10 (битва с доктором Зомбоссом)',
      },
    };

    for (final expected in expectedTitles.entries) {
      for (final locale in catalogs.entries) {
        expect(
          locale.value.dialogues
              .singleWhere((entry) => entry.groupId == expected.key)
              .title,
          expected.value[locale.key],
          reason: '${expected.key}/${locale.key}',
        );
      }
    }
  });

  test('duplicate source keys use the game-effective value once', () async {
    final catalogs = [
      await NarrativeCatalog.load(const Locale('zh')),
      await NarrativeCatalog.load(const Locale('en')),
      await NarrativeCatalog.load(const Locale('ru')),
    ];

    for (final catalog in catalogs) {
      for (final dialogue in catalog.dialogues) {
        final contentKeys = dialogue.lines
            .where((line) => line.kind != NarrativeLineKind.stage)
            .map((line) => line.key)
            .toList(growable: false);
        expect(
          contentKeys.toSet(),
          hasLength(contentKeys.length),
          reason: '${dialogue.groupId} must resolve each content key once.',
        );

        final lineSignatures = dialogue.lines
            .map(
              (line) => (
                line.key,
                line.kind,
                line.text,
                line.speaker,
                line.emotion,
                line.npc,
              ),
            )
            .toList(growable: false);
        expect(
          lineSignatures.toSet(),
          hasLength(lineSignatures.length),
          reason: '${dialogue.groupId} must not repeat an identical line.',
        );
      }

      expect(
        catalog.dialogues
            .singleWhere((entry) => entry.groupId == 'JOUST_OPEN_TUTORIAL')
            .lines,
        hasLength(3),
      );
      expect(
        catalog.dialogues
            .singleWhere((entry) => entry.groupId == 'JOUST_SELECT_TUTORIAL')
            .lines,
        hasLength(4),
      );

      NarrativeLine effectiveLine(String groupId, String key) => catalog
          .dialogues
          .singleWhere((entry) => entry.groupId == groupId)
          .lines
          .singleWhere(
            (line) => line.key == key && line.kind == NarrativeLineKind.speech,
          );

      expect(
        effectiveLine('HEIAN_13_INTRO', 'NARRATIVE_HEIAN_13_INTRO_3').npc,
        'crazydave',
      );
      expect(
        effectiveLine(
          'UNCHARTED_ICEAGE_OUTRO_ZOMBOSS_FINAL',
          'NARRATIVE_UNCHARTED_ICEAGE_OUTRO_ZOMBOSS_FINAL_4',
        ).npc,
        'crazydave',
      );
      for (final groupId in ['ATLANTIS_3_INTRO', 'HALLOWEEN_1_INTRO']) {
        final numberedKeys = catalog.dialogues
            .singleWhere((entry) => entry.groupId == groupId)
            .lines
            .where((line) => line.kind == NarrativeLineKind.speech)
            .map(
              (line) => int.parse(RegExp(r'_(\d+)$').firstMatch(line.key)![1]!),
            )
            .toList(growable: false);
        expect(numberedKeys, orderedEquals([...numberedKeys]..sort()));
      }
    }
  });

  test('all PvP map and Evil Dave dialogue stays in the PvP block', () async {
    final catalogs = [
      await NarrativeCatalog.load(const Locale('zh')),
      await NarrativeCatalog.load(const Locale('en')),
      await NarrativeCatalog.load(const Locale('ru')),
    ];

    for (final catalog in catalogs) {
      final pvp = catalog.dialogues
          .where((entry) => entry.groupId.startsWith('MAP_PVP'))
          .toList();
      expect(pvp, hasLength(11));
      expect(pvp.map((entry) => entry.number), [
        for (var index = 15; index <= 25; index++) '5.2.$index',
      ]);
      expect(
        pvp.every(
          (entry) =>
              entry.category == NarrativeCategory.otherModes &&
              entry.iconAsset.endsWith('/Mode_PvP.webp'),
        ),
        isTrue,
      );
      final indexes = pvp
          .map((entry) => catalog.dialogues.indexOf(entry))
          .toList();
      expect(indexes, [
        for (var index = indexes.first; index <= indexes.last; index++) index,
      ]);
    }

    expect(
      catalogs[0].dialogues
          .singleWhere(
            (entry) => entry.groupId == 'MAP_PVPEVILDAVID_START_INTRO',
          )
          .title,
      startsWith('对战模式 - '),
    );
  });

  test('related system tutorials remain in gameplay order', () async {
    const powerGestures = ['PINCH', 'FLICK', 'WIZARDFINGER'];
    const plantPuzzle = [
      'ELIMINATE_BLOCK_INTRO',
      'ELIMINATE_COLOR_INTRO',
      'ELIMINATE_INTRO',
      'ZOMBIE_INTRO_ELIMINATE_MISSIONFINISH',
      'ZOMBIE_INTRO_ELIMINATE_FREEZINGWIND',
      'ZOMBIE_INTRO_ELIMINATE_SPAWNSHIELD',
      'ZOMBIE_INTRO_ELIMINATE_STAGE11',
      'ZOMBIE_INTRO_ELIMINATE_STAGE12',
      'ZOMBIE_INTRO_ELIMINATE_STAGE21',
      'ZOMBIE_INTRO_ELIMINATE_STAGE22',
      'ZOMBIE_INTRO_ELIMINATE_STAGE31',
      'ZOMBIE_INTRO_ELIMINATE_STAGE32',
      'ZOMBIE_INTRO_ELIMINATE_STAGE41',
      'ZOMBIE_INTRO_ELIMINATE_STAGE42',
    ];

    for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
      final catalog = await NarrativeCatalog.load(locale);
      final ids = catalog
          .entriesForSection(NarrativeSectionId.systemTutorials)
          .map((entry) => entry.groupId)
          .toList(growable: false);

      void expectConsecutive(List<String> expected) {
        final start = ids.indexOf(expected.first);
        expect(start, isNonNegative);
        expect(ids.sublist(start, start + expected.length), expected);
      }

      expectConsecutive(powerGestures);
      expectConsecutive(const ['SEEDRAIN_DAVE_INTRO', 'SEEDRAIN_ACORN_INTRO']);
      expectConsecutive(plantPuzzle);
    }
  });

  test(
    'system feature tutorials form one consecutive series in every locale',
    () async {
      final zh = await NarrativeCatalog.load(const Locale('zh'));
      final expected = zh.dialogues
          .where(
            (entry) =>
                entry.title.startsWith('系统教程 - ') &&
                zh.sectionForEntry(entry).id ==
                    NarrativeSectionId.systemTutorials,
          )
          .map((entry) => entry.groupId)
          .toList();
      expect(expected, hasLength(32));
      expect(
        expected,
        containsAll(const [
          'UNLOCK_WORLD_1',
          'UNLOCK_WORLD_2',
          'TUTORIAL_CUSTOM_LEVEL_INTRO',
          'TUTORIAL_DAILY_REWARD_NEWPLAYER',
          'TUTORIAL_KLOTSKI_NEWPLAYER',
        ]),
      );

      for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
        final catalog = await NarrativeCatalog.load(locale);
        for (final entries in [
          catalog.entriesForSection(NarrativeSectionId.systemTutorials),
          catalog.forCategory(NarrativeCategory.all),
          searchNarratives(
            catalog,
            NarrativeCategory.systemTutorials,
            '',
          ).byTitle,
        ]) {
          final ids = entries.map((entry) => entry.groupId).toList();
          final start = ids.indexOf(expected.first);
          expect(start, isNonNegative);
          expect(
            ids.sublist(start, start + expected.length),
            expected,
            reason: locale.languageCode,
          );
        }
        final filteredExpected = expected
            .where((id) => id.contains('TUTORIAL_'))
            .toList();
        final searchIds = searchNarratives(
          catalog,
          NarrativeCategory.systemTutorials,
          'TUTORIAL_',
        ).byTitle.map((entry) => entry.groupId).toList();
        final start = searchIds.indexOf(filteredExpected.first);
        expect(start, isNonNegative);
        expect(
          searchIds.sublist(start, start + filteredExpected.length),
          filteredExpected,
        );
      }
    },
  );

  test('Russian catalogue has no substantive English fallbacks', () async {
    final en = await NarrativeCatalog.load(const Locale('en'));
    final ru = await NarrativeCatalog.load(const Locale('ru'));
    final untranslated = <String>[];

    for (
      var dialogueIndex = 0;
      dialogueIndex < en.dialogues.length;
      dialogueIndex += 1
    ) {
      final enDialogue = en.dialogues[dialogueIndex];
      final ruDialogue = ru.dialogues[dialogueIndex];
      if (enDialogue.title == ruDialogue.title) {
        untranslated.add('${enDialogue.groupId}: ${enDialogue.title}');
      }
      for (
        var lineIndex = 0;
        lineIndex < enDialogue.lines.length;
        lineIndex += 1
      ) {
        final enLine = enDialogue.lines[lineIndex];
        final ruLine = ruDialogue.lines[lineIndex];
        if (RegExp('[A-Za-z]').hasMatch(enLine.text) &&
            enLine.text == ruLine.text) {
          untranslated.add(
            '${enDialogue.groupId}/${enLine.key}: ${enLine.text}',
          );
        }
      }
    }

    expect(untranslated, isEmpty, reason: untranslated.join('\n'));
  });

  test(
    'invocation values retain their JSON types and unsafe start is disabled',
    () async {
      final catalog = await NarrativeCatalog.load(const Locale('en'));

      expect(catalog.findByValue(4000)?.value, isA<int>());
      expect(catalog.findByValue(1000450)?.value, isA<int>());
      expect(
        catalog.findByValue('FRESHINTRO_COLLECT_INTRO')?.value,
        isA<String>(),
      );
      expect(
        catalog.dialogues
            .singleWhere((entry) => entry.groupId == 'EGYPT_STAR_INTRO_OLD')
            .selectable,
        isFalse,
      );
    },
  );

  test('all generated mode and NPC image references exist', () async {
    final catalog = await NarrativeCatalog.load(const Locale('en'));
    final missing = <String>{};
    for (final entry in catalog.dialogues) {
      if (!File(entry.iconAsset).existsSync()) missing.add(entry.iconAsset);
      for (final npc in entry.characters) {
        final path = 'assets/images/npcs/npc_$npc.webp';
        if (!File(path).existsSync()) missing.add(path);
      }
    }
    expect(missing, isEmpty);
  });

  test(
    'manual original-text notes are present in all six English lines',
    () async {
      final catalog = await NarrativeCatalog.load(const Locale('en'));
      final notes = catalog.dialogues
          .expand((entry) => entry.lines)
          .where((line) => line.text.contains('Note: as in the original.'))
          .toList();
      expect(notes, hasLength(6));
      expect(
        notes.every((line) => line.kind == NarrativeLineKind.system),
        isTrue,
      );
    },
  );

  test(
    'search keeps title, content, and character matches separated',
    () async {
      final catalog = await NarrativeCatalog.load(const Locale('zh'));

      final title = searchNarratives(catalog, NarrativeCategory.all, '神秘埃及');
      expect(title.byTitle, isNotEmpty);

      final content = searchNarratives(catalog, NarrativeCategory.all, '脑子');
      expect(content.byContent, isNotEmpty);

      final speaker = searchNarratives(catalog, NarrativeCategory.all, '疯狂戴夫');
      expect(speaker.bySpeaker, isNotEmpty);

      final outlineNumber = searchNarratives(
        catalog,
        NarrativeCategory.all,
        '1.6.9',
      );
      expect(outlineNumber.isEmpty, isTrue);
    },
  );

  test('Penny variants are right-aligned and Dave variants stay left', () {
    expect(NarrativeLineView.isRightAlignedNpc('winnie'), isTrue);
    expect(NarrativeLineView.isRightAlignedNpc('winnieicon'), isTrue);
    expect(NarrativeLineView.isRightAlignedNpc('specialwinnie'), isTrue);
    expect(NarrativeLineView.isRightAlignedNpc('crazydave'), isFalse);
    expect(NarrativeLineView.isRightAlignedNpc('crazydaveicon'), isFalse);
    expect(NarrativeLineView.isRightAlignedNpc('zombossicon'), isFalse);
  });
}

import 'package:c_editor/data/music_type_catalog.dart';
import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/basic_info_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ResourceNames.ensureLoaded();
    await MusicSuffixCatalog.init();
  });

  test('catalog contains every guide and supplemental module', () {
    expect(MusicTypeCatalog.modules, hasLength(36));
    final halloween = MusicTypeCatalog.forSuffix('Halloween')!;
    expect(halloween.choices.map((choice) => choice.value), [
      'MainPath',
      'MiniGame_A',
      'MiniGame_B',
    ]);
    expect(halloween.noteKeys, contains('musicTypeNote_regularBossNoIntro'));
    expect(MusicTypeCatalog.forSuffix('modern')?.suffix, 'modern');
    expect(MusicTypeCatalog.forSuffix('Modern')?.suffix, 'modern');
    expect(MusicTypeCatalog.forSuffix('MAUSOLEUM')?.suffix, 'Mausoleum');
    expect(MusicTypeCatalog.forSuffix('ghostdom')?.suffix, 'Ghostdom');

    for (final expected in const [
      (
        suffix: 'ZCorp',
        labelKey: 'musicTypeLabel_zCorpChinese',
        zhLabel: '中文版Z公司',
      ),
      (suffix: 'SilkRoad', labelKey: 'musicTypeLabel_dunhuang', zhLabel: '敦煌'),
      (
        suffix: 'rift',
        labelKey: 'musicTypeLabel_zCorpInternational',
        zhLabel: '国际版Z公司',
      ),
    ]) {
      final module = MusicTypeCatalog.forSuffix(expected.suffix)!;
      expect(module.choices.map((choice) => choice.value), const [
        MusicTypeCatalog.mainPath,
        MusicTypeCatalog.miniGameA,
        MusicTypeCatalog.miniGameB,
      ]);
      expect(module.choices.map((choice) => choice.labelKey).toSet(), {
        expected.labelKey,
      });
      expect(
        ResourceNames.lookupWithLocale('zh', expected.labelKey),
        expected.zhLabel,
      );
      for (final locale in const ['en', 'zh', 'ru']) {
        expect(
          ResourceNames.lookupWithLocale(
            locale,
            'musicSuffix_${expected.suffix}',
          ),
          ResourceNames.lookupWithLocale(locale, expected.labelKey),
          reason: '${expected.suffix} title and label differ in $locale',
        );
      }
      expect(module.noteKeys, const ['musicTypeNote_regularBossNoIntro']);
    }

    expect(
      ResourceNames.lookupWithLocale('en', 'musicTypeLabel_brainiacManiac'),
      'Brainiac Maniac / Zombot Mark II',
    );

    final moon = MusicTypeCatalog.forSuffix('Moon')!;
    expect(moon.choices.map((choice) => choice.value), const [
      MusicTypeCatalog.mainPath,
      MusicTypeCatalog.miniGameA,
      MusicTypeCatalog.miniGameB,
      MusicTypeCatalog.miniGameC,
    ]);
    final moonMain = moon.choices.singleWhere(
      (choice) => choice.value == MusicTypeCatalog.mainPath,
    );
    final moonA = moon.choices.singleWhere(
      (choice) => choice.value == MusicTypeCatalog.miniGameA,
    );
    final moonB = moon.choices.singleWhere(
      (choice) => choice.value == MusicTypeCatalog.miniGameB,
    );
    final moonC = moon.choices.singleWhere(
      (choice) => choice.value == MusicTypeCatalog.miniGameC,
    );
    expect(moonMain.labelKey, 'musicTypeLabel_main');
    expect(moonA.labelKey, 'musicTypeLabel_moonUb');
    expect(moonB.labelKey, 'musicTypeLabel_moonMg');
    expect(moonC.labelKey, 'musicTypeLabel_moonDay24FinalWave');
    expect(
      ResourceNames.lookupWithLocale('zh', moonC.labelKey),
      '月球基地-第24天（最后一波音乐变奏）',
    );
    expect(
      ResourceNames.lookupWithLocale('zh', moonA.labelKey),
      '月球基地-终“僵”之战 / Ultimate Battle',
    );
    expect(
      ResourceNames.lookupWithLocale('en', moonB.labelKey),
      'Moon BaseZ - Demonstration Mini Game',
    );
    final eighties = MusicTypeCatalog.forSuffix('Eighties')!;
    expect(
      eighties.choices.map((choice) => choice.value),
      MusicTypeCatalog.fallbackChoices.map((choice) => choice.value),
    );
    expect(eighties.choices.map((choice) => choice.labelKey).toSet(), {
      'musicSuffix_Eighties',
    });
    expect(
      ResourceNames.lookupWithLocale('zh', eighties.noteKeys.single),
      '特殊僵尸对应的音乐需要在「普通出怪」事件中选择',
    );
  });

  test(
    'unconfigured modules default to three tracks using the suffix name',
    () {
      expect(MusicTypeCatalog.forSuffix('BGMe'), isNull);
      final choices = MusicTypeCatalog.fallbackChoicesForSuffix('BGMe');
      expect(choices.map((choice) => choice.value), const [
        MusicTypeCatalog.mainPath,
        MusicTypeCatalog.miniGameA,
        MusicTypeCatalog.miniGameB,
      ]);
      expect(choices.map((choice) => choice.labelKey).toSet(), {
        'musicSuffix_BGMe',
      });
      for (final locale in const ['en', 'zh', 'ru']) {
        expect(
          ResourceNames.lookupWithLocale(locale, choices.first.labelKey),
          isNot(choices.first.labelKey),
        );
      }
      expect(
        MusicTypeCatalog.fallbackChoicesForSuffix(
          ' EIGHTIES ',
        ).map((choice) => choice.labelKey).toSet(),
        {'musicSuffix_Eighties'},
      );
      expect(
        MusicTypeCatalog.fallbackChoicesForSuffix(
          ' ',
        ).map((choice) => choice.labelKey),
        const ['MainPath', 'MiniGame_A', 'MiniGame_B'],
      );
    },
  );

  test('all catalog labels and notes are localized', () {
    final keys = <String>{
      for (final module in MusicTypeCatalog.modules)
        for (final choice in module.choices) choice.labelKey,
    };
    for (final module in MusicTypeCatalog.modules) {
      keys.addAll(module.noteKeys);
    }

    for (final locale in const ['en', 'zh', 'ru']) {
      for (final key in keys) {
        expect(
          ResourceNames.lookupWithLocale(locale, key),
          isNot(key),
          reason: '$locale is missing $key',
        );
      }
    }
  });

  test('obsolete default, casing, and abstract label keys are removed', () {
    const obsoleteKeys = [
      'musicSuffix_default',
      'musicSuffix_Modern',
      'musicSuffix_mausoleum',
      'musicSuffix_ghostdom',
      'musicTypeLabel_fearless2',
    ];
    for (final locale in const ['en', 'zh', 'ru']) {
      for (final key in obsoleteKeys) {
        expect(
          ResourceNames.lookupWithLocale(locale, key),
          key,
          reason: '$locale still contains obsolete key $key',
        );
      }
    }
  });

  testWidgets('music picker shows current module, guide note, and codenames', (
    tester,
  ) async {
    final definition = LevelDefinitionData(
      stageModule: 'RTID(CustomStage@CurrentLevel)',
      musicType: MusicTypeCatalog.mainPath,
    );
    final levelDefinitionObject = PvzObject(
      aliases: const ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: definition.toJson(),
    );
    final stageObject = PvzObject(
      aliases: const ['CustomStage'],
      objClass: 'ModernStageProperties',
      objData: <String, dynamic>{
        'MusicSuffix': 'TeamBossRoman',
        'ResourceGroupNames': <String>[],
        'GroupsToUnloadForAds': <String>[],
      },
    );
    final levelFile = PvzLevelFile(
      objects: [levelDefinitionObject, stageObject],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BasicInfoScreen(
          levelFile: levelFile,
          levelDef: definition,
          onBack: () {},
          onStageTap: null,
          onChanged: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final currentChoice = find.text('法老王的琨曲诅咒 (MainPath)');
    expect(
      tester.widget<Text>(currentChoice).style?.fontWeight,
      isNot(FontWeight.bold),
    );
    final victoryChoice = find.textContaining('(VictoryOutro)');
    final musicStyle = DefaultTextStyle.of(
      tester.element(currentChoice),
    ).style.merge(tester.widget<Text>(currentChoice).style);
    final victoryStyle = DefaultTextStyle.of(
      tester.element(victoryChoice),
    ).style.merge(tester.widget<Text>(victoryChoice).style);
    expect(musicStyle.fontSize, victoryStyle.fontSize);
    expect(musicStyle.fontWeight, victoryStyle.fontWeight);
    await tester.ensureVisible(currentChoice);
    await tester.tap(currentChoice);
    await tester.pumpAndSettle();

    expect(find.text('当前音乐模块 (MusicSuffix)'), findsOneWidget);
    expect(find.text('炙热征服者 (时空裂缝版本)'), findsOneWidget);
    expect(find.text('TeamBossRoman'), findsOneWidget);
    final sheetScrollbar = tester.widget<Scrollbar>(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(Scrollbar),
      ),
    );
    expect(sheetScrollbar.thumbVisibility, isTrue);
    expect(sheetScrollbar.trackVisibility, isTrue);
    expect(sheetScrollbar.scrollbarOrientation, ScrollbarOrientation.right);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(AssetImageWidget),
      ),
      findsOneWidget,
    );
    expect(find.text('boss音乐为炙热征服者 (时空裂缝版本)'), findsOneWidget);
    expect(find.text('MiniGame_A'), findsOneWidget);

    await tester.tap(find.text('MiniGame_A'));
    await tester.pumpAndSettle();

    expect(definition.musicType, MusicTypeCatalog.miniGameA);
    expect(
      (levelDefinitionObject.objData as Map<String, dynamic>)['MusicType'],
      MusicTypeCatalog.miniGameA,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Moon picker includes the confirmed day 24 track and localizes the main path',
    (tester) async {
      final definition = LevelDefinitionData(
        stageModule: 'RTID(CustomMoonStage@CurrentLevel)',
      );
      final levelFile = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['CustomMoonStage'],
            objClass: 'MoonStageProperties',
            objData: <String, dynamic>{
              'MusicSuffix': 'Moon',
              'ResourceGroupNames': <String>[],
              'GroupsToUnloadForAds': <String>[],
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: BasicInfoScreen(
            levelFile: levelFile,
            levelDef: definition,
            onBack: () {},
            onStageTap: null,
            onChanged: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final currentChoice = find.text('主线音乐 (MainPath)');
      await tester.ensureVisible(currentChoice);
      await tester.tap(currentChoice);
      await tester.pumpAndSettle();

      expect(find.text('主线音乐'), findsOneWidget);
      expect(find.text('月球基地-终“僵”之战 / Ultimate Battle'), findsOneWidget);
      expect(find.text('月球基地-趣味小游戏 / Demonstration Mini Game'), findsOneWidget);
      expect(find.text('MiniGame_C'), findsOneWidget);
      expect(find.text('月球基地-第24天（最后一波音乐变奏）'), findsOneWidget);
      expect(find.text('MiniGame_D'), findsNothing);
      expect(find.text('MiniGame_E'), findsNothing);
      await tester.ensureVisible(find.text('MiniGame_C'));
      await tester.tap(find.text('MiniGame_C'));
      await tester.pumpAndSettle();
      expect(definition.musicType, MusicTypeCatalog.miniGameC);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty stage music suffix overrides stale level suffix', (
    tester,
  ) async {
    final definition = LevelDefinitionData(
      stageModule: 'RTID(DefaultMusicStage@CurrentLevel)',
      musicSuffix: 'TeamBossRoman',
    );
    final levelFile = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['DefaultMusicStage'],
          objClass: 'ModernStageProperties',
          objData: <String, dynamic>{
            'MusicSuffix': '',
            'ResourceGroupNames': <String>[],
            'GroupsToUnloadForAds': <String>[],
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BasicInfoScreen(
          levelFile: levelFile,
          levelDef: definition,
          onBack: () {},
          onStageTap: null,
          onChanged: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final currentChoice = find.text('MainPath');
    await tester.ensureVisible(currentChoice);
    await tester.tap(currentChoice);
    await tester.pumpAndSettle();

    expect(find.text('当前音乐模块 (MusicSuffix)'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(BottomSheet), matching: find.text('—')),
      findsNWidgets(2),
    );
    expect(find.textContaining('炙热征服者'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unconfigured suffix names all three choices after its module', (
    tester,
  ) async {
    await _pumpCustomMusicScreen(tester, suffix: 'BGMe');

    final picker = tester.widget<SeparatedOptionPickerField<String>>(
      find.byType(SeparatedOptionPickerField<String>),
    );
    expect(picker.items.map((item) => item.value), const [
      'MainPath',
      'MiniGame_A',
      'MiniGame_B',
    ]);
    expect(picker.items.map((item) => item.label).toSet(), {'BGMe (暂无内容)'});

    final currentChoice = find.text('BGMe (暂无内容) (MainPath)');
    await tester.ensureVisible(currentChoice);
    await tester.tap(currentChoice);
    await tester.pumpAndSettle();

    expect(find.text('BGMe (暂无内容)'), findsNWidgets(4));
    expect(find.text('MainPath'), findsOneWidget);
    expect(find.text('MiniGame_A'), findsOneWidget);
    expect(find.text('MiniGame_B'), findsOneWidget);
    expect(find.text('MiniGame_C'), findsNothing);
    expect(find.textContaining('musicSuffix_'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('imported Moon day 24 track retains its localized choice', (
    tester,
  ) async {
    final data = await _pumpCustomMusicScreen(
      tester,
      suffix: 'Moon',
      musicType: 'MiniGame_C',
    );
    final picker = tester.widget<SeparatedOptionPickerField<String>>(
      find.byType(SeparatedOptionPickerField<String>),
    );
    expect(picker.items.map((item) => item.value), const [
      'MainPath',
      'MiniGame_A',
      'MiniGame_B',
      'MiniGame_C',
    ]);

    final currentChoice = find.text('月球基地-第24天（最后一波音乐变奏） (MiniGame_C)');
    await tester.ensureVisible(currentChoice);
    await tester.tap(currentChoice);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('MiniGame_C'),
      ),
      findsOneWidget,
    );
    expect(find.text('月球基地-第24天（最后一波音乐变奏）'), findsOneWidget);
    expect(find.text('主线音乐'), findsOneWidget);

    Navigator.of(tester.element(find.byType(BottomSheet))).pop();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'After');
    await tester.pump();

    expect(data.definition.musicType, 'MiniGame_C');
    expect(
      (data.definitionObject.objData as Map<String, dynamic>)['MusicType'],
      'MiniGame_C',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown music suffix and type survive an unrelated save', (
    tester,
  ) async {
    final definition = LevelDefinitionData(
      name: 'Before',
      stageModule: 'RTID(UnknownMusicStage@CurrentLevel)',
      musicType: 'CustomTrack',
      musicSuffix: 'LegacySuffix',
    );
    final levelDefinitionObject = PvzObject(
      aliases: const ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: definition.toJson(),
    );
    final stageObject = PvzObject(
      aliases: const ['UnknownMusicStage'],
      objClass: 'ModernStageProperties',
      objData: <String, dynamic>{
        'MusicSuffix': 'MysterySuffix',
        'ResourceGroupNames': <String>[],
        'GroupsToUnloadForAds': <String>[],
      },
    );
    final levelFile = PvzLevelFile(
      objects: [levelDefinitionObject, stageObject],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BasicInfoScreen(
          levelFile: levelFile,
          levelDef: definition,
          onBack: () {},
          onStageTap: null,
          onChanged: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final currentChoice = find.text('CustomTrack');
    await tester.ensureVisible(currentChoice);
    await tester.tap(currentChoice);
    await tester.pumpAndSettle();
    expect(find.text('当前音乐模块 (MusicSuffix)'), findsOneWidget);
    final picker = tester.widget<SeparatedOptionPickerField<String>>(
      find.byType(SeparatedOptionPickerField<String>),
    );
    expect(picker.items.map((item) => item.value), const [
      'MainPath',
      'MiniGame_A',
      'MiniGame_B',
    ]);
    expect(picker.items.map((item) => item.label).toSet(), {'MysterySuffix'});
    expect(find.text('MysterySuffix'), findsNWidgets(5));
    expect(find.textContaining('musicSuffix_'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('CustomTrack'),
      ),
      findsNothing,
    );

    Navigator.of(tester.element(find.byType(BottomSheet))).pop();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'After');
    await tester.pump();

    expect(definition.musicType, 'CustomTrack');
    expect(definition.musicSuffix, 'LegacySuffix');
    expect((stageObject.objData as Map)['MusicSuffix'], 'MysterySuffix');
    expect(
      (levelDefinitionObject.objData as Map<String, dynamic>)['MusicType'],
      'CustomTrack',
    );
    expect(tester.takeException(), isNull);
  });
}

Future<({LevelDefinitionData definition, PvzObject definitionObject})>
_pumpCustomMusicScreen(
  WidgetTester tester, {
  required String suffix,
  String musicType = MusicTypeCatalog.mainPath,
}) async {
  final definition = LevelDefinitionData(
    name: 'Before',
    stageModule: 'RTID(CustomMusicStage@CurrentLevel)',
    musicType: musicType,
  );
  final definitionObject = PvzObject(
    aliases: const ['LevelDefinition'],
    objClass: 'LevelDefinition',
    objData: definition.toJson(),
  );
  final levelFile = PvzLevelFile(
    objects: [
      definitionObject,
      PvzObject(
        aliases: const ['CustomMusicStage'],
        objClass: 'ModernStageProperties',
        objData: <String, dynamic>{
          'MusicSuffix': suffix,
          'ResourceGroupNames': <String>[],
          'GroupsToUnloadForAds': <String>[],
        },
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BasicInfoScreen(
        levelFile: levelFile,
        levelDef: definition,
        onBack: () {},
        onStageTap: null,
        onChanged: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (definition: definition, definitionObject: definitionObject);
}

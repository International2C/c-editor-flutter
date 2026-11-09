import 'package:c_editor/data/narrative_catalog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(NarrativeCatalog.clearCacheForTesting);

  test('PvP dialogue follows the onboarding and battle flow', () async {
    const expectedOrder = <String>[
      'TUTORIAL_PVP_INTRO',
      'MAP_PVP_INTRO',
      'MAP_PVPMAINMENU_INTRO',
      'MAP_PVPGARDENWAR_INTRO',
      'PVP_PLANTMODULE_INTRO',
      'PVP_BATTLEMODULE1_INTRO',
      'PVP_BATTLEMODULE2_INTRO',
      'PVP_TRAINZB_INTRO',
      'PVP_TRAINZB_MORE',
      'PVP_ATTACK_INTRO',
      'PVP_ATTACKBEGIN_INTRO',
      'PVP_ATTACKMODULE_INTRO',
      'PVP_ATTACKMODULE_BUFINTRO',
      'PVP_ATTACKMODULE_END',
      'PVP_OCCUPYMAP_INTRO',
      'MAP_PVPEVILDAVID_START_INTRO',
      'MAP_PVPEVILDAVID_FAILED_INTRO',
      'MAP_PVPEVILDAVID_SUCCESS_1_INTRO',
      'MAP_PVPEVILDAVID_SUCCESS_2_INTRO',
      'MAP_PVPEVILDAVID_SUCCESS_3_INTRO',
      'MAP_PVPEVILDAVID_SUCCESS_4_INTRO',
      'MAP_PVPEVILDAVID_SUCCESS_5_INTRO',
      'MAP_PVPEVILDAVID_SUCCESS_6_INTRO',
    ];

    for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
      final catalog = await NarrativeCatalog.load(locale);
      expect(
        catalog
            .entriesForSection(NarrativeSectionId.pvpMode)
            .map((entry) => entry.groupId),
        expectedOrder,
      );
    }
  });

  test(
    'PvP opening and legacy Endless group use synchronized titles',
    () async {
      const expectedOpeningTitles = <String, String>{
        'zh': '对战模式 - 开场',
        'en': 'PvP Mode - Opening',
        'ru': 'Режим PvP — начало',
      };
      const expectedFloorTitles = <String, List<String>>{
        'zh': [
          '无尽挑战 - 第1层（旧版）',
          '无尽挑战 - 第2层（旧版）',
          '无尽挑战 - 第3层（旧版）',
          '无尽挑战 - 第4层（旧版）',
        ],
        'en': [
          'Endless Challenge - Floor 1 (Legacy)',
          'Endless Challenge - Floor 2 (Legacy)',
          'Endless Challenge - Floor 3 (Legacy)',
          'Endless Challenge - Floor 4 (Legacy)',
        ],
        'ru': [
          'Бесконечное испытание — этаж 1 (старая версия)',
          'Бесконечное испытание — этаж 2 (старая версия)',
          'Бесконечное испытание — этаж 3 (старая версия)',
          'Бесконечное испытание — этаж 4 (старая версия)',
        ],
      };
      const expectedLegacyTitles = <String, String>{
        'zh': '无尽挑战（旧版）',
        'en': 'Endless Challenge (Legacy)',
        'ru': 'Бесконечное испытание (старая версия)',
      };
      const floorIds = <String>[
        'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_ONE',
        'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_TWO',
        'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_THREE',
        'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_FOUR',
      ];

      for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
        final catalog = await NarrativeCatalog.load(locale);
        expect(
          catalog.findByValue('MAP_PVP_INTRO')?.title,
          expectedOpeningTitles[locale.languageCode],
        );
        expect(
          catalog.findByValue('DANGER_ROOM_INTRO_FESTIVAL')?.title,
          expectedLegacyTitles[locale.languageCode],
        );
        expect(
          floorIds.map((id) => catalog.findByValue(id)?.title),
          expectedFloorTitles[locale.languageCode],
        );
      }
    },
  );
}

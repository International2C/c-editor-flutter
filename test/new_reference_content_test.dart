import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_action_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _romanBase = 'ZombieZombossMech_RomanHotRodicus';
const _romanVariation = 'roman_hotrodicus_boss';
const _romanHardVariation = 'roman_hotrodicus_boss_uncharted_hard';
const _crystals = [
  'lunar_mine_ore_hardened_shell_moon13_start',
  'lunar_mine_ore_hardened_shell',
  'lunar_mine_ore_hardened_core',
  'lunar_mine_ore_fragile',
  'lunar_mine_ore_fragile_plantfood',
  'lunar_mine_ore_radiation',
];
const _zombies = {
  'zombie_moon_blade': ('星际剑客僵尸', 'Interstellar Swordsman Zombie'),
  'zombie_moon_illusionist': ('维度幻象僵尸', 'Dimensional Illusionist Zombie'),
  'supernova_gargantuar_gemini': ('超新星双子僵尸', 'Supernova Binary'),
  'zombie_supernova_imp': ('超新星小鬼僵尸', 'Supernova Imp'),
  'lunar_radiation_gargantuar': ('宇宙辐射巨人僵尸', 'Cosmic Radiation Gargantuar'),
};

Map<String, dynamic> _reference(String name) {
  final data =
      jsonDecode(File('assets/reference/$name.json').readAsStringSync()) as Map;
  return {
    for (final object in data['objects'] as List)
      for (final alias in object['aliases'] as List? ?? [])
        alias as String: object,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ResourceNames.ensureLoaded(),
      PlantRepository().init(),
      ZombieRepository().init(),
      ZombiePropertiesRepository.init(),
      GridItemRepository.init(),
      ZombossMechRepository.init(),
    ]);
  });

  test('new plants resolve names, images and reference-world filters', () {
    const expected = {
      'cosmicsaucer': ('宇宙飞碟瓜', 'Cosmic Saucer', PlantTag.worldMoon),
      'nagasalak': ('娜迦蛇皮果', 'Nāga Salak', PlantTag.worldAtlantis),
    };
    final reference = _reference('PlantTypes');
    for (final entry in expected.entries) {
      final plant = PlantRepository().getPlantInfoById(entry.key)!;
      expect(ResourceNames.lookupWithLocale('zh', plant.name), entry.value.$1);
      expect(ResourceNames.lookupWithLocale('en', plant.name), entry.value.$2);
      expect(plant.tags, contains(entry.value.$3));
      expect(
        PlantRepository().search(
          entry.key,
          entry.value.$3,
          PlantCategory.world,
        ),
        hasLength(1),
      );
      expect(reference[entry.key]['objdata']['TypeName'], entry.key);
      expect(File('assets/images/plants/${plant.icon}').existsSync(), isTrue);
    }
    expect(
      PlantRepository().search(
        'coming_soon',
        PlantTag.worldMoon,
        PlantCategory.world,
      ),
      isEmpty,
    );
  });

  test(
    'new Moon zombies appear once, in catalog order, with localized names',
    () {
      final raw =
          jsonDecode(File('assets/resources/Zombies.json').readAsStringSync())
              as List;
      final reference = _reference('ZombieTypes');
      final moon = ZombieRepository().search(
        '',
        ZombieTag.moon,
        ZombieCategory.main,
      );
      expect(
        moon.where((z) => _zombies.containsKey(z.id)).map((z) => z.id),
        _zombies.keys,
      );
      for (final entry in _zombies.entries) {
        expect(raw.where((z) => z['id'] == entry.key), hasLength(1));
        final zombie = ZombieRepository().getZombieById(entry.key)!;
        expect(reference[entry.key]['objdata']['TypeName'], zombie.id);
        expect(
          ResourceNames.lookupWithLocale('zh', zombie.name),
          entry.value.$1,
        );
        expect(
          ResourceNames.lookupWithLocale('en', zombie.name),
          entry.value.$2,
        );
        expect(
          File('assets/images/zombies/${zombie.icon}').existsSync(),
          isTrue,
        );
      }
      expect(moon.any((z) => z.id == 'stay_tuned'), isFalse);
      expect(ZombieRepository().getZombieById('stay_tuned'), isNotNull);
    },
  );

  test(
    'crystals follow lunar ore in the requested order and use reference aliases',
    () {
      final items = GridItemRepository.getAll();
      final index = items.indexWhere(
        (item) => item.typeName == 'lunar_mine_ore',
      );
      expect(
        items.skip(index + 1).take(6).map((item) => item.typeName),
        _crystals,
      );
      final reference = _reference('GridItemTypes');
      final props = _reference('PropertySheets');
      for (final id in _crystals) {
        final item = GridItemRepository.getByTypeName(id)!;
        expect(item.category, GridItemCategory.scene);
        expect(reference[id]['objdata']['TypeName'], id);
        expect(
          GridItemRepository.buildGridItemTypeRtid(
            id,
            PvzLevelFile(objects: []),
          ),
          'RTID($id@GridItemTypes)',
        );
        expect(File(GridItemRepository.getIconPath(id)).existsSync(), isTrue);
        for (final locale in ['zh', 'en', 'ru']) {
          expect(
            ResourceNames.lookupWithLocale(locale, 'griditem_$id'),
            isNot('griditem_$id'),
          );
        }
      }
      expect(
        GridItemRepository.getIconPath(_crystals[2]),
        'assets/images/griditems/lunar_mine_ore_hardened_core.webp',
      );
      for (final entry in {_crystals[0]: 2000, _crystals[1]: 3000}.entries) {
        final rtid = reference[entry.key]['objdata']['Properties'] as String;
        final alias = rtid.substring(5, rtid.indexOf('@'));
        expect(props[alias]['objdata']['Hitpoints'], entry.value);
      }
    },
  );

  test(
    'Roman boss normal and hard variants use their own reference properties',
    () {
      final catalog = ZombossMechRepository.getCatalog(_romanBase)!;
      expect(catalog.variations, [_romanVariation, _romanHardVariation]);
      expect(catalog.hasCustomInstance, isFalse);
      expect(catalog.defaultPhaseCount, 3);
      expect(
        ZombossMechRepository.findBaseForVariation(_romanVariation)!.id,
        _romanBase,
      );
      final props = _reference(
        'PropertySheets',
      )['ZombieZombossMechRomanHotRodicus'];
      expect(catalog.propsObjclass, props['objclass']);
      expect(catalog.templatePropsData(), props['objdata']);
      expect(
        ZombossMechRepository.propertiesDataForVariation(_romanVariation),
        props['objdata'],
      );
      expect(
        ZombossMechRepository.findBaseForVariation(_romanHardVariation)!.id,
        _romanBase,
      );
      final hardProps = _reference(
        'PropertySheets',
      )['ZombieZombossMechRomanHotRodicusUnchartedHard'];
      expect(catalog.propsObjclass, hardProps['objclass']);
      final hardData = ZombossMechRepository.propertiesDataForVariation(
        _romanHardVariation,
      )!;
      expect(hardData, hardProps['objdata']);
      expect((hardData['Stages'] as List).map((stage) => stage['HitPoints']), [
        16000,
        24000,
        50000,
      ]);
      expect(
        (props['objdata']['Stages'] as List).map((stage) => stage['HitPoints']),
        [80000, 120000, 250000],
      );
      final referenceActions = _reference('ZombieActions');
      for (final action in catalog.catalogActions) {
        expect(action.objclass, referenceActions[action.alias]['objclass']);
        expect(
          ZombossMechActionUtils.dataFromCatalogAction(action),
          referenceActions[action.alias]['objdata'],
        );
      }
      final referencedActions = RegExp(r'RTID\(([^@]+)@ZombieActions\)')
          .allMatches(jsonEncode([props['objdata'], hardProps['objdata']]))
          .map((m) => m.group(1)!)
          .toSet();
      expect(catalog.actionAliases, unorderedEquals(referencedActions));
      expect(
        isZombossJumpActionObjclass(
          'ZombossRomanHotRodicusJumpActionDefinition',
        ),
        isTrue,
      );
      expect(
        ResourceNames.lookupWithLocale('zh', _romanBase),
        '罗马帝国僵王 (炙热征服者)',
      );
      expect(
        ResourceNames.lookupWithLocale('en', _romanBase),
        'Roman Empire Zomboss (Zombot Hot-Rodicus)',
      );
      expect(
        ResourceNames.lookupWithLocale(
          'zh',
          '${_romanBase}_variation_$_romanVariation',
        ),
        '罗马荣光 (普通模式)',
      );
      expect(
        ResourceNames.lookupWithLocale(
          'en',
          '${_romanBase}_variation_$_romanVariation',
        ),
        'Roman Glory (Normal Mode)',
      );
      for (final entry in {
        'zh': '罗马荣光 (困难模式)',
        'en': 'Roman Glory (Hard Mode)',
        'ru': 'Слава Рима (сложный режим)',
      }.entries) {
        expect(
          ResourceNames.lookupWithLocale(
            entry.key,
            '${_romanBase}_variation_$_romanHardVariation',
          ),
          entry.value,
        );
      }
    },
  );

  testWidgets(
    'Roman action picker uses localized names and returns the real action',
    (tester) async {
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selected = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => ZombossMechActionSelectionScreen(
                      catalog: ZombossMechRepository.getCatalog(_romanBase)!,
                      levelFile: PvzLevelFile(objects: []),
                    ),
                  ),
                );
              },
              child: const Text('select action'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('select action'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'HorseHammer1');
      await tester.pumpAndSettle();
      final action = find.textContaining('Phase 1 Warhorse Headbutt');
      expect(action, findsOneWidget);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(
        selected,
        'RTID(ZombossRomanHotRodicusHorseHammer1@ZombieActions)',
      );
      expect(tester.takeException(), isNull);
    },
  );
}

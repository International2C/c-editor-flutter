import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/stage_catalog_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KongfuBossStage catalog entry', () {
    setUpAll(() async {
      await StageCatalogRepository.init();
      await StageRepository.init();
    });

    test('appears between Arbor Day and Theatre Dark as a special stage', () {
      final options = StageCatalogRepository.stageBaseOptions();
      final aliases = options.map((option) => option.alias).toList();
      final kongfuBoss = options.firstWhere(
        (option) => option.alias == 'KongfuBossStage',
      );

      expect(
        aliases.indexOf('UnchartedArbordayStage'),
        lessThan(aliases.indexOf('KongfuBossStage')),
      );
      expect(
        aliases.indexOf('KongfuBossStage'),
        lessThan(aliases.indexOf('TheatreDarkStage')),
      );
      expect(kongfuBoss.type, 'special');
      expect(kongfuBoss.iconName, 'Stage_KongfuBoss.webp');
    });

    test('uses the existing built-in stage implementation data', () {
      final impl = StageCatalogRepository.catalogImplementation(
        'KongfuBossStage',
      );

      expect(impl, isNotNull);
      expect(impl!.objclass, 'KongFuStageProperties');
      expect(impl.objdata['BackgroundImageRight'], 'TEXTURE_RIGHT_BOSS');
      expect(impl.objdata['ResourceGroupNames'], contains('Music_Boss_Kongfu'));
    });

    test('is exposed through the built-in stage repository', () {
      final item = StageRepository.allItems.firstWhere(
        (stage) => stage.alias == 'KongfuBossStage',
      );

      expect(item.type, StageType.special);
      expect(item.iconName, 'Stage_KongfuBoss.webp');
    });

    test('keeps its own custom-stage appearance display', () {
      final impl = StageCatalogRepository.catalogImplementation(
        'KongfuBossStage',
      )!;

      expect(
        CustomStageLevelUtils.displayLawnAppearanceNameKey(
          objclass: impl.objclass,
          objdata: impl.objdata,
        ),
        'stage_KongfuBossStage',
      );
      expect(
        CustomStageLevelUtils.displayLawnAppearanceIconFileName(
          objclass: impl.objclass,
          objdata: impl.objdata,
        ),
        'Stage_KongfuBoss.webp',
      );
    });
  });

  group('MoonStage catalog entry', () {
    setUpAll(() async {
      await StageCatalogRepository.init();
      await StageRepository.init();
    });

    test('appears after Heian Ages in the main stage list', () {
      final options = StageCatalogRepository.stageBaseOptions();
      final aliases = options.map((option) => option.alias).toList();
      final moon = options.firstWhere((option) => option.alias == 'MoonStage');

      expect(
        aliases.indexOf('HeianStage'),
        lessThan(aliases.indexOf('MoonStage')),
      );
      expect(
        aliases.indexOf('MoonStage'),
        lessThan(aliases.indexOf('FairyTaleStage')),
      );
      expect(moon.type, 'main');
      expect(moon.iconName, 'Stage_Moon.webp');
    });

    test('keeps the Moon-specific custom-stage setting', () {
      final impl = StageCatalogRepository.catalogImplementation('MoonStage');
      final moonBase = StageCatalogRepository.stageBaseOptions().firstWhere(
        (option) => option.alias == 'MoonStage',
      );
      final resourceGroupField = StageCatalogRepository.sectionForObjclass(
        'MoonStageProperties',
      )!.fields.firstWhere((field) => field.name == 'ResourceGroupNames');

      expect(impl, isNotNull);
      expect(impl!.objclass, 'MoonStageProperties');
      expect(impl.objdata['MusicSuffix'], 'Moon');
      expect(impl.objdata['CosmicPlantfoodFillSeconds'], 50.0);
      expect(impl.objdata['ResourceGroupNames'], contains('AudioMoon'));
      expect(moonBase.objdata['ResourceGroupNames'], contains('AudioMoon'));
      expect(resourceGroupField.defaultValue, contains('AudioMoon'));
    });
  });

  for (final alias in ['MoonStage', 'JoustStage']) {
    test(
      '$alias custom exports retain the updated reference parameters',
      () async {
        await StageCatalogRepository.init();
        final reference =
            jsonDecode(
                  File('assets/reference/LevelModules.json').readAsStringSync(),
                )
                as Map;
        final official =
            (reference['objects'] as List).singleWhere(
                  (object) =>
                      (object['aliases'] as List? ?? []).contains(alias),
                )
                as Map;
        final option = StageCatalogRepository.stageBaseOptions().firstWhere(
          (option) => option.alias == alias,
        );
        final level = PvzLevelFile(objects: []);
        CustomStageLevelUtils.createCustomStage(
          levelFile: level,
          alias: 'Custom$alias',
          baseOption: option,
        );
        final restored = PvzLevelFile.fromJson(
          jsonDecode(jsonEncode(level.toJson())) as Map<String, dynamic>,
        ).objects.single;
        expect(restored.objClass, official['objclass']);
        expect(restored.objData, official['objdata']);

        final fieldName = alias == 'MoonStage'
            ? 'ShadowBoostable'
            : 'DirtSpawnEffectName';
        final field = StageCatalogRepository.sectionForObjclass(
          option.objclass,
        )!.fields.firstWhere((field) => field.name == fieldName);
        expect(field.defaultValue, official['objdata'][fieldName]);

        // Reopening an older custom lawn synchronizes hidden parameters while
        // retaining editable values such as the user's music choice.
        final olderData = Map<String, dynamic>.from(restored.objData as Map);
        olderData.remove(fieldName);
        olderData['MusicSuffix'] = 'Egypt';
        CustomStageLevelUtils.syncHiddenFieldsFromTemplate(
          objdata: olderData,
          objclass: option.objclass,
          template: StageCatalogRepository.templateObjdataForStageObject(
            objclass: option.objclass,
            objdata: olderData,
          ),
        );
        expect(olderData[fieldName], official['objdata'][fieldName]);
        expect(olderData['MusicSuffix'], 'Egypt');
        if (alias == 'MoonStage') {
          (olderData['ShadowBoostable']['List'] as List).clear();
          expect(option.objdata, official['objdata']);
        }
      },
    );
  }

  group('CardGameStage catalog entry', () {
    setUpAll(() async {
      await StageCatalogRepository.init();
      await StageRepository.init();
    });

    test('appears between Rift and Dave Cup under Extra', () {
      final options = StageCatalogRepository.stageBaseOptions();
      final aliases = options.map((option) => option.alias).toList();
      final cardGame = options.firstWhere(
        (option) => option.alias == 'CardGameStage',
      );

      expect(
        aliases.indexOf('RiftStage'),
        lessThan(aliases.indexOf('CardGameStage')),
      );
      expect(
        aliases.indexOf('CardGameStage'),
        lessThan(aliases.indexOf('DaveCupStage')),
      );
      expect(cardGame.type, 'extra');
      expect(
        StageRepository.allItems
            .firstWhere((stage) => stage.alias == 'CardGameStage')
            .type,
        StageType.extra,
      );
    });

    test('preview backgrounds follow stage order with Unknown last', () async {
      final resolver = await StageBannerResolver.load();
      final stems = resolver.orderedStemsForStageAliases(
        StageRepository.allItems.map((stage) => stage.alias),
      );

      expect(stems.indexOf('Rift'), lessThan(stems.indexOf('CardGame')));
      expect(stems.indexOf('CardGame'), lessThan(stems.indexOf('DaveCup')));
      expect(stems.last, resolver.defaultStem);
    });
  });

  group('Roman and Space Miner stage integration', () {
    const stages = {
      'UnchartedRomaStage': (
        after: 'JourneyToTheWestStage',
        type: StageType.extra,
        icon: 'Stage_TeamBoss.webp',
      ),
      'TeamBossStage': (
        after: 'CardGameStage',
        type: StageType.extra,
        icon: 'Stage_TeamBoss.webp',
      ),
      'MoonGrappleStage': (
        after: 'AquariumStage',
        type: StageType.special,
        icon: 'Stage_MoonGrappleStage.webp',
      ),
    };

    setUpAll(() async {
      await StageCatalogRepository.init();
      await StageRepository.init();
      await CustomStagePresetRepository.init();
    });

    for (final entry in stages.entries) {
      test('${entry.key} is selectable and survives custom-stage export', () {
        final alias = entry.key;
        final expected = entry.value;
        final options = StageCatalogRepository.stageBaseOptions();
        final index = options.indexWhere((option) => option.alias == alias);
        expect(index, greaterThan(0));
        expect(options[index - 1].alias, expected.after);
        final option = options[index];
        expect(option.type, expected.type.name);
        expect(option.iconName, expected.icon);
        final builtins = StageRepository.allItems;
        final builtinIndex = builtins.indexWhere((item) => item.alias == alias);
        expect(builtinIndex, greaterThan(0));
        expect(builtins[builtinIndex - 1].alias, expected.after);
        expect(builtins[builtinIndex].type, expected.type);
        expect(builtins[builtinIndex].iconName, expected.icon);

        final reference =
            jsonDecode(
                  File('assets/reference/LevelModules.json').readAsStringSync(),
                )
                as Map<String, dynamic>;
        final official =
            (reference['objects'] as List).firstWhere(
                  (object) =>
                      (object['aliases'] as List? ?? []).contains(alias),
                )
                as Map<String, dynamic>;
        expect(option.objclass, official['objclass']);
        expect(option.objdata, official['objdata']);

        final level = PvzLevelFile(objects: []);
        final customAlias = 'Custom$alias';
        expect(
          CustomStageLevelUtils.createCustomStage(
            levelFile: level,
            alias: customAlias,
            baseOption: option,
          ),
          'RTID($customAlias@CurrentLevel)',
        );
        final restored = PvzLevelFile.fromJson(
          jsonDecode(jsonEncode(level.toJson())) as Map<String, dynamic>,
        );
        final custom = CustomStageLevelUtils.customStageObjectsInLevel(
          restored,
        ).single;
        expect(custom.aliases, [customAlias]);
        expect(custom.objClass, official['objclass']);
        expect(custom.objData, official['objdata']);
        final data = custom.objData as Map<String, dynamic>;
        expect(
          CustomStageLevelUtils.displayStageBaseNameKey(
            objclass: custom.objClass,
            objdata: data,
          ),
          'stage_$alias',
        );
        expect(
          CustomStageLevelUtils.displayLawnAppearanceIconFileName(
            objclass: custom.objClass,
            objdata: data,
          ),
          expected.icon,
        );
        expect(
          StageCatalogRepository.templateObjdataForStageObject(
            objclass: custom.objClass,
            objdata: data,
          ),
          official['objdata'],
        );
        expect(
          StageCatalogRepository.knownResourceGroups,
          containsAll(data['ResourceGroupNames'] as List),
        );
        final background = StageCatalogRepository.resolveBackgroundDisplay(
          backgroundImagePrefix: data['BackgroundImagePrefix'] as String,
          backgroundResourceGroup: data['BackgroundResourceGroup'] as String,
          resourceGroupNames: List<String>.from(data['ResourceGroupNames']),
          groupsToUnloadForAds: List<String>.from(data['GroupsToUnloadForAds']),
        );
        expect(background?.image, expected.icon);

        // Editing a custom copy must not change the built-in template.
        final editable = level.objects.single.objData as Map<String, dynamic>;
        (editable['DisabledStreetCells'] as List).clear();
        editable['MusicSuffix'] = 'Egypt';
        expect(option.objdata, official['objdata']);
        final edited = PvzLevelFile.fromJson(level.toJson()).objects.single;
        expect((edited.objData as Map)['MusicSuffix'], 'Egypt');
        expect((edited.objData as Map)['DisabledStreetCells'], isEmpty);
      });
    }

    test('official Roman stages replace the old selectable preset', () async {
      expect(
        CustomStagePresetRepository.presets.map((preset) => preset.alias),
        isNot(contains('RomanEmpireCustom')),
      );
      final resolver = await StageBannerResolver.load();
      expect(resolver.resolveStem('UnchartedRomaStage'), 'Roman');
      expect(resolver.resolveStem('TeamBossStage'), 'Roman');
      // Previously saved levels can still resolve their old preview banner.
      expect(resolver.resolveStem('RomanEmpireCustom'), 'Roman');
    });
  });

  test(
    'global resource-group list includes every custom lawn preset',
    () async {
      await StageCatalogRepository.init();
      await CustomStagePresetRepository.init();

      expect(
        StageCatalogRepository.knownResourceGroups,
        containsAll(CustomStagePresetRepository.resourceGroups),
      );
      expect(
        StageCatalogRepository.knownResourceGroups,
        contains('Modern_Gravestone'),
      );
    },
  );
}

import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    CustomStagePresetRepository.resetForTest();
    await CustomStagePresetRepository.init();
  });

  test(
    'distinguishes preset, preset-derived, and user-created custom lawns',
    () {
      final preset = CustomStagePresetRepository.presets.first;
      final presetObject = PvzObject(
        aliases: CustomStagePresetRepository.aliasesForPresetInstance(
          primaryAlias: preset.alias,
          preset: preset,
        ),
        objClass: preset.objclass,
        objData: CustomStageLevelUtils.cloneJson(preset.objdata),
      );

      expect(
        CustomStagePresetRepository.originForObject(presetObject),
        CustomStageOrigin.presetTemplate,
      );

      final derivedData =
          CustomStageLevelUtils.cloneJson(preset.objdata)
              as Map<String, dynamic>;
      derivedData['MusicSuffix'] = 'custom_test_suffix';
      final derivedObject = PvzObject(
        aliases: CustomStagePresetRepository.aliasesForPresetInstance(
          primaryAlias: preset.alias,
          preset: preset,
        ),
        objClass: preset.objclass,
        objData: derivedData,
      );

      expect(
        CustomStagePresetRepository.originForObject(derivedObject),
        CustomStageOrigin.presetDerived,
      );

      final userObject = PvzObject(
        aliases: const ['CustomStageFromBuiltin'],
        objClass: preset.objclass,
        objData: CustomStageLevelUtils.cloneJson(preset.objdata),
      );

      expect(
        CustomStagePresetRepository.originForObject(userObject),
        CustomStageOrigin.userCreated,
      );
    },
  );

  test('does not serialize editor metadata aliases for preset lawns', () {
    final preset = CustomStagePresetRepository.presets.first;
    final aliases = CustomStagePresetRepository.aliasesForPresetInstance(
      primaryAlias: preset.alias,
      preset: preset,
    );

    expect(aliases, [preset.alias]);
    expect(
      CustomStagePresetRepository.preservePresetMarkerAliases(
        primaryAlias: 'RenamedStage',
        existingAliases: aliases,
      ),
      ['RenamedStage'],
    );
  });

  test('Early Autumn sits between Modern Graveyard and Lost Volcano', () {
    final presets = CustomStagePresetRepository.presets;
    final aliases = presets.map((preset) => preset.alias).toList();
    final modern = presets.firstWhere(
      (preset) => preset.alias == 'ModernGraveyardCustom',
    );

    expect(
      aliases.indexOf('OneSidedAtlantisCustom'),
      lessThan(aliases.indexOf('ModernGraveyardCustom')),
    );
    expect(
      aliases.indexOf('ModernGraveyardCustom') + 1,
      aliases.indexOf('AutumnEarlyStageCustom'),
    );
    expect(
      aliases.indexOf('AutumnEarlyStageCustom') + 1,
      aliases.indexOf('LostVolcanoCustom'),
    );
    expect(modern.objclass, 'ModernStageProperties');
    expect(modern.objdata['ResourceGroupNames'], contains('Modern_Gravestone'));
  });

  test(
    'Early Autumn preset exports its source configuration and appearance',
    () async {
      await StageCatalogRepository.init();
      final preset = CustomStagePresetRepository.presets.singleWhere(
        (preset) => preset.alias == 'AutumnEarlyStageCustom',
      );
      final level = PvzLevelFile(objects: []);
      final rtid = CustomStageLevelUtils.createCustomStageFromTemplate(
        levelFile: level,
        alias: preset.alias,
        objclass: preset.objclass,
        objdata: preset.objdata,
      );
      final exported = PvzLevelFile.fromJson(level.toJson()).objects.single;
      expect(rtid, 'RTID(AutumnEarlyStageCustom@CurrentLevel)');
      expect(exported.objClass, 'StageModuleProperties');
      expect(exported.objData, preset.objdata);
      expect(preset.objdata['StagePrefix'], 'Autumn_Late');
      expect(preset.objdata['MusicSuffix'], 'Modern');
      expect(preset.objdata['DisabledStreetCells'], isEmpty);
      expect(
        StageCatalogRepository.stageBaseOptions().map((option) => option.alias),
        isNot(contains('AutumnEarlyStage')),
      );
      expect(
        CustomStageLevelUtils.displayLawnAppearanceIconFileName(
          objclass: exported.objClass,
          objdata: Map<String, dynamic>.from(exported.objData as Map),
        ),
        'Stage_AutumnEarly.webp',
      );
      expect(
        CustomStageLevelUtils.displayLawnAppearanceNameKey(
          objclass: exported.objClass,
          objdata: Map<String, dynamic>.from(exported.objData as Map),
        ),
        'customStagePreset_autumnEarly',
      );
    },
  );

  test('collects resource groups from every custom lawn preset', () {
    final expected = <String>{};
    for (final preset in CustomStagePresetRepository.presets) {
      for (final key in const ['ResourceGroupNames', 'GroupsToUnloadForAds']) {
        final raw = preset.objdata[key];
        if (raw is List) expected.addAll(raw.whereType<String>());
      }
    }

    expect(CustomStagePresetRepository.resourceGroups, containsAll(expected));
  });

  test('filters unload groups directly from custom lawn preset data', () {
    final groups = CustomStageLevelUtils.sourceUnloadGroupsForObjdata(
      sourceObjdata: const {
        'GroupsToUnloadForAds': ['Shared', 'UnloadOnly'],
      },
      importedGroups: const ['Shared', 'MainOnly', 'UnloadOnly'],
    );

    expect(groups, ['Shared', 'UnloadOnly']);
  });
}

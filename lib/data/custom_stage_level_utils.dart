import 'package:collection/collection.dart';
import 'package:c_editor/data/models/stage_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/stage_catalog_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';

abstract final class CustomStageLevelUtils {
  static const currentLevel = 'CurrentLevel';
  static const defaultBuiltinStageRtid = 'RTID(TutorialStage@LevelModules)';
  static const _preferredLawnAppearanceStageAliases = {
    'KongfuBossStage',
    'UnchartedRomaStage',
  };

  static const ambientAudioOptions = [
    'Amb_Tutorial_Garden_BG_LP',
    'Egypt_Wind_BG',
    'PVZ_Pirate_BG_WaterBubble_LP_02',
    'WildWest_Wind',
    'Atlantis_Currents_BG',
  ];

  static const submarineDisabledInfo = {
    'Width': 0,
    'Height': 0,
    'Hitpoints': 32000,
    'InitialLocation': {'mX': -10, 'mY': -6},
  };

  static const submarineEnabledInfoTemplate = {
    'Width': 4,
    'Height': 6,
    'Hitpoints': 32000.0,
    'InitialLocation': {'mX': 5, 'mY': 3},
  };

  static const skycityCannonDefaults = {
    'AutoCannonDamage1': 50,
    'AutoCannonDamage2': 300,
    'AutoCannonDamage3': 300,
    'SkillCannonDamage2': 300,
    'SkillCannonDamage3': 300,
    'AutoFireInterval': 5,
    'SkillFireInterval': 60,
  };

  static const skycityCannonFieldNames = [
    'AutoCannonDamage1',
    'AutoCannonDamage2',
    'AutoCannonDamage3',
    'SkillCannonDamage2',
    'SkillCannonDamage3',
    'AutoFireInterval',
    'SkillFireInterval',
  ];

  static const editableFieldNames = {
    'BasicZombieTypeName',
    'FlagZombieTypeName',
    'Armor1ZombieTypeName',
    'Armor2ZombieTypeName',
    'Armor3ZombieTypeName',
    'ResourceGroupNames',
    'GroupsToUnloadForAds',
    'BackgroundImagePrefix',
    'BackgroundResourceGroup',
    'MusicSuffix',
    'AmbientAudioSuffix',
    'DisabledStreetCells',
    'CosmicPlantfoodFillSeconds',
    'LinkedTilePropagationAlpha',
    'BackgroundImageMiddle',
    'InitSubmarineInfo',
    'HasGridItemAirShip',
    'HasCannon',
    ...skycityCannonFieldNames,
  };

  static bool isCustomStageRtid(String? rtid) {
    if (rtid == null || rtid.isEmpty) return false;
    return RtidParser.parse(rtid)?.source == currentLevel;
  }

  static PvzObject? findStageObject(PvzLevelFile levelFile, String alias) {
    return levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
  }

  static String displayNameKey({
    required String? backgroundImagePrefix,
    required Map<String, dynamic> objdata,
  }) {
    final display = StageCatalogRepository.resolveBackgroundDisplay(
      backgroundImagePrefix: backgroundImagePrefix,
      backgroundResourceGroup: objdata['BackgroundResourceGroup'] as String?,
      resourceGroupNames: stringList(objdata['ResourceGroupNames']),
      groupsToUnloadForAds: stringList(objdata['GroupsToUnloadForAds']),
    );
    return display?.nameKey ?? '';
  }

  static String displayStageBaseNameKey({
    required String objclass,
    required Map<String, dynamic> objdata,
  }) {
    final appearanceKey = displayLawnAppearanceNameKey(
      objclass: objclass,
      objdata: objdata,
    );
    if (appearanceKey.isNotEmpty) return appearanceKey;
    return displayNameKey(
      backgroundImagePrefix: objdata['BackgroundImagePrefix'] as String?,
      objdata: objdata,
    );
  }

  static String displayLawnAppearanceNameKey({
    required String objclass,
    required Map<String, dynamic> objdata,
  }) {
    final preferredOption = _preferredStageBaseOptionForObjdata(
      objclass: objclass,
      objdata: objdata,
    );
    if (preferredOption != null) return 'stage_${preferredOption.alias}';

    final display = _resolveLawnAppearanceDisplay(
      objclass: objclass,
      objdata: objdata,
    );
    if (display != null && display.nameKey.isNotEmpty) {
      return display.nameKey;
    }
    final option = StageCatalogRepository.stageBaseOptionForObjdata(
      objclass: objclass,
      objdata: objdata,
    );
    if (option != null) return 'stage_${option.alias}';
    return '';
  }

  static String? displayLawnAppearanceIconFileName({
    required String objclass,
    required Map<String, dynamic> objdata,
  }) {
    if (supportsBeachMinigame(objdata) && isBeachMinigameEnabled(objdata)) {
      return 'Stage_BeachSnake.webp';
    }
    final preferredOption = _preferredStageBaseOptionForObjdata(
      objclass: objclass,
      objdata: objdata,
    );
    if (preferredOption != null) return preferredOption.iconName;

    final display = _resolveLawnAppearanceDisplay(
      objclass: objclass,
      objdata: objdata,
    );
    if (display != null && display.image.isNotEmpty) {
      return display.image;
    }
    final option = StageCatalogRepository.stageBaseOptionForObjdata(
      objclass: objclass,
      objdata: objdata,
    );
    return option?.iconName;
  }

  static StageBaseOption? _preferredStageBaseOptionForObjdata({
    required String objclass,
    required Map<String, dynamic> objdata,
  }) {
    final option = StageCatalogRepository.stageBaseOptionForObjdata(
      objclass: objclass,
      objdata: objdata,
    );
    if (option == null) return null;
    return _preferredLawnAppearanceStageAliases.contains(option.alias)
        ? option
        : null;
  }

  static const lawnAppearanceFieldNames = [
    'BackgroundImagePrefix',
    'BackgroundResourceGroup',
    'BackgroundImageLeft',
    'BackgroundImageMiddle',
    'BackgroundImageRight',
  ];

  static Map<String, dynamic> snapshotLawnAppearance(
    Map<String, dynamic> objdata,
  ) {
    return {
      for (final key in lawnAppearanceFieldNames)
        if (objdata.containsKey(key)) key: cloneJson(objdata[key]),
    };
  }

  static void restoreLawnAppearance(
    Map<String, dynamic> objdata,
    Map<String, dynamic> snapshot,
  ) {
    for (final key in lawnAppearanceFieldNames) {
      if (snapshot.containsKey(key)) {
        objdata[key] = cloneJson(snapshot[key]);
      } else {
        objdata.remove(key);
      }
    }
  }

  static void applyLawnAppearanceFromSource(
    Map<String, dynamic> objdata,
    Map<String, dynamic> sourceObjdata,
  ) {
    for (final key in lawnAppearanceFieldNames) {
      if (sourceObjdata.containsKey(key)) {
        objdata[key] = cloneJson(sourceObjdata[key]);
      }
    }
  }

  static StageBackgroundOption? _resolveLawnAppearanceDisplay({
    required String objclass,
    required Map<String, dynamic> objdata,
  }) {
    return StageCatalogRepository.resolveBackgroundDisplay(
      backgroundImagePrefix: objdata['BackgroundImagePrefix'] as String?,
      backgroundResourceGroup: objdata['BackgroundResourceGroup'] as String?,
      resourceGroupNames: stringList(objdata['ResourceGroupNames']),
      groupsToUnloadForAds: stringList(objdata['GroupsToUnloadForAds']),
    );
  }

  static String createCustomStage({
    required PvzLevelFile levelFile,
    required String alias,
    required StageBaseOption baseOption,
  }) {
    final objdata = cloneJson(baseOption.objdata) as Map<String, dynamic>;
    final objclass = baseOption.objclass;
    final obj = PvzObject(
      objClass: objclass,
      aliases: [alias],
      objData: objdata,
    );
    levelFile.objects.add(obj);
    return RtidParser.build(alias, currentLevel);
  }

  static String createCustomStageFromTemplate({
    required PvzLevelFile levelFile,
    required String alias,
    required String objclass,
    required Map<String, dynamic> objdata,
    List<String>? aliases,
    bool prepend = false,
  }) {
    final obj = PvzObject(
      objClass: objclass,
      aliases: aliases ?? [alias],
      objData: cloneJson(objdata),
    );
    if (prepend) {
      final insertIndex = levelFile.objects.indexWhere(
        (o) =>
            o.aliases != null &&
            o.aliases!.isNotEmpty &&
            isStagePropertiesObjclass(o.objClass),
      );
      if (insertIndex == -1) {
        levelFile.objects.add(obj);
      } else {
        levelFile.objects.insert(insertIndex, obj);
      }
    } else {
      levelFile.objects.add(obj);
    }
    return RtidParser.build(alias, currentLevel);
  }

  static String uniqueCustomStageAlias(
    PvzLevelFile levelFile,
    String suggestedAlias,
  ) {
    final base = suggestedAlias.trim().isEmpty
        ? 'CustomStage'
        : suggestedAlias.trim();
    if (!_hasAlias(levelFile, base)) return base;

    var index = 2;
    while (_hasAlias(levelFile, '$base$index')) {
      index++;
    }
    return '$base$index';
  }

  static bool _hasAlias(PvzLevelFile levelFile, String alias) {
    return levelFile.objects.any((o) => o.aliases?.contains(alias) == true);
  }

  static List<String> stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().toList();
  }

  static List<String> uniqueStrings(Iterable<String> values) {
    final out = <String>[];
    final seen = <String>{};
    for (final value in values) {
      if (value.isEmpty || seen.contains(value)) continue;
      seen.add(value);
      out.add(value);
    }
    return out;
  }

  static void setStringList(
    Map<String, dynamic> objdata,
    String key,
    List<String> values,
  ) {
    objdata[key] = uniqueStrings(values);
  }

  /// Adds [importedGroups] to GroupsToUnloadForAds when they also appear in
  /// [sourceStageAlias]'s GroupsToUnloadForAds.
  static void syncUnloadGroupsFromSourceStage({
    required Map<String, dynamic> objdata,
    required String sourceStageAlias,
    required Iterable<String> importedGroups,
  }) {
    final impl = StageCatalogRepository.catalogImplementation(sourceStageAlias);
    if (impl == null) return;
    syncUnloadGroupsFromSourceObjdata(
      objdata: objdata,
      sourceObjdata: impl.objdata,
      importedGroups: importedGroups,
    );
  }

  static void syncUnloadGroupsFromSourceObjdata({
    required Map<String, dynamic> objdata,
    required Map<String, dynamic> sourceObjdata,
    required Iterable<String> importedGroups,
  }) {
    final toAlsoUnload = sourceUnloadGroupsForObjdata(
      sourceObjdata: sourceObjdata,
      importedGroups: importedGroups,
    );
    if (toAlsoUnload.isEmpty) return;
    setStringList(objdata, 'GroupsToUnloadForAds', [
      ...stringList(objdata['GroupsToUnloadForAds']),
      ...toAlsoUnload,
    ]);
  }

  static List<String> sourceUnloadGroupsForImport({
    required String sourceStageAlias,
    required Iterable<String> importedGroups,
  }) {
    final impl = StageCatalogRepository.catalogImplementation(sourceStageAlias);
    if (impl == null) return const [];
    return sourceUnloadGroupsForObjdata(
      sourceObjdata: impl.objdata,
      importedGroups: importedGroups,
    );
  }

  static List<String> sourceUnloadGroupsForObjdata({
    required Map<String, dynamic> sourceObjdata,
    required Iterable<String> importedGroups,
  }) {
    final sourceUnload = stringList(
      sourceObjdata['GroupsToUnloadForAds'],
    ).toSet();
    if (sourceUnload.isEmpty) return const [];
    return uniqueStrings(importedGroups.where(sourceUnload.contains));
  }

  static void applyAmbientEnabled(
    Map<String, dynamic> objdata, {
    required bool enabled,
  }) {
    if (enabled) {
      objdata['AmbientAudioSuffix'] ??= ambientAudioOptions.first;
    } else {
      objdata.remove('AmbientAudioSuffix');
    }
  }

  static bool isAmbientEnabled(Map<String, dynamic> objdata) =>
      objdata.containsKey('AmbientAudioSuffix');

  static void applyDisabledStreetCellsMode(
    Map<String, dynamic> objdata, {
    required String objclass,
    required bool useDefault,
  }) {
    if (useDefault) {
      objdata['DisabledStreetCells'] =
          StageCatalogRepository.defaultDisabledStreetCells(objclass);
    } else {
      objdata['DisabledStreetCells'] = <Map<String, dynamic>>[];
    }
  }

  static bool usesDefaultDisabledStreetCells(
    Map<String, dynamic> objdata,
    String objclass,
  ) {
    final current = objdata['DisabledStreetCells'];
    if (current is! List) return false;
    final defaults = StageCatalogRepository.defaultDisabledStreetCells(
      objclass,
    );
    return const DeepCollectionEquality().equals(current, defaults);
  }

  static bool supportsBeachMinigame(Map<String, dynamic> objdata) =>
      objdata['BackgroundImagePrefix'] == 'IMAGE_BACKGROUNDS_BEACH';

  static bool supportsCosmicPlantfoodFill(String objclass) =>
      objclass == 'MoonStageProperties';

  static bool isBeachMinigameEnabled(Map<String, dynamic> objdata) =>
      objdata['BackgroundImageMiddle'] == 'TEXTURE_01';

  static void applyBeachMinigame(
    Map<String, dynamic> objdata, {
    required bool enabled,
  }) {
    objdata['BackgroundImageMiddle'] = enabled ? 'TEXTURE_01' : 'TEXTURE';
  }

  static bool supportsSubmarine(String objclass) =>
      objclass == 'DeepseaStageProperties' ||
      objclass == 'DeepseaStageLandProperties';

  static bool isSubmarineEnabled(Map<String, dynamic> objdata) {
    final info = objdata['InitSubmarineInfo'];
    if (info is! Map) return true;
    final width = info['Width'];
    final height = info['Height'];
    return width != 0 || height != 0;
  }

  static void applySubmarineEnabled(
    Map<String, dynamic> objdata, {
    required bool enabled,
    double? hitpoints,
  }) {
    if (enabled) {
      final current = objdata['InitSubmarineInfo'];
      final hp =
          hitpoints ??
          (current is Map ? current['Hitpoints'] : null) ??
          submarineEnabledInfoTemplate['Hitpoints'];
      objdata['InitSubmarineInfo'] = {
        ...submarineEnabledInfoTemplate,
        'Hitpoints': hp,
      };
    } else {
      objdata['InitSubmarineInfo'] = Map<String, dynamic>.from(
        submarineDisabledInfo,
      );
    }
  }

  static double readSubmarineHitpoints(Map<String, dynamic> objdata) {
    final info = objdata['InitSubmarineInfo'];
    if (info is Map && info['Hitpoints'] != null) {
      final raw = info['Hitpoints'];
      if (raw is num) return raw.toDouble();
    }
    return (submarineEnabledInfoTemplate['Hitpoints'] as num).toDouble();
  }

  static bool supportsSkyCityAirship(String objclass) =>
      objclass == 'SkyCityStageProperties';

  static bool readBool(Map<String, dynamic> objdata, String key) {
    final value = objdata[key];
    if (value is bool) return value;
    return false;
  }

  static void applySkyCityAirship(
    Map<String, dynamic> objdata, {
    required bool enabled,
  }) {
    objdata['HasGridItemAirShip'] = enabled;
    if (!enabled) {
      objdata['HasCannon'] = false;
      for (final key in skycityCannonFieldNames) {
        objdata.remove(key);
      }
    }
  }

  static void applySkyCityCannon(
    Map<String, dynamic> objdata, {
    required bool enabled,
  }) {
    objdata['HasCannon'] = enabled;
    if (enabled) {
      for (final entry in skycityCannonDefaults.entries) {
        objdata.putIfAbsent(entry.key, () => entry.value);
      }
    } else {
      for (final key in skycityCannonFieldNames) {
        objdata.remove(key);
      }
    }
  }

  static bool hasSkyCityCannonFields(Map<String, dynamic> objdata) {
    return skycityCannonFieldNames.any(objdata.containsKey);
  }

  static void syncHiddenFieldsFromTemplate({
    required Map<String, dynamic> objdata,
    required String objclass,
    required Map<String, dynamic> template,
  }) {
    for (final entry in template.entries) {
      final key = entry.key;
      if (editableFieldNames.contains(key)) continue;
      if (key == 'FlagVeteranZombieTypeNames') continue;
      objdata[key] = cloneJson(entry.value);
    }
  }

  static dynamic cloneJson(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), cloneJson(val)));
    }
    if (value is List) {
      return value.map(cloneJson).toList();
    }
    return value;
  }

  static String? displayIconFileName({
    required String objclass,
    required Map<String, dynamic> objdata,
  }) {
    return displayLawnAppearanceIconFileName(
      objclass: objclass,
      objdata: objdata,
    );
  }

  static const displayNameSuffixDefault = ' (Custom)';

  /// Objclasses that must not be offered when creating a custom lawn.
  static const excludedCustomStageObjclasses = {'AtlantisStageProperties'};

  static const _zombieFieldOrder = [
    'BasicZombieTypeName',
    'Armor1ZombieTypeName',
    'Armor2ZombieTypeName',
    'Armor3ZombieTypeName',
    'FlagZombieTypeName',
  ];

  static List<StageFieldSpec> editableZombieFields(
    StageCatalogSection? section,
  ) {
    if (section == null) return const [];
    final byName = <String, StageFieldSpec>{};
    for (final field in section.fields) {
      if (!field.isZombieType ||
          field.name == 'FlagVeteranZombieTypeNames' ||
          field.type != 'zombieType') {
        continue;
      }
      byName[field.name] = field;
    }
    return [
      for (final name in _zombieFieldOrder)
        if (byName.containsKey(name)) byName[name]!,
    ];
  }

  static bool isStagePropertiesObjclass(String objclass) {
    if (excludedCustomStageObjclasses.contains(objclass)) return false;
    if (objclass == 'ZombossFinalStageTimeLimitedChallengeProperties') {
      return false;
    }
    return objclass.contains('Stage') && objclass.endsWith('Properties');
  }

  static List<PvzObject> customStageObjectsInLevel(PvzLevelFile levelFile) {
    return levelFile.objects
        .where(
          (o) =>
              o.aliases != null &&
              o.aliases!.isNotEmpty &&
              isStagePropertiesObjclass(o.objClass),
        )
        .toList();
  }

  static void removeCustomStageFromLevel(PvzLevelFile levelFile, String alias) {
    levelFile.objects.removeWhere((o) => o.aliases?.contains(alias) == true);
  }
}

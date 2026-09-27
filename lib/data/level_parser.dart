import 'package:collection/collection.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';

import 'pvz_models.dart';

/// Parses PvzLevelFile into ParsedLevelData (from Z-Editor-master LevelParser.kt)
class LevelParser {
  static const deepSeaStageObjclasses = {
    'DeepseaStageProperties',
    'DeepseaStageLandProperties',
  };

  static const pirateStageObjclasses = {'PirateStageProperties'};
  static const roofStageObjclasses = {'RoofStageProperties'};

  static const underwaterWorldSixRowStageAliases = {
    'DeepseaStage',
    'DeepseaLandStage',
  };

  static const soudacheStageAlias = 'SouDaCheStage';
  static const _soudacheBackgroundGroup = 'DelayLoad_Background_SouDaChe';
  static const _soudacheBackgroundPrefix = 'IMAGE_BACKGROUNDS_SOUDACHE';

  static const levelJamMusicStageObjclasses = {
    'EightiesStageProperties',
    'ModernStageProperties',
  };

  static ParsedLevelData parseLevel(PvzLevelFile levelFile) {
    final objectMap = <String, PvzObject>{};
    for (final obj in levelFile.objects) {
      final alias = obj.aliases?.isNotEmpty == true
          ? obj.aliases!.first
          : 'unknown';
      objectMap[alias] = obj;
    }

    LevelDefinitionData? levelDef;
    final levelDefList = levelFile.objects
        .where((o) => o.objClass == 'LevelDefinition')
        .toList();
    final levelDefObj = levelDefList.isEmpty ? null : levelDefList.first;
    if (levelDefObj != null && levelDefObj.objData is Map<String, dynamic>) {
      levelDef = LevelDefinitionData.fromJson(
        levelDefObj.objData as Map<String, dynamic>,
      );
    }

    WaveManagerData? waveManager;
    final wmObj = levelFile.objects
        .where((o) => o.objClass == 'WaveManagerProperties')
        .firstOrNull;
    if (wmObj != null && wmObj.objData is Map<String, dynamic>) {
      waveManager = WaveManagerData.fromJson(
        wmObj.objData as Map<String, dynamic>,
      );
    }

    WaveManagerModuleData? waveModule;
    final wmmObj = levelFile.objects
        .where((o) => o.objClass == 'WaveManagerModuleProperties')
        .firstOrNull;
    if (wmmObj != null && wmmObj.objData is Map<String, dynamic>) {
      waveModule = WaveManagerModuleData.fromJson(
        wmmObj.objData as Map<String, dynamic>,
      );
    }

    WaveGeneratorPropertiesData? waveGenerator;
    final wgObj = levelFile.objects
        .where((o) => o.objClass == 'WaveGeneratorProperties')
        .firstOrNull;
    if (wgObj != null && wgObj.objData is Map<String, dynamic>) {
      waveGenerator = WaveGeneratorPropertiesData.fromJson(
        wgObj.objData as Map<String, dynamic>,
      );
    }

    return ParsedLevelData(
      levelDef: levelDef,
      waveManager: waveManager,
      waveModule: waveModule,
      waveGenerator: waveGenerator,
      objectMap: objectMap,
    );
  }

  static String extractAlias(String rtid) {
    final start = rtid.indexOf('(');
    final end = rtid.indexOf('@');
    if (start >= 0 && end > start) {
      return rtid.substring(start + 1, end);
    }
    return rtid;
  }

  static String? resolveStagePropertiesObjclass(
    LevelDefinitionData? levelDef,
    PvzLevelFile? levelFile,
  ) {
    if (levelDef == null || levelDef.stageModule.isEmpty) return null;
    final info = RtidParser.parse(levelDef.stageModule);
    if (info == null) return null;

    if (info.source == CustomStageLevelUtils.currentLevel &&
        levelFile != null) {
      final obj = levelFile.objects.firstWhereOrNull(
        (o) => o.aliases?.contains(info.alias) == true,
      );
      return obj?.objClass;
    }

    return ReferenceRepository.instance.getObjClass(info.alias);
  }

  static Map<String, dynamic>? resolveStageObjdata(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) {
    if (levelDef == null || levelDef.stageModule.isEmpty) return null;
    final info = RtidParser.parse(levelDef.stageModule);
    if (info == null) return null;

    dynamic raw;
    if (info.source == CustomStageLevelUtils.currentLevel) {
      final obj = levelFile.objects.firstWhereOrNull(
        (o) => o.aliases?.contains(info.alias) == true,
      );
      raw = obj?.objData;
    } else {
      raw = ReferenceRepository.instance.objectForAlias(info.alias)?.objData;
    }

    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  static bool isDeepSeaStageObjclass(String? objclass) {
    if (objclass == null) return false;
    return deepSeaStageObjclasses.contains(objclass);
  }

  static bool isPirateStageObjclass(String? objclass) {
    if (objclass == null) return false;
    return pirateStageObjclasses.contains(objclass);
  }

  static bool isRoofStageObjclass(String? objclass) {
    if (objclass == null) return false;
    return roofStageObjclasses.contains(objclass);
  }

  /// Returns true if the stage is a Pirate Seas lawn.
  static bool isPirateLawn(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) {
    final objclass = resolveStagePropertiesObjclass(levelDef, levelFile);
    if (isPirateStageObjclass(objclass)) return true;
    if (objclass != 'StageModuleProperties') return false;
    final objdata = resolveStageObjdata(levelDef, levelFile);
    final world = objdata?['BelongsToWorld'];
    return world is String && world.toLowerCase() == 'pirate';
  }

  static bool isPirateLawnFromFile(PvzLevelFile levelFile) {
    final parsed = parseLevel(levelFile);
    return isPirateLawn(parsed.levelDef, levelFile);
  }

  static const _lostcityBackgroundGroup =
      'DelayLoad_Background_LostCity_Compressed';
  static const _lostcityBackgroundPrefix = 'IMAGE_BACKGROUNDS_LOSTCITY';

  /// Checks the selected appearance, independently of the stage's mechanics.
  static bool usesLostCityBackground(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) => _usesStageBackground(
    levelDef,
    levelFile,
    imagePrefixes: const {_lostcityBackgroundPrefix},
    resourceGroup: _lostcityBackgroundGroup,
  );

  static bool usesDeepSeaBackground(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) => _usesStageBackground(
    levelDef,
    levelFile,
    imagePrefixes: const {
      'IMAGE_BACKGROUNDS_DEEPSEA',
      'IMAGE_BACKGROUNDS_DEEPSEALAND',
    },
    resourceGroup: 'DelayLoad_Background_Deepsea',
  );

  static bool _usesStageBackground(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile, {
    required Set<String> imagePrefixes,
    required String resourceGroup,
  }) {
    final objdata = resolveStageObjdata(levelDef, levelFile);
    if (objdata == null) return false;
    final prefix = objdata['BackgroundImagePrefix'];
    // A previous background's resource group can remain after a manual edit.
    // Prefer the selected image and never infer appearance from loaded assets,
    // the stage alias, its class, or BelongsToWorld.
    if (prefix is String && prefix.isNotEmpty) {
      return imagePrefixes.contains(prefix);
    }
    return objdata['BackgroundResourceGroup'] == resourceGroup;
  }

  /// Returns true if the stage uses the roof lawn implementation.
  static bool isRoofLawn(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) {
    return isRoofStageObjclass(
      resolveStagePropertiesObjclass(levelDef, levelFile),
    );
  }

  static bool isRoofLawnFromFile(PvzLevelFile levelFile) {
    final parsed = parseLevel(levelFile);
    return isRoofLawn(parsed.levelDef, levelFile);
  }

  /// Returns true if the lawn uses DeepSea or DeepSeaLand grid (6x10).
  static bool isDeepSeaLawn(
    LevelDefinitionData? levelDef, [
    PvzLevelFile? levelFile,
  ]) {
    return isDeepSeaStageObjclass(
      resolveStagePropertiesObjclass(levelDef, levelFile),
    );
  }

  /// Returns true if level uses 6-row grid. Convenience for screens with levelFile only.
  static bool isDeepSeaLawnFromFile(PvzLevelFile levelFile) {
    final parsed = parseLevel(levelFile);
    return isDeepSeaLawn(parsed.levelDef, levelFile);
  }

  static bool isUnderwaterWorldSixRowLawn(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) {
    final info = levelDef == null
        ? null
        : RtidParser.parse(levelDef.stageModule);
    if (info != null &&
        underwaterWorldSixRowStageAliases.contains(info.alias)) {
      return true;
    }
    return isDeepSeaLawn(levelDef, levelFile);
  }

  static bool isSouDaCheLawn(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) {
    final info = levelDef == null
        ? null
        : RtidParser.parse(levelDef.stageModule);
    if (info != null && info.alias == soudacheStageAlias) return true;
    final objdata = resolveStageObjdata(levelDef, levelFile);
    if (objdata == null) return false;
    return objdata['BackgroundResourceGroup'] == _soudacheBackgroundGroup ||
        objdata['BackgroundImagePrefix'] == _soudacheBackgroundPrefix;
  }

  static bool isSubmarineEnabledOnLawn(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) {
    final objclass = resolveStagePropertiesObjclass(levelDef, levelFile);
    if (objclass == null ||
        !CustomStageLevelUtils.supportsSubmarine(objclass)) {
      return false;
    }
    final objdata = resolveStageObjdata(levelDef, levelFile);
    if (objdata == null) return false;
    return CustomStageLevelUtils.isSubmarineEnabled(objdata);
  }

  static bool showsTideWaveEvents(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) {
    return isDeepSeaLawn(levelDef, levelFile) &&
        isSubmarineEnabledOnLawn(levelDef, levelFile);
  }

  static bool supportsLevelJamMusic(
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) {
    final objclass = resolveStagePropertiesObjclass(levelDef, levelFile);
    if (objclass == null) return false;
    return levelJamMusicStageObjclasses.contains(objclass);
  }

  static bool supportsLevelJamMusicFromFile(PvzLevelFile levelFile) {
    final parsed = parseLevel(levelFile);
    return supportsLevelJamMusic(parsed.levelDef, levelFile);
  }

  static bool isWaveEventAvailable(
    String objClass,
    LevelDefinitionData? levelDef,
    PvzLevelFile levelFile,
  ) {
    switch (objClass) {
      case 'SpawnZombiesFishWaveActionProps':
        return isDeepSeaLawn(levelDef, levelFile);
      case 'TideWaveWaveActionProps':
        return showsTideWaveEvents(levelDef, levelFile);
      default:
        return true;
    }
  }

  static bool willBeDeepSeaStageRtid(String rtid, PvzLevelFile levelFile) {
    final info = RtidParser.parse(rtid);
    if (info == null) return false;
    if (info.source == CustomStageLevelUtils.currentLevel) {
      final obj = levelFile.objects.firstWhereOrNull(
        (o) => o.aliases?.contains(info.alias) == true,
      );
      return isDeepSeaStageObjclass(obj?.objClass);
    }
    return isDeepSeaStageObjclass(
      ReferenceRepository.instance.getObjClass(info.alias),
    );
  }

  /// Returns (rows, cols) for the lawn. DeepSea: (6, 10), standard: (5, 9).
  static (int rows, int cols) getGridDimensions(
    LevelDefinitionData? levelDef, [
    PvzLevelFile? levelFile,
  ]) {
    return isDeepSeaLawn(levelDef, levelFile) ? (6, 10) : (5, 9);
  }

  static const deepSeaBoardType = 'submarine';

  /// Keeps [LevelDefinitionData.boardType] as `"submarine"` iff [isDeepSeaLawn].
  /// Independent of custom-lawn InitSubmarineInfo — otherwise planting on row 6 fails.
  /// When [persist] is true, writes the updated definition back into [levelFile].
  /// Returns true if BoardType changed.
  static bool syncDeepSeaBoardType(
    LevelDefinitionData levelDef,
    PvzLevelFile levelFile, {
    bool persist = true,
  }) {
    final want = isDeepSeaLawn(levelDef, levelFile) ? deepSeaBoardType : null;
    final current = (levelDef.boardType == null || levelDef.boardType!.isEmpty)
        ? null
        : levelDef.boardType;
    if (current == want) return false;
    levelDef.boardType = want;
    if (persist) writeLevelDefinition(levelDef, levelFile);
    return true;
  }

  /// Writes [levelDef] into the level file's LevelDefinition object.
  static void writeLevelDefinition(
    LevelDefinitionData levelDef,
    PvzLevelFile levelFile,
  ) {
    final obj = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'LevelDefinition',
    );
    if (obj != null) obj.objData = levelDef.toJson();
  }

  /// Syncs DeepSea BoardType then persists the LevelDefinition.
  static void syncAndWriteLevelDefinition(
    LevelDefinitionData levelDef,
    PvzLevelFile levelFile,
  ) {
    syncDeepSeaBoardType(levelDef, levelFile, persist: false);
    writeLevelDefinition(levelDef, levelFile);
  }

  static (int rows, int cols) getGridDimensionsFromFile(
    PvzLevelFile levelFile,
  ) {
    final parsed = parseLevel(levelFile);
    return getGridDimensions(parsed.levelDef, levelFile);
  }

  /// Returns true if level contains any data referencing row 5 (0-indexed) or higher.
  static bool has6RowDataInLevel(PvzLevelFile levelFile) {
    for (final obj in levelFile.objects) {
      if (obj.objData is! Map<String, dynamic>) continue;
      final data = obj.objData as Map<String, dynamic>;
      if (_hasRow5OrHigher(data)) return true;
      final list = data['GridSquareBlacklist'] as List<dynamic>?;
      if (list != null) {
        for (final item in list) {
          if (item is Map) {
            final y = _jsonNum(item['mY']) ?? _jsonNum(item['Y']);
            if (y != null && y.toInt() >= 5) return true;
          }
        }
      }
      final rails = data['Rails'] as List<dynamic>?;
      if (rails != null) {
        for (final r in rails) {
          if (r is Map) {
            final end = _jsonNum(r['RowEnd'])?.toInt();
            if (end != null && end >= 5) return true;
          }
        }
      }
      final carts = data['Railcarts'] as List<dynamic>?;
      if (carts != null) {
        for (final c in carts) {
          final row = c is Map ? _jsonNum(c['Row']) : null;
          if (row != null && row.toInt() >= 5) return true;
        }
      }
      final zombies = data['Zombies'] as List<dynamic>?;
      if (zombies != null) {
        for (final z in zombies) {
          final row = z is Map ? _jsonNum(z['Row']) : null;
          if (row != null && row.toInt() >= 6) {
            return true; // 1-based: row 6 = 6th row
          }
        }
      }
    }
    return false;
  }

  static bool _hasRow5OrHigher(Map<String, dynamic> data) {
    final locations = data['SpawnPositionsPool'] as List<dynamic>?;
    if (locations != null) {
      for (final loc in locations) {
        if (loc is Map) {
          final y = _jsonNum(loc['mY']) ?? _jsonNum(loc['y']);
          if (y != null && y.toInt() >= 5) return true;
        }
      }
    }
    for (final key in ['Plants', 'Placements', 'InitialPlantPlacements']) {
      final list = data[key] as List<dynamic>?;
      if (list != null) {
        for (final p in list) {
          if (p is Map) {
            final gy = _jsonNum(p['GridY']) ?? _jsonNum(p['gridY']);
            if (gy != null && gy.toInt() >= 5) return true;
          }
        }
      }
    }
    return false;
  }

  /// JSON numbers may be encoded as [num] or [String] depending on source.
  static num? _jsonNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value.trim());
    return null;
  }
}

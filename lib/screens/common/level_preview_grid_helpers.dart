import 'package:c_editor/data/gladiator_row_utils.dart';
import 'package:collection/collection.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/mold_colony_module_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/challenge_resource_l10n.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:flutter/material.dart';

class LevelPreviewGridStyle {
  final Color gridBg;
  final Color borderColor;
  final Color cellBorderColor;
  final Color? selectionColor;
  final double cellAspectRatio;
  final double? maxWidth;

  const LevelPreviewGridStyle({
    required this.gridBg,
    required this.borderColor,
    required this.cellBorderColor,
    this.selectionColor,
    this.cellAspectRatio = 1.0,
    this.maxWidth,
  });

  LevelPreviewGridStyle copyWith({
    Color? gridBg,
    Color? borderColor,
    Color? cellBorderColor,
    Color? selectionColor,
    double? cellAspectRatio,
    double? maxWidth,
  }) {
    return LevelPreviewGridStyle(
      gridBg: gridBg ?? this.gridBg,
      borderColor: borderColor ?? this.borderColor,
      cellBorderColor: cellBorderColor ?? this.cellBorderColor,
      selectionColor: selectionColor ?? this.selectionColor,
      cellAspectRatio: cellAspectRatio ?? this.cellAspectRatio,
      maxWidth: maxWidth ?? this.maxWidth,
    );
  }
}

LevelPreviewGridStyle resolveGridStyle(
  BuildContext context,
  GridPreviewModuleKind kind,
) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final blueGreyBg = isDark ? const Color(0xFF31383B) : const Color(0xFFD7ECF1);
  const blueGreyBorder = Color(0xFF6B899A);

  final greenBg = isDark ? const Color(0xFF3C483D) : const Color(0xFFE8F5E9);
  const greenBorder = Color(0xFFC8E6C9);
  const greenCellBorder = Color(0xFFA5D6A7);

  final purpleBg = isDark ? const Color(0xFF40404B) : const Color(0xFFEFEFFF);
  const purpleBorder = Color(0xFFBAC4FA);
  const purpleCellBorder = Color(0xFF8581FA);

  final redBg = isDark ? const Color(0xFF4B3131) : const Color(0xFFFFEFEF);
  const redBorder = Color(0xFFFABABA);
  const redCellBorder = Color(0xFFFA8585);

  final zombossBg = isDark ? const Color(0xFF384038) : const Color(0xFF7A8870);

  final neutralBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);

  Color gridBg;
  Color borderColor;
  Color cellBorderColor;
  Color selectionColor = theme.colorScheme.primary;
  double cellAspectRatio = 1.0;

  switch (kind) {
    case GridPreviewModuleKind.plants:
      gridBg = greenBg;
      borderColor = greenBorder;
      cellBorderColor = greenCellBorder;
      break;

    case GridPreviewModuleKind.zombies:
    case GridPreviewModuleKind.dropShip:
      gridBg = purpleBg;
      borderColor = purpleBorder;
      cellBorderColor = purpleCellBorder;
      break;

    case GridPreviewModuleKind.common:
    case GridPreviewModuleKind.armrack:
    case GridPreviewModuleKind.energyGrid:
    case GridPreviewModuleKind.lunarMineVein:
    case GridPreviewModuleKind.radiationMeteor:
    case GridPreviewModuleKind.gladiatorRow:
    case GridPreviewModuleKind.piratePlank:
    case GridPreviewModuleKind.fogSystem:
    case GridPreviewModuleKind.roofProperties:
    case GridPreviewModuleKind.renaissance:
    case GridPreviewModuleKind.bronzeStatue:
    case GridPreviewModuleKind.smokePollution:
    case GridPreviewModuleKind.manholePipeline:
    case GridPreviewModuleKind.vases:
    case GridPreviewModuleKind.explosiveBarrels:
    case GridPreviewModuleKind.portalFight:
    case GridPreviewModuleKind.gulliverTunnel:
    case GridPreviewModuleKind.bowlingFoulLine:
    case GridPreviewModuleKind.moldColony:
      gridBg = blueGreyBg;
      borderColor = blueGreyBorder;
      cellBorderColor = blueGreyBorder.withValues(alpha: 0.8);
      break;

    case GridPreviewModuleKind.tunnelDefend:
      gridBg = isDark ? const Color(0xFF3E2723) : const Color(0xFFEFEBE9);
      borderColor = const Color(0xFF9E9E9E);
      cellBorderColor = const Color(0xFF9E9E9E).withValues(alpha: 0.5);
      cellAspectRatio = 128 / 152;
      break;

    case GridPreviewModuleKind.expeditionTiles:
      gridBg = isDark ? const Color(0xFF102B33) : const Color(0xFFE0F7FA);
      borderColor = const Color(0xFF9E9E9E);
      cellBorderColor = const Color(0xFF9E9E9E).withValues(alpha: 0.5);
      cellAspectRatio = 128 / 152;
      break;

    case GridPreviewModuleKind.railcart:
    case GridPreviewModuleKind.mechanismPlank:
      gridBg = isDark ? const Color(0xFF503C34) : const Color(0xFFD7CCC8);
      borderColor = const Color(0xFF795548);
      cellBorderColor = const Color(0xFF8D6E63);
      break;

    case GridPreviewModuleKind.tideSystem:
      gridBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0F2F1);
      borderColor = theme.dividerColor;
      cellBorderColor = theme.dividerColor.withValues(alpha: 0.8);
      break;

    case GridPreviewModuleKind.powerTile:
      gridBg = neutralBg;
      borderColor = theme.dividerColor;
      cellBorderColor = theme.dividerColor.withValues(alpha: 0.8);
      break;

    case GridPreviewModuleKind.zombossMech:
    case GridPreviewModuleKind.zomboss:
      gridBg = zombossBg;
      borderColor = const Color(0xFF8F9E82);
      cellBorderColor = const Color(0xFF8F9E82);
      break;

    case GridPreviewModuleKind.protectPlants:
    case GridPreviewModuleKind.seeingStars:
      gridBg = greenBg;
      borderColor = greenBorder;
      cellBorderColor = greenCellBorder;
      break;

    case GridPreviewModuleKind.flowers:
      gridBg = redBg;
      borderColor = redBorder;
      cellBorderColor = redCellBorder;
      break;

    case GridPreviewModuleKind.protectItems:
      gridBg = blueGreyBg;
      borderColor = blueGreyBorder;
      cellBorderColor = blueGreyBorder.withValues(alpha: 0.8);
      break;

    case GridPreviewModuleKind.empty:
      gridBg = neutralBg;
      borderColor = theme.dividerColor;
      cellBorderColor = theme.dividerColor.withValues(alpha: 0.8);
      break;
  }

  return LevelPreviewGridStyle(
    gridBg: gridBg,
    borderColor: borderColor,
    cellBorderColor: cellBorderColor,
    selectionColor: selectionColor,
    cellAspectRatio: cellAspectRatio,
  );
}

(int rows, int cols) getGridDimensions(PvzLevelFile levelFile) {
  final parsed = LevelParser.parseLevel(levelFile);
  final objclass = LevelParser.resolveStagePropertiesObjclass(
    parsed.levelDef,
    levelFile,
  );

  var (rows, cols) = LevelParser.getGridDimensionsFromFile(levelFile);

  const additional6RowStages = {'AtlantisStageProperties'};

  if (additional6RowStages.contains(objclass) ||
      LevelParser.has6RowDataInLevel(levelFile)) {
    rows = 6;
    cols = 10;
  }

  final stageData = LevelParser.resolveStageObjdata(parsed.levelDef, levelFile);
  if (stageData != null) {
    if (stageData.containsKey('RowCount'))
      rows = (stageData['RowCount'] as num).toInt();
    if (stageData.containsKey('ColumnCount'))
      cols = (stageData['ColumnCount'] as num).toInt();
  }

  return (rows, cols);
}

enum GridPreviewModuleKind {
  common,
  plants,
  zombies,
  piratePlank,
  railcart,
  mechanismPlank,
  armrack,
  energyGrid,
  lunarMineVein,
  radiationMeteor,
  gladiatorRow,
  bronzeStatue,
  powerTile,
  fogSystem,
  tideSystem,
  smokePollution,
  manholePipeline,
  renaissance,
  roofProperties,
  tunnelDefend,
  expeditionTiles,
  gulliverTunnel,
  vases,
  explosiveBarrels,
  portalFight,
  bowlingFoulLine,
  moldColony,
  dropShip,
  zombossMech,
  zomboss,
  protectPlants,
  seeingStars,
  protectItems,
  flowers,
  empty,
}

class GridPreviewCategoryOption {
  const GridPreviewCategoryOption({
    required this.kind,
    required this.label,
    this.wave,
    this.index,
  });

  final GridPreviewModuleKind kind;
  final String label;
  final int? wave;
  final int? index;

  String get key {
    if (wave != null) return '${kind.name}:w$wave';
    if (index != null) return '${kind.name}:i$index';
    return kind.name;
  }
}

bool levelHasPrePlacedGridPreview(PvzLevelFile levelFile) {
  if (levelHasPrePlacedPlants(levelFile)) return true;
  if (levelHasPrePlacedZombies(levelFile)) return true;
  if (levelHasModule(levelFile, 'InitialGridItemProperties')) return true;
  if (levelHasModule(levelFile, 'PiratePlankProperties')) return true;
  if (levelHasModule(levelFile, 'RailcartProperties')) return true;
  if (levelHasModule(levelFile, 'MechanismPlankProperties')) return true;
  if (levelHasModule(levelFile, 'BronzeProperties')) return true;
  if (levelHasModule(levelFile, 'PowerTileProperties')) return true;
  if (levelHasModule(levelFile, 'WarMistProperties')) return true;
  if (levelHasModule(levelFile, 'TideProperties')) return true;
  if (levelHasModule(levelFile, 'SmokePollutionModuleProperties')) return true;
  if (levelHasModule(levelFile, 'ManholePipelineModuleProperties')) return true;
  if (levelHasModule(levelFile, 'RenaiModuleProperties')) return true;
  if (levelHasModule(levelFile, 'RoofProperties')) return true;
  if (levelHasModule(levelFile, 'TunnelDefendModuleProperties')) return true;
  if (levelHasModule(levelFile, 'InitialGridItemGulliverTunnelProperties'))
    return true;
  if (levelHasModule(levelFile, 'ArmrackProperties')) return true;
  if (levelHasModule(levelFile, 'EnergyGridProperties')) return true;
  if (levelHasModule(levelFile, 'LunarMineVeinModuleProperties')) return true;
  if (levelHasModule(levelFile, 'RadiationMeteorModuleProperties')) return true;
  final gladiator = readGladiatorRowModuleData(levelFile);
  if (gladiator != null &&
      gladiator.usesTrophyMode &&
      gladiator.encounters.isNotEmpty) {
    return true;
  }
  if (levelHasModule(levelFile, 'VaseBreakerPresetProperties')) return true;
  if (levelHasModule(levelFile, 'VaseBreakerArcadeModuleProperties'))
    return true;
  if (levelHasModule(levelFile, 'VaseBreakerFlowModuleProperties')) return true;
  if (levelHasModule(levelFile, 'BombProperties')) return true;
  if (levelHasModule(levelFile, 'PVZ1PassageModuleProperties')) return true;
  if (levelHasModule(levelFile, 'BowlingMinigameProperties')) return true;
  if (levelHasModule(levelFile, MoldColonyModuleUtils.moduleObjClass)) {
    return true;
  }
  if (levelHasModule(levelFile, 'DropShipProperties')) return true;
  if (levelHasZomboss(levelFile)) return true;
  if (levelHasBoss(levelFile)) return true;
  if (levelHasModule(levelFile, 'ProtectThePlantChallengeProperties'))
    return true;
  if (levelHasModule(levelFile, 'ProtectTheGridItemChallengeProperties'))
    return true;
  if (levelHasModule(levelFile, 'StarChallengeModuleProperties')) return true;
  if (levelHasModule(levelFile, 'PVZ1SeeingStarsModuleProperties')) return true;

  return false;
}

bool levelHasDropShip(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'DropShipProperties');
}

bool levelHasCommonGridItems(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'InitialGridItemProperties');
}

bool levelHasPrePlacedPlants(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'InitialPlantProperties') ||
      levelHasModule(levelFile, 'InitialPlantEntryProperties') ||
      levelHasModule(levelFile, 'FrozenPlantPlacement');
}

bool levelHasPrePlacedZombies(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'InitialZombieProperties');
}

bool levelHasFastEntry(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'ZombieMoveFastModuleProperties');
}

bool levelHasWeather(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'DefaultSnow') ||
      levelHasModule(levelFile, 'LightningRain') ||
      levelHasModule(levelFile, 'DefaultRainDark');
}

enum LevelWeatherType { snow, lightning, rain }

LevelWeatherType? getLevelWeatherType(PvzLevelFile levelFile) {
  if (levelHasModule(levelFile, 'DefaultSnow')) return LevelWeatherType.snow;
  if (levelHasModule(levelFile, 'LightningRain'))
    return LevelWeatherType.lightning;
  if (levelHasModule(levelFile, 'DefaultRainDark'))
    return LevelWeatherType.rain;
  return null;
}

String? getWeatherLabel(LevelWeatherType type, AppLocalizations l10n) {
  switch (type) {
    case LevelWeatherType.snow:
      return l10n.weatherOption_DefaultSnow_label;
    case LevelWeatherType.lightning:
      return l10n.weatherOption_LightningRain_label;
    case LevelWeatherType.rain:
      return l10n.weatherOption_DefaultRainDark_label;
  }
}

bool levelHasSpermWhale(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'SpermWhaleModuleProperties');
}

bool levelHasWitch(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'WitchModuleProperties');
}

List<GridPreviewCategoryOption> collectGridPreviewCategories(
  BuildContext context,
  PvzLevelFile levelFile,
  AppLocalizations l10n,
) {
  final categories = <GridPreviewCategoryOption>[];

  if (levelHasPrePlacedPlants(levelFile)) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.plants,
        label: l10n.previewTabPlants,
      ),
    );
  }

  final hasPrePlacedZombies = levelHasPrePlacedZombies(levelFile);
  final hasDropShip = levelHasModule(levelFile, 'DropShipProperties');

  if (hasPrePlacedZombies) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.zombies,
        label: l10n.previewTabZombies,
      ),
    );
  }

  if (hasDropShip) {
    final dropData = readDropShipData(levelFile);
    if (dropData != null && dropData.appearWaves.isNotEmpty) {
      if (dropData.appearWaves.length <= 1) {
        categories.add(
          GridPreviewCategoryOption(
            kind: GridPreviewModuleKind.dropShip,
            label: l10n.moduleTitle_DropShipProperties,
          ),
        );
      } else {
        for (int i = 0; i < dropData.appearWaves.length; i++) {
          final wave = dropData.appearWaves[i].wave + 1;
          categories.add(
            GridPreviewCategoryOption(
              kind: GridPreviewModuleKind.dropShip,
              label: l10n.customZombieWaveItem(wave),
              index: i,
            ),
          );
        }
      }
    }
  }

  final lunarMineForCommon = readLunarMineVeinModuleData(levelFile);
  final hasLunarVeinsOnCommon =
      lunarMineForCommon != null && lunarMineForCommon.placements.isNotEmpty;
  if (levelHasCommonGridItems(levelFile) || hasLunarVeinsOnCommon) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.common,
        label: l10n.previewTabGridItems,
      ),
    );
  }

  void addModule(GridPreviewModuleKind kind, String label) {
    categories.add(GridPreviewCategoryOption(kind: kind, label: label));
  }

  if (levelHasModule(levelFile, 'PiratePlankProperties')) {
    addModule(
      GridPreviewModuleKind.piratePlank,
      l10n.moduleTitle_PiratePlankProperties,
    );
  }
  if (levelHasModule(levelFile, 'RailcartProperties')) {
    addModule(
      GridPreviewModuleKind.railcart,
      l10n.moduleTitle_RailcartProperties,
    );
  }
  if (levelHasModule(levelFile, 'MechanismPlankProperties')) {
    addModule(
      GridPreviewModuleKind.mechanismPlank,
      l10n.moduleTitle_MechanismPlankProperties,
    );
  }
  if (levelHasModule(levelFile, 'BronzeProperties')) {
    addModule(
      GridPreviewModuleKind.bronzeStatue,
      l10n.moduleTitle_BronzeProperties,
    );
  }
  if (levelHasModule(levelFile, 'PowerTileProperties')) {
    addModule(
      GridPreviewModuleKind.powerTile,
      l10n.moduleTitle_PowerTileProperties,
    );
  }
  if (levelHasModule(levelFile, 'WarMistProperties')) {
    addModule(
      GridPreviewModuleKind.fogSystem,
      l10n.moduleTitle_WarMistProperties,
    );
  }
  if (levelHasModule(levelFile, 'TideProperties')) {
    addModule(
      GridPreviewModuleKind.tideSystem,
      l10n.moduleTitle_TideProperties,
    );
  }
  if (levelHasModule(levelFile, 'SmokePollutionModuleProperties')) {
    addModule(
      GridPreviewModuleKind.smokePollution,
      l10n.moduleTitle_SmokePollutionModuleProperties,
    );
  }
  if (levelHasModule(levelFile, 'BombProperties')) {
    addModule(
      GridPreviewModuleKind.explosiveBarrels,
      l10n.moduleTitle_BombProperties,
    );
  }
  if (levelHasModule(levelFile, 'PVZ1PassageModuleProperties')) {
    addModule(
      GridPreviewModuleKind.portalFight,
      l10n.moduleTitle_PVZ1PassageModuleProperties,
    );
  }
  if (levelHasModule(levelFile, 'BowlingMinigameProperties')) {
    addModule(
      GridPreviewModuleKind.bowlingFoulLine,
      l10n.moduleTitle_BowlingMinigameProperties,
    );
  }
  if (levelHasModule(levelFile, MoldColonyModuleUtils.moduleObjClass)) {
    addModule(
      GridPreviewModuleKind.moldColony,
      l10n.moduleTitle_MoldColonyChallengeProps,
    );
  }
  if (levelHasModule(levelFile, 'ManholePipelineModuleProperties')) {
    final pipeData = readManholePipelineData(levelFile);
    if (pipeData != null) {
      if (pipeData.pipelineList.length <= 1) {
        addModule(
          GridPreviewModuleKind.manholePipeline,
          l10n.moduleTitle_ManholePipelineModuleProperties,
        );
      } else {
        for (int i = 0; i < pipeData.pipelineList.length; i++) {
          categories.add(
            GridPreviewCategoryOption(
              kind: GridPreviewModuleKind.manholePipeline,
              label: l10n.pipeN(i + 1),
              index: i,
            ),
          );
        }
      }
    }
  }
  final renaiData = readRenaiModuleData(levelFile);
  if (renaiData != null) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.renaissance,
        label: l10n.renaiModuleDayStatues,
      ),
    );

    if (renaiData.nightEnabled) {
      categories.add(
        GridPreviewCategoryOption(
          kind: GridPreviewModuleKind.renaissance,
          label: l10n.renaiModuleNightStatues,
          index: 1,
        ),
      );
    }
  }
  if (levelHasModule(levelFile, 'RoofProperties')) {
    addModule(
      GridPreviewModuleKind.roofProperties,
      l10n.moduleTitle_RoofProperties,
    );
  }
  if (levelHasStandardTunnelDefendModule(levelFile)) {
    addModule(
      GridPreviewModuleKind.tunnelDefend,
      l10n.moduleTitle_TunnelDefendModuleProperties,
    );
  }
  if (levelHasExpeditionTilesModule(levelFile)) {
    addModule(
      GridPreviewModuleKind.expeditionTiles,
      l10n.moduleTitle_SouDaCheTunnelDefendDefault,
    );
  }
  if (levelHasModule(levelFile, 'InitialGridItemGulliverTunnelProperties')) {
    addModule(
      GridPreviewModuleKind.gulliverTunnel,
      l10n.moduleTitle_InitialGridItemGulliverTunnelProperties,
    );
  }

  if (levelHasModule(levelFile, 'ProtectThePlantChallengeProperties')) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.protectPlants,
        label: l10n.moduleTitle_ProtectThePlantChallengeProperties,
      ),
    );
  }
  if (levelHasModule(levelFile, 'PVZ1SeeingStarsModuleProperties')) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.seeingStars,
        label: l10n.moduleTitle_PVZ1SeeingStarsModuleProperties,
      ),
    );
  }
  if (levelHasModule(levelFile, 'ProtectTheGridItemChallengeProperties')) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.protectItems,
        label: l10n.moduleTitle_ProtectTheGridItemChallengeProperties,
      ),
    );
  }

  final flowersChallenge = readFlowersChallengeData(levelFile);
  if (flowersChallenge != null) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.flowers,
        label: ChallengeResourceL10n.title(
          context,
          'StarChallengeZombieDistanceProps',
        ),
      ),
    );
  }

  final armrackData = readArmrackModuleData(levelFile);
  if (armrackData != null) {
    final waves = armrackData.overrides.map((o) => o.wave).toSet().toList()
      ..sort();
    for (final wave in waves) {
      categories.add(
        GridPreviewCategoryOption(
          kind: GridPreviewModuleKind.armrack,
          label: _waveCategoryLabel(
            l10n,
            l10n.moduleTitle_ArmrackProperties,
            wave,
            waves.length,
          ),
          wave: wave,
        ),
      );
    }
  }

  final energyData = readEnergyGridModuleData(levelFile);
  if (energyData != null) {
    final waves = energyData.overrides.map((o) => o.wave).toSet().toList()
      ..sort();
    for (final wave in waves) {
      categories.add(
        GridPreviewCategoryOption(
          kind: GridPreviewModuleKind.energyGrid,
          label: _waveCategoryLabel(
            l10n,
            l10n.moduleTitle_EnergyGridProperties,
            wave,
            waves.length,
          ),
          wave: wave,
        ),
      );
    }
  }

  final lunarMineData = readLunarMineVeinModuleData(levelFile);
  if (lunarMineData != null) {
    final waves =
        lunarMineData.placements
            .map((placement) => placement.emergenceWave)
            .toSet()
            .toList()
          ..sort();
    if (waves.isEmpty) waves.add(1);
    for (final wave in waves) {
      categories.add(
        GridPreviewCategoryOption(
          kind: GridPreviewModuleKind.lunarMineVein,
          label: _waveCategoryLabel(
            l10n,
            l10n.moduleTitle_LunarMineVeinModuleProperties,
            wave,
            waves.length,
          ),
          wave: wave,
        ),
      );
    }
  }

  final radiationMeteorData = readRadiationMeteorModuleData(levelFile);
  if (radiationMeteorData != null) {
    final waves =
        radiationMeteorData.spawnSchedule
            .map((spawn) => spawn.wave)
            .toSet()
            .toList()
          ..sort();
    if (waves.isEmpty) waves.add(1);
    for (final wave in waves) {
      categories.add(
        GridPreviewCategoryOption(
          kind: GridPreviewModuleKind.radiationMeteor,
          label: _waveCategoryLabel(
            l10n,
            l10n.moduleTitle_RadiationMeteorModuleProperties,
            wave,
            waves.length,
          ),
          wave: wave,
        ),
      );
    }
  }

  final gladiatorData = readGladiatorRowModuleData(levelFile);
  if (gladiatorData != null && gladiatorData.usesTrophyMode) {
    for (var index = 0; index < gladiatorData.encounters.length; index++) {
      final encounter = gladiatorData.encounters[index];
      categories.add(
        GridPreviewCategoryOption(
          kind: GridPreviewModuleKind.gladiatorRow,
          label:
              '${l10n.groupN(index + 1)} · ${l10n.customZombieWaveItem(encounter.wave + 1)}',
          index: index,
        ),
      );
    }
  }

  if (levelHasZomboss(levelFile)) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.zombossMech,
        label: l10n.zomboss,
      ),
    );
  }
  if (levelHasBoss(levelFile)) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.zomboss,
        label: l10n.boss,
      ),
    );
  }

  if (levelHasModule(levelFile, 'VaseBreakerPresetProperties') ||
      levelHasModule(levelFile, 'VaseBreakerArcadeModuleProperties') ||
      levelHasModule(levelFile, 'VaseBreakerFlowModuleProperties')) {
    categories.add(
      GridPreviewCategoryOption(
        kind: GridPreviewModuleKind.vases,
        label: l10n.vaseBreaker,
      ),
    );
  }

  return categories;
}

String _waveCategoryLabel(
  AppLocalizations l10n,
  String moduleTitle,
  int wave,
  int waveCount,
) {
  return l10n.customZombieWaveItem(wave);
}

PvzObject? findModuleObject(PvzLevelFile levelFile, String objClass) {
  final direct = levelFile.objects.firstWhereOrNull(
    (o) => o.objClass == objClass,
  );
  if (direct != null) return direct;

  final parsed = LevelParser.parseLevel(levelFile);
  final modules = parsed.levelDef?.modules ?? [];

  final moduleAliases = modules
      .map((m) => RtidParser.parse(m)?.alias)
      .whereType<String>()
      .toSet();

  for (final obj in levelFile.objects) {
    if (obj.objClass == objClass) {
      if (obj.aliases != null &&
          obj.aliases!.any((a) => moduleAliases.contains(a))) {
        return obj;
      }
    }
  }
  return null;
}

LunarMineVeinModulePropertiesData? readLunarMineVeinModuleData(
  PvzLevelFile levelFile,
) {
  final obj = findModuleObject(levelFile, 'LunarMineVeinModuleProperties');
  return obj != null
      ? LunarMineVeinModulePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

MoonLifeSupportSystemPropertiesData? readMoonLifeSupportSystemData(
  PvzLevelFile levelFile,
) {
  final obj = findModuleObject(levelFile, 'MoonLifeSupportSystemProperties');
  if (obj == null || obj.objData is! Map) return null;
  try {
    return MoonLifeSupportSystemPropertiesData.fromJson(
      Map<String, dynamic>.from(obj.objData as Map),
    );
  } catch (_) {
    return MoonLifeSupportSystemPropertiesData();
  }
}

RadiationMeteorModulePropertiesData? readRadiationMeteorModuleData(
  PvzLevelFile levelFile,
) {
  final obj = findModuleObject(levelFile, 'RadiationMeteorModuleProperties');
  return obj != null
      ? RadiationMeteorModulePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

SmokePollutionModulePropertiesData? readSmokePollutionData(
  PvzLevelFile levelFile,
) {
  final obj = findModuleObject(levelFile, 'SmokePollutionModuleProperties');
  return obj != null
      ? SmokePollutionModulePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

ManholePipelineModuleData? readManholePipelineData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'ManholePipelineModuleProperties');
  return obj != null
      ? ManholePipelineModuleData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

RenaiModulePropertiesData? readRenaiModuleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'RenaiModuleProperties');
  return obj != null
      ? RenaiModulePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

RoofPropertiesData? readRoofPropertiesData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'RoofProperties');
  return obj != null
      ? RoofPropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

const String expeditionTilesDefaultAlias = 'SouDaCheTunnelDefendDefault';

bool isExpeditionTilesModuleObject(PvzObject obj) {
  if (obj.objClass != 'TunnelDefendModuleProperties') return false;
  final aliases = obj.aliases ?? const <String>[];
  if (aliases.any(
    (alias) =>
        alias == expeditionTilesDefaultAlias ||
        alias.startsWith('SoudacheTunnelDefendStage'),
  )) {
    return true;
  }
  final data = obj.objData;
  return data is Map && (data['BrickMapIndex'] as num?)?.toInt() == 3;
}

bool levelHasExpeditionTilesModule(PvzLevelFile levelFile) {
  if (levelFile.objects.any(isExpeditionTilesModuleObject)) return true;
  final parsed = LevelParser.parseLevel(levelFile);
  for (final rtid in parsed.levelDef?.modules ?? const <String>[]) {
    final info = RtidParser.parse(rtid);
    final alias = info?.alias;
    if (alias == expeditionTilesDefaultAlias ||
        (alias?.startsWith('SoudacheTunnelDefendStage') ?? false)) {
      return true;
    }
  }
  return false;
}

bool levelHasStandardTunnelDefendModule(PvzLevelFile levelFile) {
  if (levelFile.objects.any(
    (obj) =>
        obj.objClass == 'TunnelDefendModuleProperties' &&
        !isExpeditionTilesModuleObject(obj),
  )) {
    return true;
  }
  final parsed = LevelParser.parseLevel(levelFile);
  for (final rtid in parsed.levelDef?.modules ?? const <String>[]) {
    final info = RtidParser.parse(rtid);
    if (info == null) continue;
    if (info.alias == 'TunnelDefend') return true;
    if (info.source == 'CurrentLevel') {
      final obj = parsed.objectMap[info.alias];
      if (obj != null &&
          obj.objClass == 'TunnelDefendModuleProperties' &&
          !isExpeditionTilesModuleObject(obj)) {
        return true;
      }
    }
  }
  return false;
}

TunnelDefendModuleData? readTunnelDefendData(PvzLevelFile levelFile) {
  final obj = levelFile.objects.firstWhereOrNull(
    (item) =>
        item.objClass == 'TunnelDefendModuleProperties' &&
        !isExpeditionTilesModuleObject(item),
  );
  return obj != null
      ? TunnelDefendModuleData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

TunnelDefendModuleData? readExpeditionTilesData(PvzLevelFile levelFile) {
  final obj = levelFile.objects.firstWhereOrNull(isExpeditionTilesModuleObject);
  return obj != null
      ? TunnelDefendModuleData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
          defaultReportError: false,
        )
      : null;
}

InitialGridItemGulliverTunnelPropertiesData? readGulliverTunnelData(
  PvzLevelFile levelFile,
) {
  final obj = findModuleObject(
    levelFile,
    'InitialGridItemGulliverTunnelProperties',
  );
  return obj != null
      ? InitialGridItemGulliverTunnelPropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

PiratePlankPropertiesData? readPiratePlankModuleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'PiratePlankProperties');
  return obj != null
      ? PiratePlankPropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

RailcartPropertiesData? readRailcartModuleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'RailcartProperties');
  return obj != null
      ? RailcartPropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

BronzePropertiesData? readBronzeModuleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'BronzeProperties');
  return obj != null
      ? BronzePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

PowerTilePropertiesData? readPowerTileModuleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'PowerTileProperties');
  return obj != null
      ? PowerTilePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

WarMistPropertiesData? readWarMistModuleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'WarMistProperties');
  return obj != null
      ? WarMistPropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

TidePropertiesData? readTideModuleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'TideProperties');
  return obj != null
      ? TidePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

BombPropertiesData? readBombPropertiesData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'BombProperties');
  return obj != null
      ? BombPropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

PVZ1PassageModulePropertiesData? readPassageModuleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'PVZ1PassageModuleProperties');
  return obj != null
      ? PVZ1PassageModulePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

BowlingMinigamePropertiesData? readBowlingMinigameData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'BowlingMinigameProperties');
  return obj != null
      ? BowlingMinigamePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

BoardGridMapPropsData? readMoldColonyLayoutData(PvzLevelFile levelFile) {
  final module = findModuleObject(
    levelFile,
    MoldColonyModuleUtils.moduleObjClass,
  );
  if (module?.objData is! Map) return null;
  final data = MoldColonyChallengePropsData.fromJson(
    Map<String, dynamic>.from(module!.objData as Map),
  );
  final layout = MoldColonyModuleUtils.findLayoutObject(
    levelFile,
    data.locations,
  );
  if (layout?.objData is! Map) return null;
  return BoardGridMapPropsData.fromJson(
    Map<String, dynamic>.from(layout!.objData as Map),
  );
}

PVZ1CopycatsModulePropertiesData? readCopycatsModuleData(
  PvzLevelFile levelFile,
) {
  final obj = findModuleObject(levelFile, 'PVZ1CopycatsModuleProperties');
  return obj != null
      ? PVZ1CopycatsModulePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

PVZ1SeeingStarsModulePropertiesData? readSeeingStarsModuleData(
  PvzLevelFile levelFile,
) {
  final obj = findModuleObject(levelFile, 'PVZ1SeeingStarsModuleProperties');
  return obj != null
      ? PVZ1SeeingStarsModulePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

DropShipPropertiesData? readDropShipData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'DropShipProperties');
  return obj != null
      ? DropShipPropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

HeianWindModulePropertiesData? readHeianWindData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'HeianWindModuleProperties');
  return obj != null
      ? HeianWindModulePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

WitchModulePropertiesData? readWitchModuleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'WitchModuleProperties');
  return obj != null
      ? WitchModulePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

SpermWhaleModulePropertiesData? readSpermWhaleModuleData(
  PvzLevelFile levelFile,
) {
  final obj = findModuleObject(levelFile, 'SpermWhaleModuleProperties');
  return obj != null
      ? SpermWhaleModulePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

Map<String, dynamic>? readMechanismPlankModuleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'MechanismPlankProperties');
  return obj != null ? Map<String, dynamic>.from(obj.objData as Map) : null;
}

List<List<bool>> buildRailcartRailsGrid(
  RailcartPropertiesData data,
  int rows,
  int cols,
) {
  final grid = List.generate(cols, (_) => List.filled(rows, false));
  for (final rail in data.rails) {
    for (var r = rail.rowStart; r <= rail.rowEnd; r++) {
      if (rail.column >= 0 && rail.column < cols && r >= 0 && r < rows)
        grid[rail.column][r] = true;
    }
  }
  return grid;
}

Set<String> buildRailcartCartSet(RailcartPropertiesData data) {
  return data.railcarts.map((c) => '${c.column},${c.row}').toSet();
}

class MechanismPlankPreviewState {
  const MechanismPlankPreviewState({
    required this.mX,
    required this.mY,
    required this.mWidth,
    required this.mHeight,
    required this.cartLocalRows,
  });
  final int mX, mY, mWidth, mHeight;
  final Set<int> cartLocalRows;
  bool isInsideRect(int col, int row) =>
      col >= mX && col < mX + mWidth && row >= mY && row < mY + mHeight;
  bool hasRailAt(int col, int row) {
    if (!isInsideRect(col, row)) return false;
    return cartLocalRows.any((cartRow) => (row - mY - cartRow).abs() <= 1);
  }

  bool hasCartAt(int col, int row) =>
      isInsideRect(col, row) && cartLocalRows.contains(row - mY);
  String cartAssetKind(int col) => mWidth <= 1
      ? 'middle'
      : (col <= mX ? 'left' : (col >= mX + mWidth - 1 ? 'right' : 'middle'));
}

MechanismPlankPreviewState? buildMechanismPlankPreviewState(
  Map<String, dynamic>? data,
) {
  if (data == null) return null;
  final rect = Map<String, dynamic>.from(
    data['MechanismGearsRect'] as Map? ?? {},
  );
  final plankRows = ((data['MechanismPlankRows'] as List?) ?? ['0', '4'])
      .map((e) => int.tryParse(e.toString()))
      .whereType<int>()
      .toSet();
  return MechanismPlankPreviewState(
    mX: (rect['mX'] as num?)?.toInt() ?? 0,
    mY: (rect['mY'] as num?)?.toInt() ?? 0,
    mWidth: (rect['mWidth'] as num?)?.toInt() ?? 4,
    mHeight: (rect['mHeight'] as num?)?.toInt() ?? 5,
    cartLocalRows: plankRows,
  );
}

SeedRainPropertiesData? readSeedRainData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'SeedRainProperties');
  return obj != null
      ? SeedRainPropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

ZombieRushModuleData? readZombieRushData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'ZombieRushModuleProperties');
  return obj != null
      ? ZombieRushModuleData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

bool hasPVZ1Overwhelm(PvzLevelFile levelFile, LevelDefinitionData def) {
  if (def.modules.any((m) => m.contains('PVZ1Overwhelm'))) return true;
  return findModuleObject(levelFile, 'PVZ1OverwhelmModuleProperties') != null;
}

String? findLawnMowerAlias(LevelDefinitionData def) {
  const mowerAliases = {
    'FrontLawnMowers',
    'EgyptMowers',
    'PirateMowers',
    'WestMowers',
    'KongFuMowers',
    'FutureMowers',
    'DarkMowers',
    'BeachMowers',
    'IceageMowers',
    'IceageZombossMowers',
    'LostCityMowers',
    'EightiesMowers',
    'EightiesZombossMowers',
    'DinoMowers',
    'ModernMowers',
    'SteamMowers',
    'RenaiMowers',
    'HeianMowers',
    'RomanMowers2',
    'MoonMowers',
    'FairyTaleMowers',
    'ZCorpMowers',
    'RunningSubwayMowers',
    'MausoleumMowers',
    'QinGhostMowers',
  };

  for (final m in def.modules) {
    final info = RtidParser.parse(m);
    if (info != null && mowerAliases.contains(info.alias)) {
      return info.alias;
    }
  }
  return null;
}

ZombossMechBattleModuleData? readZombossBattleData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'ZombossBattleModuleProperties');
  return obj != null
      ? ZombossMechBattleModuleData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

bool levelHasBoss(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'ZombossLastStandMinigameProperties');
}

ZombossLastStandMinigameData? readZombossLastStandData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'ZombossLastStandMinigameProperties');
  return obj != null
      ? ZombossLastStandMinigameData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

bool levelHasZomboss(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'ZombossBattleModuleProperties');
}

VaseBreakerPresetData? readVaseBreakerData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'VaseBreakerPresetProperties');
  return obj != null
      ? VaseBreakerPresetData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

VaseBreakerArcadeModuleData? readVaseBreakerArcadeData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'VaseBreakerArcadeModuleProperties');
  return obj != null
      ? VaseBreakerArcadeModuleData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

ProtectThePlantChallengePropertiesData? readProtectPlantData(
  PvzLevelFile levelFile,
) {
  final obj = findModuleObject(levelFile, 'ProtectThePlantChallengeProperties');
  return obj != null
      ? ProtectThePlantChallengePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

ProtectTheGridItemChallengePropertiesData? readProtectGridItemData(
  PvzLevelFile levelFile,
) {
  final obj = findModuleObject(
    levelFile,
    'ProtectTheGridItemChallengeProperties',
  );
  return obj != null
      ? ProtectTheGridItemChallengePropertiesData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

StarChallengeZombieDistanceData? readFlowersChallengeData(
  PvzLevelFile levelFile,
) {
  const targetClass = 'StarChallengeZombieDistanceProps';

  for (final o in levelFile.objects) {
    if (o.objClass == targetClass && o.objData is Map) {
      return StarChallengeZombieDistanceData.fromJson(
        Map<String, dynamic>.from(o.objData as Map),
      );
    }
  }

  final starObjs = levelFile.objects.where(
    (o) => o.objClass == 'StarChallengeModuleProperties',
  );

  for (final obj in starObjs) {
    final data = obj.objData;
    if (data is! Map) continue;

    final stars = data['Challenges'] as List?;
    if (stars == null) continue;

    for (final star in stars) {
      if (star is! List) continue;
      for (final challenge in star) {
        if (challenge is Map) {
          final objClass = challenge['objclass'] ?? challenge['objClass'];
          if (objClass == targetClass) {
            return StarChallengeZombieDistanceData.fromJson(
              Map<String, dynamic>.from(challenge),
            );
          }
        } else if (challenge is String) {
          // Resolve RTID
          final info = RtidParser.parse(challenge);
          if (info == null) continue;
          final alias = info.alias;

          String? objClass;
          Map<String, dynamic>? objData;

          if (info.source == 'CurrentLevel') {
            final localObj = levelFile.objects.firstWhereOrNull(
              (o) => o.aliases?.contains(alias) == true,
            );
            objClass = localObj?.objClass;
            if (localObj?.objData is Map)
              objData = Map<String, dynamic>.from(localObj!.objData as Map);
          } else {
            objClass = ReferenceRepository.instance.getObjClass(alias);
            final refObj = ReferenceRepository.instance.objectForAlias(alias);
            if (refObj?.objData is Map)
              objData = Map<String, dynamic>.from(refObj!.objData as Map);
          }

          if (objClass == targetClass && objData != null) {
            return StarChallengeZombieDistanceData.fromJson(objData);
          }
        }
      }
    }
  }

  return null;
}

VaseBreakerFlowModuleData? readVaseBreakerFlowData(PvzLevelFile levelFile) {
  final obj = findModuleObject(levelFile, 'VaseBreakerFlowModuleProperties');
  return obj != null
      ? VaseBreakerFlowModuleData.fromJson(
          Map<String, dynamic>.from(obj.objData as Map),
        )
      : null;
}

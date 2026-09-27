import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/utils/custom_icons.dart';

enum ModuleCategory { base, mode, scene, gimmick }

class ModuleMetadata {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final String? assetIconPath;
  final bool isCore;
  final ModuleCategory category;
  final String defaultAlias;
  final String defaultSource;
  final bool allowMultiple;
  final String duplicateAliasNumberSeparator;
  final dynamic Function()? initialDataFactory;
  final String? uniqueKey;
  // In Flutter, we might use a route name or a widget builder
  // For now, we'll just store the route name or ID
  final String routeId;
  final String objClass;

  const ModuleMetadata({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    this.assetIconPath,
    required this.isCore,
    required this.category,
    required this.defaultAlias,
    this.defaultSource = 'CurrentLevel',
    this.allowMultiple = false,
    this.duplicateAliasNumberSeparator = '_',
    this.initialDataFactory,
    this.uniqueKey,
    required this.routeId,
    this.objClass = '',
  });

  String get effectiveAlias => defaultAlias;
  String get selectionKey => uniqueKey ?? objClass;

  Map<String, dynamic>? get initialData {
    final obj = initialDataFactory?.call();
    if (obj == null) return null;
    if (obj is Map<String, dynamic>) return obj;
    return (obj as dynamic).toJson() as Map<String, dynamic>;
  }

  String getTitle(BuildContext context) {
    return ModuleRegistry.getTitle(context, titleKey);
  }

  String getDescription(BuildContext context) {
    return ModuleRegistry.getDescription(context, descriptionKey);
  }
}

class ModuleRegistry {
  static const String defaultMetadataKey = 'Unknown';

  static ModuleMetadata getMetadata(String objClass) {
    final meta = registry[objClass];
    if (meta != null) return meta.copyWith(objClass: objClass);
    return ModuleMetadata(
      titleKey: defaultMetadataKey,
      descriptionKey: defaultMetadataKey,
      icon: Icons.help_outline,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: objClass,
      defaultSource: 'CurrentLevel',
      routeId: 'Unknown',
      objClass: objClass,
    );
  }

  static ModuleMetadata getMetadataForAlias(String alias, String objClass) {
    if (objClass == 'TunnelDefendModuleProperties' &&
        (alias == 'SouDaCheTunnelDefendDefault' ||
            alias.startsWith('SoudacheTunnelDefendStage'))) {
      return registry['SouDaCheTunnelDefendDefault']!.copyWith(
        objClass: objClass,
      );
    }
    for (final meta in registry.values) {
      if (meta.defaultAlias == alias && meta.objClass == objClass) {
        return meta.copyWith(objClass: objClass);
      }
    }
    for (final meta in registry.values) {
      if (meta.defaultAlias == alias) {
        return meta.copyWith(objClass: objClass);
      }
    }
    return getMetadata(objClass);
  }

  static ModuleMetadata? getMetadataByAlias(String alias) {
    for (final meta in registry.values) {
      if (meta.defaultAlias == alias) {
        return meta;
      }
    }
    return null;
  }

  static List<ModuleMetadata> getAllModules() => all;

  static String getTitle(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'moduleTitle_WaveManagerModuleProperties':
        return l10n.moduleTitle_WaveManagerModuleProperties;
      case 'moduleTitle_WaveGeneratorProperties':
        return l10n.moduleTitle_WaveGeneratorProperties;
      case 'moduleTitle_CustomLevelModuleProperties':
        return l10n.moduleTitle_CustomLevelModuleProperties;
      case 'moduleTitle_StandardLevelIntroProperties':
        return l10n.moduleTitle_StandardLevelIntroProperties;
      case 'moduleTitle_ZombiesAteYourBrainsProperties':
        return l10n.moduleTitle_ZombiesAteYourBrainsProperties;
      case 'moduleTitle_ZombiesDeadWinConProperties':
        return l10n.moduleTitle_ZombiesDeadWinConProperties;
      case 'moduleTitle_BronzeDeadWinConProperties':
        return l10n.moduleTitle_BronzeDeadWinConProperties;
      case 'moduleTitle_SpermWhaleModuleProperties':
        return l10n.moduleTitle_SpermWhaleModuleProperties;
      case 'moduleTitle_PennyClassroomModuleProperties':
        return l10n.moduleTitle_PennyClassroomModuleProperties;
      case 'moduleTitle_SeedBankProperties':
        return l10n.moduleTitle_SeedBankProperties;
      case 'moduleTitle_ConveyorSeedBankProperties':
        return l10n.moduleTitle_ConveyorSeedBankProperties;
      case 'moduleTitle_SunDropperProperties':
        return l10n.moduleTitle_SunDropperProperties;
      case 'moduleTitle_MoonExpertProperties':
        return l10n.moduleTitle_MoonExpertProperties;
      case 'moduleTitle_MoonLifeSupportSystemProperties':
        return l10n.moduleTitle_MoonLifeSupportSystemProperties;
      case 'moduleTitle_LunarTerminalModuleProperties':
        return l10n.moduleTitle_LunarTerminalModuleProperties;
      case 'moduleTitle_LunarMineVeinModuleProperties':
        return l10n.moduleTitle_LunarMineVeinModuleProperties;
      case 'moduleTitle_RadiationMeteorModuleProperties':
        return l10n.moduleTitle_RadiationMeteorModuleProperties;
      case 'moduleTitle_GladiatorRowModuleProperties':
        return l10n.moduleTitle_GladiatorRowModuleProperties;
      case 'moduleTitle_LevelMutatorMaxSunProps':
        return l10n.moduleTitle_LevelMutatorMaxSunProps;
      case 'moduleTitle_LevelMutatorStartingPlantfoodProps':
        return l10n.moduleTitle_LevelMutatorStartingPlantfoodProps;
      case 'moduleTitle_LevelMutatorRiftTimedSunProps':
        return l10n.moduleTitle_LevelMutatorRiftTimedSunProps;
      case 'moduleTitle_PickupCollectableTutorialProperties':
        return l10n.moduleTitle_PickupCollectableTutorialProperties;
      case 'moduleTitle_StarChallengeModuleProperties':
        return l10n.moduleTitle_StarChallengeModuleProperties;
      case 'moduleTitle_LevelScoringModuleProperties':
        return l10n.moduleTitle_LevelScoringModuleProperties;
      case 'moduleTitle_SouDaCheDamageTextModuleProperties':
        return l10n.moduleTitle_SouDaCheDamageTextModuleProperties;
      case 'moduleTitle_BowlingMinigameProperties':
        return l10n.moduleTitle_BowlingMinigameProperties;
      case 'moduleTitle_NewBowlingMinigameProperties':
        return l10n.moduleTitle_NewBowlingMinigameProperties;
      case 'moduleTitle_VaseBreakerPresetProperties':
        return l10n.moduleTitle_VaseBreakerPresetProperties;
      case 'moduleTitle_VaseBreakerArcadeModuleProperties':
        return l10n.moduleTitle_VaseBreakerArcadeModuleProperties;
      case 'moduleTitle_VaseBreakerFlowModuleProperties':
        return l10n.moduleTitle_VaseBreakerFlowModuleProperties;
      case 'moduleTitle_EvilDaveProperties':
        return l10n.moduleTitle_EvilDaveProperties;
      case 'moduleTitle_ZombossBattleModuleProperties':
        return l10n.moduleTitle_ZombossBattleModuleProperties;
      case 'moduleTitle_ZombossBattleIntroProperties':
        return l10n.moduleTitle_ZombossBattleIntroProperties;
      case 'moduleTitle_ZombossLastStandMinigameProperties':
        return l10n.moduleTitle_ZombossLastStandMinigameProperties;
      case 'moduleTitle_SeedRainProperties':
        return l10n.moduleTitle_SeedRainProperties;
      case 'moduleTitle_LastStandMinigameProperties':
        return l10n.moduleTitle_LastStandMinigameProperties;
      case 'moduleTitle_CowboyMinigameProperties':
        return l10n.moduleTitle_CowboyMinigameProperties;
      case 'moduleTitle_SingleHandedProperties':
        return l10n.moduleTitle_SingleHandedProperties;
      case 'moduleTitle_IntroSingleHandedProperties':
        return l10n.moduleTitle_IntroSingleHandedProperties;
      case 'moduleTitle_PVZ1OverwhelmModuleProperties':
        return l10n.moduleTitle_PVZ1OverwhelmModuleProperties;
      case 'moduleTitle_SunBombChallengeProperties':
        return l10n.moduleTitle_SunBombChallengeProperties;
      case 'moduleTitle_IncreasedCostModuleProperties':
        return l10n.moduleTitle_IncreasedCostModuleProperties;
      case 'moduleTitle_DeathHoleModuleProperties':
        return l10n.moduleTitle_DeathHoleModuleProperties;
      case 'moduleTitle_ZombieMoveFastModuleProperties':
        return l10n.moduleTitle_ZombieMoveFastModuleProperties;
      case 'moduleTitle_InitialPlantProperties':
        return l10n.moduleTitle_InitialPlantProperties;
      case 'moduleTitle_InitialPlantEntryProperties':
        return l10n.moduleTitle_InitialPlantEntryProperties;
      case 'moduleTitle_InitialZombieProperties':
        return l10n.moduleTitle_InitialZombieProperties;
      case 'moduleTitle_InitialGridItemProperties':
        return l10n.moduleTitle_InitialGridItemProperties;
      case 'moduleTitle_ProtectThePlantChallengeProperties':
        return l10n.moduleTitle_ProtectThePlantChallengeProperties;
      case 'moduleTitle_ProtectTheGridItemChallengeProperties':
        return l10n.moduleTitle_ProtectTheGridItemChallengeProperties;
      case 'moduleTitle_MoldColonyChallengeProps':
        return l10n.moduleTitle_MoldColonyChallengeProps;
      case 'moduleTitle_ZombiePotionModuleProperties':
        return l10n.moduleTitle_ZombiePotionModuleProperties;
      case 'moduleTitle_PiratePlankProperties':
        return l10n.moduleTitle_PiratePlankProperties;
      case 'moduleTitle_RailcartProperties':
        return l10n.moduleTitle_RailcartProperties;
      case 'moduleTitle_MechanismPlankProperties':
        return l10n.moduleTitle_MechanismPlankProperties;
      case 'moduleTitle_PowerTileProperties':
        return l10n.moduleTitle_PowerTileProperties;
      case 'moduleTitle_ManholePipelineModuleProperties':
        return l10n.moduleTitle_ManholePipelineModuleProperties;
      case 'moduleTitle_RoofProperties':
        return l10n.moduleTitle_RoofProperties;
      case 'moduleTitle_TideProperties':
        return l10n.moduleTitle_TideProperties;
      case 'moduleTitle_BombProperties':
        return l10n.moduleTitle_BombProperties;
      case 'moduleTitle_BronzeProperties':
        return l10n.moduleTitle_BronzeProperties;
      case 'moduleTitle_ArmrackProperties':
        return l10n.moduleTitle_ArmrackProperties;
      case 'moduleTitle_EnergyGridProperties':
        return l10n.moduleTitle_EnergyGridProperties;
      case 'moduleTitle_WarMistProperties':
        return l10n.moduleTitle_WarMistProperties;
      case 'moduleTitle_RainDarkProperties':
        return l10n.moduleTitle_RainDarkProperties;
      case 'moduleTitle_LawnMowerProperties':
        return l10n.moduleTitle_LawnMowerProperties;
      case 'moduleTitle_TunnelDefendModuleProperties':
        return l10n.moduleTitle_TunnelDefendModuleProperties;
      case 'moduleTitle_SouDaCheTunnelDefendDefault':
        return l10n.moduleTitle_SouDaCheTunnelDefendDefault;
      case 'moduleTitle_ZombieRushModuleProperties':
        return l10n.moduleTitle_ZombieRushModuleProperties;
      case 'moduleTitle_RenaiModuleProperties':
        return l10n.moduleTitle_RenaiModuleProperties;
      case 'moduleTitle_SmokePollutionModuleProperties':
        return l10n.moduleTitle_SmokePollutionModuleProperties;
      case 'moduleTitle_DropShipProperties':
        return l10n.moduleTitle_DropShipProperties;
      case 'moduleTitle_GlacierModuleProperties':
        return l10n.moduleTitle_GlacierModuleProperties;
      case 'moduleTitle_HeianWindModuleProperties':
        return l10n.moduleTitle_HeianWindModuleProperties;
      case 'moduleTitle_WitchModuleProperties':
        return l10n.moduleTitle_WitchModuleProperties;
      case 'moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties':
        return l10n.moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties;
      case 'moduleTitle_RiftThemeDemoModuleProperties':
        return l10n.moduleTitle_RiftThemeDemoModuleProperties;
      case 'moduleTitle_InitialGridItemGulliverTunnelProperties':
        return l10n.moduleTitle_InitialGridItemGulliverTunnelProperties;
      case 'moduleTitle_LevelPowerupModuleProperties':
        return l10n.moduleTitle_LevelPowerupModuleProperties;
      case 'moduleTitle_RocketZombieFlickModuleProperties':
        return l10n.moduleTitle_RocketZombieFlickModuleProperties;
      case 'moduleTitle_PVZ1PassageModuleProperties':
        return l10n.moduleTitle_PVZ1PassageModuleProperties;
      case 'moduleTitle_PVZ1CopycatsModuleProperties':
        return l10n.moduleTitle_PVZ1CopycatsModuleProperties;
      case 'moduleTitle_StatueMazeModuleProperties':
        return l10n.moduleTitle_StatueMazeModuleProperties;
      case 'moduleTitle_CamelMinigameProperties':
        return l10n.moduleTitle_CamelMinigameProperties;
      case 'moduleTitle_OakTrainProperties':
        return l10n.moduleTitle_OakTrainProperties;
      case 'moduleTitle_OakTrainIntroProperties':
        return l10n.moduleTitle_OakTrainIntroProperties;
      case 'moduleTitle_PVZ1SeeingStarsModuleProperties':
        return l10n.moduleTitle_PVZ1SeeingStarsModuleProperties;
      case 'moduleTitle_GoldRoadProperties':
        return l10n.moduleTitle_GoldRoadProperties;
      default:
        return key;
    }
  }

  static String getDescription(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'moduleDesc_WaveManagerModuleProperties':
        return l10n.moduleDesc_WaveManagerModuleProperties;
      case 'moduleDesc_WaveGeneratorProperties':
        return l10n.moduleDesc_WaveGeneratorProperties;
      case 'moduleDesc_CustomLevelModuleProperties':
        return l10n.moduleDesc_CustomLevelModuleProperties;
      case 'moduleDesc_StandardLevelIntroProperties':
        return l10n.moduleDesc_StandardLevelIntroProperties;
      case 'moduleDesc_ZombiesAteYourBrainsProperties':
        return l10n.moduleDesc_ZombiesAteYourBrainsProperties;
      case 'moduleDesc_ZombiesDeadWinConProperties':
        return l10n.moduleDesc_ZombiesDeadWinConProperties;
      case 'moduleDesc_BronzeDeadWinConProperties':
        return l10n.moduleDesc_BronzeDeadWinConProperties;
      case 'moduleDesc_SpermWhaleModuleProperties':
        return l10n.moduleDesc_SpermWhaleModuleProperties;
      case 'moduleDesc_PennyClassroomModuleProperties':
        return l10n.moduleDesc_PennyClassroomModuleProperties;
      case 'moduleDesc_SeedBankProperties':
        return l10n.moduleDesc_SeedBankProperties;
      case 'moduleDesc_ConveyorSeedBankProperties':
        return l10n.moduleDesc_ConveyorSeedBankProperties;
      case 'moduleDesc_SunDropperProperties':
        return l10n.moduleDesc_SunDropperProperties;
      case 'moduleDesc_MoonExpertProperties':
        return l10n.moduleDesc_MoonExpertProperties;
      case 'moduleDesc_MoonLifeSupportSystemProperties':
        return l10n.moduleDesc_MoonLifeSupportSystemProperties;
      case 'moduleDesc_LunarTerminalModuleProperties':
        return l10n.moduleDesc_LunarTerminalModuleProperties;
      case 'moduleDesc_LunarMineVeinModuleProperties':
        return l10n.moduleDesc_LunarMineVeinModuleProperties;
      case 'moduleDesc_RadiationMeteorModuleProperties':
        return l10n.moduleDesc_RadiationMeteorModuleProperties;
      case 'moduleDesc_GladiatorRowModuleProperties':
        return l10n.moduleDesc_GladiatorRowModuleProperties;
      case 'moduleDesc_LevelMutatorMaxSunProps':
        return l10n.moduleDesc_LevelMutatorMaxSunProps;
      case 'moduleDesc_LevelMutatorStartingPlantfoodProps':
        return l10n.moduleDesc_LevelMutatorStartingPlantfoodProps;
      case 'moduleDesc_LevelMutatorRiftTimedSunProps':
        return l10n.moduleDesc_LevelMutatorRiftTimedSunProps;
      case 'moduleDesc_PickupCollectableTutorialProperties':
        return l10n.moduleDesc_PickupCollectableTutorialProperties;
      case 'moduleDesc_StarChallengeModuleProperties':
        return l10n.moduleDesc_StarChallengeModuleProperties;
      case 'moduleDesc_LevelScoringModuleProperties':
        return l10n.moduleDesc_LevelScoringModuleProperties;
      case 'moduleDesc_SouDaCheDamageTextModuleProperties':
        return l10n.moduleDesc_SouDaCheDamageTextModuleProperties;
      case 'moduleDesc_BowlingMinigameProperties':
        return l10n.moduleDesc_BowlingMinigameProperties;
      case 'moduleDesc_NewBowlingMinigameProperties':
        return l10n.moduleDesc_NewBowlingMinigameProperties;
      case 'moduleDesc_VaseBreakerPresetProperties':
        return l10n.moduleDesc_VaseBreakerPresetProperties;
      case 'moduleDesc_VaseBreakerArcadeModuleProperties':
        return l10n.moduleDesc_VaseBreakerArcadeModuleProperties;
      case 'moduleDesc_VaseBreakerFlowModuleProperties':
        return l10n.moduleDesc_VaseBreakerFlowModuleProperties;
      case 'moduleDesc_EvilDaveProperties':
        return l10n.moduleDesc_EvilDaveProperties;
      case 'moduleDesc_ZombossBattleModuleProperties':
        return l10n.moduleDesc_ZombossBattleModuleProperties;
      case 'moduleDesc_ZombossBattleIntroProperties':
        return l10n.moduleDesc_ZombossBattleIntroProperties;
      case 'moduleDesc_ZombossLastStandMinigameProperties':
        return l10n.moduleDesc_ZombossLastStandMinigameProperties;
      case 'moduleDesc_SeedRainProperties':
        return l10n.moduleDesc_SeedRainProperties;
      case 'moduleDesc_LastStandMinigameProperties':
        return l10n.moduleDesc_LastStandMinigameProperties;
      case 'moduleDesc_CowboyMinigameProperties':
        return l10n.moduleDesc_CowboyMinigameProperties;
      case 'moduleDesc_SingleHandedProperties':
        return l10n.moduleDesc_SingleHandedProperties;
      case 'moduleDesc_IntroSingleHandedProperties':
        return l10n.moduleDesc_IntroSingleHandedProperties;
      case 'moduleDesc_PVZ1OverwhelmModuleProperties':
        return l10n.moduleDesc_PVZ1OverwhelmModuleProperties;
      case 'moduleDesc_SunBombChallengeProperties':
        return l10n.moduleDesc_SunBombChallengeProperties;
      case 'moduleDesc_IncreasedCostModuleProperties':
        return l10n.moduleDesc_IncreasedCostModuleProperties;
      case 'moduleDesc_DeathHoleModuleProperties':
        return l10n.moduleDesc_DeathHoleModuleProperties;
      case 'moduleDesc_ZombieMoveFastModuleProperties':
        return l10n.moduleDesc_ZombieMoveFastModuleProperties;
      case 'moduleDesc_InitialPlantProperties':
        return l10n.moduleDesc_InitialPlantProperties;
      case 'moduleDesc_InitialPlantEntryProperties':
        return l10n.moduleDesc_InitialPlantEntryProperties;
      case 'moduleDesc_InitialZombieProperties':
        return l10n.moduleDesc_InitialZombieProperties;
      case 'moduleDesc_InitialGridItemProperties':
        return l10n.moduleDesc_InitialGridItemProperties;
      case 'moduleDesc_ProtectThePlantChallengeProperties':
        return l10n.moduleDesc_ProtectThePlantChallengeProperties;
      case 'moduleDesc_ProtectTheGridItemChallengeProperties':
        return l10n.moduleDesc_ProtectTheGridItemChallengeProperties;
      case 'moduleDesc_MoldColonyChallengeProps':
        return l10n.moduleDesc_MoldColonyChallengeProps;
      case 'moduleDesc_ZombiePotionModuleProperties':
        return l10n.moduleDesc_ZombiePotionModuleProperties;
      case 'moduleDesc_PiratePlankProperties':
        return l10n.moduleDesc_PiratePlankProperties;
      case 'moduleDesc_RailcartProperties':
        return l10n.moduleDesc_RailcartProperties;
      case 'moduleDesc_MechanismPlankProperties':
        return l10n.moduleDesc_MechanismPlankProperties;
      case 'moduleDesc_PowerTileProperties':
        return l10n.moduleDesc_PowerTileProperties;
      case 'moduleDesc_ManholePipelineModuleProperties':
        return l10n.moduleDesc_ManholePipelineModuleProperties;
      case 'moduleDesc_RoofProperties':
        return l10n.moduleDesc_RoofProperties;
      case 'moduleDesc_TideProperties':
        return l10n.moduleDesc_TideProperties;
      case 'moduleDesc_BombProperties':
        return l10n.moduleDesc_BombProperties;
      case 'moduleDesc_BronzeProperties':
        return l10n.moduleDesc_BronzeProperties;
      case 'moduleDesc_ArmrackProperties':
        return l10n.moduleDesc_ArmrackProperties;
      case 'moduleDesc_EnergyGridProperties':
        return l10n.moduleDesc_EnergyGridProperties;
      case 'moduleDesc_WarMistProperties':
        return l10n.moduleDesc_WarMistProperties;
      case 'moduleDesc_RainDarkProperties':
        return l10n.moduleDesc_RainDarkProperties;
      case 'moduleDesc_LawnMowerProperties':
        return l10n.moduleDesc_LawnMowerProperties;
      case 'moduleDesc_TunnelDefendModuleProperties':
        return l10n.moduleDesc_TunnelDefendModuleProperties;
      case 'moduleDesc_SouDaCheTunnelDefendDefault':
        return l10n.moduleDesc_SouDaCheTunnelDefendDefault;
      case 'moduleDesc_ZombieRushModuleProperties':
        return l10n.moduleDesc_ZombieRushModuleProperties;
      case 'moduleDesc_RenaiModuleProperties':
        return l10n.moduleDesc_RenaiModuleProperties;
      case 'moduleDesc_SmokePollutionModuleProperties':
        return l10n.moduleDesc_SmokePollutionModuleProperties;
      case 'moduleDesc_DropShipProperties':
        return l10n.moduleDesc_DropShipProperties;
      case 'moduleDesc_GlacierModuleProperties':
        return l10n.moduleDesc_GlacierModuleProperties;
      case 'moduleDesc_HeianWindModuleProperties':
        return l10n.moduleDesc_HeianWindModuleProperties;
      case 'moduleDesc_WitchModuleProperties':
        return l10n.moduleDesc_WitchModuleProperties;
      case 'moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties':
        return l10n.moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties;
      case 'moduleDesc_RiftThemeDemoModuleProperties':
        return l10n.moduleDesc_RiftThemeDemoModuleProperties;
      case 'moduleDesc_InitialGridItemGulliverTunnelProperties':
        return l10n.moduleDesc_InitialGridItemGulliverTunnelProperties;
      case 'moduleDesc_LevelPowerupModuleProperties':
        return l10n.moduleDesc_LevelPowerupModuleProperties;
      case 'moduleDesc_RocketZombieFlickModuleProperties':
        return l10n.moduleDesc_RocketZombieFlickModuleProperties;
      case 'moduleDesc_PVZ1PassageModuleProperties':
        return l10n.moduleDesc_PVZ1PassageModuleProperties;
      case 'moduleDesc_PVZ1CopycatsModuleProperties':
        return l10n.moduleDesc_PVZ1CopycatsModuleProperties;
      case 'moduleDesc_PVZ1SeeingStarsModuleProperties':
        return l10n.moduleDesc_PVZ1SeeingStarsModuleProperties;
      case 'moduleDesc_StatueMazeModuleProperties':
        return l10n.moduleDesc_StatueMazeModuleProperties;
      case 'moduleDesc_CamelMinigameProperties':
        return l10n.moduleDesc_CamelMinigameProperties;
      case 'moduleDesc_OakTrainProperties':
        return l10n.moduleDesc_OakTrainProperties;
      case 'moduleDesc_OakTrainIntroProperties':
        return l10n.moduleDesc_OakTrainIntroProperties;
      case 'moduleDesc_GoldRoadProperties':
        return l10n.moduleDesc_GoldRoadProperties;
      default:
        return key;
    }
  }

  static final Map<String, ModuleMetadata> registry = {
    'WaveManagerModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_WaveManagerModuleProperties',
      descriptionKey: 'moduleDesc_WaveManagerModuleProperties',
      icon: Icons.timeline,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'NewWaves',
      initialDataFactory: () => WaveManagerModuleData(
        waveManagerProps: 'RTID(WaveManagerProps@CurrentLevel)',
        dynamicZombies: [
          DynamicZombieGroup(
            pointIncrement: 0,
            startingPoints: 0,
            startingWave: 0,
            zombiePool: [],
            zombieLevel: [],
          ),
        ],
      ),
      routeId: 'WaveManagerModule',
    ),
    'WaveGeneratorProperties': ModuleMetadata(
      titleKey: 'moduleTitle_WaveGeneratorProperties',
      descriptionKey: 'moduleDesc_WaveGeneratorProperties',
      icon: Icons.waves,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'WaveGenerator',
      initialDataFactory: () => WaveGeneratorPropertiesData(
        waveSpendingPoints: 100,
        waveSpendingPointIncrement: 100,
        waves: [WaveGeneratorWaveData()],
      ),
      routeId: 'WaveGenerator',
    ),
    'CustomLevelModuleProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_CustomLevelModuleProperties',
      descriptionKey: 'moduleDesc_CustomLevelModuleProperties',
      icon: Icons.home,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'DefaultCustomLevel',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
    'StandardLevelIntroProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_StandardLevelIntroProperties',
      descriptionKey: 'moduleDesc_StandardLevelIntroProperties',
      icon: Icons.movie_filter,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'StandardIntro',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
    'ZombiesAteYourBrainsProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_ZombiesAteYourBrainsProperties',
      descriptionKey: 'moduleDesc_ZombiesAteYourBrainsProperties',
      icon: Icons.dangerous,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'DefaultZombieWinCondition',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
    'ZombiesDeadWinConProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_ZombiesDeadWinConProperties',
      descriptionKey: 'moduleDesc_ZombiesDeadWinConProperties',
      icon: Icons.redeem,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'ZombiesDeadWinCon',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
    'BronzeDeadWinConProperties': ModuleMetadata(
      titleKey: 'moduleTitle_BronzeDeadWinConProperties',
      descriptionKey: 'moduleDesc_BronzeDeadWinConProperties',
      icon: Icons.fitness_center,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'BronzeDeadWinCon',
      defaultSource: 'LevelModules',
      initialDataFactory: () => <String, dynamic>{},
      routeId: 'UnknownDetail',
    ),
    'SeedBankProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SeedBankProperties',
      descriptionKey: 'moduleDesc_SeedBankProperties',
      icon: Icons.yard,
      isCore: true,
      allowMultiple: true,
      category: ModuleCategory.base,
      defaultAlias: 'SeedBank',
      initialDataFactory: () => SeedBankData(),
      routeId: 'SeedBank',
    ),
    'ConveyorSeedBankProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ConveyorSeedBankProperties',
      descriptionKey: 'moduleDesc_ConveyorSeedBankProperties',
      icon: Icons.linear_scale,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'ConveyorBelt',
      initialDataFactory: () => ConveyorBeltData(),
      routeId: 'ConveyorBelt',
    ),
    'PennyClassroomModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PennyClassroomModuleProperties',
      descriptionKey: 'moduleDesc_PennyClassroomModuleProperties',
      icon: Icons.layers,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'PennyClassroom',
      initialDataFactory: () => PennyClassroomModuleData(),
      routeId: 'PennyClassroomModule',
    ),
    'SunDropperProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_SunDropperProperties',
      descriptionKey: 'moduleDesc_SunDropperProperties',
      icon: Icons.wb_sunny,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'DefaultSunDropper',
      defaultSource: 'LevelModules',
      routeId: 'SunDropper',
    ),
    'LevelMutatorMaxSunProps': ModuleMetadata(
      titleKey: 'moduleTitle_LevelMutatorMaxSunProps',
      descriptionKey: 'moduleDesc_LevelMutatorMaxSunProps',
      icon: Icons.brightness_high,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'OverrideMaxSun',
      initialDataFactory: () => LevelMutatorMaxSunPropsData(),
      routeId: 'MaxSunModule',
    ),
    'LevelMutatorStartingPlantfoodProps': ModuleMetadata(
      titleKey: 'moduleTitle_LevelMutatorStartingPlantfoodProps',
      descriptionKey: 'moduleDesc_LevelMutatorStartingPlantfoodProps',
      icon: Icons.eco,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'OverrideStartingPlantFood',
      initialDataFactory: () => LevelMutatorStartingPlantfoodPropsData(),
      routeId: 'StartingPlantfoodModule',
    ),
    'StarChallengeModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_StarChallengeModuleProperties',
      descriptionKey: 'moduleDesc_StarChallengeModuleProperties',
      icon: Icons.fact_check,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'ChallengeModule',
      initialDataFactory: () => StarChallengeModuleData(),
      routeId: 'StarChallenge',
    ),
    'LevelScoringModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_LevelScoringModuleProperties',
      descriptionKey: 'moduleDesc_LevelScoringModuleProperties',
      icon: Icons.scoreboard,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'LevelScoring',
      initialDataFactory: () => LevelScoringData(),
      routeId: 'UnknownDetail',
    ),
    'SouDaCheDamageTextModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SouDaCheDamageTextModuleProperties',
      descriptionKey: 'moduleDesc_SouDaCheDamageTextModuleProperties',
      icon: Icons.numbers,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'SouDaCheDamageTextModule',
      initialDataFactory: () => <String, dynamic>{},
      routeId: 'UnknownDetail',
    ),
    'LawnMowerProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_LawnMowerProperties',
      descriptionKey: 'moduleDesc_LawnMowerProperties',
      icon: Icons.cleaning_services,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'FrontLawnMowers',
      defaultSource: 'LevelModules',
      routeId: 'LawnMower',
    ),
    'MoonExpertProperties': ModuleMetadata(
      titleKey: 'moduleTitle_MoonExpertProperties',
      descriptionKey: 'moduleDesc_MoonExpertProperties',
      icon: Icons.nightlight_round,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'MoonExpertProps',
      initialDataFactory: () => MoonExpertPropertiesData(),
      routeId: 'MoonExpertModule',
    ),
    'CamelMinigameProperties': ModuleMetadata(
      titleKey: 'moduleTitle_CamelMinigameProperties',
      descriptionKey: 'moduleDesc_CamelMinigameProperties',
      icon: CustomIcons.camel,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.mode,
      defaultAlias: 'CamelMinigame',
      initialDataFactory: () => CamelMinigamePropertiesData(),
      routeId: 'CamelMinigame',
    ),
    'LastStandMinigameProperties': ModuleMetadata(
      titleKey: 'moduleTitle_LastStandMinigameProperties',
      descriptionKey: 'moduleDesc_LastStandMinigameProperties',
      icon: Icons.shield,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'LastStand',
      initialDataFactory: () => LastStandMinigamePropertiesData(),
      routeId: 'LastStandMinigame',
    ),
    'CowboyMinigameProperties': ModuleMetadata(
      titleKey: 'moduleTitle_CowboyMinigameProperties',
      descriptionKey: 'moduleDesc_CowboyMinigameProperties',
      icon: Icons.fence,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'CowboyMinigame',
      initialDataFactory: () => CowboyMinigamePropertiesData(),
      routeId: 'CowboyMinigame',
    ),
    'BombProperties': ModuleMetadata(
      titleKey: 'moduleTitle_BombProperties',
      descriptionKey: 'moduleDesc_BombProperties',
      icon: Icons.local_fire_department,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.mode,
      defaultAlias: 'Bombs',
      initialDataFactory: () => BombPropertiesData(),
      routeId: 'Bombs',
    ),
    'ZombossBattleModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombossBattleModuleProperties',
      descriptionKey: 'moduleDesc_ZombossBattleModuleProperties',
      icon: Icons.smart_toy_outlined,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'ZombossBattle',
      allowMultiple: true,
      duplicateAliasNumberSeparator: '',
      initialDataFactory: () => ZombossMechBattleModuleData(),
      routeId: 'ZombossMechBattle',
    ),
    'ZombossBattleIntroProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombossBattleIntroProperties',
      descriptionKey: 'moduleDesc_ZombossBattleIntroProperties',
      icon: Icons.movie_filter,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'ZombossBattleIntro',
      initialDataFactory: () => ZombossMechBattleIntroData(),
      routeId: 'UnknownDetail',
    ),
    'ZombossLastStandMinigameProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombossLastStandMinigameProperties',
      descriptionKey: 'moduleDesc_ZombossLastStandMinigameProperties',
      icon: Icons.castle,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'ZombossLastStand',
      allowMultiple: true,
      duplicateAliasNumberSeparator: '',
      initialDataFactory: () => ZombossLastStandMinigameData(),
      routeId: 'ZombossBattle',
    ),
    'SunBombChallengeProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SunBombChallengeProperties',
      descriptionKey: 'moduleDesc_SunBombChallengeProperties',
      icon: Icons.brightness_high,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'SunBombs',
      initialDataFactory: () => SunBombChallengeData(),
      routeId: 'SunBombChallenge',
    ),
    'SingleHandedProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SingleHandedProperties',
      descriptionKey: 'moduleDesc_SingleHandedProperties',
      icon: Icons.sledding,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'SingleHanded',
      initialDataFactory: () => SingleHandedPropertiesData(),
      routeId: 'SingleHanded',
    ),
    'IntroSingleHandedProperties': ModuleMetadata(
      titleKey: 'moduleTitle_IntroSingleHandedProperties',
      descriptionKey: 'moduleDesc_IntroSingleHandedProperties',
      icon: Icons.sledding,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'SingleHandedTutorial',
      initialDataFactory: () => IntroSingleHandedPropertiesData(),
      routeId: 'SingleHandedTutorial',
    ),
    'EvilDaveProperties': ModuleMetadata(
      titleKey: 'moduleTitle_EvilDaveProperties',
      descriptionKey: 'moduleDesc_EvilDaveProperties',
      icon: Icons.emoji_people,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'EvilDave',
      initialDataFactory: () => EvilDavePropertiesData(),
      routeId: 'UnknownDetail',
    ),
    'OakTrainProperties': ModuleMetadata(
      titleKey: 'moduleTitle_OakTrainProperties',
      descriptionKey: 'moduleDesc_OakTrainProperties',
      icon: Icons.gps_fixed,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.mode,
      defaultAlias: 'OakTrain',
      initialDataFactory: () => OakTrainPropertiesData(),
      routeId: 'OakTrain',
    ),
    'OakTrainIntroProperties': ModuleMetadata(
      titleKey: 'moduleTitle_OakTrainIntroProperties',
      descriptionKey: 'moduleDesc_OakTrainIntroProperties',
      icon: Icons.gps_fixed,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'OakTrainTutorial',
      defaultSource: 'CurrentLevel',
      initialDataFactory: () => <String, dynamic>{},
      routeId: 'UnknownDetail',
      objClass: 'OakTrainIntroProperties',
    ),
    'BowlingMinigameProperties': ModuleMetadata(
      titleKey: 'moduleTitle_BowlingMinigameProperties',
      descriptionKey: 'moduleDesc_BowlingMinigameProperties',
      icon: Icons.sports_esports,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'BowlingBulbMinigame',
      initialDataFactory: () => BowlingMinigamePropertiesData(),
      routeId: 'BowlingMinigameModule',
    ),
    'NewBowlingMinigameProperties': ModuleMetadata(
      titleKey: 'moduleTitle_NewBowlingMinigameProperties',
      descriptionKey: 'moduleDesc_NewBowlingMinigameProperties',
      icon: Icons.sports_esports,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'NewBowlingBulbMinigame',
      initialDataFactory: () => NewBowlingMinigamePropertiesData(),
      routeId: 'UnknownDetail',
    ),
    'VaseBreakerPresetProperties': ModuleMetadata(
      titleKey: 'moduleTitle_VaseBreakerPresetProperties',
      descriptionKey: 'moduleDesc_VaseBreakerPresetProperties',
      icon: Icons.grid_4x4,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'VaseBreakerProps',
      initialDataFactory: () => VaseBreakerPresetData(),
      routeId: 'UnknownDetail',
    ),
    'VaseBreakerArcadeModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_VaseBreakerArcadeModuleProperties',
      descriptionKey: 'moduleDesc_VaseBreakerArcadeModuleProperties',
      icon: Icons.sports_esports,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'VaseBreakerArcade',
      defaultSource: 'LevelModules',
      initialDataFactory: () => VaseBreakerArcadeModuleData(),
      routeId: 'UnknownDetail',
    ),
    'VaseBreakerFlowModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_VaseBreakerFlowModuleProperties',
      descriptionKey: 'moduleDesc_VaseBreakerFlowModuleProperties',
      icon: Icons.next_plan,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'VaseBreakerFlow',
      defaultSource: 'LevelModules',
      initialDataFactory: () => VaseBreakerFlowModuleData(),
      routeId: 'UnknownDetail',
    ),
    'GoldRoadProperties': ModuleMetadata(
      titleKey: 'moduleTitle_GoldRoadProperties',
      descriptionKey: 'moduleDesc_GoldRoadProperties',
      icon: Icons.route,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'DefaultGoldRoad',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
      objClass: 'GoldRoadProperties',
    ),
    'StatueMazeModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_StatueMazeModuleProperties',
      descriptionKey: 'moduleDesc_StatueMazeModuleProperties',
      icon: Icons.account_balance,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.mode,
      defaultAlias: 'StatueMazeModule',
      initialDataFactory: () => StatueMazeModulePropertiesData.createDefault(),
      routeId: 'StatueMazeModule',
    ),
    'SeedRainProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SeedRainProperties',
      descriptionKey: 'moduleDesc_SeedRainProperties',
      icon: Icons.thunderstorm,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'SeedRain',
      initialDataFactory: () => SeedRainPropertiesData(),
      routeId: 'SeedRainModule',
    ),
    'LevelMutatorRiftTimedSunProps': ModuleMetadata(
      titleKey: 'moduleTitle_LevelMutatorRiftTimedSunProps',
      descriptionKey: 'moduleDesc_LevelMutatorRiftTimedSunProps',
      icon: Icons.wb_sunny_outlined,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'ZombieSunDrop',
      initialDataFactory: () => RiftTimedSunModuleData(),
      routeId: 'ZombieSunDropModule',
    ),
    'PVZ1OverwhelmModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PVZ1OverwhelmModuleProperties',
      descriptionKey: 'moduleDesc_PVZ1OverwhelmModuleProperties',
      icon: Icons.local_florist,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'PVZ1Overwhelm',
      initialDataFactory: () => PVZ1OverwhelmModulePropertiesData(),
      routeId: 'UnknownDetail',
    ),
    'PVZ1CopycatsModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PVZ1CopycatsModuleProperties',
      descriptionKey: 'moduleDesc_PVZ1CopycatsModuleProperties',
      icon: Icons.auto_awesome,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.mode,
      defaultAlias: 'PVZ1CopycatsModule',
      initialDataFactory: () => PVZ1CopycatsModulePropertiesData(),
      routeId: 'PVZ1CopycatsModule',
    ),
    'PVZ1SeeingStarsModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PVZ1SeeingStarsModuleProperties',
      descriptionKey: 'moduleDesc_PVZ1SeeingStarsModuleProperties',
      icon: Icons.star_outline,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.mode,
      defaultAlias: 'PVZ1SeeingStars',
      initialDataFactory: () => PVZ1SeeingStarsModulePropertiesData(),
      routeId: 'PVZ1SeeingStarsModule',
    ),
    'IncreasedCostModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_IncreasedCostModuleProperties',
      descriptionKey: 'moduleDesc_IncreasedCostModuleProperties',
      icon: Icons.trending_up,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'IncreasedCostModule',
      initialDataFactory: () => IncreasedCostModulePropertiesData(),
      routeId: 'IncreasedCostModule',
    ),
    'DeathHoleModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_DeathHoleModuleProperties',
      descriptionKey: 'moduleDesc_DeathHoleModuleProperties',
      icon: Icons.trip_origin,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'DeathHoleModule',
      initialDataFactory: () => DeathHoleModuleData(),
      routeId: 'DeathHoleModule',
    ),
    'PVZ1PassageModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PVZ1PassageModuleProperties',
      descriptionKey: 'moduleDesc_PVZ1PassageModuleProperties',
      icon: Icons.swap_horiz,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.mode,
      defaultAlias: 'PassageModule',
      initialDataFactory: () => PVZ1PassageModulePropertiesData(),
      routeId: 'PVZ1PassageModule',
    ),
    'PickupCollectableTutorialProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PickupCollectableTutorialProperties',
      descriptionKey: 'moduleDesc_PickupCollectableTutorialProperties',
      icon: Icons.school,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'PickupCollectableTutorial',
      initialDataFactory: () => PickupCollectableTutorialData(),
      routeId: 'PickupCollectableTutorial',
    ),
    'ZombieMoveFastModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombieMoveFastModuleProperties',
      descriptionKey: 'moduleDesc_ZombieMoveFastModuleProperties',
      icon: Icons.fast_forward,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'FastSpeed',
      initialDataFactory: () => ZombieMoveFastModulePropertiesData(),
      routeId: 'ZombieMoveFastModule',
    ),
    'ZombieRushModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombieRushModuleProperties',
      descriptionKey: 'moduleDesc_ZombieRushModuleProperties',
      icon: Icons.timer,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'ZombieRushModule',
      initialDataFactory: () => ZombieRushModuleData(),
      routeId: 'ZombieRushModule',
    ),
    'RiftThemeDemoModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_RiftThemeDemoModuleProperties',
      descriptionKey: 'moduleDesc_RiftThemeDemoModuleProperties',
      icon: Icons.theater_comedy,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'RiftTheme',
      initialDataFactory: () => RiftThemeDemoModulePropertiesData(),
      routeId: 'RiftThemeModule',
    ),
    'InitialPlantProperties': ModuleMetadata(
      titleKey: 'moduleTitle_InitialPlantProperties',
      descriptionKey: 'moduleDesc_InitialPlantProperties',
      icon: Icons.ac_unit,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'FrozenPlantPlacement',
      initialDataFactory: () => InitialPlantPropertiesData(),
      routeId: 'InitialPlantProperties',
    ),
    'InitialPlantEntryProperties': ModuleMetadata(
      titleKey: 'moduleTitle_InitialPlantEntryProperties',
      descriptionKey: 'moduleDesc_InitialPlantEntryProperties',
      icon: Icons.widgets,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'InitialPlants',
      initialDataFactory: () => InitialPlantEntryData(),
      routeId: 'InitialPlantEntry',
    ),
    'InitialZombieProperties': ModuleMetadata(
      titleKey: 'moduleTitle_InitialZombieProperties',
      descriptionKey: 'moduleDesc_InitialZombieProperties',
      icon: Icons.widgets,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'FrozenZombiePlacement',
      initialDataFactory: () => InitialZombieEntryData(),
      routeId: 'InitialZombieEntry',
    ),
    'InitialGridItemProperties': ModuleMetadata(
      titleKey: 'moduleTitle_InitialGridItemProperties',
      descriptionKey: 'moduleDesc_InitialGridItemProperties',
      icon: Icons.widgets,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'GridItemPlacement',
      initialDataFactory: () => InitialGridItemEntryData(),
      routeId: 'InitialGridItemEntry',
    ),
    'ProtectThePlantChallengeProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ProtectThePlantChallengeProperties',
      descriptionKey: 'moduleDesc_ProtectThePlantChallengeProperties',
      icon: Icons.security,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'ProtectThePlant',
      initialDataFactory: () => ProtectThePlantChallengePropertiesData(),
      routeId: 'ProtectThePlant',
    ),
    'ProtectTheGridItemChallengeProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ProtectTheGridItemChallengeProperties',
      descriptionKey: 'moduleDesc_ProtectTheGridItemChallengeProperties',
      icon: Icons.security,
      isCore: true,
      allowMultiple: true,
      category: ModuleCategory.scene,
      defaultAlias: 'ProtectTheGridItem',
      duplicateAliasNumberSeparator: '',
      initialDataFactory: () => ProtectTheGridItemChallengePropertiesData(),
      routeId: 'ProtectTheGridItem',
    ),
    'MoldColonyChallengeProps': ModuleMetadata(
      titleKey: 'moduleTitle_MoldColonyChallengeProps',
      descriptionKey: 'moduleDesc_MoldColonyChallengeProps',
      icon: Icons.grid_3x3,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'DoNotPlantBeforeLine',
      initialDataFactory: () => MoldColonyChallengePropsData(),
      routeId: 'MoldColony',
    ),
    'PiratePlankProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PiratePlankProperties',
      descriptionKey: 'moduleDesc_PiratePlankProperties',
      icon: Icons.edit_road,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'PiratePlanks',
      initialDataFactory: () => PiratePlankPropertiesData(),
      routeId: 'PiratePlank',
    ),
    'RailcartProperties': ModuleMetadata(
      titleKey: 'moduleTitle_RailcartProperties',
      descriptionKey: 'moduleDesc_RailcartProperties',
      icon: Icons.edit_road,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'Railcarts',
      initialDataFactory: () => RailcartPropertiesData(),
      routeId: 'Railcart',
    ),
    'MechanismPlankProperties': ModuleMetadata(
      titleKey: 'moduleTitle_MechanismPlankProperties',
      descriptionKey: 'moduleDesc_MechanismPlankProperties',
      icon: Icons.edit_road,
      isCore: true,
      allowMultiple: true,
      category: ModuleCategory.scene,
      defaultAlias: 'MechanismPlank',
      duplicateAliasNumberSeparator: '',
      initialDataFactory: () => {
        'MechanismGearsRect': {'mHeight': 5, 'mWidth': 4, 'mX': 0, 'mY': 0},
        'MechanismPlankRows': ['0', '4'],
      },
      routeId: 'MechanismPlank',
    ),
    'ArmrackProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ArmrackProperties',
      descriptionKey: 'moduleDesc_ArmrackProperties',
      icon: Icons.sports_martial_arts,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'Armrack',
      initialDataFactory: () => ArmrackPropertiesData(),
      routeId: 'Armrack',
    ),
    'EnergyGridProperties': ModuleMetadata(
      titleKey: 'moduleTitle_EnergyGridProperties',
      descriptionKey: 'moduleDesc_EnergyGridProperties',
      icon: Icons.grid_on,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'EnergyGrid',
      initialDataFactory: () => EnergyGridPropertiesData(),
      routeId: 'EnergyGrid',
    ),
    'BronzeProperties': ModuleMetadata(
      titleKey: 'moduleTitle_BronzeProperties',
      descriptionKey: 'moduleDesc_BronzeProperties',
      icon: Icons.fitness_center,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'Bronze',
      initialDataFactory: () => BronzePropertiesData(),
      routeId: 'Bronze',
    ),
    'PowerTileProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PowerTileProperties',
      descriptionKey: 'moduleDesc_PowerTileProperties',
      icon: Icons.bolt,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'FutureLinkedTileGroups',
      initialDataFactory: () => PowerTilePropertiesData(),
      routeId: 'PowerTile',
    ),
    'ZombiePotionModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombiePotionModuleProperties',
      descriptionKey: 'moduleDesc_ZombiePotionModuleProperties',
      icon: Icons.science,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'ZombiePotions',
      initialDataFactory: () => ZombiePotionModulePropertiesData(),
      routeId: 'ZombiePotionModuleProperties',
    ),
    'WarMistProperties': ModuleMetadata(
      titleKey: 'moduleTitle_WarMistProperties',
      descriptionKey: 'moduleDesc_WarMistProperties',
      icon: Icons.cloud,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'WarMist',
      initialDataFactory: () => WarMistPropertiesData(),
      routeId: 'WarMistProperties',
    ),
    'TideProperties': ModuleMetadata(
      titleKey: 'moduleTitle_TideProperties',
      descriptionKey: 'moduleDesc_TideProperties',
      icon: Icons.water_drop,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'Tide',
      initialDataFactory: () => TidePropertiesData(),
      routeId: 'Tide',
    ),
    'RainDarkProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_RainDarkProperties',
      descriptionKey: 'moduleDesc_RainDarkProperties',
      icon: Icons.ac_unit,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'DefaultSnow',
      defaultSource: 'LevelModules',
      routeId: 'RainDarkProperties',
    ),
    'SmokePollutionModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SmokePollutionModuleProperties',
      descriptionKey: 'moduleDesc_SmokePollutionModuleProperties',
      icon: Icons.cloud,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'SmokePollution',
      initialDataFactory: () => SmokePollutionModulePropertiesData(),
      routeId: 'SmokePollutionModule',
    ),
    'ManholePipelineModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ManholePipelineModuleProperties',
      descriptionKey: 'moduleDesc_ManholePipelineModuleProperties',
      icon: Icons.timeline,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'ManholePipeline',
      initialDataFactory: () => ManholePipelineModuleData(),
      routeId: 'ManholePipelineModule',
    ),
    'RenaiModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_RenaiModuleProperties',
      descriptionKey: 'moduleDesc_RenaiModuleProperties',
      icon: Icons.architecture,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'RenaiModule',
      initialDataFactory: () => RenaiModulePropertiesData(),
      routeId: 'RenaiModule',
    ),
    'LunarMineVeinModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_LunarMineVeinModuleProperties',
      descriptionKey: 'moduleDesc_LunarMineVeinModuleProperties',
      icon: Icons.diamond_outlined,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'ExampleLunarMineVeins',
      initialDataFactory: () => LunarMineVeinModulePropertiesData(),
      routeId: 'LunarMineVeinModule',
    ),
    'RoofProperties': ModuleMetadata(
      titleKey: 'moduleTitle_RoofProperties',
      descriptionKey: 'moduleDesc_RoofProperties',
      icon: Icons.local_florist,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'RoofProps',
      initialDataFactory: () => RoofPropertiesData(),
      routeId: 'RoofProperties',
    ),
    'TunnelDefendModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_TunnelDefendModuleProperties',
      descriptionKey: 'moduleDesc_TunnelDefendModuleProperties',
      icon: Icons.landscape,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'TunnelDefend',
      initialDataFactory: () => TunnelDefendModuleData(reportError: true),
      routeId: 'TunnelDefendModule',
    ),
    'SouDaCheTunnelDefendDefault': ModuleMetadata(
      titleKey: 'moduleTitle_SouDaCheTunnelDefendDefault',
      descriptionKey: 'moduleDesc_SouDaCheTunnelDefendDefault',
      icon: Icons.grid_view,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'SouDaCheTunnelDefendDefault',
      uniqueKey: 'SouDaCheTunnelDefendDefault',
      objClass: 'TunnelDefendModuleProperties',
      initialDataFactory: () => TunnelDefendModuleData(
        brickMapIndex: 3,
        reportError: false,
      ).toJson(includeTunnelSequenceInterval: false),
      routeId: 'TunnelDefendModule',
    ),
    'InitialGridItemGulliverTunnelProperties': ModuleMetadata(
      titleKey: 'moduleTitle_InitialGridItemGulliverTunnelProperties',
      descriptionKey: 'moduleDesc_InitialGridItemGulliverTunnelProperties',
      icon: Icons.circle_outlined,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'TunnelPlacement',
      initialDataFactory: () => InitialGridItemGulliverTunnelPropertiesData(),
      routeId: 'GulliverTunnelModule',
    ),
    'LevelPowerupModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_LevelPowerupModuleProperties',
      descriptionKey: 'moduleDesc_LevelPowerupModuleProperties',
      icon: Icons.touch_app,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'LevelPowerups',
      initialDataFactory: () => LevelPowerupModulePropertiesData(),
      routeId: 'LevelPowerups',
    ),
    'RocketZombieFlickModuleProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_RocketZombieFlickModuleProperties',
      descriptionKey: 'moduleDesc_RocketZombieFlickModuleProperties',
      icon: Icons.swipe_vertical,
      isCore: false,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'RocketZombieFlick',
      routeId: 'UnknownDetail',
    ),
    'DropShipProperties': ModuleMetadata(
      titleKey: 'moduleTitle_DropShipProperties',
      descriptionKey: 'moduleDesc_DropShipProperties',
      icon: Icons.flight_land,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'DropShip',
      initialDataFactory: () => DropShipPropertiesData(),
      routeId: 'DropShip',
    ),
    'HeianWindModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_HeianWindModuleProperties',
      descriptionKey: 'moduleDesc_HeianWindModuleProperties',
      icon: Icons.air,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'HeianWindModule',
      initialDataFactory: () => HeianWindModulePropertiesData(),
      routeId: 'HeianWindModule',
    ),
    'SpermWhaleModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SpermWhaleModuleProperties',
      descriptionKey: 'moduleDesc_SpermWhaleModuleProperties',
      icon: Icons.water,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'SpermWhaleModule',
      initialDataFactory: () => SpermWhaleModulePropertiesData(),
      routeId: 'SpermWhaleModule',
    ),
    'MoonLifeSupportSystemProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_MoonLifeSupportSystemProperties',
      descriptionKey: 'moduleDesc_MoonLifeSupportSystemProperties',
      icon: Icons.battery_charging_full,
      isCore: true,
      category: ModuleCategory.gimmick,
      defaultAlias: 'MoonLifeSupportSystemModule',
      defaultSource: 'LevelModules',
      routeId: 'MoonLifeSupportSystem',
    ),
    'LunarTerminalModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_LunarTerminalModuleProperties',
      descriptionKey: 'moduleDesc_LunarTerminalModuleProperties',
      icon: Icons.precision_manufacturing,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'LunarTerminalModule',
      initialDataFactory: () => LunarTerminalModulePropertiesData(),
      routeId: 'LunarTerminalModule',
    ),
    'RadiationMeteorModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_RadiationMeteorModuleProperties',
      descriptionKey: 'moduleDesc_RadiationMeteorModuleProperties',
      icon: Icons.crisis_alert_rounded,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'RadiationMeteorModule',
      initialDataFactory: () => RadiationMeteorModulePropertiesData(),
      routeId: 'RadiationMeteorModule',
    ),
    'GladiatorRowModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_GladiatorRowModuleProperties',
      descriptionKey: 'moduleDesc_GladiatorRowModuleProperties',
      icon: Icons.emoji_events,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'GladiatorRowModule',
      initialDataFactory: () => GladiatorRowModulePropertiesData(),
      routeId: 'GladiatorRowModule',
    ),
    'WitchModuleProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_WitchModuleProperties',
      descriptionKey: 'moduleDesc_WitchModuleProperties',
      icon: Icons.auto_fix_high,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'WitchModule',
      defaultSource: 'LevelModules',
      routeId: 'WitchModule',
    ),
    'GlacierModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_GlacierModuleProperties',
      descriptionKey: 'moduleDesc_GlacierModuleProperties',
      icon: Icons.ac_unit,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'GlacierModule',
      initialDataFactory: () => GlacierModulePropertiesData.createDefault(),
      routeId: 'GlacierModule',
    ),
    'ZombossFinalStageTimeLimitedChallengeProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties',
      descriptionKey:
          'moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties',
      icon: Icons.timer,
      isCore: false,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'FinalStageTimeLimitedChallenge',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
  };

  static List<ModuleMetadata> get all {
    return registry.entries
        .map(
          (e) => e.value.copyWith(
            objClass: e.value.objClass.isEmpty ? e.key : e.value.objClass,
          ),
        )
        .toList();
  }
}

extension ModuleMetadataCopyWith on ModuleMetadata {
  ModuleMetadata copyWith({
    String? titleKey,
    String? descriptionKey,
    IconData? icon,
    String? assetIconPath,
    bool? isCore,
    ModuleCategory? category,
    String? defaultAlias,
    String? defaultSource,
    bool? allowMultiple,
    String? duplicateAliasNumberSeparator,
    dynamic Function()? initialDataFactory,
    String? uniqueKey,
    String? routeId,
    String? objClass,
  }) {
    return ModuleMetadata(
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      icon: icon ?? this.icon,
      assetIconPath: assetIconPath ?? this.assetIconPath,
      isCore: isCore ?? this.isCore,
      category: category ?? this.category,
      defaultAlias: defaultAlias ?? this.defaultAlias,
      defaultSource: defaultSource ?? this.defaultSource,
      allowMultiple: allowMultiple ?? this.allowMultiple,
      duplicateAliasNumberSeparator:
          duplicateAliasNumberSeparator ?? this.duplicateAliasNumberSeparator,
      initialDataFactory: initialDataFactory ?? this.initialDataFactory,
      uniqueKey: uniqueKey ?? this.uniqueKey,
      routeId: routeId ?? this.routeId,
      objClass: objClass ?? this.objClass,
    );
  }
}

extension ModuleCategoryTitle on ModuleCategory {
  String get title {
    switch (this) {
      case ModuleCategory.base:
        return 'Base';
      case ModuleCategory.mode:
        return 'Mode';
      case ModuleCategory.scene:
        return 'Scene';
      case ModuleCategory.gimmick:
        return 'Gimmick';
    }
  }
}

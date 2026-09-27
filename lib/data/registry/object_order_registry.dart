import 'package:c_editor/data/pvz_models.dart';

/// Object ordering for level file. Ported from Z-Editor-master ObjectOrderRegistry.kt
class ObjectOrderRegistry {
  ObjectOrderRegistry._();

  static const _orderList = [
    'LevelDefinition',
    'SeedBankProperties',
    'ConveyorSeedBankProperties',
    'PennyClassroomModuleProperties',
    'SunDropperProperties',
    'WitchModuleProperties',
    'SunBombChallengeProperties',
    'SingleHandedProperties',
    'IntroSingleHandedProperties',
    'BombProperties',
    'BronzeProperties',
    'ArmrackProperties',
    'EnergyGridProperties',
    'LastStandMinigameProperties',
    'CowboyMinigameProperties',
    'BowlingMinigameProperties',
    'NewBowlingMinigameProperties',
    'SeedRainProperties',
    'PiratePlankProperties',
    'TideProperties',
    'RoofProperties',
    'RailcartProperties',
    'PowerTileProperties',
    'ZombiePotionModuleProperties',
    'RenaiModuleProperties',
    'LunarMineVeinModuleProperties',
    'SmokePollutionModuleProperties',
    'DropShipProperties',
    'HeianWindModuleProperties',
    'SpermWhaleModuleProperties',
    'MoonLifeSupportSystemProperties',
    'LunarTerminalModuleProperties',
    'RadiationMeteorModuleProperties',
    'GladiatorRowModuleProperties',
    'LevelPowerupModuleProperties',
    'WarMistProperties',
    'ZombieMoveFastModuleProperties',
    'ZombossFinalStageTimeLimitedChallengeProperties',
    'TunnelDefendModuleProperties',
    'ZombieRushModuleProperties',
    'LawnMowerProperties',
    'MoonExpertProperties',
    'IncreasedCostModuleProperties',
    'DeathHoleModuleProperties',
    'PVZ1PassageModuleProperties',
    'PVZ1CopycatsModuleProperties',
    'PVZ1SeeingStarsModuleProperties',
    'LevelScoringModuleProperties',
    'LevelMutatorStartingPlantfoodProps',
    'LevelMutatorMaxSunProps',
    'RiftThemeDemoModuleProperties',
    'LevelMutatorRiftTimedSunProps',
    'PickupCollectableTutorialProperties',
    'InitialPlantProperties',
    'InitialPlantEntryProperties',
    'InitialZombieProperties',
    'InitialGridItemProperties',
    'InitialGridItemGulliverTunnelProperties',
    'ProtectThePlantChallengeProperties',
    'ProtectTheGridItemChallengeProperties',
    'MoldColonyChallengeProps',
    'BoardGridMapProps',
    'GlacierModuleProperties',
    'ZombossBattleIntroProperties',
    'ZombossBattleModuleProperties',
    'ZombossLastStandMinigameProperties',
    'VaseBreakerPresetProperties',
    'EvilDaveProperties',
    'StarChallengeModuleProperties',
    'StarChallengeBeatTheLevelProps',
    'StarChallengeSaveMowersProps',
    'StarChallengePlantFoodNonuseProps',
    'StarChallengePlantsSurviveProps',
    'StarChallengeZombieDistanceProps',
    'StarChallengeSunProducedProps',
    'StarChallengeSunUsedProps',
    'StarChallengeSpendSunHoldoutProps',
    'StarChallengeKillZombiesInTimeProps',
    'StarChallengeZombieSpeedProps',
    'StarChallengeSunReducedProps',
    'StarChallengePlantsLostProps',
    'StarChallengeSimultaneousPlantsProps',
    'StarChallengeUnfreezePlantsProps',
    'StarChallengeBlowZombieProps',
    'StarChallengeTargetScoreProps',
    'ApplyZombieConditionsChallengeProps',
    'PlantDefeatZombieChallengeProps',
    'DefeatZombiesOfTypeChallengeProps',
    'DestroyGridItemsChallengeProps',
    'StarChallengeDisablePlantProps',
    'StarChallengeSandstormZombieKillProps',
    'StarChallengeTentZombieKillProps',
    'StarChallengeBufferTileZombieKillProps',
    'StarChallengePotionZombieKillProps',
    'StarChallengeBarrelPowderZombieKillProps',
    'StarChallengeBlowBarrelZombieProps',
    'StarChallengeFirecrackerZombieKillProps',
    'StarChallengeFireworksZombieKillProps',
    'ZombiePerfumerChallengeProps',
    'BalletSlipChallengeProps',
    'ZombieExplodenutChallengeProps',
    'ZombieJalapenoChallengeProps',
    'RenaiRollerChallengeProps',
    'ZombiePeaChallengeProps',
    'SteamManholeChallengeProps',
    'StarChallengeSaveBombsProps',
    'WaveManagerModuleProperties',
    'WaveManagerProperties',
    'WaveGeneratorProperties',
    'SpawnZombiesJitteredWaveActionProps',
    'SpawnZombiesFromGroundSpawnerProps',
    'SpawnZombiesFromGridItemSpawnerProps',
    'BeachStageEventZombieSpawnerProps',
    'StormZombieSpawnerProps',
    'RaidingPartyZombieSpawnerProps',
    'SpiderRainZombieSpawnerProps',
    'ParachuteRainZombieSpawnerProps',
    'BassRainZombieSpawnerProps',
    'SpawnModernPortalsWaveActionProps',
    'FrostWindWaveActionProps',
    'DinoWaveActionProps',
    'DinoTreadActionProps',
    'DinoRunActionProps',
    'TidalChangeWaveActionProps',
    'SpawnZombiesFishWaveActionProps',
    'TideWaveWaveActionProps',
    'BlackHoleWaveActionProps',
    'ZombiePotionActionProps',
    'ZombieAtlantisShellActionProps',
    'SpawnRocketLandingWaveActionProps',
    'GravityGeneratorWaveActionProps',
    'WaveActionMagicMirrorTeleportationArrayProps',
    'SpawnEagleFlagsWaveActionProps',
    'WaveActionZombieTentProps',
    'PumpkinHouseActionProps',
    'SchoolBusWaveActionProps',
    'HamsterZombieSpawnerProps',
    'BarrelWaveActionProps',
    'BungeeWaveActionProps',
    'ThunderWaveActionProps',
    'SpawnGravestonesWaveActionProps',
    'ModifyConveyorWaveActionProps',
    'ZombieType',
    'ZombiePropertySheet',
  ];

  static final _orderMap = {
    for (var i = 0; i < _orderList.length; i++) _orderList[i]: i,
  };

  /// Returns sort priority (lower = earlier). Unknown classes get max value.
  static int getPriority(String objClass) {
    return _orderMap[objClass] ?? 0x7FFFFFFF;
  }

  static bool _isDigit(String c) =>
      c.length == 1 && c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;

  static int _naturalCompare(String s1, String s2) {
    var i = 0;
    var j = 0;
    while (i < s1.length && j < s2.length) {
      final c1 = s1[i];
      final c2 = s2[j];
      if (_isDigit(c1) && _isDigit(c2)) {
        var num1 = 0;
        while (i < s1.length && _isDigit(s1[i])) {
          if (num1 < 100000000000000000) {
            num1 = num1 * 10 + (s1.codeUnitAt(i) - 0x30);
          }
          i++;
        }
        var num2 = 0;
        while (j < s2.length && _isDigit(s2[j])) {
          if (num2 < 100000000000000000) {
            num2 = num2 * 10 + (s2.codeUnitAt(j) - 0x30);
          }
          j++;
        }
        if (num1 != num2) return num1.compareTo(num2);
      } else {
        if (c1 != c2) return c1.compareTo(c2);
        i++;
        j++;
      }
    }
    return s1.length - s2.length;
  }

  /// Comparator for sorting PvzObject list.
  static int compare(PvzObject o1, PvzObject o2) {
    final p1 = getPriority(o1.objClass);
    final p2 = getPriority(o2.objClass);
    if (p1 != 0x7FFFFFFF && p2 != 0x7FFFFFFF) return p1 - p2;
    if (p1 != 0x7FFFFFFF) return -1;
    if (p2 != 0x7FFFFFFF) return 1;
    if (o1.objClass != o2.objClass) return o1.objClass.compareTo(o2.objClass);
    final alias1 = o1.aliases?.isNotEmpty == true ? o1.aliases!.first : '';
    final alias2 = o2.aliases?.isNotEmpty == true ? o2.aliases!.first : '';
    return _naturalCompare(alias1, alias2);
  }
}

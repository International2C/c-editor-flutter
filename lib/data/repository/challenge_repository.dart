import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/challenge_resource_l10n.dart';
import 'package:c_editor/utils/selection_search.dart';

const kPlantDefeatZombieDefaultDescription = '[KILL_DESC]';

/// Challenge type metadata. Ported from Z-Editor-master ChallengeRepository.kt
class ChallengeTypeInfo {
  const ChallengeTypeInfo({
    required this.objClass,
    required this.defaultAlias,
    required this.icon,
    this.initialDataFactory,
  });

  final String objClass;
  final String defaultAlias;
  final IconData icon;
  final Object? Function()? initialDataFactory;

  String localizedTitle(BuildContext context) =>
      ChallengeRepository.localizedTitle(context, objClass);

  String localizedDescription(BuildContext context) =>
      ChallengeRepository.localizedDescription(context, objClass);
}

/// Challenge repository. Ported from Z-Editor-master ChallengeRepository.kt
class ChallengeRepository {
  ChallengeRepository._();

  static final List<ChallengeTypeInfo> allChallenges = [
    ChallengeTypeInfo(
      objClass: 'StarChallengeBeatTheLevelProps',
      defaultAlias: 'BeatTheLevel',
      icon: Icons.campaign,
      initialDataFactory: () => StarChallengeBeatTheLevelData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeSaveMowersProps',
      defaultAlias: 'SaveMowers',
      icon: Icons.cleaning_services,
      initialDataFactory: () => StarChallengeSaveMowerData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengePlantFoodNonuseProps',
      defaultAlias: 'PlantfoodNonuse',
      icon: Icons.eco,
      initialDataFactory: () => StarChallengePlantFoodNonuseData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengePlantsSurviveProps',
      defaultAlias: 'PlantsSurvive',
      icon: Icons.security,
      initialDataFactory: () => StarChallengePlantSurviveData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeZombieDistanceProps',
      defaultAlias: 'ZombieDistance',
      icon: Icons.do_not_step,
      initialDataFactory: () => StarChallengeZombieDistanceData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeSunProducedProps',
      defaultAlias: 'SunProduced',
      icon: Icons.wb_sunny,
      initialDataFactory: () => StarChallengeSunProducedData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeSunUsedProps',
      defaultAlias: 'SunUsed',
      icon: Icons.savings,
      initialDataFactory: () => StarChallengeSunUsedData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeSpendSunHoldoutProps',
      defaultAlias: 'SpendSunHoldout',
      icon: Icons.hourglass_empty,
      initialDataFactory: () => StarChallengeSpendSunHoldoutData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeKillZombiesInTimeProps',
      defaultAlias: 'KillZombies',
      icon: Icons.pest_control,
      initialDataFactory: () => StarChallengeKillZombiesInTimeData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeZombieSpeedProps',
      defaultAlias: 'ZombieSpeed',
      icon: Icons.speed,
      initialDataFactory: () => StarChallengeZombieSpeedData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeSunReducedProps',
      defaultAlias: 'SunReduced',
      icon: Icons.brightness_low,
      initialDataFactory: () => StarChallengeSunReducedData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengePlantsLostProps',
      defaultAlias: 'PlantsLost',
      icon: Icons.heart_broken,
      initialDataFactory: () => StarChallengePlantsLostData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeSimultaneousPlantsProps',
      defaultAlias: 'SimultaneousPlants',
      icon: Icons.forest,
      initialDataFactory: () => StarChallengeSimultaneousPlantsData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeUnfreezePlantsProps',
      defaultAlias: 'UnfreezePlants',
      icon: Icons.ac_unit,
      initialDataFactory: () => StarChallengeUnfreezePlantsData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeBlowZombieProps',
      defaultAlias: 'BlowZombie',
      icon: Icons.air,
      initialDataFactory: () => StarChallengeBlowZombieData(),
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeTargetScoreProps',
      defaultAlias: 'ReachTheScore',
      icon: Icons.scoreboard,
      initialDataFactory: () => StarChallengeTargetScoreData(),
    ),
    ChallengeTypeInfo(
      objClass: 'ApplyZombieConditionsChallengeProps',
      defaultAlias: 'ApplyZombieConditionsChallenge',
      icon: Icons.coronavirus,
      initialDataFactory: () => {
        'ConditionToInflict': ['hypnotized'],
        'IncludeBurnedToAsh': true,
        'IncludeElectrified': true,
        'NumZombieConditionsToApply': 5,
      },
    ),
    ChallengeTypeInfo(
      objClass: 'PlantDefeatZombieChallengeProps',
      defaultAlias: 'DefeatZombie',
      icon: Icons.pest_control,
      initialDataFactory: () => {
        'Description': kPlantDefeatZombieDefaultDescription,
        'NumZombiesToKill': 12,
        'PlantTypeName': 'peashooter',
      },
    ),
    ChallengeTypeInfo(
      objClass: 'DefeatZombiesOfTypeChallengeProps',
      defaultAlias: 'DefeatZombiesOfType',
      icon: Icons.filter_list,
      initialDataFactory: () => {
        'Description': '',
        'NumZombiesToKill': 30,
        'TypesToKill': {'List': <String>[], 'ListType': 'whitelist'},
      },
    ),
    ChallengeTypeInfo(
      objClass: 'DestroyGridItemsChallengeProps',
      defaultAlias: 'DestroyGridItems',
      icon: Icons.delete_forever,
      initialDataFactory: () => {
        'GridItemType': 'gravestone',
        'GridItemsToDestroy': 10,
        'ChallengeDescription': '',
      },
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeDisablePlantProps',
      defaultAlias: 'DisablePlant',
      icon: Icons.block,
      initialDataFactory: () => {'Profession': 'warrior'},
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeSandstormZombieKillProps',
      defaultAlias: 'SandstormZombieKill',
      icon: Icons.thunderstorm,
      initialDataFactory: () => {'Count': 8},
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeTentZombieKillProps',
      defaultAlias: 'TentZombieKill',
      icon: Icons.festival,
      initialDataFactory: () => {'Count': 8},
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeBufferTileZombieKillProps',
      defaultAlias: 'BufferTileZombieKill',
      icon: Icons.grid_on,
      initialDataFactory: () => {'Count': 8},
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengePotionZombieKillProps',
      defaultAlias: 'PotionZombieKill',
      icon: Icons.science,
      initialDataFactory: () => {'Count': 8},
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeBarrelPowderZombieKillProps',
      defaultAlias: 'BarrelPowderZombieKill',
      icon: Icons.whatshot,
      initialDataFactory: () => {'Count': 8},
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeBlowBarrelZombieProps',
      defaultAlias: 'BlowBarrelZombieKill',
      icon: Icons.air,
      initialDataFactory: () => {'Count': 8},
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeFirecrackerZombieKillProps',
      defaultAlias: 'FirecrackerZombieKill',
      icon: Icons.celebration,
      initialDataFactory: () => {'Count': 8},
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeFireworksZombieKillProps',
      defaultAlias: 'FireworksZombieKill',
      icon: Icons.auto_awesome,
      initialDataFactory: () => {'Count': 8},
    ),
    ChallengeTypeInfo(
      objClass: 'ZombiePerfumerChallengeProps',
      defaultAlias: 'CleanPoison',
      icon: Icons.cloud_off,
      initialDataFactory: () => {'PoisonToClean': 3},
    ),
    ChallengeTypeInfo(
      objClass: 'BalletSlipChallengeProps',
      defaultAlias: 'BalletSlip',
      icon: Icons.ice_skating,
      initialDataFactory: () => {'BalletToSlip': 8},
    ),
    ChallengeTypeInfo(
      objClass: 'ZombieExplodenutChallengeProps',
      defaultAlias: 'ZombieExplodenut',
      icon: Icons.warning,
      initialDataFactory: () => {'MaximumExplode': 5},
    ),
    ChallengeTypeInfo(
      objClass: 'ZombieJalapenoChallengeProps',
      defaultAlias: 'ZombieJalapeno',
      icon: Icons.local_fire_department,
      initialDataFactory: () => {'MaximumJalapeno': 5},
    ),
    ChallengeTypeInfo(
      objClass: 'RenaiRollerChallengeProps',
      defaultAlias: 'RenaiRoller',
      icon: Icons.attractions,
      initialDataFactory: () => {'MaximumPlantsDied': 5},
    ),
    ChallengeTypeInfo(
      objClass: 'ZombiePeaChallengeProps',
      defaultAlias: 'ZombiePea',
      icon: Icons.grass,
      initialDataFactory: () => {'MaximumPlantsHitted': 80},
    ),
    ChallengeTypeInfo(
      objClass: 'SteamManholeChallengeProps',
      defaultAlias: 'SteamManhole',
      icon: Icons.plumbing,
      initialDataFactory: () => {'MaximumManholeEntered': 5},
    ),
    ChallengeTypeInfo(
      objClass: 'StarChallengeSaveBombsProps',
      defaultAlias: 'SaveBombs',
      icon: Icons.lock,
      initialDataFactory: () => <String, dynamic>{},
    ),
  ];

  static List<ChallengeTypeInfo> search(String query, BuildContext context) {
    if (query.trim().isEmpty) return allChallenges;
    return allChallenges.where((c) {
      return matchesSelectionSearch(query, [
        c.localizedTitle(context),
        c.localizedDescription(context),
        c.objClass,
        c.defaultAlias,
        'starChallenge_${c.objClass}_title',
        'starChallenge_${c.objClass}_desc',
      ]);
    }).toList();
  }

  static String localizedTitle(BuildContext context, String objClass) {
    return ChallengeResourceL10n.title(
      context,
      objClass,
      fallback: getInfo(objClass)?.defaultAlias,
    );
  }

  static String localizedDescription(BuildContext context, String objClass) {
    return ChallengeResourceL10n.description(context, objClass);
  }

  static ChallengeTypeInfo? getInfo(String objClass) {
    try {
      return allChallenges.firstWhere((c) => c.objClass == objClass);
    } catch (_) {
      return null;
    }
  }

  /// Suggests the next local alias for [challenge].
  ///
  /// Existing objects of the same challenge type also reserve the numeric
  /// suffix even when their alias was customized or came from an older build
  /// with a different default spelling.
  static String suggestUniqueAlias({
    required ChallengeTypeInfo challenge,
    required PvzLevelFile levelFile,
    Iterable<String> referencedRtids = const <String>[],
  }) {
    final usedAliases = <String>{};
    var hasSameChallengeType = false;

    for (final object in levelFile.objects) {
      usedAliases.addAll(object.aliases ?? const <String>[]);
      if (object.objClass == challenge.objClass) {
        hasSameChallengeType = true;
      }
    }
    for (final rtid in referencedRtids) {
      final info = RtidParser.parse(rtid);
      if (info != null) usedAliases.add(info.alias);
    }

    final base = challenge.defaultAlias.trim().isEmpty
        ? 'Challenge'
        : challenge.defaultAlias.trim();
    if (!hasSameChallengeType && !usedAliases.contains(base)) return base;

    var suffix = 1;
    while (usedAliases.contains('$base$suffix')) {
      suffix++;
    }
    return '$base$suffix';
  }
}

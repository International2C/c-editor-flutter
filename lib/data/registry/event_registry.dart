import 'package:flutter/material.dart';
import '../pvz_models.dart';

enum EventCategory { zombieSpawn, gridItemSpawn, environmental, other }

class EventMetadata {
  EventMetadata({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    required this.darkColor,
    required this.category,
    required this.defaultAlias,
    required this.defaultObjClass,
    required this.initialDataFactory,
    this.summaryProvider,
    this.assetIconPath,
  });

  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final String? assetIconPath;
  final Color color;
  final Color darkColor;
  final EventCategory category;
  final String defaultAlias;
  final String defaultObjClass;
  final Object Function() initialDataFactory;
  final String Function(PvzObject obj)? summaryProvider;
}

class EventRegistry {
  static final Map<String, EventMetadata> _registry = {
    'SpawnZombiesJitteredWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_SpawnZombiesJitteredWaveActionProps',
      descriptionKey: 'eventDesc_SpawnZombiesJitteredWaveActionProps',
      icon: Icons.groups,
      color: const Color(0xFF2196F3),
      darkColor: const Color(0xFF90CAF9),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'JitteredEvent',
      defaultObjClass: 'SpawnZombiesJitteredWaveActionProps',
      initialDataFactory: () => WaveActionData(),
      summaryProvider: (obj) {
        try {
          final data = WaveActionData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.zombies.length}';
        } catch (_) {
          return '';
        }
      },
    ),
    'SpawnZombiesFishWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_SpawnZombiesFishWaveActionProps',
      descriptionKey: 'eventDesc_SpawnZombiesFishWaveActionProps',
      icon: Icons.water,
      color: const Color(0xFF00ACC1),
      darkColor: const Color(0xFF81D4FA),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'ZombieFishWave',
      defaultObjClass: 'SpawnZombiesFishWaveActionProps',
      initialDataFactory: () => SpawnZombiesFishWaveActionPropsData(),
      summaryProvider: (obj) {
        try {
          final data = SpawnZombiesFishWaveActionPropsData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return 'Z:${data.zombies.length} F:${data.fishes.length}';
        } catch (_) {
          return '';
        }
      },
    ),
    'SpawnZombiesFromGroundSpawnerProps': EventMetadata(
      titleKey: 'eventTitle_SpawnZombiesFromGroundSpawnerProps',
      descriptionKey: 'eventDesc_SpawnZombiesFromGroundSpawnerProps',
      icon: Icons.groups,
      color: const Color(0xFF936457),
      darkColor: const Color(0xFFC2A197),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'GroundSpawnEvent',
      defaultObjClass: 'SpawnZombiesFromGroundSpawnerProps',
      initialDataFactory: () => WaveActionData(),
      summaryProvider: (obj) {
        try {
          final data = SpawnZombiesFromGroundData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.zombies.length}';
        } catch (_) {
          return '';
        }
      },
    ),
    'SpawnZombiesFromGridItemSpawnerProps': EventMetadata(
      titleKey: 'eventTitle_SpawnZombiesFromGridItemSpawnerProps',
      descriptionKey: 'eventDesc_SpawnZombiesFromGridItemSpawnerProps',
      icon: Icons.groups,
      color: const Color(0xFF607D8B),
      darkColor: const Color(0xFFB0BEC5),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'GraveSpawner',
      defaultObjClass: 'SpawnZombiesFromGridItemSpawnerProps',
      initialDataFactory: () => SpawnZombiesFromGridItemData(),
    ),
    'SpawnGravestonesWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_SpawnGravestonesWaveActionProps',
      descriptionKey: 'eventDesc_SpawnGravestonesWaveActionProps',
      icon: Icons.unarchive,
      color: const Color(0xFF607D8B),
      darkColor: const Color(0xFFB0BEC5),
      category: EventCategory.gridItemSpawn,
      defaultAlias: 'GravestonesEvent',
      defaultObjClass: 'SpawnGravestonesWaveActionProps',
      initialDataFactory: () => SpawnGraveStonesData(),
    ),
    'ModifyConveyorWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_ModifyConveyorWaveActionProps',
      descriptionKey: 'eventDesc_ModifyConveyorWaveActionProps',
      icon: Icons.transform,
      color: const Color(0xFF4AC380),
      darkColor: const Color(0xFF7CBD99),
      category: EventCategory.other,
      defaultAlias: 'ModConveyorEvent',
      defaultObjClass: 'ModifyConveyorWaveActionProps',
      initialDataFactory: () => ModifyConveyorWaveActionData(),
    ),
    'StormZombieSpawnerProps': EventMetadata(
      titleKey: 'eventTitle_StormZombieSpawnerProps',
      descriptionKey: 'eventDesc_StormZombieSpawnerProps',
      icon: Icons.storm,
      color: const Color(0xFFFF9800),
      darkColor: const Color(0xFFFFCC80),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'StormEvent',
      defaultObjClass: 'StormZombieSpawnerProps',
      initialDataFactory: () => StormZombieSpawnerPropsData(),
    ),
    'RaidingPartyZombieSpawnerProps': EventMetadata(
      titleKey: 'eventTitle_RaidingPartyZombieSpawnerProps',
      descriptionKey: 'eventDesc_RaidingPartyZombieSpawnerProps',
      icon: Icons.tsunami,
      color: const Color(0xFFFF9800),
      darkColor: const Color(0xFFFFCC80),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'RaidingPartyEvent',
      defaultObjClass: 'RaidingPartyZombieSpawnerProps',
      initialDataFactory: () => RaidingPartyEventData(),
    ),
    'BlackHoleWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_BlackHoleWaveActionProps',
      descriptionKey: 'eventDesc_BlackHoleWaveActionProps',
      icon: Icons.circle_outlined,
      color: const Color(0xFF9C27B0),
      darkColor: const Color(0xFFCE93D8),
      category: EventCategory.environmental,
      defaultAlias: 'BlackHoleEvent',
      defaultObjClass: 'BlackHoleWaveActionProps',
      initialDataFactory: () => BlackHoleEventData(),
      summaryProvider: (obj) {
        try {
          final data = BlackHoleEventData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return 'col: ${data.colNumPlantIsDragged}';
        } catch (_) {
          return '';
        }
      },
    ),
    'SpiderRainZombieSpawnerProps': EventMetadata(
      titleKey: 'eventTitle_SpiderRainZombieSpawnerProps',
      descriptionKey: 'eventDesc_SpiderRainZombieSpawnerProps',
      icon: Icons.pest_control,
      color: const Color(0xFFFF9800),
      darkColor: const Color(0xFFFFCC80),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'SpiderRainEvent',
      defaultObjClass: 'SpiderRainZombieSpawnerProps',
      initialDataFactory: () => ParachuteRainEventData(),
      summaryProvider: (obj) {
        try {
          final data = ParachuteRainEventData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.groupSize}x${data.spiderCount}';
        } catch (_) {
          return '';
        }
      },
    ),
    'ZombiePotionActionProps': EventMetadata(
      titleKey: 'eventTitle_ZombiePotionActionProps',
      descriptionKey: 'eventDesc_ZombiePotionActionProps',
      icon: Icons.science,
      color: const Color(0xFF607D8B),
      darkColor: const Color(0xFFB0BEC5),
      category: EventCategory.gridItemSpawn,
      defaultAlias: 'PotionEvent',
      defaultObjClass: 'ZombiePotionActionProps',
      initialDataFactory: () => ZombiePotionActionPropsData(),
    ),
    'TidalChangeWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_TidalChangeWaveActionProps',
      descriptionKey: 'eventDesc_TidalChangeWaveActionProps',
      icon: Icons.water_drop,
      color: const Color(0xFF00ACC1),
      darkColor: const Color(0xFF81D4FA),
      category: EventCategory.environmental,
      defaultAlias: 'TidalChangeEvent',
      defaultObjClass: 'TidalChangeWaveActionProps',
      initialDataFactory: () => TidalChangeWaveActionData(),
    ),
    'BeachStageEventZombieSpawnerProps': EventMetadata(
      titleKey: 'eventTitle_BeachStageEventZombieSpawnerProps',
      descriptionKey: 'eventDesc_BeachStageEventZombieSpawnerProps',
      icon: Icons.water,
      color: const Color(0xFF00ACC1),
      darkColor: const Color(0xFF81D4FA),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'LowTideEvent',
      defaultObjClass: 'BeachStageEventZombieSpawnerProps',
      initialDataFactory: () => BeachStageEventData(),
      summaryProvider: (obj) {
        try {
          final data = BeachStageEventData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.zombieCount}';
        } catch (_) {
          return '';
        }
      },
    ),
    'FrostWindWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_FrostWindWaveActionProps',
      descriptionKey: 'eventDesc_FrostWindWaveActionProps',
      icon: Icons.ac_unit,
      color: const Color(0xFF0288D1),
      darkColor: const Color(0xFF90CAF9),
      category: EventCategory.environmental,
      defaultAlias: 'FrostWindEvent',
      defaultObjClass: 'FrostWindWaveActionProps',
      initialDataFactory: () => FrostWindWaveActionPropsData(),
      summaryProvider: (obj) {
        try {
          final data = FrostWindWaveActionPropsData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.winds.length}';
        } catch (_) {
          return '';
        }
      },
    ),
    'ParachuteRainZombieSpawnerProps': EventMetadata(
      titleKey: 'eventTitle_ParachuteRainZombieSpawnerProps',
      descriptionKey: 'eventDesc_ParachuteRainZombieSpawnerProps',
      icon: Icons.paragliding,
      color: const Color(0xFFFF9800),
      darkColor: const Color(0xFFFFCC80),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'ParachuteRainEvent',
      defaultObjClass: 'ParachuteRainZombieSpawnerProps',
      initialDataFactory: () => ParachuteRainEventData(),
      summaryProvider: (obj) {
        try {
          final data = ParachuteRainEventData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.groupSize}x${data.spiderCount}';
        } catch (_) {
          return '';
        }
      },
    ),
    'ThunderWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_ThunderWaveActionProps',
      descriptionKey: 'eventDesc_ThunderWaveActionProps',
      icon: Icons.thunderstorm,
      color: const Color(0xFF5C6BC0),
      darkColor: const Color(0xFF9FA8DA),
      category: EventCategory.environmental,
      defaultAlias: 'ThunderEvent',
      defaultObjClass: 'ThunderWaveActionProps',
      initialDataFactory: () => ThunderWaveActionPropsData(),
      summaryProvider: (obj) {
        try {
          final data = ThunderWaveActionPropsData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.thunders.length}';
        } catch (_) {
          return '';
        }
      },
    ),
    'BassRainZombieSpawnerProps': EventMetadata(
      titleKey: 'eventTitle_BassRainZombieSpawnerProps',
      descriptionKey: 'eventDesc_BassRainZombieSpawnerProps',
      icon: Icons.music_note,
      color: const Color(0xFFFF9800),
      darkColor: const Color(0xFFFFCC80),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'BassRainEvent',
      defaultObjClass: 'BassRainZombieSpawnerProps',
      initialDataFactory: () => ParachuteRainEventData(),
    ),
    'DinoWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_DinoWaveActionProps',
      descriptionKey: 'eventDesc_DinoWaveActionProps',
      icon: Icons.pets,
      color: const Color(0xFF91B900),
      darkColor: const Color(0xFFA2B659),
      category: EventCategory.other,
      defaultAlias: 'DinoTimeEvent',
      defaultObjClass: 'DinoWaveActionProps',
      initialDataFactory: () => DinoWaveActionPropsData(),
    ),
    'DinoTreadActionProps': EventMetadata(
      titleKey: 'eventTitle_DinoTreadActionProps',
      descriptionKey: 'eventDesc_DinoTreadActionProps',
      icon: Icons.pets,
      color: const Color(0xFF91B900),
      darkColor: const Color(0xFFA2B659),
      category: EventCategory.other,
      defaultAlias: 'DinoTreadEvent',
      defaultObjClass: 'DinoTreadActionProps',
      initialDataFactory: () => DinoTreadActionPropsData(),
    ),
    'DinoRunActionProps': EventMetadata(
      titleKey: 'eventTitle_DinoRunActionProps',
      descriptionKey: 'eventDesc_DinoRunActionProps',
      icon: Icons.pets,
      color: const Color(0xFF91B900),
      darkColor: const Color(0xFFA2B659),
      category: EventCategory.other,
      defaultAlias: 'DinoRunEvent',
      defaultObjClass: 'DinoRunActionProps',
      initialDataFactory: () => DinoRunActionPropsData(),
    ),
    'SpawnModernPortalsWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_SpawnModernPortalsWaveActionProps',
      descriptionKey: 'eventDesc_SpawnModernPortalsWaveActionProps',
      icon: Icons.hourglass_empty,
      color: const Color(0xFFFF9800),
      darkColor: const Color(0xFFFFCC80),
      category: EventCategory.gridItemSpawn,
      defaultAlias: 'PortalEvent',
      defaultObjClass: 'SpawnModernPortalsWaveActionProps',
      initialDataFactory: () => PortalEventData(),
    ),
    'TideWaveWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_TideWaveWaveActionProps',
      descriptionKey: 'eventDesc_TideWaveWaveActionProps',
      icon: Icons.water,
      color: const Color(0xFF00ACC1),
      darkColor: const Color(0xFF81D4FA),
      category: EventCategory.environmental,
      defaultAlias: 'TideWaveEvent',
      defaultObjClass: 'TideWaveWaveActionProps',
      initialDataFactory: () => TideWaveWaveActionPropsData(),
    ),
    'ZombieAtlantisShellActionProps': EventMetadata(
      titleKey: 'eventTitle_ZombieAtlantisShellActionProps',
      descriptionKey: 'eventDesc_ZombieAtlantisShellActionProps',
      icon: Icons.beach_access,
      color: const Color(0xFF00838F),
      darkColor: const Color(0xFF4DD0E1),
      category: EventCategory.gridItemSpawn,
      defaultAlias: 'ShellEvent',
      defaultObjClass: 'ZombieAtlantisShellActionProps',
      initialDataFactory: () => ZombieAtlantisShellActionPropsData(),
      summaryProvider: (obj) {
        try {
          final data = ZombieAtlantisShellActionPropsData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.tiles.length}';
        } catch (_) {
          return '';
        }
      },
    ),
    'SpawnRocketLandingWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_SpawnRocketLandingWaveActionProps',
      descriptionKey: 'eventDesc_SpawnRocketLandingWaveActionProps',
      icon: Icons.rocket_launch,
      color: const Color(0xFF5C6BC0),
      darkColor: const Color(0xFF9FA8DA),
      category: EventCategory.gridItemSpawn,
      defaultAlias: 'Rocket',
      defaultObjClass: 'SpawnRocketLandingWaveActionProps',
      initialDataFactory: () => SpawnRocketLandingWaveActionPropsData(),
      summaryProvider: (obj) {
        try {
          final data = SpawnRocketLandingWaveActionPropsData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.spawnCount}';
        } catch (_) {
          return '';
        }
      },
    ),
    'GravityGeneratorWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_GravityGeneratorWaveActionProps',
      descriptionKey: 'eventDesc_GravityGeneratorWaveActionProps',
      icon: Icons.vertical_align_center,
      color: const Color(0xFF7B1FA2),
      darkColor: const Color(0xFFCE93D8),
      category: EventCategory.environmental,
      defaultAlias: 'Gravity',
      defaultObjClass: 'GravityGeneratorWaveActionProps',
      initialDataFactory: () => GravityGeneratorWaveActionPropsData(),
    ),
    'FairyTaleFogWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_FairyTaleFogWaveActionProps',
      descriptionKey: 'eventDesc_FairyTaleFogWaveActionProps',
      icon: Icons.cloud,
      color: const Color(0xFFBE5DBA),
      darkColor: const Color(0xFFBD99BB),
      category: EventCategory.environmental,
      defaultAlias: 'FairyFogEvent',
      defaultObjClass: 'FairyTaleFogWaveActionProps',
      initialDataFactory: () => FairyTaleFogWaveActionData(),
    ),
    'FairyTaleWindWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_FairyTaleWindWaveActionProps',
      descriptionKey: 'eventDesc_FairyTaleWindWaveActionProps',
      icon: Icons.air,
      color: const Color(0xFFBE5DBA),
      darkColor: const Color(0xFFBD99BB),
      category: EventCategory.environmental,
      defaultAlias: 'WindEvent',
      defaultObjClass: 'FairyTaleWindWaveActionProps',
      initialDataFactory: () => FairyTaleWindWaveActionData(),
    ),
    'WaveActionMagicMirrorTeleportationArrayProps': EventMetadata(
      titleKey: 'eventTitle_MagicMirrorWaveActionProps',
      descriptionKey: 'eventDesc_MagicMirrorWaveActionProps',
      icon: Icons.tablet,
      color: const Color(0xFFBE5DBA),
      darkColor: const Color(0xFFBD99BB),
      category: EventCategory.gridItemSpawn,
      defaultAlias: 'MagicMirrorEvent',
      defaultObjClass: 'WaveActionMagicMirrorTeleportationArrayProps',
      initialDataFactory: () => MagicMirrorWaveActionData(),
    ),
    'SpawnEagleFlagsWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_SpawnEagleFlagsWaveActionProps',
      descriptionKey: 'eventDesc_SpawnEagleFlagsWaveActionProps',
      icon: Icons.flag,
      color: const Color(0xFFB78921),
      darkColor: const Color(0xFFFFD54F),
      category: EventCategory.gridItemSpawn,
      defaultAlias: 'EagleFlagEvent',
      defaultObjClass: 'SpawnEagleFlagsWaveActionProps',
      initialDataFactory: () => SpawnEagleFlagsWaveActionPropsData(),
      summaryProvider: (obj) {
        try {
          final data = SpawnEagleFlagsWaveActionPropsData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.flags.length}';
        } catch (_) {
          return '';
        }
      },
    ),
    'BarrelWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_BarrelWaveActionProps',
      descriptionKey: 'eventDesc_BarrelWaveActionProps',
      icon: Icons.local_fire_department,
      color: const Color(0xFFE65100),
      darkColor: const Color(0xFFFFAB91),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'BarrelEvent',
      defaultObjClass: 'BarrelWaveActionProps',
      initialDataFactory: () => BarrelWaveEventData(),
      summaryProvider: (obj) {
        try {
          final data = BarrelWaveEventData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.barrels.length}';
        } catch (_) {
          return '';
        }
      },
    ),
    'BungeeWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_BungeeWaveActionProps',
      descriptionKey: 'eventDesc_BungeeWaveActionProps',
      icon: Icons.paragliding,
      color: const Color(0xFFFF9800),
      darkColor: const Color(0xFFFFCC80),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'BungeeDropEvent',
      defaultObjClass: 'BungeeWaveActionProps',
      initialDataFactory: () => BungeeWaveActionData(),
      summaryProvider: (obj) {
        try {
          final data = BungeeWaveActionData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return 'C${data.target.mX + 1}R${data.target.mY + 1}';
        } catch (_) {
          return '';
        }
      },
    ),
    'SchoolBusWaveActionProps': EventMetadata(
      titleKey: 'eventTitle_SchoolBusWaveActionProps',
      descriptionKey: 'eventDesc_SchoolBusWaveActionProps',
      icon: Icons.icecream,
      color: const Color(0xFFFFC107),
      darkColor: const Color(0xFFFFECB3),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'SchoolBusEvent',
      defaultObjClass: 'SchoolBusWaveActionProps',
      initialDataFactory: () => SchoolBusWaveActionPropsData(),
      summaryProvider: (obj) {
        try {
          final data = SchoolBusWaveActionPropsData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          final zCount = data.des.params.zombies.length;
          return zCount > 0 ? 'R${data.des.row} · $zCount' : 'R${data.des.row}';
        } catch (_) {
          return '';
        }
      },
    ),
    'HamsterZombieSpawnerProps': EventMetadata(
      titleKey: 'eventTitle_HamsterZombieSpawnerProps',
      descriptionKey: 'eventDesc_HamsterZombieSpawnerProps',
      icon: Icons.pets,
      color: const Color(0xFF607D8B),
      darkColor: const Color(0xFFB0BEC5),
      category: EventCategory.zombieSpawn,
      defaultAlias: 'HamsterBallEvent',
      defaultObjClass: 'HamsterZombieSpawnerProps',
      initialDataFactory: () => HamsterZombieSpawnerPropsData(),
      summaryProvider: (obj) {
        try {
          final data = HamsterZombieSpawnerPropsData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.zombies.length}';
        } catch (_) {
          return '';
        }
      },
    ),
    'WaveActionZombieTentProps': EventMetadata(
      titleKey: 'eventTitle_WaveActionZombieTentProps',
      descriptionKey: 'eventDesc_WaveActionZombieTentProps',
      icon: Icons.festival,
      color: const Color(0xFFC62828),
      darkColor: const Color(0xFFEF9A9A),
      category: EventCategory.gridItemSpawn,
      defaultAlias: 'FestivalZombieTentEvent',
      defaultObjClass: 'WaveActionZombieTentProps',
      initialDataFactory: () => WaveActionZombieTentPropsData(),
      summaryProvider: (obj) {
        try {
          final data = WaveActionZombieTentPropsData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.zombieTents.length}';
        } catch (_) {
          return '';
        }
      },
    ),
    'PumpkinHouseActionProps': EventMetadata(
      titleKey: 'eventTitle_PumpkinHouseActionProps',
      descriptionKey: 'eventDesc_PumpkinHouseActionProps',
      icon: Icons.holiday_village,
      color: const Color(0xFFE65100),
      darkColor: const Color(0xFFFFAB91),
      category: EventCategory.gridItemSpawn,
      defaultAlias: 'PumpkinHouseEvent',
      defaultObjClass: 'PumpkinHouseActionProps',
      initialDataFactory: () => PumpkinHouseActionPropsData(),
      summaryProvider: (obj) {
        try {
          final data = PumpkinHouseActionPropsData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          return '${data.tiles.length}';
        } catch (_) {
          return '';
        }
      },
    ),
  };

  static List<EventMetadata> getAll() => _registry.values.toList();
  static EventMetadata? getByObjClass(String? objClass) {
    if (objClass == null) return null;
    return _registry[objClass];
  }
}

import 'package:c_editor/data/gladiator_row_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';

class ZombieDiscovery {
  static const skyCityImp = 'skycity_ggtimp';

  static const bronzeGargMap = {
    'kongfu_strong_bronze': 'kongfu_strong_bronze',
    'kongfu_magic_bronze': 'kongfu_magic_bronze',
    'kongfu_agile_bronze': 'kongfu_agile_bronze',
  };

  static const renaissanceStatueMap = {
    'renai_statue_zombie1': 'renai_worker',
    'renai_statue_zombie1_half': 'renai_worker',
    'renai_statue_zombie_armor1': 'renai_armor1',
    'renai_statue_zombie_armor1_half': 'renai_armor1',
    'renai_statue_zombie_armor2': 'renai_armor2',
    'renai_statue_zombie_armor2_half': 'renai_armor2',
    'renai_statue_zombie_perfumer': 'renai_perfumer',
    'renai_statue_zombie_perfumer_half': 'renai_perfumer',
    'renai_zomboss_statue_zombie1_half': 'renai_worker',
  };

  static const ignoredIds = {
    'sandstorm',
    'snowstorm',
    'barrelmoster',
    'barrelempty',
    'barrelpowder',
    'schoolbus_normal',
    'schoolbus_special',
    // Event transport/container types. The actual passengers are discovered
    // from their nested zombie fields instead.
    'hamster_ball',
    'krill',
    'hermitcrab',
    'inkfish',
    'jellyfish',
    'pufferfish',
    'starfish',
    'swordfish',
    'cthulhusmalljelly',
    'smalljellyfish',
  };

  static Set<String> discoverZombies(
    PvzLevelFile levelFile,
    ParsedLevelData parsed,
  ) {
    final zombies = <String>{};
    final customZombieAliases = {
      for (final obj in levelFile.objects)
        if (obj.objClass == 'ZombieType') ...?obj.aliases,
    };
    void addZombie(String id) => _addZombie(id, zombies, customZombieAliases);

    for (final obj in levelFile.objects) {
      if (obj.objClass == 'InitialZombieProperties') {
        final data = obj.objData;
        if (data is Map) {
          final list = data['InitialZombiePlacements'] ?? data['Zombies'];
          if (list is List) {
            for (final e in list) {
              if (e is Map) {
                final type = e['TypeName'] ?? e['ZombieType'];
                if (type is String) addZombie(type);
              }
            }
          }
        }
      }
    }

    final wm = parsed.waveManager;
    if (wm is WaveManagerData) {
      for (final wave in wm.waves) {
        for (final rtid in wave) {
          final alias = LevelParser.extractAlias(rtid);
          final obj = parsed.objectMap[alias];
          if (obj != null) {
            _extractFromWaveAction(obj, zombies, customZombieAliases);
          }
        }
      }
    }

    final wg = parsed.waveGenerator;
    if (wg != null) {
      for (final wave in wg.waves) {
        for (final z in wave.zombies) {
          if (z.type.isNotEmpty) addZombie(z.type);
        }
        for (final pool in wave.addToZombiePool) {
          if (pool.type.isNotEmpty) addZombie(pool.type);
        }
      }
      for (final pool in wg.addToZombiePool) {
        if (pool.type.isNotEmpty) addZombie(pool.type);
      }
    }

    final wmm = parsed.waveModule;
    if (wmm != null) {
      for (final group in wmm.dynamicZombies) {
        for (final zId in group.zombiePool) {
          if (zId.isNotEmpty) addZombie(zId);
        }
      }
    }

    final bronzeData = readBronzeModuleData(levelFile);
    if (bronzeData != null) {
      for (final batch in bronzeData.data) {
        for (final item in batch.itemList) {
          final id = switch (item.kind) {
            BronzeStatueKind.strength => 'kongfu_strong_bronze',
            BronzeStatueKind.mage => 'kongfu_magic_bronze',
            BronzeStatueKind.agile => 'kongfu_agile_bronze',
          };
          final garg = bronzeGargMap[id];
          if (garg != null) addZombie(garg);
        }
      }
    }

    final renaiData = readRenaiModuleData(levelFile);
    if (renaiData != null) {
      final allStatues = [
        ...renaiData.statueInfos,
        ...renaiData.statueNightInfos,
      ];
      for (final s in allStatues) {
        final z = renaissanceStatueMap[_cleanId(s.typeName)];
        if (z != null) addZombie(z);
      }
    }

    final gladiator = readGladiatorRowModuleData(levelFile);
    if (gladiator != null) {
      for (final encounter in gladiator.encounters) {
        for (final spawn in encounter.spawns) {
          if (spawn.count > 0) addZombie(spawn.zombieType);
        }
      }
      for (final entry in gladiator.punishmentPool) {
        if (entry.weight > 0) addZombie(entry.zombieType);
      }
    }

    if (levelHasModule(levelFile, 'DropShipProperties')) {
      addZombie(skyCityImp);
    }

    if (levelHasModule(levelFile, 'GlacierModuleProperties')) {
      for (final obj in levelFile.objects) {
        if (obj.objClass == 'GlacierModuleProperties') {
          final data = obj.objData;
          if (data is Map) {
            final colData = data['ZombieSpawnData'];
            if (colData is List) {
              for (final col in colData) {
                if (col is List) {
                  for (final zEntry in col) {
                    if (zEntry is Map) {
                      final type = zEntry['TypeName'];
                      if (type is String) addZombie(type);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    for (final obj in levelFile.objects) {
      if (obj.objClass == 'ZombieType') {
        final aliases = obj.aliases;
        if (aliases != null && aliases.isNotEmpty) {
          addZombie(aliases.first);
        }
      }
    }

    return zombies;
  }

  static bool hasWaves(ParsedLevelData parsed) {
    final wm = parsed.waveManager;
    if (wm is WaveManagerData && wm.waves.isNotEmpty) {
      for (final wave in wm.waves) {
        if (wave.isNotEmpty) return true;
      }
    }

    final wg = parsed.waveGenerator;
    if (wg != null && wg.waves.isNotEmpty) {
      return true;
    }

    return false;
  }

  static Set<String> discoverEvents(ParsedLevelData parsed) {
    final events = <String>{};
    final wm = parsed.waveManager;
    if (wm is WaveManagerData) {
      for (final wave in wm.waves) {
        for (final rtid in wave) {
          final alias = LevelParser.extractAlias(rtid);
          final obj = parsed.objectMap[alias];
          if (obj != null) {
            events.add(obj.objClass);
          }
        }
      }
    }
    return events;
  }

  static void _extractFromWaveAction(
    PvzObject obj,
    Set<String> out,
    Set<String> customZombieAliases,
  ) {
    const skippedClasses = {
      'SpawnGravestonesWaveActionProps',
      'ModifyConveyorWaveActionProps',
      'ZombiePotionActionProps',
      'PumpkinHouseActionProps',
      'SpawnEagleFlagsWaveActionProps',
      'ThunderWaveActionProps',
      'ZombieAtlantisShellActionProps',
      'SpawnRocketLandingWaveActionProps',
      'GravityGeneratorWaveActionProps',
    };

    if (skippedClasses.contains(obj.objClass)) {
      return;
    }

    if (obj.objClass == 'RaidingPartyZombieSpawnerProps') {
      _addZombie('swashbuckler', out, customZombieAliases);
    }

    final data = obj.objData;
    if (data is! Map) return;

    if (obj.objClass == 'BungeeWaveActionProps') {
      final bungee = BungeeWaveActionData.normalizeJson(
        Map<String, dynamic>.from(data),
      );
      final name = bungee['zombieName'];
      if (name is String && name.isNotEmpty) {
        _addZombie(name, out, customZombieAliases);
      }
      return;
    }

    _scanForZombies(data, out, customZombieAliases);
  }

  static void _scanForZombies(
    dynamic d,
    Set<String> out,
    Set<String> customZombieAliases, {
    bool isZombieEntry = false,
  }) {
    if (d is Map) {
      // A single entry can contain both a transport/container `Type` and the
      // zombie carried inside it (for example a hamsterball). Inspect every
      // zombie-bearing field rather than stopping at the first match.
      const zombieTypeKeys = [
        'ZombieType',
        'ZombieName',
        'ZombieTypeName',
        'SpiderZombieName',
        'ZombieInsideBallType',
      ];
      for (final key in zombieTypeKeys) {
        final value = d[key];
        if (value is String && value.isNotEmpty) {
          _addZombie(value, out, customZombieAliases);
        }
      }
      // Generic Type/TypeName fields also describe tide directions, creature
      // containers and stat modifiers. Bare names are resources only inside
      // an explicitly named zombie collection, not throughout its descendants.
      for (final key in const ['Type', 'TypeName']) {
        final value = d[key];
        if (value is String &&
            (isZombieEntry || _isZombieReference(value, customZombieAliases))) {
          _addZombie(value, out, customZombieAliases);
        }
      }
      const zombieCollections = {
        'Zombies',
        'ZombiePool',
        'AddToZombiePool',
        'InitialZombiePlacements',
        'ZombieSpawnData',
      };
      for (final entry in d.entries) {
        _scanForZombies(
          entry.value,
          out,
          customZombieAliases,
          isZombieEntry: zombieCollections.contains(entry.key),
        );
      }
    } else if (d is List) {
      for (final e in d) {
        _scanForZombies(
          e,
          out,
          customZombieAliases,
          isZombieEntry: isZombieEntry,
        );
      }
    } else if (isZombieEntry && d is String) {
      _addZombie(d, out, customZombieAliases);
    }
  }

  static final _resourceReference = RegExp(r'^RTID\(([^@()]+)@([^@()]+)\)$');

  static bool _isZombieReference(
    String value,
    Set<String> customZombieAliases,
  ) {
    final reference = _resourceReference.firstMatch(value.trim());
    if (reference == null) return false;
    return reference.group(2) == 'ZombieTypes' ||
        (reference.group(2) == 'CurrentLevel' &&
            customZombieAliases.contains(reference.group(1)));
  }

  static void _addZombie(
    String id,
    Set<String> out,
    Set<String> customZombieAliases,
  ) {
    final value = id.trim();
    final reference = _resourceReference.firstMatch(value);
    if (reference != null) {
      // Keep the resource namespace until it has been classified. An unknown
      // grid item or plant need not be in the editor's catalogs to be excluded.
      final source = reference.group(2);
      if (source != 'ZombieTypes' &&
          !(source == 'CurrentLevel' &&
              customZombieAliases.contains(reference.group(1)))) {
        return;
      }
    } else if (value.startsWith('RTID(')) {
      return;
    }
    final clean = (reference?.group(1) ?? value).trim();
    // Some wave actions use the generic `Type` field for obstacles. Never let
    // an explicitly named grid item leak into the level's zombie summary,
    // even when it has not been added to the editor's grid-item catalog yet.
    final isGridItem =
        clean.toLowerCase().startsWith('griditem_') ||
        GridItemRepository.getByTypeName(clean) != null ||
        ReferenceRepository.instance.isKnownGridItem(clean);
    if (clean.isNotEmpty && !ignoredIds.contains(clean) && !isGridItem) {
      out.add(clean);
    }
  }

  static String _cleanId(String id) {
    if (id.contains('(') && id.contains('@')) {
      return LevelParser.extractAlias(id);
    }
    return id;
  }
}

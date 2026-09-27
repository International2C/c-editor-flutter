import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zombie_discovery.dart';

abstract final class CamelMinigameUtils {
  static const moduleClass = 'CamelMinigameProperties';
  static const memoryZombieTypes = {
    'camel_segment_touch',
    'camel_onehump_touch',
    'camel_twohump_touch',
    'camel_manyhump_touch',
  };

  static bool isMemoryZombie(String id, PvzLevelFile level) {
    final alias = RtidParser.parse(id)?.alias ?? id;
    for (final object in level.objects) {
      if (object.objClass != 'ZombieType' ||
          object.aliases?.contains(alias) != true ||
          object.objData is! Map) {
        continue;
      }
      final data = object.objData as Map;
      final zombieClass = data['ZombieClass'];
      if (zombieClass is String && zombieClass.isNotEmpty) {
        return zombieClass == 'ZombieCamelTouch';
      }
      return memoryZombieTypes.contains(data['TypeName']);
    }
    return memoryZombieTypes.contains(alias) ||
        ZombiePropertiesRepository.getZombieClassByAlias(alias) ==
            'ZombieCamelTouch';
  }

  /// Only inspect objects reachable from active modules and their wave events.
  /// Unused events, custom zombie definitions and stage defaults are not spawns.
  static List<String> incompatibleZombies(PvzLevelFile level) {
    final parsed = LevelParser.parseLevel(level);
    final local = {
      for (final object in level.objects)
        for (final alias in object.aliases ?? <String>[]) alias: object,
    };
    final reachable = <PvzObject>{};
    void visit(dynamic value) {
      if (value is Map) {
        for (final entry in value.entries) {
          if (entry.key == 'TargetRestriction' ||
              entry.key.toString().startsWith('#')) {
            continue;
          }
          visit(entry.value);
        }
      } else if (value is List) {
        for (final item in value) {
          visit(item);
        }
      } else if (value is String) {
        final rtid = RtidParser.parse(value);
        final object = rtid == null
            ? local[value]
            : switch (rtid.source) {
                'CurrentLevel' || '.' => local[rtid.alias],
                'LevelModules' => ReferenceRepository.instance.objectForAlias(
                  rtid.alias,
                ),
                _ => null,
              };
        if (object != null &&
            reachable.add(object) &&
            object.objClass != 'ZombieType') {
          visit(object.objData);
        }
      }
    }

    visit(parsed.levelDef?.modules ?? <String>[]);
    final active = PvzLevelFile(objects: reachable.toList());
    final zombies = ZombieDiscovery.discoverZombies(
      active,
      LevelParser.parseLevel(active),
    );
    // Seed rain and containers can also spawn zombies using explicit fields.
    void collectExplicitSpawns(dynamic value) {
      if (value is Map) {
        for (final entry in value.entries) {
          if (entry.key == 'TargetRestriction' ||
              entry.key.toString().startsWith('#')) {
            continue;
          }
          if (const {
            'ZombieTypeName',
            'ZombieTypesToSpawn',
            'ZombieInsideBallType',
          }.contains(entry.key)) {
            final id = entry.value;
            if (id is String && id.isNotEmpty) {
              zombies.add(RtidParser.parse(id)?.alias ?? id);
            }
          }
          collectExplicitSpawns(entry.value);
        }
      } else if (value is List) {
        for (final item in value) {
          collectExplicitSpawns(item);
        }
      }
    }

    for (final object in reachable) {
      if (object.objClass != 'ZombieType') {
        collectExplicitSpawns(object.objData);
      }
    }
    return zombies.where((id) => !isMemoryZombie(id, level)).toList()..sort();
  }
}

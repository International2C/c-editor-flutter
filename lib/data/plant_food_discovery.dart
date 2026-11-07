import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/level_escalation_runtime.dart';
import 'package:collection/collection.dart';

class PlantFoodDiscovery {
  static int calculateTotalPlantFood(
    PvzLevelFile levelFile,
    ParsedLevelData parsed,
  ) {
    int total = 0;

    if (parsed.waveGenerator != null) {
      for (final wave in parsed.waveGenerator!.waves) {
        final dynamic count = wave.spawnPlantFoodCount;
        if (count is num) total += count.toInt();
      }
    }

    final escalation = LevelEscalationRuntime.resolve(levelFile);
    if (escalation.isEffective) {
      total += escalation.data!.plantfoodToSpawnCount.clamp(0, 1 << 31);
    }

    final wm = parsed.waveManager;
    if (wm != null) {
      for (final wave in wm.waves) {
        for (final rtid in wave) {
          final alias = LevelParser.extractAlias(rtid);
          final obj = parsed.objectMap[alias];
          if (obj != null && obj.objData is Map) {
            final data = obj.objData as Map;

            final dynamic addPf =
                data['AdditionalPlantfood'] ?? data['AdditionalPlantFood'];
            if (addPf is num) total += addPf.toInt();

            final drops = data['SpawnPlantName'] as List?;
            if (drops != null) {
              total += drops
                  .where((e) => e == 'plantfood' || e == 'tool_plantfood')
                  .length;
            }

            if (obj.objClass == 'SpawnGravestonesWaveActionProps') {
              final pool = data['GravestonePool'] as List?;
              if (pool != null) {
                for (var item in pool) {
                  if (item is Map) {
                    final type = item['Type'];
                    final count = item['Count'] ?? 1;
                    if (_isPfItem(type)) {
                      total += (count as num).toInt();
                    }
                  }
                }
              }
            }

            if (obj.objClass == 'ModifyConveyorWaveActionProps') {
              final adds = data['Add'] as List?;
              if (adds != null) {
                for (var item in adds) {
                  if (item is Map) {
                    final type = item['Type'] ?? item['ToolType'];
                    if (type == 'plantfood' || type == 'tool_plantfood') {
                      total += 1;
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
      if (obj.objClass == 'InitialGridItemProperties') {
        final data = obj.objData;
        if (data is Map) {
          final list = data['InitialGridItemPlacements'] ?? data['GridItems'];
          if (list is List) {
            for (final e in list) {
              if (e is Map) {
                final type = e['TypeName'] ?? e['GridItemType'];
                if (_isPfItem(type)) {
                  total += 1;
                }
              }
            }
          }
        }
      }
    }

    final energyData = readEnergyGridModuleData(levelFile);
    if (energyData != null) {
      for (final over in energyData.overrides) {
        total += over.itemList.length;
      }
    }

    return total;
  }

  static bool _isPfItem(dynamic type) {
    if (type is! String) return false;
    const pfItems = {
      'gravestonePlantfoodOnDestruction',
      'tool_plantfood',
      'plantfood',
    };
    return pfItems.contains(type);
  }

  static int getStartingPlantFood(
    PvzLevelFile levelFile,
    ParsedLevelData parsed,
  ) {
    int pf = 0;
    final mutator = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'LevelMutatorStartingPlantfoodProps',
    );
    if (mutator != null && mutator.objData is Map) {
      final data = mutator.objData as Map;
      final raw =
          data['StartingPlantfoodOverride'] ?? data['StartingPlantfood'] ?? 0;
      if (raw is num) pf = raw.toInt();
    } else {
      final ls = levelFile.objects.firstWhereOrNull(
        (o) =>
            o.objClass == 'LastStandMinigameProperties' ||
            o.objClass == 'ZombossLastStandMinigameProperties',
      );
      if (ls != null && ls.objData is Map) {
        final raw = (ls.objData as Map)['StartingPlantfood'] ?? 0;
        if (raw is num) pf = raw.toInt();
      }
    }
    return pf;
  }
}

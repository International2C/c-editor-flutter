import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/utils/target_zombie_check.dart';

abstract final class OakTrainUtils {
  static bool needsOxygenSupport(PvzLevelFile level) {
    final cls = LevelParser.resolveStagePropertiesObjclass(
      LevelParser.parseLevel(level).levelDef,
      level,
    );
    return LevelParser.isDeepSeaStageObjclass(cls) ||
        cls == 'MoonStageProperties';
  }

  static bool hasIncompatibleTargets(PvzObject event) {
    if (!const {
      'SpawnZombiesJitteredWaveActionProps',
      'SpawnZombiesFishWaveActionProps',
    }.contains(event.objClass)) {
      return false;
    }
    if (event.objData is! Map) return false;
    final zombies = (event.objData as Map)['Zombies'];
    if (zombies is! List) return false;
    return zombies.any((z) {
      if (z is! Map || z['Type'] is! String) return false;
      final type = z['Type'] as String;
      final rtid = RtidParser.parse(type);
      // Custom variants may deliberately implement different abilities.
      if (rtid != null && rtid.source != 'ZombieTypes') return false;
      return isTargetZombie(rtid?.alias ?? type);
    });
  }

  static bool hasIncompatibleWaveSpawns(PvzLevelFile level) {
    final parsed = LevelParser.parseLevel(level);
    final manager = parsed.waveManager;
    if (manager is! WaveManagerData) return false;
    return manager.waves.expand((wave) => wave).any((rtid) {
      final alias = RtidParser.parse(rtid)?.alias ?? rtid;
      final event = parsed.objectMap[alias];
      return event != null && hasIncompatibleTargets(event);
    });
  }
}

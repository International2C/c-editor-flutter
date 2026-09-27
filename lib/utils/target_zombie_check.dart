import 'package:c_editor/data/pvz_models.dart';

bool isTargetZombie(String id) {
  return id.startsWith('zombie_target_arrow') ||
      id.startsWith('zombie_target_bottle') ||
      id.startsWith('zombie_target_wizard') ||
      id.startsWith('zombie_target_archmage') ||
      id.startsWith('zombie_target_gargantuar');
}

final _camelTouchPattern = RegExp(r'^camel_.*_touch$');

bool isCamelTouchZombie(String id) => _camelTouchPattern.hasMatch(id);

bool hasOakTrain(PvzLevelFile levelFile) {
  return levelFile.objects.any((o) => o.objClass == 'OakTrainProperties');
}

bool isTargetZombieBlocked(String selectedId, PvzLevelFile levelFile) {
  return isTargetZombie(selectedId) && !hasOakTrain(levelFile);
}

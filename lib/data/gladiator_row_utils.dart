import 'package:c_editor/data/pvz_models.dart';

/// Stored Wave is zero-based; the timeline labels its first wave as 1.
List<GladiatorEncounterData> gladiatorEncountersForWave(
  GladiatorRowModulePropertiesData data,
  int timelineWave,
) => data.encounters.where((e) => e.wave == timelineWave - 1).toList();

GladiatorRowModulePropertiesData? readGladiatorRowModuleData(
  PvzLevelFile level,
) {
  for (final object in level.objects) {
    if (object.objClass == 'GladiatorRowModuleProperties' &&
        object.objData is Map) {
      return GladiatorRowModulePropertiesData.fromJson(
        Map<String, dynamic>.from(object.objData as Map),
      );
    }
  }
  return null;
}

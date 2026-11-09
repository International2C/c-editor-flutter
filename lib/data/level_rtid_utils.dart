import 'package:c_editor/data/pvz_models.dart';

/// Replaces RTID string references across all level objects.
abstract final class LevelRtidUtils {
  static void replaceReferences(
    PvzLevelFile levelFile,
    String oldRtid,
    String newRtid,
  ) {
    if (oldRtid == newRtid) return;
    for (final obj in levelFile.objects) {
      obj.objData = replaceInValue(obj.objData, oldRtid, newRtid);
    }
  }

  static dynamic replaceInValue(dynamic value, String oldRtid, String newRtid) {
    if (value == oldRtid) return newRtid;
    if (value is List) {
      return [for (final item in value) replaceInValue(item, oldRtid, newRtid)];
    }
    if (value is Map<String, dynamic>) {
      return <String, dynamic>{
        for (final entry in value.entries)
          entry.key: replaceInValue(entry.value, oldRtid, newRtid),
      };
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key: replaceInValue(entry.value, oldRtid, newRtid),
      };
    }
    return value;
  }
}

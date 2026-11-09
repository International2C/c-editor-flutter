import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Helpers for the independent `ZombieJitterOffsets` presets referenced by
/// wave events.
abstract final class JitterOffsetsUtils {
  static const objectClass = 'ZombieJitterOffsets';

  static ZombieJitterOffsetsData dataOf(PvzObject preset) {
    final data = preset.objData;
    if (data is ZombieJitterOffsetsData) return data;
    if (data is Map) {
      return ZombieJitterOffsetsData.fromJson(Map<String, dynamic>.from(data));
    }
    return ZombieJitterOffsetsData();
  }

  /// The game's random-offset routine requires a positive upper bound.
  ///
  /// A negative cumulative increment remains editable because it is accepted
  /// by the level format, but once the row accumulator plus its random value is
  /// below zero the game's unsigned conversion can produce an abnormally large
  /// X coordinate. A non-positive random upper bound is always invalid for the
  /// same positioning routine and does not disable randomness.
  static bool isDataValid(ZombieJitterOffsetsData data) =>
      data.randomJitter > 0;

  static bool isPresetValid(PvzObject preset) => isDataValid(dataOf(preset));

  static List<PvzObject> listPresets(PvzLevelFile levelFile) => levelFile
      .objects
      .where((object) => object.objClass == objectClass)
      .toList();

  static List<PvzObject> findReferrers(PvzLevelFile levelFile, String alias) {
    return levelFile.objects.where((object) {
      if (object.objData is! Map) return false;
      final data = Map<String, dynamic>.from(object.objData as Map);
      final rtid = data['JitterOffsets'];
      if (rtid is! String) return false;
      final info = RtidParser.parse(rtid);
      return info?.source == 'CurrentLevel' && info?.alias == alias;
    }).toList();
  }

  static int unreferencedCount(PvzLevelFile levelFile) =>
      listPresets(levelFile).where((preset) {
        final aliases = preset.aliases;
        final alias = aliases == null || aliases.isEmpty ? '' : aliases.first;
        return alias.isEmpty || findReferrers(levelFile, alias).isEmpty;
      }).length;

  static String nextAlias(PvzLevelFile levelFile) {
    final taken = levelFile.objects
        .expand((object) => object.aliases ?? const <String>[])
        .toSet();
    var index = 0;
    while (true) {
      final candidate = index == 0 ? 'Offsets' : 'Offsets$index';
      if (!taken.contains(candidate)) return candidate;
      index++;
    }
  }

  static int renamePresetReferences(
    PvzLevelFile levelFile,
    String oldAlias,
    String newAlias,
  ) {
    var changed = 0;
    for (final referrer in findReferrers(levelFile, oldAlias)) {
      final data = Map<String, dynamic>.from(referrer.objData as Map);
      final info = RtidParser.parse(data['JitterOffsets'] as String);
      data['JitterOffsets'] = RtidParser.build(
        newAlias,
        info?.source ?? 'CurrentLevel',
      );
      referrer.objData = data;
      changed++;
    }
    return changed;
  }
}

import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/BungeeWaveTargetData.dart';

class BungeeWaveActionData extends PvzModel {
  BungeeWaveActionData({
    BungeeWaveTargetData? target,
    this.zombieName = 'tutorial',
    this.level = 1,
  }) : target = target ?? BungeeWaveTargetData();

  BungeeWaveTargetData target;
  String zombieName;
  int level;

  /// Migrate legacy editor keys without changing other event data.
  /// If both spellings exist, the official lower-case key takes precedence.
  static Map<String, dynamic> normalizeJson(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);
    for (final entry in const {
      'Target': 'target',
      'ZombieName': 'zombieName',
    }.entries) {
      if (!result.containsKey(entry.key)) continue;
      if (!result.containsKey(entry.value)) {
        result[entry.value] = result[entry.key];
      }
      result.remove(entry.key);
    }
    return result;
  }

  factory BungeeWaveActionData.fromJson(Map<String, dynamic> json) {
    final data = normalizeJson(json);
    final t = data['target'];
    return BungeeWaveActionData(
      target: t is Map<String, dynamic>
          ? BungeeWaveTargetData.fromJson(t)
          : BungeeWaveTargetData(),
      zombieName: data['zombieName'] as String? ?? '',
      level: data['Level'] as int? ?? 1,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'target': target.toJson(),
    'zombieName': zombieName,
    'Level': level,
  };
}

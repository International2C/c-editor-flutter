import 'package:c_editor/data/pvz_models/PvzModel.dart';

/// One weighted zombie entry inside a tent (`ZombieTypesToSpawn` item).
class ZombieTentSpawnEntryData extends PvzModel {
  ZombieTentSpawnEntryData({
    this.zombieTypeName = '',
    this.weight = 10,
    this.level = 0,
  });

  String zombieTypeName;
  num weight;
  int level;

  factory ZombieTentSpawnEntryData.fromJson(Map<String, dynamic> json) {
    return ZombieTentSpawnEntryData(
      zombieTypeName: json['ZombieTypeName'] as String? ?? '',
      weight: _parseNum(json['Weight']) ?? 10,
      level: _parseInt(json['Level']) ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'ZombieTypeName': zombieTypeName,
    'Weight': weight,
    'Level': level,
  };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

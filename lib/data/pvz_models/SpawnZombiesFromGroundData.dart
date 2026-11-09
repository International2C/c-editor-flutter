import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/ZombieSpawnData.dart';

class SpawnZombiesFromGroundData extends PvzModel {
  SpawnZombiesFromGroundData({
    this.jitterOffsets,
    this.zombieSpawnPattern,
    this.fixedOffset,
    this.columnStart = 6,
    this.columnEnd = 9,
    this.additionalPlantFood,
    this.spawnPlantName,
    this.zombies = const [],
  });

  /// Imported compatibility field; the ground-rise positioning path ignores it.
  String? jitterOffsets;

  /// Imported compatibility field; ignored by the ground-rise positioning path.
  String? zombieSpawnPattern;

  /// Preserved when round-tripping JSON, but not used by ground-rise actions.
  num? fixedOffset;
  int columnStart;
  int columnEnd;
  int? additionalPlantFood;
  List<String>? spawnPlantName;
  List<ZombieSpawnData> zombies;

  factory SpawnZombiesFromGroundData.fromJson(Map<String, dynamic> json) {
    return SpawnZombiesFromGroundData(
      jitterOffsets: json['JitterOffsets'] as String?,
      zombieSpawnPattern: json['ZombieSpawnPattern'] as String?,
      fixedOffset: json['FixedOffset'] as num?,
      columnStart: json['ColumnStart'] as int? ?? 6,
      columnEnd: json['ColumnEnd'] as int? ?? 9,
      additionalPlantFood: json['AdditionalPlantfood'] as int?,
      spawnPlantName: (json['SpawnPlantName'] as List<dynamic>?)
          ?.cast<String>(),
      zombies:
          (json['Zombies'] as List<dynamic>?)?.map((e) {
            if (e is Map<String, dynamic>) {
              return ZombieSpawnData.fromJson(e);
            }
            if (e is String) {
              return ZombieSpawnData(type: e);
            }
            return ZombieSpawnData();
          }).toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'ColumnStart': columnStart,
      'ColumnEnd': columnEnd,
      'Zombies': zombies.map((e) => e.toJson()).toList(),
    };
    if (jitterOffsets?.isNotEmpty == true) {
      data['JitterOffsets'] = jitterOffsets;
    }
    if (zombieSpawnPattern?.isNotEmpty == true) {
      data['ZombieSpawnPattern'] = zombieSpawnPattern;
    }
    if (fixedOffset != null) {
      data['FixedOffset'] = fixedOffset;
    }
    if (additionalPlantFood != null) {
      data['AdditionalPlantfood'] = additionalPlantFood;
    }
    if (spawnPlantName != null) {
      data['SpawnPlantName'] = spawnPlantName;
    }
    return data;
  }
}

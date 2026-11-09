import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/ZombieSpawnData.dart';

class WaveActionData extends PvzModel {
  WaveActionData({
    this.jitterOffsets,
    this.zombieSpawnPattern,
    this.fixedOffset,
    this.notificationEvents,
    this.additionalPlantFood,
    this.spawnPlantName,
    this.zombies = const [],
  });

  String? jitterOffsets;
  String? zombieSpawnPattern;
  num? fixedOffset;
  List<String>? notificationEvents;
  int? additionalPlantFood;
  List<String>? spawnPlantName;
  List<ZombieSpawnData> zombies;

  factory WaveActionData.fromJson(Map<String, dynamic> json) {
    return WaveActionData(
      jitterOffsets: json['JitterOffsets'] as String?,
      zombieSpawnPattern: json['ZombieSpawnPattern'] as String?,
      fixedOffset: json['FixedOffset'] as num?,
      notificationEvents: (json['NotificationEvents'] as List<dynamic>?)
          ?.cast<String>(),
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
    if (notificationEvents != null) {
      data['NotificationEvents'] = notificationEvents;
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

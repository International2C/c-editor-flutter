import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/FishSpawnData.dart';
import 'package:c_editor/data/pvz_models/ZombieSpawnData.dart';

class SpawnZombiesFishWaveActionPropsData extends PvzModel {
  SpawnZombiesFishWaveActionPropsData({
    this.jitterOffsets,
    this.zombieSpawnPattern,
    this.fixedOffset,
    this.notificationEvents,
    this.additionalPlantFood,
    this.spawnPlantName,
    this.zombies = const [],
    this.fishes = const [],
  });

  /// Applied only to [zombies]; [fishes] use a separate positioning path.
  String? jitterOffsets;
  String? zombieSpawnPattern;
  num? fixedOffset;
  List<String>? notificationEvents;
  int? additionalPlantFood;
  List<String>? spawnPlantName;
  List<ZombieSpawnData> zombies;
  List<FishSpawnData> fishes;

  factory SpawnZombiesFishWaveActionPropsData.fromJson(
    Map<String, dynamic> json,
  ) {
    final zombiesRaw = json['Zombies'] as List<dynamic>? ?? [];
    final fishesRaw = json['Fishes'] as List<dynamic>? ?? [];
    return SpawnZombiesFishWaveActionPropsData(
      jitterOffsets: json['JitterOffsets'] as String?,
      zombieSpawnPattern: json['ZombieSpawnPattern'] as String?,
      fixedOffset: json['FixedOffset'] as num?,
      notificationEvents: (json['NotificationEvents'] as List<dynamic>?)
          ?.cast<String>(),
      additionalPlantFood: json['AdditionalPlantfood'] as int?,
      spawnPlantName: (json['SpawnPlantName'] as List<dynamic>?)
          ?.cast<String>(),
      zombies: zombiesRaw.map((e) {
        if (e is Map<String, dynamic>) return ZombieSpawnData.fromJson(e);
        if (e is String) return ZombieSpawnData(type: e);
        return ZombieSpawnData();
      }).toList(),
      fishes: fishesRaw
          .map((e) => FishSpawnData.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'Zombies': zombies.map((e) => e.toJson()).toList(),
    };
    if (jitterOffsets?.isNotEmpty == true) {
      m['JitterOffsets'] = jitterOffsets;
    }
    if (zombieSpawnPattern?.isNotEmpty == true) {
      m['ZombieSpawnPattern'] = zombieSpawnPattern;
    }
    if (fixedOffset != null) {
      m['FixedOffset'] = fixedOffset;
    }
    if (notificationEvents != null) {
      m['NotificationEvents'] = notificationEvents;
    }
    if (additionalPlantFood != null) {
      m['AdditionalPlantfood'] = additionalPlantFood;
    }
    if (spawnPlantName != null) m['SpawnPlantName'] = spawnPlantName;
    if (fishes.isNotEmpty) m['Fishes'] = fishes.map((e) => e.toJson()).toList();
    return m;
  }
}

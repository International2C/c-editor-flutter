import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/ZombieSpawnData.dart';

class SpawnZombiesFromGridItemData extends PvzModel {
  SpawnZombiesFromGridItemData({
    this.waveStartMessage,
    this.zombieSpawnWaitTime = 0,
    this.jitterOffsets,
    this.zombieSpawnPattern,
    this.fixedOffset = 0,
    this.gridTypes = const [],
    this.zombies = const [],
  });

  String? waveStartMessage;
  int zombieSpawnWaitTime;

  /// The obstacle-rise positioning path ignores these three imported fields.
  /// Preserve them when editing other properties of an existing event.
  String? jitterOffsets;
  String? zombieSpawnPattern;
  double fixedOffset;
  List<String> gridTypes;
  List<ZombieSpawnData> zombies;

  SpawnZombiesFromGridItemData copyWith({
    String? waveStartMessage,
    bool clearWaveStartMessage = false,
    int? zombieSpawnWaitTime,
    String? jitterOffsets,
    bool clearJitterOffsets = false,
    String? zombieSpawnPattern,
    bool clearZombieSpawnPattern = false,
    double? fixedOffset,
    List<String>? gridTypes,
    List<ZombieSpawnData>? zombies,
  }) {
    return SpawnZombiesFromGridItemData(
      waveStartMessage: clearWaveStartMessage
          ? null
          : (waveStartMessage ?? this.waveStartMessage),
      zombieSpawnWaitTime: zombieSpawnWaitTime ?? this.zombieSpawnWaitTime,
      jitterOffsets: clearJitterOffsets
          ? null
          : (jitterOffsets ?? this.jitterOffsets),
      zombieSpawnPattern: clearZombieSpawnPattern
          ? null
          : (zombieSpawnPattern ?? this.zombieSpawnPattern),
      fixedOffset: fixedOffset ?? this.fixedOffset,
      gridTypes: gridTypes ?? this.gridTypes,
      zombies: zombies ?? this.zombies,
    );
  }

  factory SpawnZombiesFromGridItemData.fromJson(Map<String, dynamic> json) {
    return SpawnZombiesFromGridItemData(
      waveStartMessage: json['WaveStartMessage'] as String?,
      zombieSpawnWaitTime: json['ZombieSpawnWaitTime'] as int? ?? 0,
      jitterOffsets: json['JitterOffsets'] as String?,
      zombieSpawnPattern: json['ZombieSpawnPattern'] as String?,
      fixedOffset: (json['FixedOffset'] as num?)?.toDouble() ?? 0,
      gridTypes: (json['GridTypes'] as List<dynamic>?)?.cast<String>() ?? [],
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
      'ZombieSpawnWaitTime': zombieSpawnWaitTime,
      'GridTypes': gridTypes,
      'Zombies': zombies.map((e) => e.toJson()).toList(),
    };
    if (waveStartMessage != null) data['WaveStartMessage'] = waveStartMessage;
    if (jitterOffsets?.isNotEmpty == true) {
      data['JitterOffsets'] = jitterOffsets;
    }
    if (zombieSpawnPattern?.isNotEmpty == true) {
      data['ZombieSpawnPattern'] = zombieSpawnPattern;
    }
    if (fixedOffset != 0) data['FixedOffset'] = fixedOffset;
    return data;
  }
}

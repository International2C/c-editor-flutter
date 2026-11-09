import 'package:c_editor/data/pvz_models/PvzModel.dart';

/// LevelEscalationModuleProperties — point/flag based difficulty escalation.
class LevelEscalationModuleData extends PvzModel {
  LevelEscalationModuleData({
    this.flagCount = 3,
    this.wavesPerFlag = 4,
    this.startingPoints = 100,
    this.pointIncrementPerWave = 75,
    this.plantfoodToSpawnCount = 4,
    this.waveManagerProps,
    List<String>? zombiePool,
  }) : zombiePool = zombiePool ?? <String>[];

  int flagCount;
  int wavesPerFlag;
  int startingPoints;
  int pointIncrementPerWave;
  int plantfoodToSpawnCount;
  String? waveManagerProps;
  List<String> zombiePool;

  int get totalWaves => flagCount * wavesPerFlag;

  factory LevelEscalationModuleData.fromJson(Map<String, dynamic> json) {
    return LevelEscalationModuleData(
      flagCount: json['FlagCount'] as int? ?? 3,
      wavesPerFlag: json['WavesPerFlag'] as int? ?? 4,
      startingPoints: json['StartingPoints'] as int? ?? 100,
      pointIncrementPerWave: json['PointIncrementPerWave'] as int? ?? 75,
      plantfoodToSpawnCount: json['PlantfoodToSpawnCount'] as int? ?? 4,
      waveManagerProps: json['WaveManagerProps'] as String?,
      zombiePool:
          (json['ZombiePool'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'FlagCount': flagCount,
    'WavesPerFlag': wavesPerFlag,
    'StartingPoints': startingPoints,
    'PointIncrementPerWave': pointIncrementPerWave,
    'PlantfoodToSpawnCount': plantfoodToSpawnCount,
    if (waveManagerProps != null) 'WaveManagerProps': waveManagerProps,
    'ZombiePool': zombiePool,
  };
}

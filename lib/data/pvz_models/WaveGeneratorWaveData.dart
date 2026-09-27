import 'package:c_editor/data/pvz_models/PvzModel.dart';
import 'package:c_editor/data/pvz_models/WaveGeneratorPoolEntryData.dart';
import 'package:c_editor/data/pvz_models/WaveGeneratorZombieEntryData.dart';

class WaveGeneratorWaveData extends PvzModel {
  WaveGeneratorWaveData({
    this.disableRandomSpawns = true,
    this.zombies = const [],
    this.spawnPlantFoodCount,
    this.addToZombiePool = const [],
    this.wavePointStart,
    this.wavePointIncrement,
    this.wavePointOverride,
    this.colNumPlantIsDragged,
    this.waitUntilAllZombiesDie,
    this.waveSpawnTime,
  });

  bool disableRandomSpawns;
  List<WaveGeneratorZombieEntryData> zombies;
  int? spawnPlantFoodCount;
  List<WaveGeneratorPoolEntryData> addToZombiePool;
  int? wavePointStart;
  int? wavePointIncrement;
  bool? wavePointOverride;

  /// Built-in black hole event column count for this wave.
  int? colNumPlantIsDragged;
  bool? waitUntilAllZombiesDie;
  num? waveSpawnTime;

  factory WaveGeneratorWaveData.fromJson(Map<String, dynamic> json) {
    return WaveGeneratorWaveData(
      disableRandomSpawns: json['DisableRandomSpawns'] as bool? ?? true,
      zombies:
          (json['Zombies'] as List<dynamic>?)
              ?.map(
                (e) => WaveGeneratorZombieEntryData.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
      spawnPlantFoodCount: json['SpawnPlantFoodCount'] as int?,
      addToZombiePool:
          (json['AddToZombiePool'] as List<dynamic>?)
              ?.map(
                (e) => WaveGeneratorPoolEntryData.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
      wavePointStart: json['WavePointStart'] as int?,
      wavePointIncrement: json['WavePointIncrement'] as int?,
      wavePointOverride: json['WavePointOverride'] as bool?,
      colNumPlantIsDragged: json['ColNumPlantIsDragged'] as int?,
      waitUntilAllZombiesDie: json['WaitUntilAllZombiesDie'] as bool?,
      waveSpawnTime: json['WaveSpawnTime'] as num?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'DisableRandomSpawns': disableRandomSpawns,
      'Zombies': zombies.map((z) => z.toJson()).toList(),
    };
    if (spawnPlantFoodCount != null) {
      data['SpawnPlantFoodCount'] = spawnPlantFoodCount;
    }
    if (addToZombiePool.isNotEmpty) {
      data['AddToZombiePool'] = addToZombiePool.map((e) => e.toJson()).toList();
    }
    if (wavePointStart != null) data['WavePointStart'] = wavePointStart;
    if (wavePointIncrement != null) {
      data['WavePointIncrement'] = wavePointIncrement;
    }
    if (wavePointOverride != null) {
      data['WavePointOverride'] = wavePointOverride;
    }
    if (colNumPlantIsDragged != null) {
      data['ColNumPlantIsDragged'] = colNumPlantIsDragged;
    }
    if (waitUntilAllZombiesDie != null) {
      data['WaitUntilAllZombiesDie'] = waitUntilAllZombiesDie;
    }
    if (waveSpawnTime != null) data['WaveSpawnTime'] = waveSpawnTime;
    return data;
  }
}

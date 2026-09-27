import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/Point2D.dart';
import 'package:c_editor/data/pvz_models/Point3DDouble.dart';
import 'package:c_editor/data/pvz_models/RectData.dart';
import 'package:c_editor/data/pvz_models/ZombieResilienceData.dart';

class ZombiePropertySheetData extends PvzModel {
  ZombiePropertySheetData({
    this.hitpoints = 0.0,
    this.speed = 0.0,
    this.speedVariance,
    this.eatDPS = 0.0,
    this.weight = 0,
    this.wavePointCost = 0,
    this.sizeType,
    this.hitRect,
    this.attackRect,
    this.artCenter,
    this.shadowOffset,
    this.groundTrackName = '',
    this.canSpawnPlantFood = false,
    this.canSurrender,
    this.enableShowHealthBarByDamage,
    this.canBePlantTossedweak,
    this.canBePlantTossedStrong,
    this.canBeLaunchedByPlants,
    this.drawHealthBarTime,
    this.enableEliteImmunities,
    this.enableEliteScale,
    this.canTriggerZombieWin,
    this.chillInsteadOfFreeze,
    this.eliteScale,
    this.armDropFraction,
    this.headDropFraction,
    this.resilience,
  });

  /// Resilience: RTID string (e.g. RTID(ResilienceFire2@ResilienceConfig))
  /// or embedded ZombieResilienceData for custom config.
  Object? resilience;

  /// Returns the resilience RTID string if using a preset, null otherwise.
  String? get resilienceRtid =>
      resilience is String ? resilience as String : null;

  /// Returns embedded custom resilience data, null if using preset or disabled.
  ZombieResilienceData? get resilienceCustom =>
      resilience is ZombieResilienceData
      ? resilience as ZombieResilienceData
      : null;

  double hitpoints;
  double speed;
  double? speedVariance;
  double eatDPS;
  int weight;
  int wavePointCost;
  String? sizeType;
  RectData? hitRect;
  RectData? attackRect;
  Point2D? artCenter;
  Point3DDouble? shadowOffset;
  String groundTrackName;
  bool canSpawnPlantFood;
  bool? canSurrender;
  bool? enableShowHealthBarByDamage;
  bool? canBePlantTossedweak;
  bool? canBePlantTossedStrong;
  bool? canBeLaunchedByPlants;
  double? drawHealthBarTime;
  bool? enableEliteImmunities;
  bool? enableEliteScale;
  bool? canTriggerZombieWin;
  bool? chillInsteadOfFreeze;
  double? eliteScale;
  double? armDropFraction;
  double? headDropFraction;

  factory ZombiePropertySheetData.fromJson(Map<String, dynamic> json) {
    return ZombiePropertySheetData(
      hitpoints: (json['Hitpoints'] as num?)?.toDouble() ?? 0.0,
      speed: (json['Speed'] as num?)?.toDouble() ?? 0.0,
      speedVariance: (json['SpeedVariance'] as num?)?.toDouble(),
      eatDPS: (json['EatDPS'] as num?)?.toDouble() ?? 0.0,
      weight: (json['Weight'] as num?)?.toInt() ?? 0,
      wavePointCost: (json['WavePointCost'] as num?)?.toInt() ?? 0,
      sizeType: json['SizeType'] as String?,
      hitRect: json['HitRect'] is Map<String, dynamic>
          ? RectData.fromJson(json['HitRect'] as Map<String, dynamic>)
          : null,
      attackRect: json['AttackRect'] is Map<String, dynamic>
          ? RectData.fromJson(json['AttackRect'] as Map<String, dynamic>)
          : null,
      artCenter: json['ArtCenter'] is Map<String, dynamic>
          ? Point2D.fromJson(json['ArtCenter'] as Map<String, dynamic>)
          : null,
      shadowOffset: json['ShadowOffset'] is Map<String, dynamic>
          ? Point3DDouble.fromJson(json['ShadowOffset'] as Map<String, dynamic>)
          : null,
      groundTrackName: json['GroundTrackName'] as String? ?? '',
      canSpawnPlantFood: json['CanSpawnPlantFood'] as bool? ?? false,
      canSurrender: json['CanSurrender'] as bool?,
      enableShowHealthBarByDamage: json['EnableShowHealthBarByDamage'] as bool?,
      canBePlantTossedweak: json['CanBePlantTossedweak'] as bool?,
      canBePlantTossedStrong: json['CanBePlantTossedStrong'] as bool?,
      canBeLaunchedByPlants: json['CanBeLaunchedByPlants'] as bool?,
      drawHealthBarTime: (json['DrawHealthBarTime'] as num?)?.toDouble(),
      enableEliteImmunities: json['EnableEliteImmunities'] as bool?,
      enableEliteScale: json['EnableEliteScale'] as bool?,
      canTriggerZombieWin: json['CanTriggerZombieWin'] as bool?,
      chillInsteadOfFreeze: json['ChillInsteadOfFreeze'] as bool?,
      eliteScale: (json['EliteScale'] as num?)?.toDouble(),
      armDropFraction: (json['ArmDropFraction'] as num?)?.toDouble(),
      headDropFraction: (json['HeadDropFraction'] as num?)?.toDouble(),
      resilience: () {
        final r = json['Resilience'];
        if (r == null) return null;
        if (r is String) return r;
        if (r is Map) {
          return ZombieResilienceData.fromJson(Map<String, dynamic>.from(r));
        }
        return null;
      }(),
    );
  }

  Map<String, dynamic> toJson() => {
    'Hitpoints': hitpoints,
    'Speed': speed,
    if (speedVariance != null) 'SpeedVariance': speedVariance,
    'EatDPS': eatDPS,
    'Weight': weight,
    'WavePointCost': wavePointCost,
    if (sizeType != null) 'SizeType': sizeType,
    if (hitRect != null) 'HitRect': hitRect!.toJson(),
    if (attackRect != null) 'AttackRect': attackRect!.toJson(),
    if (artCenter != null) 'ArtCenter': artCenter!.toJson(),
    if (shadowOffset != null) 'ShadowOffset': shadowOffset!.toJson(),
    'GroundTrackName': groundTrackName,
    'CanSpawnPlantFood': canSpawnPlantFood,
    if (canSurrender != null) 'CanSurrender': canSurrender,
    if (enableShowHealthBarByDamage != null)
      'EnableShowHealthBarByDamage': enableShowHealthBarByDamage,
    if (canBePlantTossedweak != null)
      'CanBePlantTossedweak': canBePlantTossedweak,
    if (canBePlantTossedStrong != null)
      'CanBePlantTossedStrong': canBePlantTossedStrong,
    if (canBeLaunchedByPlants != null)
      'CanBeLaunchedByPlants': canBeLaunchedByPlants,
    if (drawHealthBarTime != null) 'DrawHealthBarTime': drawHealthBarTime,
    if (enableEliteImmunities != null)
      'EnableEliteImmunities': enableEliteImmunities,
    if (enableEliteScale != null) 'EnableEliteScale': enableEliteScale,
    if (canTriggerZombieWin != null) 'CanTriggerZombieWin': canTriggerZombieWin,
    if (chillInsteadOfFreeze != null)
      'ChillInsteadOfFreeze': chillInsteadOfFreeze,
    if (eliteScale != null) 'EliteScale': eliteScale,
    if (armDropFraction != null) 'ArmDropFraction': armDropFraction,
    if (headDropFraction != null) 'HeadDropFraction': headDropFraction,
    if (resilience != null)
      'Resilience': resilience is ZombieResilienceData
          ? (resilience as ZombieResilienceData).toJson()
          : resilience,
  };
}

/// ZombieResilience (armor) config. Excludes AnimLabels.

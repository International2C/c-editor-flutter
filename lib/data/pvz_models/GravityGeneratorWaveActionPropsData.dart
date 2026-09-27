import 'package:c_editor/data/pvz_models/PvzModel.dart';
import 'package:c_editor/data/pvz_models/RectData.dart';
import 'package:c_editor/data/pvz_models/TileLocationData.dart';

class GravityGeneratorWaveActionPropsData extends PvzModel {
  GravityGeneratorWaveActionPropsData({
    Map<String, num>? parameters,
    this.gravityLevel = 'anti',
    this.targetType = 'plant',
    RectData? range,
    this.targetGrid,
    List<String>? targetRestriction,
    this.warningMessage = '',
    Map<String, dynamic>? extraData,
  }) : parameters = {...parameterDefaults, ...?parameters},
       range = range ?? RectData(mX: -1, mY: 0, mWidth: 3, mHeight: 1),
       targetRestriction = targetRestriction ?? [],
       _extraData = extraData ?? {};

  // Defaults follow the supplied MOON14_B / MOON22 events.
  static const parameterDefaults = <String, num>{
    'ActivationDelay': 0,
    'Duration': 8,
    'DeployDuration': 1,
    'ChargeDuration': 2,
    'RetractDuration': 5,
    'PlantExitDelay': 6,
    'ZombieRiseDuration': 1.5,
    'ZombieTranslateDuration': 4,
    'ZombieFallDuration': 0.7,
    'ZombieLiftHeight': 100,
    'ZombieForwardDistance': 64,
    'HeavyPlantSinkDuration': 0.5,
  };

  final Map<String, num> parameters;
  num parameter(String key) => parameters[key] ?? parameterDefaults[key]!;
  String gravityLevel;
  String targetType;
  RectData range;
  TileLocationData? targetGrid;
  List<String> targetRestriction;
  // Imported messages are preserved, but there is no editor for this field.
  final String warningMessage;
  final Map<String, dynamic> _extraData;

  factory GravityGeneratorWaveActionPropsData.fromJson(
    Map<String, dynamic> json,
  ) {
    final extra = Map<String, dynamic>.from(json)
      ..removeWhere(
        (key, _) =>
            parameterDefaults.containsKey(key) ||
            const {
              'GravityLevel',
              'TargetType',
              'Range',
              'TargetGrid',
              'TargetRestriction',
              'WarningMessage',
            }.contains(key),
      );
    final data = GravityGeneratorWaveActionPropsData(
      parameters: {
        for (final key in parameterDefaults.keys)
          if (json[key] is num) key: json[key] as num,
      },
      gravityLevel: json['GravityLevel'] as String? ?? 'anti',
      targetType: json['TargetType'] as String? ?? 'plant',
      range: json['Range'] is Map
          ? RectData.fromJson(Map<String, dynamic>.from(json['Range'] as Map))
          : null,
      targetGrid: json['TargetGrid'] is Map
          ? TileLocationData.fromJson(
              Map<String, dynamic>.from(json['TargetGrid'] as Map),
            )
          : null,
      targetRestriction: (json['TargetRestriction'] as List? ?? [])
          .whereType<String>()
          .toList(),
      warningMessage: json['WarningMessage'] as String? ?? '',
      extraData: extra,
    );
    // Inactive-mode parameters may be omitted in imported events. Display their
    // defaults in the editor without adding them to the export until edited.
    data.parameters.removeWhere((key, _) => json[key] is! num);
    return data;
  }

  /// Range is a rectangle offset from the target plant or the target grid cell.
  bool affectsCell(int col, int row) {
    final x = (targetType == 'grid' ? targetGrid?.mx ?? 0 : 0) + range.mX;
    final y = (targetType == 'grid' ? targetGrid?.my ?? 0 : 0) + range.mY;
    return col >= x &&
        col < x + range.mWidth &&
        row >= y &&
        row < y + range.mHeight;
  }

  @override
  Map<String, dynamic> toJson() => {
    ..._extraData,
    ...parameters,
    'GravityLevel': gravityLevel,
    'TargetType': targetType,
    'Range': range.toJson(),
    if (targetGrid != null) 'TargetGrid': targetGrid!.toJson(),
    'TargetRestriction': List<String>.from(targetRestriction),
    'WarningMessage': warningMessage,
  };
}

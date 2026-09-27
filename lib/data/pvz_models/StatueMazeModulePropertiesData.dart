import 'package:c_editor/data/pvz_models/PvzModel.dart';

class StatueMatrixInfo extends PvzModel {
  StatueMatrixInfo({
    this.type = 'c',
    this.waitDuration = 2.0,
    this.rotateTime = 1.5,
  });

  String type;
  double waitDuration;
  double rotateTime;

  factory StatueMatrixInfo.fromJson(Map<String, dynamic> json) {
    return StatueMatrixInfo(
      type: json['Type'] as String? ?? 'c',
      waitDuration: (json['WaitDuration'] as num?)?.toDouble() ?? 2.0,
      rotateTime: (json['RotateTime'] as num?)?.toDouble() ?? 1.5,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Type': type,
    'WaitDuration': waitDuration,
    'RotateTime': rotateTime,
  };
}

class StatueSetInfo extends PvzModel {
  StatueSetInfo({
    this.matrixSize = 4,
    this.displayTime = 3.0,
    this.targetNum = 3,
    List<StatueMatrixInfo>? matrixInfos,
    this.bonusLife = 0,
  }) : matrixInfos = matrixInfos ?? [];

  int matrixSize;
  double displayTime;
  int targetNum;
  List<StatueMatrixInfo> matrixInfos;
  int bonusLife;

  factory StatueSetInfo.fromJson(Map<String, dynamic> json) {
    final rawInfos = json['MatrixInfos'];
    final infos = <StatueMatrixInfo>[];
    if (rawInfos is List) {
      for (final e in rawInfos) {
        if (e is Map<String, dynamic>) {
          infos.add(StatueMatrixInfo.fromJson(e));
        } else if (e is Map) {
          infos.add(StatueMatrixInfo.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return StatueSetInfo(
      matrixSize: json['MatrixSize'] as int? ?? 4,
      displayTime: (json['DisplayTime'] as num?)?.toDouble() ?? 3.0,
      targetNum: json['TargetNum'] as int? ?? 3,
      matrixInfos: infos,
      bonusLife: json['BonusLife'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'MatrixSize': matrixSize,
    'DisplayTime': displayTime,
    'TargetNum': targetNum,
    'MatrixInfos': matrixInfos.map((e) => e.toJson()).toList(),
    'BonusLife': bonusLife,
  };
}

class StatueMazeModulePropertiesData extends PvzModel {
  StatueMazeModulePropertiesData({List<StatueSetInfo>? setInfos})
      : setInfos = setInfos ?? [StatueSetInfo()];

  List<StatueSetInfo> setInfos;

  factory StatueMazeModulePropertiesData.createDefault() {
    return StatueMazeModulePropertiesData(
      setInfos: [StatueSetInfo()],
    );
  }

  factory StatueMazeModulePropertiesData.fromJson(Map<String, dynamic> json) {
    final rawSets = json['SetInfos'];
    final sets = <StatueSetInfo>[];
    if (rawSets is List) {
      for (final e in rawSets) {
        if (e is Map<String, dynamic>) {
          sets.add(StatueSetInfo.fromJson(e));
        } else if (e is Map) {
          sets.add(StatueSetInfo.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return StatueMazeModulePropertiesData(setInfos: sets.isEmpty ? null : sets);
  }

  @override
  Map<String, dynamic> toJson() => {
    'SetInfos': setInfos.map((e) => e.toJson()).toList(),
  };
}

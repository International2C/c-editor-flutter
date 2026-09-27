import 'package:c_editor/data/pvz_models/PvzModel.dart';

class OakTrainPropertiesData extends PvzModel {
  OakTrainPropertiesData({
    this.totalLife = 1000,
    this.arrowScore = 100,
    this.wizardScore = 300,
    this.archmageScore = 500,
    this.bossScore = 2000,
    this.healNum = 300,
    this.arrowPowerNum = 8,
    this.arrowMultipleNum = 5,
    List<int>? initArrowsNum,
  }) : initArrowsNum = initArrowsNum ?? const [12, 10, 5, 0];

  int totalLife;
  int arrowScore;
  int wizardScore;
  int archmageScore;
  int bossScore;
  int healNum;
  int arrowPowerNum;
  int arrowMultipleNum;
  List<int> initArrowsNum;

  factory OakTrainPropertiesData.fromJson(Map<String, dynamic> json) {
    final rawList = json['InitArrowsNum'];
    final arrows = <int>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is num) arrows.add(e.toInt());
      }
    }
    return OakTrainPropertiesData(
      totalLife: json['TotalLife'] as int? ?? 1000,
      arrowScore: json['ArrowScore'] as int? ?? 100,
      wizardScore: json['WizardScore'] as int? ?? 300,
      archmageScore: json['ArchmageScore'] as int? ?? 500,
      bossScore: json['BossScore'] as int? ?? 2000,
      healNum: json['HealNum'] as int? ?? 300,
      arrowPowerNum: json['ArrowPowerNum'] as int? ?? 8,
      arrowMultipleNum: json['ArrowMultipleNum'] as int? ?? 5,
      initArrowsNum: arrows.isEmpty ? null : arrows,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'TotalLife': totalLife,
    'ArrowScore': arrowScore,
    'WizardScore': wizardScore,
    'ArchmageScore': archmageScore,
    'BossScore': bossScore,
    'HealNum': healNum,
    'ArrowPowerNum': arrowPowerNum,
    'ArrowMultipleNum': arrowMultipleNum,
    'InitArrowsNum': initArrowsNum,
  };
}

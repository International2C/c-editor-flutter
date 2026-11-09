import 'package:c_editor/data/pvz_models/PvzModel.dart';

class ZombieAirbubbleActionPropsData extends PvzModel {
  ZombieAirbubbleActionPropsData({
    this.bubbleNumber = 10,
    this.bubbleHealth = 2000,
    this.speedRangeMin = 0.5,
    this.speedRangeMax = 2.5,
  });

  int bubbleNumber;
  int bubbleHealth;
  double speedRangeMin;
  double speedRangeMax;

  factory ZombieAirbubbleActionPropsData.fromJson(Map<String, dynamic> json) {
    return ZombieAirbubbleActionPropsData(
      bubbleNumber: (json['BubbleNumber'] as num?)?.toInt() ?? 10,
      bubbleHealth: (json['BubbleHealth'] as num?)?.toInt() ?? 2000,
      speedRangeMin: (json['SpeedRangeMin'] as num?)?.toDouble() ?? 0.5,
      speedRangeMax: (json['SpeedRangeMax'] as num?)?.toDouble() ?? 2.5,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'BubbleNumber': bubbleNumber,
    'BubbleHealth': bubbleHealth,
    'SpeedRangeMin': speedRangeMin,
    'SpeedRangeMax': speedRangeMax,
  };
}

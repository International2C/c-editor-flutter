import 'package:c_editor/data/pvz_models/PvzModel.dart';

class CamelMinigamePropertiesData extends PvzModel {
  CamelMinigamePropertiesData({
    this.additionalXBufferBetweenChains = 50,
    this.camelSegmentRiseStagger = 0.33,
    this.cardMatchTime = 0,
    this.cardMatchingTime = 0.5,
    this.cardNoMatchTime = 1.5,
    this.cardTypesUsed = 3,
    this.initialTutorialZombieRiseDelay = 2,
    this.maxSpawnX = 600,
    this.minSpawnXEnd = 500,
    this.minSpawnXStart = 550,
    this.showTutorial = true,
  });

  int additionalXBufferBetweenChains;
  double camelSegmentRiseStagger;
  double cardMatchTime;
  double cardMatchingTime;
  double cardNoMatchTime;
  int cardTypesUsed;
  double initialTutorialZombieRiseDelay;
  int maxSpawnX;
  int minSpawnXEnd;
  int minSpawnXStart;
  bool showTutorial;

  factory CamelMinigamePropertiesData.fromJson(Map<String, dynamic> json) {
    return CamelMinigamePropertiesData(
      additionalXBufferBetweenChains:
          json['AdditionalXBufferBetweenChains'] as int? ?? 50,
      camelSegmentRiseStagger:
          (json['CamelSegmentRiseStagger'] as num?)?.toDouble() ?? 0.33,
      cardMatchTime: (json['CardMatchTime'] as num?)?.toDouble() ?? 0,
      cardMatchingTime: (json['CardMatchingTime'] as num?)?.toDouble() ?? 0.5,
      cardNoMatchTime: (json['CardNoMatchTime'] as num?)?.toDouble() ?? 1.5,
      cardTypesUsed: json['CardTypesUsed'] as int? ?? 3,
      initialTutorialZombieRiseDelay:
          (json['InitialTutorialZombieRiseDelay'] as num?)?.toDouble() ?? 2,
      maxSpawnX: json['MaxSpawnX'] as int? ?? 600,
      minSpawnXEnd: json['MinSpawnXEnd'] as int? ?? 500,
      minSpawnXStart: json['MinSpawnXStart'] as int? ?? 550,
      showTutorial: json['ShowTutorial'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'AdditionalXBufferBetweenChains': additionalXBufferBetweenChains,
    'CamelSegmentRiseStagger': camelSegmentRiseStagger,
    'CardMatchTime': cardMatchTime,
    'CardMatchingTime': cardMatchingTime,
    'CardNoMatchTime': cardNoMatchTime,
    'CardTypesUsed': cardTypesUsed,
    'InitialTutorialZombieRiseDelay': initialTutorialZombieRiseDelay,
    'MaxSpawnX': maxSpawnX,
    'MinSpawnXEnd': minSpawnXEnd,
    'MinSpawnXStart': minSpawnXStart,
    'ShowTutorial': showTutorial,
  };
}

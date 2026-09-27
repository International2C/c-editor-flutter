import 'package:c_editor/data/pvz_models/PvzModel.dart';

/// One cell of the Seeing Stars pattern: the plant that must occupy
/// (`MatchPlantGridX`, `MatchPlantGridY`) for the level to be won.
class SeeingStarsMatchPlantData extends PvzModel {
  SeeingStarsMatchPlantData({
    this.gridX = 0,
    this.gridY = 0,
    this.matchTypeName = 'starfruit',
  });

  int gridX;
  int gridY;
  String matchTypeName;

  factory SeeingStarsMatchPlantData.fromJson(Map<String, dynamic> json) {
    final x = json['MatchPlantGridX'];
    final y = json['MatchPlantGridY'];
    return SeeingStarsMatchPlantData(
      gridX: x is num ? x.toInt() : 0,
      gridY: y is num ? y.toInt() : 0,
      matchTypeName: json['MatchTypeName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'MatchPlantGridX': gridX,
    'MatchPlantGridY': gridY,
    'MatchTypeName': matchTypeName,
  };
}

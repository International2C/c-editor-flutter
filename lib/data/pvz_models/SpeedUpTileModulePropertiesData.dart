import 'package:c_editor/data/pvz_models/PvzModel.dart';
import 'package:c_editor/data/pvz_models/SpeedUpTileRoadData.dart';

class SpeedUpTileModulePropertiesData extends PvzModel {
  SpeedUpTileModulePropertiesData({List<SpeedUpTileRoadData>? roads})
    : roads = roads ?? [];

  List<SpeedUpTileRoadData> roads;
  Map<String, dynamic> _originalFields = {};

  factory SpeedUpTileModulePropertiesData.fromJson(Map<String, dynamic> json) {
    return SpeedUpTileModulePropertiesData(
      roads: (json['Roads'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (entry) =>
                SpeedUpTileRoadData.fromJson(Map<String, dynamic>.from(entry)),
          )
          .toList(),
    ).._originalFields = Map<String, dynamic>.from(json);
  }

  @override
  Map<String, dynamic> toJson() => {
    ..._originalFields,
    'Roads': roads.map((road) => road.toJson()).toList(),
  };
}

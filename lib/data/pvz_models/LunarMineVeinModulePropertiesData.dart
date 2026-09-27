import 'package:c_editor/data/pvz_models/PvzModel.dart';

class LunarMineVeinPlacementData extends PvzModel {
  LunarMineVeinPlacementData({
    this.typeName = 'lunar_mine_vein',
    this.gridX = 0,
    this.gridY = 0,
    this.emergenceWave = 1,
  });

  String typeName;
  int gridX;
  int gridY;
  int emergenceWave;

  factory LunarMineVeinPlacementData.fromJson(Map<String, dynamic> json) {
    return LunarMineVeinPlacementData(
      typeName: json['TypeName'] as String? ?? 'lunar_mine_vein',
      gridX: (json['GridX'] as num?)?.toInt() ?? 0,
      gridY: (json['GridY'] as num?)?.toInt() ?? 0,
      emergenceWave: (json['EmergenceWave'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'TypeName': typeName,
    'GridX': gridX,
    'GridY': gridY,
    'EmergenceWave': emergenceWave,
  };
}

class LunarMineVeinModulePropertiesData extends PvzModel {
  LunarMineVeinModulePropertiesData({
    List<LunarMineVeinPlacementData>? placements,
  }) : placements = placements ?? <LunarMineVeinPlacementData>[];

  List<LunarMineVeinPlacementData> placements;

  factory LunarMineVeinModulePropertiesData.fromJson(
    Map<String, dynamic> json,
  ) {
    return LunarMineVeinModulePropertiesData(
      placements:
          (json['VeinPlacements'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (entry) => LunarMineVeinPlacementData.fromJson(
                  Map<String, dynamic>.from(entry),
                ),
              )
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'VeinPlacements': placements.map((entry) => entry.toJson()).toList(),
  };
}

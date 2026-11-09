import 'package:c_editor/data/pvz_models/PvzModel.dart';
import 'package:c_editor/data/speed_up_tile_catalog.dart';

/// One speed-up road tile. Both grid coordinates are zero-based in level JSON.
class SpeedUpTileRoadData extends PvzModel {
  SpeedUpTileRoadData({
    this.gridX = 0,
    this.gridY = 0,
    this.img = SpeedUpTileCatalog.left,
  });

  int gridX;
  int gridY;
  String img;
  Map<String, dynamic> _originalFields = {};

  factory SpeedUpTileRoadData.fromJson(Map<String, dynamic> json) {
    return SpeedUpTileRoadData(
      gridX: (json['GridX'] as num?)?.toInt() ?? 0,
      gridY: (json['GridY'] as num?)?.toInt() ?? 0,
      img: json['Img'] as String? ?? SpeedUpTileCatalog.left,
    ).._originalFields = Map<String, dynamic>.from(json);
  }

  @override
  Map<String, dynamic> toJson() => {
    ..._originalFields,
    'GridX': gridX,
    'GridY': gridY,
    'Img': img,
  };
}

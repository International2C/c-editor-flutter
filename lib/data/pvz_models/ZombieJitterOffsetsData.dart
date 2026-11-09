import 'package:c_editor/data/pvz_models/PvzModel.dart';

/// Data stored by an independent `ZombieJitterOffsets` level object.
///
/// The object is not a LevelDefinition module. Basic and Underwater spawners
/// apply it to their zombie lists. Underwater fish and rise-from-ground actions
/// bypass this positioning routine; their imported references remain preserved.
class ZombieJitterOffsetsData extends PvzModel {
  ZombieJitterOffsetsData({this.offsetIncrement = 80, this.randomJitter = 30});

  int offsetIncrement;
  int randomJitter;

  factory ZombieJitterOffsetsData.fromJson(Map<String, dynamic> json) {
    return ZombieJitterOffsetsData(
      offsetIncrement:
          (json['ZombieSpawningOffsetIncrement'] as num?)?.toInt() ?? 80,
      randomJitter: (json['ZombieSpawningRandomJitter'] as num?)?.toInt() ?? 30,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'ZombieSpawningOffsetIncrement': offsetIncrement,
    'ZombieSpawningRandomJitter': randomJitter,
  };
}

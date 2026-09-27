import 'package:c_editor/data/pvz_models/PvzModel.dart';
import 'package:c_editor/data/pvz_models/SeeingStarsMatchPlantData.dart';

/// `PVZ1SeeingStarsModuleProperties` — the Memory Lane "Seeing Stars"
/// minigame. The level is won once every [matchPlants] cell holds the
/// requested plant, so this module carries its own win condition.
class PVZ1SeeingStarsModulePropertiesData extends PvzModel {
  PVZ1SeeingStarsModulePropertiesData({
    List<SeeingStarsMatchPlantData>? matchPlants,
    this.cycleIndex = 5,
    this.settlementDuration = 3.0,
  }) : matchPlants = matchPlants ?? <SeeingStarsMatchPlantData>[];

  List<SeeingStarsMatchPlantData> matchPlants;

  /// Wave the spawner loops back to once the last wave has been reached.
  int cycleIndex;

  /// Seconds between completing the pattern and the win being settled.
  double settlementDuration;

  factory PVZ1SeeingStarsModulePropertiesData.fromJson(
    Map<String, dynamic> json,
  ) {
    final plants = json['MatchPlants'];
    final cycle = json['CycleIndex'];
    final duration = json['SettlementDuration'];
    return PVZ1SeeingStarsModulePropertiesData(
      matchPlants: plants is List
          ? plants
                .whereType<Map>()
                .map(
                  (e) => SeeingStarsMatchPlantData.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : <SeeingStarsMatchPlantData>[],
      cycleIndex: cycle is num ? cycle.toInt() : 5,
      settlementDuration: duration is num ? duration.toDouble() : 3.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'MatchPlants': matchPlants.map((e) => e.toJson()).toList(),
    'CycleIndex': cycleIndex,
    'SettlementDuration': settlementDuration,
  };
}

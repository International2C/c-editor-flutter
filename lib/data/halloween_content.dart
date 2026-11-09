import 'package:c_editor/data/pvz_models/PvzModel.dart';

const scarecrowClass = 'SpawnPumpkinScarecrowWaveActionProps';
const cauldronClass = 'InitialGridItemWizardCrucibleProps';

class HalloweenContentData extends PvzModel {
  HalloweenContentData({required bool cauldron})
    : data = cauldron
          ? {'InitialGridItemWizardCrucibles': <dynamic>[]}
          : {
              'PumpkinScarecrowPool': [
                {'Count': 1, 'Type': 'RTID(pumpkin_scarecrow@GridItemTypes)'},
              ],
              'Hitpoints': 4000,
              'Level': 0,
              'SpawnPositionsPool': <dynamic>[],
            };
  final Map<String, dynamic> data;
  @override
  Map<String, dynamic> toJson() => data;
}

Map<String, dynamic> newCauldron(int x, int y) => {
  'GridX': x,
  'GridY': y,
  'TypeName': 'wizard_crucible',
  'BoilingDuration': 5,
  'CrucibleHitpoints': 3000,
  'ExplodeDamageAmount': 1000,
  'VenomDamageAmountPerSecond': 200,
  'VenomExistDuration': 5,
};

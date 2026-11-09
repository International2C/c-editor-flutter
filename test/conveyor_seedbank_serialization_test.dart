import 'package:c_editor/data/pvz_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial conveyor tool cards serialize with PlantType', () {
    for (final id in ['tool_projectile_wallnut', 'tool_powertile_alpha']) {
      final json = InitialPlantListData(plantType: id).toJson();

      expect(json['PlantType'], id);
      expect(json, isNot(contains('ToolType')));
    }
  });

  test('legacy initial conveyor ToolType is read and normalized', () {
    final data = InitialPlantListData.fromJson({
      'ToolType': 'tool_projectile_wallnut',
    });

    expect(data.plantType, 'tool_projectile_wallnut');
    expect(data.toJson()['PlantType'], 'tool_projectile_wallnut');
    expect(data.toJson(), isNot(contains('ToolType')));
  });

  test('valid PlantType wins over a stale ToolType', () {
    final data = InitialPlantListData.fromJson({
      'PlantType': 'tool_projectile_wallnut',
      'ToolType': 'tool_projectile_wallnut_big',
    });

    expect(data.plantType, 'tool_projectile_wallnut');
  });

  test('modify-conveyor tool cards keep the ToolType schema', () {
    final json = ModifyConveyorPlantData(type: 'tool_powertile_alpha').toJson();

    expect(json['ToolType'], 'tool_powertile_alpha');
    expect(json, isNot(contains('Type')));
  });
}

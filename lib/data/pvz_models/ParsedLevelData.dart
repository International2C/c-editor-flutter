import 'package:c_editor/data/pvz_models/LevelDefinitionData.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';

class ParsedLevelData {
  ParsedLevelData({
    this.levelDef,
    this.waveManager,
    this.waveManagerAlias,
    this.waveModule,
    this.waveGenerator,
    required this.objectMap,
  });

  LevelDefinitionData? levelDef;
  dynamic waveManager;
  String? waveManagerAlias;
  dynamic waveModule;
  dynamic waveGenerator;
  Map<String, PvzObject> objectMap;
}

import 'package:c_editor/data/pvz_models/PvzModel.dart';

/// Keeps inherited configuration and unknown game fields intact when editing.
class GladiatorRowModulePropertiesData extends PvzModel {
  GladiatorRowModulePropertiesData()
    : this.fromJson({
        'ResourceGroupNames': ['GladiatorRow', 'ZombieRomanBasicResGroup'],
        'BaseConfig': 'RTID(DefaultGladiatorRowConfig@PropertySheets)',
        'GameplayVersion': 1,
        'ZombieWinPunishmentZombieLevel': 1,
        'ZombieWinPunishmentZombiePool': [
          {'ZombieTypeName': 'roman_flag', 'Weight': 10},
          {'ZombieTypeName': 'roman_armor1', 'Weight': 8},
          {'ZombieTypeName': 'roman_armor2', 'Weight': 4},
          {'ZombieTypeName': 'roman_armor3', 'Weight': 2},
        ],
        'Encounters': [],
      });

  GladiatorRowModulePropertiesData.fromJson(Map<String, dynamic> json)
    : values = Map<String, dynamic>.from(json),
      encounters = (json['Encounters'] as List? ?? [])
          .map(
            (e) => GladiatorEncounterData.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      punishmentPool = (json['ZombieWinPunishmentZombiePool'] as List? ?? [])
          .map(
            (e) => GladiatorPunishmentZombieData.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();

  final Map<String, dynamic> values;
  final List<GladiatorEncounterData> encounters;
  final List<GladiatorPunishmentZombieData> punishmentPool;

  // The referenced default config uses the retired mode (0); trophy duels
  // require an explicit GameplayVersion: 1 in the level module.
  bool get usesTrophyMode => values['GameplayVersion'] == 1;

  // Defaults from DefaultGladiatorRowConfig. Do not flatten these into exports:
  // the game continues to inherit them through BaseConfig unless edited.
  static const optionDefaults = <String, num>{
    'ArenaDuration': 20.0,
    'PlantWinPlantfoodCount': 10,
    'ZombieWinPunishmentCageCount': 20,
    'ZombieWinPunishmentDuration': 10.0,
    'ZombieWinPunishmentZombieLevel': 1,
  };

  num option(String key) => values[key] as num? ?? optionDefaults[key]!;

  void addResourceGroups(Iterable<String> groups) {
    final current = (values['ResourceGroupNames'] as List? ?? [])
        .whereType<String>();
    values['ResourceGroupNames'] = {...current, ...groups}.toList();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...values,
    'Encounters': encounters.map((e) => e.toJson()).toList(),
    if (values.containsKey('ZombieWinPunishmentZombiePool') ||
        punishmentPool.isNotEmpty)
      'ZombieWinPunishmentZombiePool': punishmentPool
          .map((e) => e.toJson())
          .toList(),
  };
}

class GladiatorEncounterData extends PvzModel {
  GladiatorEncounterData({int wave = 0, int row = 2})
    : this.fromJson({
        'Wave': wave,
        'Row': row,
        'WarningDuration': 6.0,
        'FirstCageDelay': 0.0,
        'Spawns': [],
      });

  GladiatorEncounterData.fromJson(Map<String, dynamic> json)
    : values = Map<String, dynamic>.from(json),
      spawns = (json['Spawns'] as List? ?? [])
          .map(
            (e) => GladiatorSpawnData.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();

  final Map<String, dynamic> values;
  final List<GladiatorSpawnData> spawns;
  int get wave => (values['Wave'] as num?)?.toInt() ?? 0;
  set wave(int value) => values['Wave'] = value;
  int get row => (values['Row'] as num?)?.toInt() ?? 2;
  set row(int value) => values['Row'] = value;
  num get warningDuration => values['WarningDuration'] as num? ?? 6.0;
  num get firstCageDelay => values['FirstCageDelay'] as num? ?? 0.0;

  @override
  Map<String, dynamic> toJson() => {
    ...values,
    'Spawns': spawns.map((e) => e.toJson()).toList(),
  };
}

class GladiatorSpawnData extends PvzModel {
  GladiatorSpawnData({String zombieType = 'roman_shield_top'})
    : values = {
        'Time': 0.0,
        'GridX': 6,
        'Count': 1,
        'Interval': 5.0,
        'Level': 1,
        'ZombieType': zombieType,
      };

  GladiatorSpawnData.fromJson(Map<String, dynamic> json)
    : values = Map<String, dynamic>.from(json);

  final Map<String, dynamic> values;
  String get zombieType => values['ZombieType'] as String? ?? '';
  set zombieType(String value) => values['ZombieType'] = value;
  int get gridX => (values['GridX'] as num?)?.toInt() ?? 6;
  int get count => (values['Count'] as num?)?.toInt() ?? 1;
  int get level => (values['Level'] as num?)?.toInt() ?? 1;
  num get time => values['Time'] as num? ?? 0.0;
  num get interval => values['Interval'] as num? ?? 5.0;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(values);
}

class GladiatorPunishmentZombieData extends PvzModel {
  GladiatorPunishmentZombieData({required String zombieType})
    : values = {'ZombieTypeName': zombieType, 'Weight': 1};
  GladiatorPunishmentZombieData.fromJson(Map<String, dynamic> json)
    : values = Map<String, dynamic>.from(json);

  final Map<String, dynamic> values;
  String get zombieType => values['ZombieTypeName'] as String? ?? '';
  set zombieType(String value) => values['ZombieTypeName'] = value;
  num get weight => values['Weight'] as num? ?? 1;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(values);
}

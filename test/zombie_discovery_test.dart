import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

PvzLevelFile _levelWithActions(
  List<PvzObject> actions, {
  List<PvzObject> otherObjects = const [],
}) {
  return PvzLevelFile(
    objects: [
      ...otherObjects,
      ...actions,
      PvzObject(
        aliases: const ['WaveManager'],
        objClass: 'WaveManagerProperties',
        objData: WaveManagerData(
          waves: [
            [
              for (final action in actions)
                'RTID(${action.aliases!.first}@CurrentLevel)',
            ],
          ],
        ).toJson(),
      ),
    ],
  );
}

Set<String> _discover(PvzLevelFile level) =>
    ZombieDiscovery.discoverZombies(level, LevelParser.parseLevel(level));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Future.wait([ReferenceRepository.init(), GridItemRepository.init()]);
  });

  for (final legacy in [false, true]) {
    test('Bungee zombies are discovered with legacy fields: $legacy', () {
      final level = _levelWithActions([
        PvzObject(
          aliases: ['BungeeDropEvent0'],
          objClass: 'BungeeWaveActionProps',
          objData: {
            legacy ? 'Target' : 'target': {'mX': 6, 'mY': 2},
            legacy ? 'ZombieName' : 'zombieName': 'tutorial',
            'Level': 1,
          },
        ),
      ]);
      expect(_discover(level), {'tutorial'});
    });
  }

  test('Bungee discovery uses the official value when legacy keys coexist', () {
    final level = _levelWithActions([
      PvzObject(
        aliases: ['BungeeDropEvent0'],
        objClass: 'BungeeWaveActionProps',
        objData: {
          'target': {'mX': 6, 'mY': 2},
          'zombieName': 'tutorial',
          'ZombieName': 'mummy',
          'Level': 1,
        },
      ),
    ]);
    expect(_discover(level), {'tutorial'});
  });

  test('Atlantis tide movement and tide changes are not zombies', () {
    final level = _levelWithActions([
      for (final direction in const ['left', 'right'])
        PvzObject(
          aliases: ['Tide_$direction'],
          objClass: 'TideWaveWaveActionProps',
          objData: TideWaveWaveActionPropsData(type: direction).toJson(),
        ),
      PvzObject(
        aliases: const ['TidalChange'],
        objClass: 'TidalChangeWaveActionProps',
        objData: TidalChangeWaveActionData(
          tidalChange: TidalChangeInternalData(
            changeType: 'relative',
            changeAmount: 1,
          ),
        ).toJson(),
      ),
      PvzObject(
        aliases: const ['FishSpawn'],
        objClass: 'SpawnZombiesFishWaveActionProps',
        objData: SpawnZombiesFishWaveActionPropsData(
          zombies: [
            ZombieSpawnData(
              type: 'RTID(atlantis_basic@ZombieTypes)',
              direction: 'left',
            ),
          ],
          fishes: [FishSpawnData(type: 'hermitcrab')],
        ).toJson(),
      ),
      PvzObject(
        aliases: const ['ShellSpawn'],
        objClass: 'ZombieAtlantisShellActionProps',
        objData: ZombieAtlantisShellActionPropsData(
          tiles: [AtlantisShellTileData()],
        ).toJson(),
      ),
    ]);

    expect(_discover(level), {'atlantis_basic'});
  });

  test('zombie entry metadata cannot introduce generic resource names', () {
    final level = _levelWithActions([
      PvzObject(
        aliases: const ['Spawn'],
        objClass: 'SpawnZombiesJitteredWaveActionProps',
        objData: const {
          'Zombies': [
            {
              'Type': 'future_zombie',
              'Direction': 'right',
              'Position': {'Type': 'left', 'TypeName': 'random'},
              'ZombieStats': [
                {'Type': 'toughness', 'Value': 'toughness1'},
                {'Type': 'speed', 'Value': 'speed3'},
              ],
            },
          ],
          'OtherEntries': [
            {'TypeName': 'future_obstacle'},
          ],
        },
      ),
    ]);

    expect(_discover(level), {'future_zombie'});
  });

  test('resource namespaces exclude unknown plants, obstacles and actions', () {
    final level = _levelWithActions([
      PvzObject(
        aliases: const ['FutureSpawn'],
        objClass: 'FutureWaveActionProps',
        objData: const {
          'Type': 'RTID(future_zombie@ZombieTypes)',
          'Nested': [
            {'Type': 'RTID(future_obstacle@GridItemTypes)'},
            {'ZombieType': 'RTID(future_plant@PlantTypes)'},
            {'ZombieName': 'RTID(future_action@ZombieActions)'},
            {'TypeName': 'RTID(future_props@PropertySheets)'},
          ],
          'Zombies': [
            {'Type': 'RTID(unlisted_obstacle@GridItemTypes)'},
            {'TypeName': 'RTID(unlisted_plant@PlantTypes)'},
            {'Type': 'RTID(invalid@ZombieTypes) trailing'},
          ],
        },
      ),
    ]);

    expect(_discover(level), {'future_zombie'});
  });

  test('explicit zombie fields retain unknown custom code names', () {
    final keys = const [
      'ZombieType',
      'ZombieName',
      'ZombieTypeName',
      'SpiderZombieName',
      'ZombieInsideBallType',
    ];
    final level = _levelWithActions([
      PvzObject(
        aliases: const ['FutureSpawn'],
        objClass: 'FutureWaveActionProps',
        objData: {
          for (final key in keys) key: 'custom_$key',
          'Type': 'unknown_event_mode',
        },
      ),
    ]);

    expect(_discover(level), {for (final key in keys) 'custom_$key'});
  });

  test(
    'direction-like names are retained when explicitly zombie resources',
    () {
      final level = _levelWithActions([
        PvzObject(
          aliases: const ['CustomSpawn'],
          objClass: 'FutureWaveActionProps',
          objData: const {
            'Type': 'RTID(left@ZombieTypes)',
            'Zombies': [
              {'TypeName': 'right'},
            ],
          },
        ),
      ]);

      expect(_discover(level), {'left', 'right'});
    },
  );

  test('nested school bus and hamster passengers survive classification', () {
    final level = _levelWithActions([
      PvzObject(
        aliases: const ['Bus'],
        objClass: 'SchoolBusWaveActionProps',
        objData: SchoolBusWaveActionPropsData(
          des: SchoolBusDesData(
            params: SchoolBusParamsData(
              zombies: [SchoolBusZombieData(typeName: 'future_bus_passenger')],
            ),
          ),
        ).toJson(),
      ),
      PvzObject(
        aliases: const ['Hamster'],
        objClass: 'HamsterZombieSpawnerProps',
        objData: const {
          'Zombies': [
            {
              'Type': 'RTID(hamster_ball@ZombieTypes)',
              'ZombieInsideBallType': 'future_ball_passenger',
            },
          ],
        },
      ),
    ]);

    expect(_discover(level), {'future_bus_passenger', 'future_ball_passenger'});
  });

  test(
    'all CurrentLevel wave references require a local ZombieType object',
    () {
      final level = _levelWithActions(
        [
          PvzObject(
            aliases: const ['Spawn'],
            objClass: 'FutureWaveActionProps',
            objData: const {
              'Nested': [
                {'Type': 'RTID(secondary_custom@CurrentLevel)'},
                {'Type': 'RTID(custom_obstacle@CurrentLevel)'},
                {'Type': 'RTID(unknown_event@CurrentLevel)'},
              ],
              'ZombieType': 'RTID(custom_creature@CurrentLevel)',
              'ZombieName': 'RTID(custom_obstacle@CurrentLevel)',
              'ZombieInsideBallType': 'RTID(unknown_passenger@CurrentLevel)',
              'Zombies': [
                {'Type': 'RTID(custom_creature@CurrentLevel)'},
                {'TypeName': 'RTID(custom_obstacle@CurrentLevel)'},
                {'ZombieType': 'RTID(secondary_custom@CurrentLevel)'},
              ],
              'ZombiePool': ['RTID(custom_obstacle@CurrentLevel)'],
            },
          ),
        ],
        otherObjects: [
          PvzObject(
            aliases: const ['primary_custom', 'secondary_custom'],
            objClass: 'ZombieType',
            objData: const {},
          ),
          PvzObject(
            aliases: const ['custom_obstacle'],
            objClass: 'GridItemType',
            objData: const {},
          ),
          PvzObject(
            aliases: const ['custom_creature'],
            objClass: 'CreatureType',
            objData: const {},
          ),
        ],
      );

      expect(_discover(level), {'primary_custom', 'secondary_custom'});
    },
  );

  test(
    'initial placements and generated pools validate CurrentLevel types',
    () {
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['custom_zombie'],
            objClass: 'ZombieType',
            objData: const {},
          ),
          PvzObject(
            aliases: const ['custom_creature'],
            objClass: 'CreatureType',
            objData: const {},
          ),
          PvzObject(
            aliases: const ['InitialZombies'],
            objClass: 'InitialZombieProperties',
            objData: const {
              'InitialZombiePlacements': [
                {'TypeName': 'RTID(custom_creature@CurrentLevel)'},
                {'ZombieType': 'RTID(custom_zombie@CurrentLevel)'},
              ],
            },
          ),
          PvzObject(
            aliases: const ['WaveGenerator'],
            objClass: 'WaveGeneratorProperties',
            objData: WaveGeneratorPropertiesData(
              waves: [
                WaveGeneratorWaveData(
                  zombies: [
                    WaveGeneratorZombieEntryData(
                      type: 'RTID(custom_creature@CurrentLevel)',
                    ),
                    WaveGeneratorZombieEntryData(type: 'unknown_bare_zombie'),
                  ],
                  addToZombiePool: [
                    WaveGeneratorPoolEntryData(
                      type: 'RTID(custom_creature@CurrentLevel)',
                    ),
                  ],
                ),
              ],
              addToZombiePool: [
                WaveGeneratorPoolEntryData(
                  type: 'RTID(missing_object@CurrentLevel)',
                ),
              ],
            ).toJson(),
          ),
          PvzObject(
            aliases: const ['WaveModule'],
            objClass: 'WaveManagerModuleProperties',
            objData: WaveManagerModuleData(
              dynamicZombies: [
                DynamicZombieGroup(
                  zombiePool: [
                    'RTID(custom_creature@CurrentLevel)',
                    'RTID(custom_zombie@CurrentLevel)',
                  ],
                ),
              ],
            ).toJson(),
          ),
        ],
      );

      expect(_discover(level), {'custom_zombie', 'unknown_bare_zombie'});
    },
  );

  test(
    'zombie collections support string entries without scanning other lists',
    () {
      final level = _levelWithActions([
        PvzObject(
          aliases: const ['PoolSpawn'],
          objClass: 'FutureWaveActionProps',
          objData: const {
            'Zombies': ['future_spawn', 'RTID(atlantis_imp@ZombieTypes)'],
            'ZombiePool': ['future_pool'],
            'AddToZombiePool': [
              {'Type': 'future_addition'},
            ],
            'SpawnColumn': ['left', 'right'],
            'StartingPlants': ['peashooter', 'sunflower'],
            'BlackList': ['wallnut'],
          },
        ),
      ]);

      expect(_discover(level), {
        'future_spawn',
        'atlantis_imp',
        'future_pool',
        'future_addition',
      });
    },
  );

  test('initial placements reject other namespaces and empty code names', () {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['InitialZombies'],
          objClass: 'InitialZombieProperties',
          objData: const {
            'InitialZombiePlacements': [
              {'TypeName': 'custom_initial'},
              {'ZombieType': 'RTID(custom_initial_rtid@ZombieTypes)'},
              {'TypeName': 'RTID(not_a_zombie@GridItemTypes)'},
              {'TypeName': '  '},
            ],
          },
        ),
      ],
    );

    expect(_discover(level), {'custom_initial', 'custom_initial_rtid'});
  });
}

import 'package:c_editor/data/jitter_offsets_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _objectData(PvzObject object) =>
    Map<String, dynamic>.from(object.objData as Map);

PvzLevelFile _buildTestLevel() => PvzLevelFile(
  objects: <PvzObject>[
    PvzObject(
      aliases: <String>['Offsets'],
      objClass: 'ZombieJitterOffsets',
      objData: <String, dynamic>{
        'ZombieSpawningOffsetIncrement': 20,
        'ZombieSpawningRandomJitter': 10,
      },
    ),
    PvzObject(
      aliases: <String>['Wave1FishOffsets'],
      objClass: 'SpawnZombiesFishWaveActionProps',
      objData: <String, dynamic>{
        'JitterOffsets': 'RTID(Offsets@CurrentLevel)',
        'Zombies': <Map<String, dynamic>>[
          <String, dynamic>{
            'Type': 'RTID(atlantis_basic@ZombieTypes)',
            'Row': '3',
            'Direction': 'right',
            'Level': 1,
          },
        ],
      },
    ),
    PvzObject(
      aliases: <String>['Wave2FishDefault'],
      objClass: 'SpawnZombiesFishWaveActionProps',
      objData: <String, dynamic>{'Zombies': <dynamic>[]},
    ),
  ],
);

void main() {
  test('fish event model preserves JitterOffsets on round trip', () {
    final original = _objectData(_buildTestLevel().objects[1]);

    final restored = SpawnZombiesFishWaveActionPropsData.fromJson(original);
    final exported = restored.toJson();

    expect(restored.jitterOffsets, 'RTID(Offsets@CurrentLevel)');
    expect(exported['JitterOffsets'], 'RTID(Offsets@CurrentLevel)');
    expect(exported['Zombies'], hasLength(1));
  });

  test('fish event is found and updated as an Offsets referrer', () {
    final level = _buildTestLevel();

    final referrers = JitterOffsetsUtils.findReferrers(level, 'Offsets');
    expect(referrers, hasLength(1));
    expect(referrers.single.aliases, contains('Wave1FishOffsets'));

    expect(
      JitterOffsetsUtils.renamePresetReferences(
        level,
        'Offsets',
        'OffsetsRenamed',
      ),
      1,
    );
    expect(
      _objectData(level.objects[1])['JitterOffsets'],
      'RTID(OffsetsRenamed@CurrentLevel)',
    );
    expect(_objectData(level.objects[2]), isNot(contains('JitterOffsets')));
  });

  test('Basic Spawner model preserves JitterOffsets on round trip', () {
    final restored = WaveActionData.fromJson(<String, dynamic>{
      'JitterOffsets': 'RTID(Offsets@CurrentLevel)',
      'AdditionalPlantfood': 1,
      'Zombies': <Map<String, dynamic>>[
        <String, dynamic>{
          'Type': 'RTID(tutorial@ZombieTypes)',
          'Row': '3',
          'Level': 1,
        },
      ],
    });

    final exported = restored.toJson();
    expect(restored.jitterOffsets, 'RTID(Offsets@CurrentLevel)');
    expect(exported['JitterOffsets'], 'RTID(Offsets@CurrentLevel)');
    expect(exported['AdditionalPlantfood'], 1);
    expect(exported['Zombies'], hasLength(1));
  });
}

import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/wave_point_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ZombiePropertiesRepository.init);

  PvzLevelFile buildLevel({required List<DynamicZombieGroup> groups}) {
    return PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['WaveModule'],
          objClass: 'WaveManagerModuleProperties',
          objData: WaveManagerModuleData(dynamicZombies: groups).toJson(),
        ),
      ],
    );
  }

  test('duplicate pool entries are merged instead of overwritten', () {
    final entries = WavePointAnalysis.resolveEntries(const [
      'RTID(modern_balloon@ZombieTypes)',
      'RTID(modern_balloon@ZombieTypes)',
    ]);
    expect(entries, hasLength(1));
    expect(entries.single.id, 'modern_balloon');
    expect(entries.single.cost, 400);
  });

  test('custom CurrentLevel pool entries are reported as having no data', () {
    final level = buildLevel(
      groups: [
        DynamicZombieGroup(zombiePool: const ['RTID(my_custom@CurrentLevel)']),
      ],
    );
    final parsed = LevelParser.parseLevel(level);
    final analysis = WavePointAnalysis.analyze(100, parsed, waveIndex: 1);
    expect(analysis.missingStats, ['my_custom']);
    expect(analysis.customIds, ['my_custom']);
    expect(analysis.expectation['my_custom'], 0.0);
  });

  test('only custom and no-data entries are hidden from prediction rows', () {
    final analysis = WavePointAnalysis.analyzePool(const [
      // Costs 100: cannot be bought with a 50 point budget.
      'RTID(pirate@ZombieTypes)',
      // Bundled flag carrier: WavePointCost is known but Weight is 0. The
      // Wave Manager path ignores Weight, so it stays a normal row.
      'RTID(pirate_flag@ZombieTypes)',
      'RTID(my_custom@CurrentLevel)',
    ], 50);

    expect(analysis.customIds, ['my_custom']);
    expect(analysis.missingStats, ['my_custom']);
    expect(analysis.hiddenIds, {'my_custom'});
    // Only custom/no-data ids are hidden; both buyable zombies get a row
    // (0.00 while this wave is too poor).
    final rows = [
      for (final e in analysis.expectation.entries)
        if (!analysis.hiddenIds.contains(e.key)) e.key,
    ];
    expect(rows, ['pirate', 'pirate_flag']);
    expect(analysis.expectation['pirate'], 0.0);
    expect(analysis.expectation['pirate_flag'], 0.0);
  });

  test('a Weight = 0 flag carrier is bought from points like any zombie', () {
    final analysis = WavePointAnalysis.analyzePool(const [
      'RTID(pirate@ZombieTypes)',
      'RTID(pirate_flag@ZombieTypes)',
    ], 500);

    expect(analysis.hiddenIds, isEmpty);
    expect(analysis.missingStats, isEmpty);
    expect(analysis.expectation['pirate'], greaterThan(0));
    expect(analysis.expectation['pirate_flag'], greaterThan(0));
  });

  test('same-cost candidates split the expectation evenly', () {
    final result = WavePointAnalysis.calculate([
      InputEntry(id: 'a', cost: 10),
      InputEntry(id: 'b', cost: 10),
    ], 100);
    expect(result['a'], 5.0);
    expect(result['b'], 5.0);
  });

  test('every active group contributes its pool to the expectation', () {
    final level = buildLevel(
      groups: [
        DynamicZombieGroup(
          startingWave: 0,
          zombiePool: const ['RTID(pirate@ZombieTypes)'],
        ),
        DynamicZombieGroup(
          startingWave: 3,
          zombiePool: const ['RTID(pirate_armor1@ZombieTypes)'],
        ),
      ],
    );
    final parsed = LevelParser.parseLevel(level);

    expect(WavePointAnalysis.poolForWave(parsed, 1), [
      'RTID(pirate@ZombieTypes)',
    ]);
    expect(WavePointAnalysis.poolForWave(parsed, 4), [
      'RTID(pirate@ZombieTypes)',
      'RTID(pirate_armor1@ZombieTypes)',
    ]);
    expect(WavePointAnalysis.poolForWave(parsed, null), [
      'RTID(pirate@ZombieTypes)',
      'RTID(pirate_armor1@ZombieTypes)',
    ]);

    final early = WavePointAnalysis.analyze(100, parsed, waveIndex: 1);
    expect(early.missingStats, isEmpty);
    expect(early.expectation.keys, ['pirate']);
    // Pirate costs 100: exactly one spawn fits into 100 points.
    expect(early.expectation['pirate'], 1.0);

    final later = WavePointAnalysis.analyze(1000, parsed, waveIndex: 4);
    expect(later.expectation.keys, containsAll(['pirate', 'pirate_armor1']));
    expect(later.expectation['pirate'], greaterThan(0));
    expect(later.expectation['pirate_armor1'], greaterThan(0));
  });

  test('budgets above 20000 points are not truncated', () {
    final result = WavePointAnalysis.calculate([
      InputEntry(id: 'z', cost: 10),
    ], 150000);
    expect(result['z'], 15000.0);
  });

  test('a single deterministic zombie spends the whole budget', () {
    final result = WavePointAnalysis.calculate([
      InputEntry(id: 'z', cost: 100),
    ], 450);
    expect(result['z'], 4.0);
  });
}

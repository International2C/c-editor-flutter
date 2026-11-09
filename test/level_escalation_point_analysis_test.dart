import 'package:c_editor/data/level_escalation_point_analysis.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ZombiePropertiesRepository.init);

  LevelEscalationModuleData data({
    int flagCount = 3,
    int wavesPerFlag = 4,
    int startingPoints = 100,
    int pointIncrementPerWave = 75,
    List<String> zombiePool = const [],
  }) {
    return LevelEscalationModuleData(
      flagCount: flagCount,
      wavesPerFlag: wavesPerFlag,
      startingPoints: startingPoints,
      pointIncrementPerWave: pointIncrementPerWave,
      zombiePool: zombiePool,
    );
  }

  test('points grow per wave and flag waves multiply the budget by 2.5', () {
    final module = data();
    expect(LevelEscalationPointAnalysis.totalWaves(module), 12);
    expect(LevelEscalationPointAnalysis.pointsAtWave(module, 1), 100);
    expect(LevelEscalationPointAnalysis.pointsAtWave(module, 2), 175);
    expect(LevelEscalationPointAnalysis.pointsAtWave(module, 3), 250);
    expect(LevelEscalationPointAnalysis.pointsAtWave(module, 4), 812);
    expect(LevelEscalationPointAnalysis.pointsAtWave(module, 5), 400);
    expect(LevelEscalationPointAnalysis.pointsAtWave(module, 12), 2312);
    expect(LevelEscalationPointAnalysis.pointsAtWave(module, 0), 0);

    expect(LevelEscalationPointAnalysis.isFlagWave(module, 4), isTrue);
    expect(LevelEscalationPointAnalysis.isFlagWave(module, 8), isTrue);
    expect(LevelEscalationPointAnalysis.isFlagWave(module, 12), isTrue);
    expect(LevelEscalationPointAnalysis.isFlagWave(module, 5), isFalse);
    expect(LevelEscalationPointAnalysis.isFlagWave(module, 0), isFalse);
  });

  test('the budget is capped at 60000 before the flag multiplier', () {
    final module = data(flagCount: 2, pointIncrementPerWave: 100000);
    expect(LevelEscalationPointAnalysis.pointsAtWave(module, 2), 60000);
    expect(LevelEscalationPointAnalysis.pointsAtWave(module, 4), 150000);
  });

  test('waves per flag falls back when unset', () {
    final module = data(wavesPerFlag: 0);
    expect(LevelEscalationPointAnalysis.flagInterval(module), 10);
    expect(LevelEscalationPointAnalysis.isFlagWave(module, 10), isTrue);
    expect(LevelEscalationPointAnalysis.isFlagWave(module, 4), isFalse);
  });

  test('expectation covers the module pool', () {
    final module = data(
      startingPoints: 1000,
      zombiePool: const ['RTID(modern_balloon@ZombieTypes)'],
    );
    final result = LevelEscalationPointAnalysis.expectationAtWave(module, 1);
    expect(result.missingStats, isEmpty);
    expect(result.customIds, isEmpty);
    // Balloon costs 400: 1000 points spawn exactly two of them.
    expect(result.expectation['modern_balloon'], 2.0);
  });
}

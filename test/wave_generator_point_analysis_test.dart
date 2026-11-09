import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/wave_generator_point_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

WaveGeneratorPropertiesData generator({
  int start = 100,
  int increment = 100,
  List<WaveGeneratorPoolEntryData> pool = const [],
  required List<WaveGeneratorWaveData> waves,
}) {
  return WaveGeneratorPropertiesData(
    waveSpendingPoints: start,
    waveSpendingPointIncrement: increment,
    addToZombiePool: pool,
    waves: waves,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ZombiePropertiesRepository.init);

  group('legacy point trajectory', () {
    test('uses global start and increment for ordinary waves', () {
      final data = generator(
        start: 100,
        increment: 150,
        waves: List.generate(4, (_) => WaveGeneratorWaveData()),
      );

      expect(
        WaveGeneratorPointAnalysis.calculateStates(
          data,
        ).map((state) => state.randomSpawnPoints),
        [100, 250, 400, 550],
      );
    });

    test('disabled random waves do not pause the point trajectory', () {
      final data = generator(
        start: 100,
        increment: 150,
        waves: [
          ...List.generate(
            9,
            (_) => WaveGeneratorWaveData(disableRandomSpawns: true),
          ),
          WaveGeneratorWaveData(disableRandomSpawns: false),
        ],
      );

      expect(WaveGeneratorPointAnalysis.pointsAtWave(data, 10), 1450);
    });

    test('WavePointStart is temporary when override is false', () {
      final data = generator(
        waves: [
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(wavePointStart: 120, wavePointOverride: false),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
        ],
      );

      expect(
        WaveGeneratorPointAnalysis.calculateStates(
          data,
        ).map((state) => state.randomSpawnPoints),
        [100, 200, 300, 120, 500, 600],
      );
    });

    test('WavePointOverride resets the continuing point trajectory', () {
      final data = generator(
        waves: [
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(wavePointStart: 120, wavePointOverride: true),
          WaveGeneratorWaveData(),
        ],
      );

      expect(
        WaveGeneratorPointAnalysis.calculateStates(
          data,
        ).map((state) => state.randomSpawnPoints),
        [100, 200, 300, 120, 220],
      );
    });

    test('local increment continues after a point trajectory reset', () {
      final data = generator(
        waves: [
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(
            wavePointStart: 120,
            wavePointIncrement: 40,
            wavePointOverride: true,
          ),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
        ],
      );

      expect(
        WaveGeneratorPointAnalysis.calculateStates(
          data,
        ).map((state) => state.randomSpawnPoints),
        [100, 200, 300, 120, 160, 200],
      );
    });

    test('local increment updates the continuing trajectory without reset', () {
      final data = generator(
        waves: [
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(
            wavePointStart: 120,
            wavePointIncrement: 40,
            wavePointOverride: false,
          ),
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(),
        ],
      );

      expect(
        WaveGeneratorPointAnalysis.calculateStates(
          data,
        ).map((state) => state.randomSpawnPoints),
        [100, 200, 300, 120, 440, 480],
      );
      expect(WaveGeneratorPointAnalysis.pointsAtWave(data, 5), 440);
    });

    test('local increment is ignored without WavePointStart', () {
      final data = generator(
        waves: [
          WaveGeneratorWaveData(),
          WaveGeneratorWaveData(wavePointIncrement: 5),
          WaveGeneratorWaveData(),
        ],
      );

      expect(
        WaveGeneratorPointAnalysis.calculateStates(
          data,
        ).map((state) => state.randomSpawnPoints),
        [100, 200, 300],
      );
    });

    test('flag interval only marks interval waves and changes no budget', () {
      final data = generator(
        start: 100,
        increment: 100,
        waves: List.generate(8, (_) => WaveGeneratorWaveData()),
      )..flagWaveInterval = 7;
      final states = WaveGeneratorPointAnalysis.calculateStates(data);

      expect(states[6].isFlagWave, isTrue);
      expect(states[7].isFlagWave, isFalse);
      expect(states[6].randomSpawnPoints, 700);
      expect(states[7].randomSpawnPoints, 800);
    });
  });

  group('cumulative zombie pool', () {
    const initial = 'RTID(kongfu_basic@ZombieTypes)';
    const disabledAddition = 'RTID(kongfu_flag@ZombieTypes)';
    const laterAddition = 'RTID(kongfu_bucket@ZombieTypes)';

    test('disabled random wave can still extend the pool', () {
      final data = generator(
        pool: [WaveGeneratorPoolEntryData(type: initial)],
        waves: [
          WaveGeneratorWaveData(
            disableRandomSpawns: true,
            addToZombiePool: [
              WaveGeneratorPoolEntryData(type: disabledAddition),
            ],
          ),
        ],
      );

      expect(WaveGeneratorPointAnalysis.poolAtWave(data, 1), [
        initial,
        disabledAddition,
      ]);
    });

    test('later enabled wave uses additions from disabled waves', () {
      final data = generator(
        pool: [WaveGeneratorPoolEntryData(type: initial)],
        waves: [
          WaveGeneratorWaveData(
            disableRandomSpawns: true,
            addToZombiePool: [
              WaveGeneratorPoolEntryData(type: disabledAddition),
            ],
          ),
          WaveGeneratorWaveData(disableRandomSpawns: false),
        ],
      );

      expect(WaveGeneratorPointAnalysis.poolAtWave(data, 2), [
        initial,
        disabledAddition,
      ]);
    });

    test('changing an earlier wave refreshes later effective pools', () {
      final data = generator(
        pool: [WaveGeneratorPoolEntryData(type: initial)],
        waves: [
          WaveGeneratorWaveData(
            addToZombiePool: [
              WaveGeneratorPoolEntryData(type: disabledAddition),
            ],
          ),
          WaveGeneratorWaveData(
            addToZombiePool: [WaveGeneratorPoolEntryData(type: laterAddition)],
          ),
        ],
      );
      expect(WaveGeneratorPointAnalysis.poolAtWave(data, 2), [
        initial,
        disabledAddition,
        laterAddition,
      ]);

      data.waves[0].addToZombiePool = const [];
      expect(WaveGeneratorPointAnalysis.poolAtWave(data, 2), [
        initial,
        laterAddition,
      ]);
    });

    test('keeps duplicate pool slots in the effective pool', () {
      final data = generator(
        pool: [
          WaveGeneratorPoolEntryData(type: initial),
          WaveGeneratorPoolEntryData(type: initial),
        ],
        waves: [
          WaveGeneratorWaveData(
            addToZombiePool: [WaveGeneratorPoolEntryData(type: initial)],
          ),
        ],
      );

      expect(WaveGeneratorPointAnalysis.poolAtWave(data, 1).length, 3);
    });
  });

  group('random-purchase statistical preview', () {
    const cheap = WaveGeneratorSpawnCandidate(id: 'cheap', cost: 10, weight: 1);
    const heavy = WaveGeneratorSpawnCandidate(id: 'heavy', cost: 20, weight: 3);

    test(
      'fixed spawns are reported separately and consume no random points',
      () {
        final preview = WaveGeneratorPointAnalysis.simulateRandomSpawns(
          points: 100,
          fixedSpawnCount: 5,
          candidates: const [cheap],
          iterations: 20,
          seed: 1,
        );

        expect(preview.averageTotal, 10);
        expect(preview.fixedSpawnCount, 5);
      },
    );

    test('stops immediately when no candidate is affordable', () {
      final preview = WaveGeneratorPointAnalysis.simulateRandomSpawns(
        points: 9,
        fixedSpawnCount: 0,
        candidates: const [cheap],
        iterations: 20,
      );

      expect(preview.averageTotal, 0);
      expect(preview.commonMaximum, 0);
    });

    test('never generates more than 50 random zombies', () {
      final preview = WaveGeneratorPointAnalysis.simulateRandomSpawns(
        points: 1000,
        fixedSpawnCount: 0,
        candidates: const [
          WaveGeneratorSpawnCandidate(id: 'one', cost: 1, weight: 1),
        ],
        iterations: 20,
      );

      expect(preview.averageTotal, 50);
      expect(preview.commonMinimum, 50);
      expect(preview.commonMaximum, 50);
    });

    test('uses weighted roulette among equally affordable candidates', () {
      final preview = WaveGeneratorPointAnalysis.simulateRandomSpawns(
        points: 10,
        fixedSpawnCount: 0,
        candidates: const [
          WaveGeneratorSpawnCandidate(id: 'light', cost: 10, weight: 1),
          WaveGeneratorSpawnCandidate(id: 'heavy', cost: 10, weight: 3),
        ],
        iterations: 12000,
        seed: 42,
      );

      final byId = {for (final entry in preview.entries) entry.id: entry};
      expect(preview.averageTotal, 1);
      expect(byId['light']!.averageCount, closeTo(0.25, 0.03));
      expect(byId['heavy']!.averageCount, closeTo(0.75, 0.03));
    });

    test('a Weight = 0 candidate is never bought', () {
      const zeroWeight = WaveGeneratorSpawnCandidate(
        id: 'zero',
        cost: 10,
        weight: 0,
      );
      final preview = WaveGeneratorPointAnalysis.simulateRandomSpawns(
        points: 100,
        fixedSpawnCount: 0,
        candidates: const [zeroWeight],
        iterations: 50,
        seed: 7,
      );

      expect(preview.averageTotal, 0);
      expect(preview.entries.single.averageCount, 0);
    });

    test('fixed seed returns exactly the same statistical preview', () {
      WaveGeneratorSpawnPreview run() =>
          WaveGeneratorPointAnalysis.simulateRandomSpawns(
            points: 135,
            fixedSpawnCount: 2,
            candidates: const [cheap, heavy],
            iterations: 1000,
            seed: 12345,
          );

      final first = run();
      final second = run();
      expect(second.averageTotal, first.averageTotal);
      expect(second.commonMinimum, first.commonMinimum);
      expect(second.commonMaximum, first.commonMaximum);
      expect(
        second.entries.map((entry) => entry.averageCount),
        first.entries.map((entry) => entry.averageCount),
      );
    });
  });

  group('legacy pool entry overrides', () {
    test('round-trips Cost, Weight, and Overridden', () {
      final entry = WaveGeneratorPoolEntryData.fromJson(const {
        'Type': 'RTID(tutorial@ZombieTypes)',
        'Cost': 25,
        'Weight': 7000,
        'Overridden': true,
      });

      expect(entry.cost, 25);
      expect(entry.weight, 7000);
      expect(entry.overridden, isTrue);
      expect(entry.toJson(), {
        'Type': 'RTID(tutorial@ZombieTypes)',
        'Cost': 25,
        'Weight': 7000,
        'Overridden': true,
      });
    });

    test('pool overrides beat property values and -1 falls back', () {
      final overridden = generator(
        start: 100,
        pool: [
          WaveGeneratorPoolEntryData(
            type: 'RTID(modern_balloon@ZombieTypes)',
            cost: 50,
            weight: 1234,
          ),
        ],
        waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
      );
      final fallback = generator(
        start: 400,
        pool: [
          WaveGeneratorPoolEntryData(type: 'RTID(modern_balloon@ZombieTypes)'),
        ],
        waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
      );

      final overriddenEntry = WaveGeneratorPointAnalysis.calculatePreview(
        overridden,
        1,
        iterations: 20,
      ).entries.single;
      final fallbackEntry = WaveGeneratorPointAnalysis.calculatePreview(
        fallback,
        1,
        iterations: 20,
      ).entries.single;
      expect((overriddenEntry.cost, overriddenEntry.weight), (50, 1234));
      expect((fallbackEntry.cost, fallbackEntry.weight), (400, 3000));
    });

    test('preview cache and whole-level count both include Weight', () {
      WaveGeneratorPropertiesData weighted(
        int tutorialWeight,
        int balloonWeight,
      ) => generator(
        start: 100,
        pool: [
          WaveGeneratorPoolEntryData(
            type: 'RTID(tutorial@ZombieTypes)',
            cost: 100,
            weight: tutorialWeight,
          ),
          WaveGeneratorPoolEntryData(
            type: 'RTID(modern_balloon@ZombieTypes)',
            cost: 100,
            weight: balloonWeight,
          ),
        ],
        waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
      );

      final tutorialHeavy = WaveGeneratorPointAnalysis.calculatePreview(
        weighted(9, 1),
        1,
      );
      final balloonHeavy = WaveGeneratorPointAnalysis.calculatePreview(
        weighted(1, 9),
        1,
      );
      double average(WaveGeneratorSpawnPreview preview, String id) =>
          preview.entries.singleWhere((entry) => entry.id == id).averageCount;
      expect(average(tutorialHeavy, 'tutorial'), greaterThan(0.8));
      expect(average(balloonHeavy, 'tutorial'), lessThan(0.2));

      final differentCosts = generator(
        start: 100,
        pool: [
          WaveGeneratorPoolEntryData(
            type: 'RTID(tutorial@ZombieTypes)',
            cost: 10,
            weight: 1,
          ),
          WaveGeneratorPoolEntryData(
            type: 'RTID(modern_balloon@ZombieTypes)',
            cost: 100,
            weight: 100,
          ),
        ],
        waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
      );
      final total = WaveGeneratorPointAnalysis.simulateTotalZombieCount(
        differentCosts,
      );
      expect(total.average, lessThan(2));
    });
  });

  group('WavePointOverride serialization', () {
    test('preserves the field and omits it when absent', () {
      final absent = WaveGeneratorWaveData.fromJson({
        'DisableRandomSpawns': false,
        'Zombies': <dynamic>[],
      });
      expect(absent.wavePointOverride, isNull);
      expect(absent.toJson(), isNot(contains('WavePointOverride')));

      final enabled = WaveGeneratorWaveData.fromJson({
        'DisableRandomSpawns': false,
        'Zombies': <dynamic>[],
        'WavePointOverride': true,
      });
      expect(enabled.wavePointOverride, isTrue);
      expect(enabled.toJson()['WavePointOverride'], isTrue);
    });
  });
}

import 'dart:math';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zombie_count_simulation.dart';

/// Effective state of one legacy [WaveGeneratorProperties] wave.
class WaveGeneratorWaveState {
  const WaveGeneratorWaveState({
    required this.waveNumber,
    required this.randomSpawnPoints,
    required this.randomSpawnsEnabled,
    required this.isFlagWave,
    required this.fixedSpawnCount,
    required this.effectivePool,
    required this.addedToPool,
    required this.usesTemporaryPointStart,
    required this.resetsPointTrajectory,
    required this.nextPointIncrement,
  });

  final int waveNumber;
  final int randomSpawnPoints;
  final bool randomSpawnsEnabled;
  final bool isFlagWave;
  final int fixedSpawnCount;
  final List<String> effectivePool;
  final List<String> addedToPool;
  final bool usesTemporaryPointStart;
  final bool resetsPointTrajectory;
  final int nextPointIncrement;
}

/// One zombie option used by the random-purchase preview.
class WaveGeneratorSpawnCandidate {
  const WaveGeneratorSpawnCandidate({
    required this.id,
    required this.cost,
    required this.weight,
  });

  final String id;
  final int cost;
  final double weight;
}

class WaveGeneratorSpawnPreviewEntry {
  const WaveGeneratorSpawnPreviewEntry({
    required this.id,
    required this.cost,
    required this.weight,
    required this.averageCount,
  });

  final String id;
  final int cost;
  final double weight;
  final double averageCount;
}

/// Stable statistical preview of legacy random point purchases.
class WaveGeneratorSpawnPreview {
  const WaveGeneratorSpawnPreview({
    required this.points,
    required this.fixedSpawnCount,
    required this.iterations,
    required this.averageTotal,
    required this.commonMinimum,
    required this.commonMaximum,
    required this.entries,
    required this.missingDataTypes,
    required this.zeroWeightTypes,
    required this.randomSpawnsEnabled,
    required this.poolIsEmpty,
  });

  final int points;
  final int fixedSpawnCount;
  final int iterations;
  final double averageTotal;
  final int commonMinimum;
  final int commonMaximum;
  final List<WaveGeneratorSpawnPreviewEntry> entries;

  /// Pool zombies without a usable effective cost or weight.
  final List<String> missingDataTypes;

  /// Pool zombies whose effective Weight is exactly 0. This is valid data,
  /// but these entries have no interval in the weighted probability set.
  final List<String> zeroWeightTypes;
  final bool randomSpawnsEnabled;
  final bool poolIsEmpty;

  bool get canCalculate =>
      randomSpawnsEnabled && points > 0 && entries.isNotEmpty;
}

/// Shared calculations for the legacy embedded Wave Generator system.
///
/// This intentionally does not use Wave Manager flag-wave multipliers,
/// final-wave rules, or dynamic-zombie starting-wave behavior. They belong to
/// a different point-spawn system.
class WaveGeneratorPointAnalysis {
  WaveGeneratorPointAnalysis._();

  static const int defaultSimulationIterations = 2000;
  static const int maxRandomSpawns = 50;
  static const int _stablePreviewSeed = 0x57415645;
  static final Map<String, WaveGeneratorSpawnPreview> _previewCache = {};

  /// Calculates the continuously advancing legacy point trajectory.
  ///
  /// A WavePointStart without WavePointOverride is temporary: that wave uses
  /// the local value while the original trajectory advances in the background.
  /// A local WavePointIncrement (when present) becomes the increment used
  /// afterwards in either branch. WavePointOverride only decides whether the
  /// trajectory position is reset to WavePointStart.
  static List<WaveGeneratorWaveState> calculateStates(
    WaveGeneratorPropertiesData data,
  ) {
    var currentPoints = data.waveSpendingPoints;
    var currentIncrement = data.waveSpendingPointIncrement;
    final pool = <String>[for (final entry in data.addToZombiePool) entry.type];
    final states = <WaveGeneratorWaveState>[];
    final interval = data.flagWaveInterval;

    for (var index = 0; index < data.waves.length; index++) {
      final wave = data.waves[index];
      final hasLocalStart = wave.wavePointStart != null;
      final resetsTrajectory =
          hasLocalStart && (wave.wavePointOverride ?? false);
      final budget = wave.wavePointStart ?? currentPoints;

      if (hasLocalStart && wave.wavePointIncrement != null) {
        currentIncrement = wave.wavePointIncrement!;
      }

      final additions = <String>[
        for (final entry in wave.addToZombiePool) entry.type,
      ];
      pool.addAll(additions);

      states.add(
        WaveGeneratorWaveState(
          waveNumber: index + 1,
          randomSpawnPoints: budget,
          randomSpawnsEnabled: !wave.disableRandomSpawns,
          isFlagWave: interval > 0 && (index + 1) % interval == 0,
          fixedSpawnCount: wave.zombies.length,
          effectivePool: List.unmodifiable(pool),
          addedToPool: List.unmodifiable(additions),
          usesTemporaryPointStart: hasLocalStart && !resetsTrajectory,
          resetsPointTrajectory: resetsTrajectory,
          nextPointIncrement: currentIncrement,
        ),
      );

      if (resetsTrajectory) {
        currentPoints = budget + currentIncrement;
      } else {
        currentPoints += currentIncrement;
      }
    }
    return states;
  }

  /// Effective random-spawn budget for a 1-based wave number.
  ///
  /// Wave numbers beyond the stored list continue the last effective point
  /// trajectory. This is useful for small trajectory previews in the editor.
  static int pointsAtWave(WaveGeneratorPropertiesData data, int waveNumber) {
    if (waveNumber < 1) return 0;
    var currentPoints = data.waveSpendingPoints;
    var currentIncrement = data.waveSpendingPointIncrement;

    for (var index = 0; index < waveNumber; index++) {
      final wave = index < data.waves.length ? data.waves[index] : null;
      final hasLocalStart = wave?.wavePointStart != null;
      final resetsTrajectory =
          hasLocalStart && (wave!.wavePointOverride ?? false);
      final budget = wave?.wavePointStart ?? currentPoints;
      final localIncrement = hasLocalStart ? wave?.wavePointIncrement : null;

      if (localIncrement != null) {
        currentIncrement = localIncrement;
      }
      if (index == waveNumber - 1) return budget;

      if (resetsTrajectory) {
        currentPoints = budget + currentIncrement;
      } else {
        currentPoints += currentIncrement;
      }
    }
    return 0;
  }

  static bool isFlagWave(WaveGeneratorPropertiesData data, int waveNumber) {
    return waveNumber > 0 &&
        data.flagWaveInterval > 0 &&
        waveNumber % data.flagWaveInterval == 0;
  }

  /// Cumulative zombie pool eligible on [waveNumber] (1-based), including the
  /// initial pool and per-wave additions through the current wave. Pool changes
  /// still apply on waves where random spawning itself is disabled.
  static List<String> poolAtWave(
    WaveGeneratorPropertiesData data,
    int waveNumber,
  ) {
    if (waveNumber < 1) return [];
    final pool = <String>[for (final entry in data.addToZombiePool) entry.type];
    final wavesToInclude = min(waveNumber, data.waves.length);
    for (var index = 0; index < wavesToInclude; index++) {
      pool.addAll(data.waves[index].addToZombiePool.map((entry) => entry.type));
    }
    return pool;
  }

  /// Cumulative pool entries, retaining legacy per-entry Cost/Weight
  /// overrides. [poolAtWave] remains the display-oriented Type-only view.
  static List<WaveGeneratorPoolEntryData> poolEntriesAtWave(
    WaveGeneratorPropertiesData data,
    int waveNumber,
  ) {
    if (waveNumber < 1) return [];
    final pool = <WaveGeneratorPoolEntryData>[...data.addToZombiePool];
    final wavesToInclude = min(waveNumber, data.waves.length);
    for (var index = 0; index < wavesToInclude; index++) {
      pool.addAll(data.waves[index].addToZombiePool);
    }
    return pool;
  }

  static List<WaveGeneratorSpawnCandidate> _resolveCandidates(
    List<WaveGeneratorPoolEntryData> pool,
    List<String> missingDataTypes,
    List<String> zeroWeightTypes,
  ) {
    final candidatesByType = <String, WaveGeneratorSpawnCandidate>{};
    for (final entry in pool) {
      final rtid = entry.type;
      final alias = RtidParser.parse(rtid)?.alias ?? rtid;
      final typeName = ZombiePropertiesRepository.getTypeNameByAlias(alias);
      final stats = ZombiePropertiesRepository.getStats(typeName);
      final hasPropertySheet =
          ZombiePropertiesRepository.hasResolvedPropertySheet(typeName);
      final cost = entry.cost != -1
          ? entry.cost
          : (hasPropertySheet ? stats.cost : -1);
      final weight = entry.weight != -1
          ? entry.weight
          : (hasPropertySheet ? stats.weight : -1);
      if (cost <= 0 || weight < 0) {
        if (!missingDataTypes.contains(typeName)) {
          missingDataTypes.add(typeName);
        }
        continue;
      }
      if (weight == 0) {
        candidatesByType.remove(typeName);
        if (!zeroWeightTypes.contains(typeName)) {
          zeroWeightTypes.add(typeName);
        }
        continue;
      }
      zeroWeightTypes.remove(typeName);
      candidatesByType[typeName] = WaveGeneratorSpawnCandidate(
        id: typeName,
        cost: cost,
        // ProbabilitySet::AddItem replaces an existing item's weight when the
        // same zombie type appears again.
        weight: weight.toDouble(),
      );
    }
    return candidatesByType.values.toList();
  }

  /// Simulates the game's repeated random purchase loop.
  ///
  /// The same seed produces the same result. Every step filters candidates by
  /// effective Cost, selects among positive-weight candidates by weighted
  /// roulette, deducts Cost, and repeats.
  static WaveGeneratorSpawnPreview simulateRandomSpawns({
    required int points,
    required int fixedSpawnCount,
    required List<WaveGeneratorSpawnCandidate> candidates,
    int iterations = defaultSimulationIterations,
    int seed = _stablePreviewSeed,
    List<String> missingDataTypes = const [],
    List<String> zeroWeightTypes = const [],
    bool? poolIsEmpty,
  }) {
    final safeIterations = max(1, iterations);
    final random = Random(seed);
    final totalCounts = <String, int>{
      for (final candidate in candidates) candidate.id: 0,
    };
    final generatedTotals = <int>[];

    for (var run = 0; run < safeIterations; run++) {
      var remainingPoints = max(0, points);
      var generated = 0;
      while (remainingPoints > 0 && generated < maxRandomSpawns) {
        final affordable = candidates
            .where(
              (candidate) =>
                  candidate.cost > 0 &&
                  candidate.cost <= remainingPoints &&
                  candidate.weight > 0,
            )
            .toList();
        if (affordable.isEmpty) break;

        final totalWeight = affordable.fold<double>(
          0,
          (sum, candidate) => sum + candidate.weight,
        );
        if (totalWeight <= 0) break;
        var pick = random.nextDouble() * totalWeight;
        var selected = affordable.last;
        for (final candidate in affordable) {
          pick -= candidate.weight;
          if (pick < 0) {
            selected = candidate;
            break;
          }
        }

        remainingPoints -= selected.cost;
        generated++;
        totalCounts[selected.id] = (totalCounts[selected.id] ?? 0) + 1;
      }
      generatedTotals.add(generated);
    }

    generatedTotals.sort();
    int percentile(double value) {
      if (generatedTotals.isEmpty) return 0;
      final index = ((generatedTotals.length - 1) * value).round();
      return generatedTotals[index];
    }

    final entries = [
      for (final candidate in candidates)
        WaveGeneratorSpawnPreviewEntry(
          id: candidate.id,
          cost: candidate.cost,
          weight: candidate.weight,
          averageCount:
              (totalCounts[candidate.id] ?? 0) / safeIterations.toDouble(),
        ),
    ]..sort((a, b) => b.averageCount.compareTo(a.averageCount));

    return WaveGeneratorSpawnPreview(
      points: points,
      fixedSpawnCount: fixedSpawnCount,
      iterations: safeIterations,
      averageTotal: generatedTotals.isEmpty
          ? 0
          : generatedTotals.reduce((a, b) => a + b) / generatedTotals.length,
      commonMinimum: percentile(0.10),
      commonMaximum: percentile(0.90),
      entries: entries,
      missingDataTypes: missingDataTypes,
      zeroWeightTypes: zeroWeightTypes,
      randomSpawnsEnabled: true,
      poolIsEmpty: poolIsEmpty ?? candidates.isEmpty,
    );
  }

  static WaveGeneratorSpawnPreview calculatePreview(
    WaveGeneratorPropertiesData data,
    int waveNumber, {
    int iterations = defaultSimulationIterations,
  }) {
    final inRange = waveNumber >= 1 && waveNumber <= data.waves.length;
    final wave = inRange ? data.waves[waveNumber - 1] : null;
    final points = pointsAtWave(data, waveNumber);
    final pool = poolEntriesAtWave(data, waveNumber);
    final missing = <String>[];
    final zeroWeight = <String>[];
    final candidates = _resolveCandidates(pool, missing, zeroWeight);
    final enabled = wave != null && !wave.disableRandomSpawns;
    final fixedCount = wave?.zombies.length ?? 0;

    // Zombies without usable cost/weight data and zero-weight entries are
    // reported but do not block valid positive-weight candidates.
    if (!enabled || points <= 0 || pool.isEmpty) {
      return WaveGeneratorSpawnPreview(
        points: points,
        fixedSpawnCount: fixedCount,
        iterations: 0,
        averageTotal: 0,
        commonMinimum: 0,
        commonMaximum: 0,
        entries: const [],
        missingDataTypes: List.unmodifiable(missing),
        zeroWeightTypes: List.unmodifiable(zeroWeight),
        randomSpawnsEnabled: enabled,
        poolIsEmpty: pool.isEmpty,
      );
    }

    final cacheKey = [
      waveNumber,
      points,
      fixedCount,
      iterations,
      for (final candidate in candidates)
        '${candidate.id}:${candidate.cost}:${candidate.weight}',
      missing.join(','),
      zeroWeight.join(','),
    ].join('|');
    final cached = _previewCache[cacheKey];
    if (cached != null) return cached;

    final preview = simulateRandomSpawns(
      points: points,
      fixedSpawnCount: fixedCount,
      candidates: candidates,
      iterations: iterations,
      seed: _stablePreviewSeed + waveNumber,
      missingDataTypes: List.unmodifiable(missing),
      zeroWeightTypes: List.unmodifiable(zeroWeight),
      poolIsEmpty: pool.isEmpty,
    );
    if (_previewCache.length >= 64) {
      _previewCache.remove(_previewCache.keys.first);
    }
    _previewCache[cacheKey] = preview;
    return preview;
  }

  /// Zombie count summed across every wave of the generator: each run buys
  /// zombies wave by wave with the wave's own pool and budget, so the range
  /// reflects how a whole playthrough's random spawning behaves.
  static ZombieCountEstimate simulateTotalZombieCount(
    WaveGeneratorPropertiesData data,
  ) {
    final waves =
        <({List<({int cost, double weight})> candidates, int points})>[];
    final missing = <String>[];
    final zeroWeight = <String>[];
    for (var waveNumber = 1; waveNumber <= data.waves.length; waveNumber++) {
      final wave = data.waves[waveNumber - 1];
      if (wave.disableRandomSpawns) continue;
      final points = pointsAtWave(data, waveNumber);
      if (points <= 0) continue;
      final candidates = _resolveCandidates(
        poolEntriesAtWave(data, waveNumber),
        missing,
        zeroWeight,
      );
      if (candidates.isEmpty) continue;
      waves.add((
        candidates: [
          for (final candidate in candidates)
            (cost: candidate.cost, weight: candidate.weight),
        ],
        points: points,
      ));
    }
    return ZombieCountSimulation.simulateWeightedTotal(waves);
  }

  static bool showExpectationForWave(
    WaveGeneratorPropertiesData data,
    int waveNumber,
  ) {
    if (waveNumber < 1 || waveNumber > data.waves.length) return false;
    return !data.waves[waveNumber - 1].disableRandomSpawns &&
        pointsAtWave(data, waveNumber) > 0 &&
        poolAtWave(data, waveNumber).isNotEmpty;
  }
}

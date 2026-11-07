import 'dart:math' as math;

/// Approximate zombie spawn count for point budgets: a mean plus a common
/// range (10th–90th percentile of Monte-Carlo runs), the same idea the
/// Wave Generator preview already uses.
class ZombieCountEstimate {
  const ZombieCountEstimate({
    required this.average,
    required this.minimum,
    required this.maximum,
  });

  /// Mean simulated spawn count across all runs.
  final double average;

  /// 10th percentile of the simulated totals.
  final int minimum;

  /// 90th percentile of the simulated totals.
  final int maximum;
}

/// Monte-Carlo estimation of how many zombies a point budget buys. Wave
/// Manager callers use the uniform methods; the legacy Wave Generator uses
/// the weighted methods because its runtime builds a ProbabilitySet.
class ZombieCountSimulation {
  ZombieCountSimulation._();

  static const int iterations = 600;
  static const int maxSpawnsPerWave = 50;
  static const int _seed = 0x5a0b1e5;
  static const int _cacheLimit = 64;

  static final math.Random _rng = math.Random(_seed);
  static final Map<String, ZombieCountEstimate> _cache =
      <String, ZombieCountEstimate>{};

  /// Estimate for a single wave: [costs] are the WavePointCost values of the
  /// affordable pool (values below 1 are ignored), [points] is the wave
  /// budget.
  static ZombieCountEstimate simulateWave(List<int> costs, int points) {
    final valid = costs.where((c) => c >= 1).toList()..sort();
    if (valid.isEmpty || points <= 0) {
      return const ZombieCountEstimate(average: 0, minimum: 0, maximum: 0);
    }
    final key = 'wave|$points|${valid.join(',')}';
    return _cache.putIfAbsent(key, () {
      if (_cache.length > _cacheLimit) _cache.clear();
      final totals = List<int>.filled(iterations, 0);
      var sum = 0.0;
      for (var i = 0; i < iterations; i++) {
        final count = _simulateOnce(valid, points);
        totals[i] = count;
        sum += count;
      }
      totals.sort();
      return ZombieCountEstimate(
        average: sum / iterations,
        minimum: totals[_percentileIndex(0.10)],
        maximum: totals[_percentileIndex(0.90)],
      );
    });
  }

  /// Estimate summed over independent waves: each run buys zombies in every
  /// wave and the totals are added, so the range reflects per-wave variance
  /// as well.
  static ZombieCountEstimate simulateTotal(
    List<({List<int> costs, int points})> waves,
  ) {
    final prepared = <(List<int>, int)>[];
    for (final wave in waves) {
      final valid = wave.costs.where((c) => c >= 1).toList()..sort();
      if (valid.isEmpty || wave.points <= 0) continue;
      prepared.add((valid, wave.points));
    }
    if (prepared.isEmpty) {
      return const ZombieCountEstimate(average: 0, minimum: 0, maximum: 0);
    }
    final key =
        'total|${[for (final (costs, points) in prepared) '$points:${costs.join(',')}'].join('|')}';
    return _cache.putIfAbsent(key, () {
      if (_cache.length > _cacheLimit) _cache.clear();
      final totals = List<int>.filled(iterations, 0);
      var sum = 0.0;
      for (var i = 0; i < iterations; i++) {
        var runTotal = 0;
        for (final (costs, points) in prepared) {
          runTotal += _simulateOnce(costs, points);
        }
        totals[i] = runTotal;
        sum += runTotal;
      }
      totals.sort();
      return ZombieCountEstimate(
        average: sum / iterations,
        minimum: totals[_percentileIndex(0.10)],
        maximum: totals[_percentileIndex(0.90)],
      );
    });
  }

  /// Weighted counterpart used by the legacy Wave Generator. Candidates with
  /// non-positive cost or weight are ignored; each purchase re-filters by the
  /// remaining point budget before performing weighted roulette selection.
  static ZombieCountEstimate simulateWeightedTotal(
    List<({List<({int cost, double weight})> candidates, int points})> waves,
  ) {
    final prepared = <(List<({int cost, double weight})>, int)>[];
    for (final wave in waves) {
      final valid = wave.candidates
          .where((candidate) => candidate.cost >= 1 && candidate.weight > 0)
          .toList();
      if (valid.isEmpty || wave.points <= 0) continue;
      prepared.add((valid, wave.points));
    }
    if (prepared.isEmpty) {
      return const ZombieCountEstimate(average: 0, minimum: 0, maximum: 0);
    }
    final key =
        'weighted-total|${[
          for (final (candidates, points) in prepared) '$points:${[for (final candidate in candidates) '${candidate.cost}@${candidate.weight}'].join(',')}',
        ].join('|')}';
    return _cache.putIfAbsent(key, () {
      if (_cache.length > _cacheLimit) _cache.clear();
      final totals = List<int>.filled(iterations, 0);
      var sum = 0.0;
      for (var i = 0; i < iterations; i++) {
        var runTotal = 0;
        for (final (candidates, points) in prepared) {
          runTotal += _simulateWeightedOnce(candidates, points);
        }
        totals[i] = runTotal;
        sum += runTotal;
      }
      totals.sort();
      return ZombieCountEstimate(
        average: sum / iterations,
        minimum: totals[_percentileIndex(0.10)],
        maximum: totals[_percentileIndex(0.90)],
      );
    });
  }

  /// One purchase loop with the given pre-sorted costs.
  static int _simulateOnce(List<int> sortedCosts, int points) {
    var remaining = points;
    var count = 0;
    while (count < maxSpawnsPerWave) {
      final affordable = _affordableCount(sortedCosts, remaining);
      if (affordable <= 0) break;
      remaining -= sortedCosts[_rng.nextInt(affordable)];
      count++;
    }
    return count;
  }

  static int _simulateWeightedOnce(
    List<({int cost, double weight})> candidates,
    int points,
  ) {
    var remaining = points;
    var count = 0;
    while (count < maxSpawnsPerWave) {
      final affordable = candidates
          .where(
            (candidate) => candidate.cost <= remaining && candidate.weight > 0,
          )
          .toList();
      if (affordable.isEmpty) break;
      final totalWeight = affordable.fold<double>(
        0,
        (sum, candidate) => sum + candidate.weight,
      );
      if (totalWeight <= 0) break;
      var pick = _rng.nextDouble() * totalWeight;
      var selected = affordable.last;
      for (final candidate in affordable) {
        pick -= candidate.weight;
        if (pick < 0) {
          selected = candidate;
          break;
        }
      }
      remaining -= selected.cost;
      count++;
    }
    return count;
  }

  /// Number of entries in the sorted cost list that are <= [budget].
  static int _affordableCount(List<int> sortedCosts, int budget) {
    var low = 0;
    var high = sortedCosts.length;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (sortedCosts[mid] <= budget) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }

  static int _percentileIndex(double percentile) {
    final index = (percentile * (iterations - 1)).round();
    return index.clamp(0, iterations - 1);
  }
}

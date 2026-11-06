import 'dart:math' as math;
import 'dart:typed_data';

import 'pvz_models.dart';
import 'rtid_parser.dart';
import 'repository/zombie_properties_repository.dart';

/// Expected spawn counts of a point prediction (Wave Manager point budget).
class WaveExpectation {
  const WaveExpectation({
    this.expectation = const {},
    this.missingStats = const [],
    this.customIds = const [],
  });

  /// Expected count per zombie type id. Zombies without reliable data are
  /// present with a value of `0.0`.
  final Map<String, double> expectation;

  /// Ids excluded from the calculation because no usable WavePointCost data
  /// exists (unknown or custom zombies, or property sheets without cost).
  final List<String> missingStats;

  /// Ids that came from custom `@CurrentLevel` (or otherwise unknown) pool
  /// entries. They have no point cost data, so prediction lists show every
  /// other pool zombie as a row and report only these ids as missing data.
  final List<String> customIds;

  /// Ids that must not appear as prediction rows: custom entries and
  /// entries without WavePointCost data. Weight = 0 does not matter — the
  /// Wave Manager / Escalation Spawning purchase path does not read the
  /// sheet's Weight. Legacy WaveGenerator previewing is handled separately.
  Set<String> get hiddenIds => {...missingStats, ...customIds};
}

class WavePointAnalysis {
  /// Highest point budget the expectation DP handles. A wave is capped at
  /// 60000 base points and flag waves multiply that by 2.5.
  static const int maxBudgetPoints = 150000;

  /// Base points cap per wave before the flag-wave multiplier.
  static const int basePointCap = 60000;

  static Map<String, double> calculate(
    List<InputEntry> entries,
    int totalPoints,
  ) {
    if (totalPoints <= 0 || entries.isEmpty) {
      return {for (final e in entries) e.id: 0.0};
    }
    // Wave Manager / Escalation Spawning selects uniformly among affordable
    // pool entries and ignores the sheet's Weight. The legacy WaveGenerator
    // uses a separate weighted simulation. Entries without usable cost data
    // never spawn in this path.
    final valid = entries.where((e) => e.cost >= 1).toList();
    if (valid.isEmpty) return {for (final e in entries) e.id: 0.0};

    final safePoints = totalPoints.clamp(0, maxBudgetPoints);
    final n = valid.length;
    final cost = Int32List(n);
    for (var i = 0; i < n; i++) {
      cost[i] = valid[i].cost;
    }

    // Group the candidate counts by cost: the recurrence only depends on how
    // many distinct types sit behind each distinct cost, not on single
    // entries.
    final countByCost = <int, int>{};
    for (var i = 0; i < n; i++) {
      if (cost[i] < 1) continue;
      countByCost.update(cost[i], (c) => c + 1, ifAbsent: () => 1);
    }
    var maxCost = 0;
    for (final c in countByCost.keys) {
      if (c > maxCost) maxCost = c;
    }

    final exp = List<Float64List>.generate(
      n,
      (_) => Float64List(safePoints + 1),
    );

    // Phase 1: the budget is still below the most expensive zombie, so the
    // affordable set grows with every point.
    final affordableCosts = <int>[];
    final affordableCounts = <double>[];
    var candidateSum = 0.0;
    final phase1End = math.min(maxCost, safePoints);
    for (var p = 1; p <= phase1End; p++) {
      final added = countByCost[p];
      if (added != null) {
        affordableCosts.add(p);
        affordableCounts.add(added.toDouble());
        candidateSum += added;
      }
      if (candidateSum <= 0) {
        for (var j = 0; j < n; j++) {
          exp[j][p] = exp[j][p - 1];
        }
        continue;
      }
      for (var j = 0; j < n; j++) {
        final row = exp[j];
        var sum = 0.0;
        for (var k = 0; k < affordableCosts.length; k++) {
          sum +=
              affordableCounts[k] / candidateSum * row[p - affordableCosts[k]];
        }
        if (cost[j] >= 1 && cost[j] <= p) {
          sum += 1 / candidateSum;
        }
        row[p] = sum;
      }
    }

    // Phase 2: every zombie is affordable, so the probabilities stay fixed
    // and the rest of the budget is a plain linear recurrence.
    if (candidateSum > 0 && safePoints > phase1End) {
      final groupProb = Float64List(affordableCosts.length);
      for (var k = 0; k < affordableCosts.length; k++) {
        groupProb[k] = affordableCounts[k] / candidateSum;
      }
      final spawnProb = Float64List(n);
      for (var j = 0; j < n; j++) {
        if (cost[j] >= 1) spawnProb[j] = 1 / candidateSum;
      }
      for (var p = phase1End + 1; p <= safePoints; p++) {
        for (var j = 0; j < n; j++) {
          final row = exp[j];
          var sum = spawnProb[j];
          for (var k = 0; k < affordableCosts.length; k++) {
            sum += groupProb[k] * row[p - affordableCosts[k]];
          }
          row[p] = sum;
        }
      }
    }

    final result = <String, double>{};
    for (var i = 0; i < n; i++) {
      result[valid[i].id] = exp[i][safePoints];
    }
    for (final e in entries) {
      result.putIfAbsent(e.id, () => 0.0);
    }
    return result;
  }

  /// Resolves pool RTIDs into calculation entries using the bundled zombie
  /// reference. Entries from `@ZombieTypes` (or any alias the bundled
  /// reference knows) are treated as non-custom; custom `@CurrentLevel`
  /// entries have no point cost data and are flagged via
  /// [InputEntry.custom] so lists can report them as missing data.
  /// Entries listed more than once are merged so they count once.
  static List<InputEntry> resolveEntries(List<String> pool) {
    final byId = <String, InputEntry>{};
    for (final rtid in pool) {
      final info = RtidParser.parse(rtid);
      final alias = info?.alias ?? rtid;
      if (alias.isEmpty) continue;
      final custom =
          info?.source != 'ZombieTypes' &&
          !ZombiePropertiesRepository.isValidAlias(alias);
      final typeName = ZombiePropertiesRepository.getTypeNameByAlias(alias);
      final id = typeName.isNotEmpty ? typeName : alias;
      final stats = ZombiePropertiesRepository.getStats(typeName);
      final existing = byId[id];
      if (existing == null) {
        byId[id] = InputEntry(id: id, cost: stats.cost, custom: custom);
      } else {
        existing.custom = existing.custom && custom;
      }
    }
    return byId.values.toList();
  }

  /// Full prediction for a pool: expectation plus ids with missing stats.
  static WaveExpectation analyzePool(List<String> pool, int points) {
    if (pool.isEmpty) return const WaveExpectation();
    final entries = resolveEntries(pool);
    final missing = <String>[
      for (final e in entries)
        if (e.cost < 1) e.id,
    ];
    final custom = <String>[
      for (final e in entries)
        if (e.custom) e.id,
    ];
    if (points <= 0) {
      return WaveExpectation(
        expectation: {for (final e in entries) e.id: 0.0},
        missingStats: missing,
        customIds: custom,
      );
    }
    return WaveExpectation(
      expectation: calculate(entries, points),
      missingStats: missing,
      customIds: custom,
    );
  }

  /// All zombie pool RTIDs of the Wave Manager groups active at [waveIndex].
  /// When [waveIndex] is null every group is included.
  static List<String> poolForWave(ParsedLevelData parsed, int? waveIndex) {
    final waveModule = parsed.waveModule is WaveManagerModuleData
        ? parsed.waveModule as WaveManagerModuleData
        : null;
    if (waveModule == null) return const [];
    final pool = <String>[];
    for (final group in waveModule.dynamicZombies) {
      if (waveIndex != null && waveIndex < group.startingWave + 1) continue;
      pool.addAll(group.zombiePool);
    }
    return pool;
  }

  /// Point prediction for the Wave Manager: covers the zombie pools of every
  /// group active at [waveIndex] (or of all groups when [waveIndex] is null).
  static WaveExpectation analyze(
    int points,
    ParsedLevelData parsed, {
    int? waveIndex,
  }) {
    final pool = poolForWave(parsed, waveIndex);
    if (pool.isEmpty) return const WaveExpectation();
    return analyzePool(pool, points);
  }

  static Map<String, double> calculateExpectation(
    int points,
    ParsedLevelData parsed, {
    int? waveIndex,
  }) {
    if (points <= 0) return {};
    return analyze(points, parsed, waveIndex: waveIndex).expectation;
  }
}

class InputEntry {
  InputEntry({required this.id, required this.cost, this.custom = false});
  final String id;

  /// WavePointCost from the bundled sheet; `0` when the cost data is missing.
  final int cost;

  /// True when the pool entry is not a zombie the bundled reference knows
  /// (custom `@CurrentLevel` zombie or unknown alias).
  bool custom;
}

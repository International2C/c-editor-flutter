import 'package:c_editor/data/zombie_count_simulation.dart';
import 'package:c_editor/l10n/app_localizations.dart';

enum ZombieCountEstimateScope { wave, allWaves }

/// Formats a simulated average to one decimal place without keeping a
/// redundant trailing zero (for example, `2` instead of `2.0`).
String formatEstimatedCount(double value) {
  final fixed = value.toStringAsFixed(1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}

/// Builds the localized summary for a simulated count. A collapsed percentile
/// interval is omitted because `2–2` adds no information beyond "about 2".
String zombieCountEstimateText(
  AppLocalizations? l10n,
  ZombieCountEstimate estimate, {
  required ZombieCountEstimateScope scope,
}) {
  final count = formatEstimatedCount(estimate.average);
  final hasRange = estimate.minimum != estimate.maximum;

  return switch ((scope, hasRange)) {
    (ZombieCountEstimateScope.wave, false) =>
      l10n?.zombieCountWaveEstimateNoRange(count) ?? 'This wave: about $count',
    (ZombieCountEstimateScope.wave, true) =>
      l10n?.zombieCountWaveEstimate(
            count,
            estimate.minimum,
            estimate.maximum,
          ) ??
          'This wave: about $count '
              '(common range: ${estimate.minimum}–${estimate.maximum})',
    (ZombieCountEstimateScope.allWaves, false) =>
      l10n?.zombieCountTotalEstimateNoRange(count) ??
          'All waves combined: about $count',
    (ZombieCountEstimateScope.allWaves, true) =>
      l10n?.zombieCountTotalEstimate(
            count,
            estimate.minimum,
            estimate.maximum,
          ) ??
          'All waves combined: about $count '
              '(common range: ${estimate.minimum}–${estimate.maximum})',
  };
}

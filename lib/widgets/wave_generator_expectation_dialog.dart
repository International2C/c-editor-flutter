import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/wave_generator_point_analysis.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart' show isDesktopPlatform;
import 'package:c_editor/widgets/zombie_count_estimate_text.dart';

const _kUnknownIconPath = 'assets/images/others/unknown.webp';

double _expectationDialogIconSize(BuildContext context) {
  final isDesktop = isDesktopPlatform(context);
  final compact = MediaQuery.sizeOf(context).width < 400;
  if (isDesktop) return compact ? 44 : 48;
  return compact ? 36 : 40;
}

void showWaveGeneratorExpectationDialog(
  BuildContext context, {
  required WaveGeneratorPropertiesData data,
  required int waveIndex,
}) {
  final l10n = AppLocalizations.of(context);
  final preview = WaveGeneratorPointAnalysis.calculatePreview(data, waveIndex);
  // Candidates already exclude custom and no-data zombies; rows whose
  // simulated average rounds to 0.00 for this wave's budget are dropped —
  // a wave with a richer budget still shows them.
  final shownItems = [
    for (final entry in preview.entries)
      if (entry.averageCount >= 0.005) entry,
  ];
  // Summed estimate across every wave of the generator, shown below the
  // per-wave numbers so the dialog covers a whole playthrough as well.
  final totalEstimate = preview.canCalculate
      ? WaveGeneratorPointAnalysis.simulateTotalZombieCount(data)
      : null;

  showDialog<void>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final mediaSize = MediaQuery.sizeOf(ctx);
      final iconSize = _expectationDialogIconSize(ctx);
      final summaryStyle = theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
      );
      final body = <Widget>[
        Text(
          l10n?.waveGeneratorEffectiveRandomPoints(preview.points) ??
              'Effective random-spawn points: ${preview.points}',
          style: summaryStyle,
        ),
      ];

      final missing = preview.missingDataTypes;
      final zeroWeight = preview.zeroWeightTypes;
      // Only block the whole preview when nothing was left to simulate;
      // otherwise the remaining pool zombies are still listed.
      final blocked =
          missing.isNotEmpty &&
          preview.entries.isEmpty &&
          preview.randomSpawnsEnabled &&
          preview.points > 0;

      if (blocked) {
        body.addAll([
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n?.waveGeneratorExpectationMissingData(missing.join(', ')) ??
                    'Preview unavailable because some zombies are missing WavePointCost data: ${missing.join(', ')}',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ),
        ]);
        if (zeroWeight.isNotEmpty) {
          body.addAll([
            const SizedBox(height: 12),
            Text(
              l10n?.waveGeneratorExpectationZeroWeight(zeroWeight.join(', ')) ??
                  'These zombies have a random-spawn weight of 0 and will not '
                      'be selected by the Wave Generator: '
                      '${zeroWeight.join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ]);
        }
      } else {
        body.addAll([
          if (missing.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n?.waveGeneratorExpectationMissingData(missing.join(', ')) ??
                  'These zombies have no resolvable effective spawn cost or '
                      'weight and are excluded from the preview: '
                      '${missing.join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (zeroWeight.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n?.waveGeneratorExpectationZeroWeight(zeroWeight.join(', ')) ??
                  'These zombies have a random-spawn weight of 0 and will not '
                      'be selected by the Wave Generator: '
                      '${zeroWeight.join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (!preview.randomSpawnsEnabled) ...[
            const SizedBox(height: 12),
            Text(
              l10n?.waveGeneratorExpectationDisabled ??
                  'Random spawning is disabled on this wave.',
            ),
          ] else if (preview.poolIsEmpty ||
              preview.points <= 0 ||
              (shownItems.isEmpty &&
                  !(preview.entries.isEmpty && zeroWeight.isNotEmpty))) ...[
            const SizedBox(height: 12),
            Text(
              l10n?.waveGeneratorExpectationEmpty ??
                  'No eligible pool zombies for random spawns on this wave.',
              style: theme.textTheme.bodySmall,
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              l10n?.waveGeneratorExpectationEstimatedTotal(
                    formatEstimatedCount(preview.averageTotal),
                  ) ??
                  'Average random spawns: about '
                      '${formatEstimatedCount(preview.averageTotal)}',
              style: summaryStyle,
            ),
            if (preview.commonMinimum != preview.commonMaximum) ...[
              const SizedBox(height: 4),
              Text(
                l10n?.waveGeneratorExpectationCommonRange(
                      preview.commonMinimum,
                      preview.commonMaximum,
                    ) ??
                    'Common range: ${preview.commonMinimum}–${preview.commonMaximum}',
                style: summaryStyle,
              ),
            ],
            if (totalEstimate != null && totalEstimate.average > 0) ...[
              const SizedBox(height: 6),
              Text(
                zombieCountEstimateText(
                  l10n,
                  totalEstimate,
                  scope: ZombieCountEstimateScope.allWaves,
                ),
                style: summaryStyle,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              l10n?.waveGeneratorExpectationPoolNote ??
                  'This is a stable statistical preview of repeated weighted '
                      'selections from the current effective pool, not a '
                      'prediction of the game RNG.',
              key: const ValueKey('waveGeneratorExpectationPoolNote'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final entry in shownItems)
              Builder(
                builder: (context) {
                  final typeName = entry.id;
                  final info = ZombieRepository().getZombieById(typeName);
                  final nameKey =
                      info?.name ?? ZombieRepository().getName(typeName);
                  final displayName = ResourceNames.lookup(ctx, nameKey);
                  final iconPath = info?.iconAssetPath ?? _kUnknownIconPath;
                  return _ExpectationZombieEntryTile(
                    iconSize: iconSize,
                    iconPath: iconPath,
                    displayName: displayName.isNotEmpty
                        ? displayName
                        : typeName,
                    typeName: typeName,
                    costWeightLabel:
                        l10n?.waveGeneratorExpectationCostWeight(
                          entry.cost,
                          entry.weight.toStringAsFixed(0),
                        ) ??
                        'Cost ${entry.cost} · Weight ${entry.weight.toStringAsFixed(0)}',
                    averageLabel:
                        l10n?.waveGeneratorExpectationAverageCount(
                          entry.averageCount.toStringAsFixed(2),
                        ) ??
                        'Avg. ${entry.averageCount.toStringAsFixed(2)}',
                  );
                },
              ),
          ],
        ]);
      }

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: mediaSize.height - 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l10n?.waveGeneratorExpectationTitle(waveIndex) ??
                            '${l10n?.waveLabel ?? 'Wave'} $waveIndex — Random spawn preview',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: l10n?.close ?? 'Close',
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: body,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ExpectationZombieEntryTile extends StatelessWidget {
  const _ExpectationZombieEntryTile({
    required this.iconSize,
    required this.iconPath,
    required this.displayName,
    required this.typeName,
    required this.costWeightLabel,
    required this.averageLabel,
  });

  final double iconSize;
  final String iconPath;
  final String displayName;
  final String typeName;
  final String costWeightLabel;
  final String averageLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 420 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: AssetImageWidget(
                      assetPath: iconPath,
                      altCandidates: imageAltCandidates(iconPath),
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      typeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: secondaryStyle,
                    ),
                    Text(
                      costWeightLabel,
                      key: const ValueKey('waveGeneratorExpectationCostWeight'),
                      style: secondaryStyle,
                    ),
                    if (compact) ...[
                      const SizedBox(height: 4),
                      Text(
                        averageLabel,
                        key: const ValueKey(
                          'waveGeneratorExpectationAverageCount',
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    averageLabel,
                    key: const ValueKey('waveGeneratorExpectationAverageCount'),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

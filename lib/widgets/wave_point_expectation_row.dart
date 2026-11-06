import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:flutter/material.dart';

class WavePointExpectationRow extends StatelessWidget {
  const WavePointExpectationRow({
    super.key,
    required this.typeName,
    required this.expectedCount,
    required this.countKey,
    required this.iconSize,
    this.fallbackIconPath,
  });

  final String typeName;
  final double expectedCount;
  final Key countKey;
  final double iconSize;
  final String? fallbackIconPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final repository = ZombieRepository();
    final info = repository.getZombieById(typeName);
    final name = ResourceNames.lookupOrFallback(
      context,
      info?.name ?? repository.getName(typeName),
      typeName,
    );
    final iconPath = info?.iconAssetPath ?? fallbackIconPath;
    final cost = ZombiePropertiesRepository.getStats(typeName).cost;
    final formattedCount = expectedCount.toStringAsFixed(2);
    final count = Text(
      l10n?.pointSpawnExpectedCount(formattedCount) ?? formattedCount,
      key: countKey,
      style: theme.textTheme.bodyMedium,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final stackCount =
            constraints.maxWidth < iconSize + 18 + 220 * textScale;
        return Row(
          crossAxisAlignment: stackCount
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: SizedBox.square(
                  dimension: iconSize,
                  child: iconPath != null
                      ? AssetImageWidget(
                          assetPath: iconPath,
                          altCandidates: imageAltCandidates(iconPath),
                          width: iconSize,
                          height: iconSize,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            name.isEmpty ? '?' : name[0].toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
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
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (name != typeName)
                    Text(
                      typeName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    l10n?.zombiePointCost(cost) ?? 'Point cost: $cost',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (stackCount) ...[const SizedBox(height: 4), count],
                ],
              ),
            ),
            if (!stackCount) ...[const SizedBox(width: 8), count],
          ],
        );
      },
    );
  }
}

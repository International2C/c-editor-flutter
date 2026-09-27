import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';

/// Coordinates are measured from the left edge of column 1, at 64 per tile.
/// Markers show configured positions without predicting the live zombie buffer.
class CamelSpawnDistancePreview extends StatelessWidget {
  const CamelSpawnDistancePreview({
    super.key,
    required this.rows,
    required this.columns,
    required this.maxSpawnX,
    required this.minSpawnXStart,
    required this.minSpawnXEnd,
  });
  final int rows;
  final int columns;
  final double maxSpawnX;
  final double minSpawnXStart;
  final double minSpawnXEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final markers = [
      ('MaxSpawnX', l10n.camelMaxSpawnX, maxSpawnX, Colors.red),
      (
        'MinSpawnXStart',
        l10n.camelMinSpawnXStart,
        minSpawnXStart,
        Colors.green,
      ),
      ('MinSpawnXEnd', l10n.camelMinSpawnXEnd, minSpawnXEnd, Colors.blue),
    ];
    final start = math.min(0.0, markers.map((m) => m.$3).reduce(math.min)) - 16;
    final end =
        math.max(columns * 64.0, markers.map((m) => m.$3).reduce(math.max)) +
        16;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = constraints.maxWidth / (end - start);
                final height = (rows * 64 * scale).clamp(140.0, 450.0);
                double x(double value) => (value - start) * scale;
                return Column(
                  children: [
                    SizedBox(
                      height: 24,
                      child: Stack(
                        children: [
                          for (var col = 0; col <= columns; col++)
                            Positioned(
                              left: x(col * 64.0) - 12,
                              width: 24,
                              top: 0,
                              bottom: 0,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('${col * 64}'),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height,
                      child: Stack(
                        key: const ValueKey('camelSpawnDistancePreview'),
                        children: [
                          Positioned.fill(
                            child: ColoredBox(
                              color: colors.surfaceContainerHighest,
                            ),
                          ),
                          Positioned(
                            left: x(0),
                            width: columns * 64 * scale,
                            top: 0,
                            bottom: 0,
                            child: Column(
                              children: [
                                for (var row = 0; row < rows; row++)
                                  Expanded(
                                    child: Row(
                                      children: [
                                        for (var col = 0; col < columns; col++)
                                          Expanded(
                                            child: Container(
                                              key: ValueKey(
                                                'camelSpawnCell-$row-$col',
                                              ),
                                              decoration: BoxDecoration(
                                                color: colors.primaryContainer
                                                    .withValues(alpha: 0.3),
                                                border: Border.all(
                                                  color: colors.outline,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          for (final marker in markers)
                            Positioned(
                              left: x(marker.$3) - 1.5,
                              width: 3,
                              top: 0,
                              bottom: 0,
                              child: ColoredBox(
                                key: ValueKey('camelSpawnLine-${marker.$1}'),
                                color: marker.$4,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final marker in markers)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: Icon(Icons.circle, color: marker.$4, size: 12),
                ),
                Expanded(
                  child: Text(
                    '${marker.$2}: ${marker.$3 == marker.$3.roundToDouble() ? marker.$3.toInt() : marker.$3}',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

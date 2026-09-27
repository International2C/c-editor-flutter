import 'package:flutter/material.dart';

/// The wave number and its optional flag share one unwrapped label.
class WaveNumberLabel extends StatelessWidget {
  const WaveNumberLabel({
    super.key,
    required this.waveNumber,
    required this.isFlagWave,
    this.fontSize = 16,
    this.flagSize = 12,
  });

  final int waveNumber;
  final bool isFlagWave;
  final double fontSize;
  final double flagSize;

  static const _flagGap = 2.0;

  TextStyle _textStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      );

  /// Reserve flag space even on ordinary waves so changing the flag interval
  /// does not shift the event content. Measure with the same scale as [build].
  Size minimumSize(BuildContext context, {required double minWidth}) {
    final painter = TextPainter(
      text: TextSpan(text: '$waveNumber', style: _textStyle(context)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      maxLines: 1,
    )..layout();
    final size = Size(
      (painter.width.ceilToDouble() + _flagGap + flagSize).clamp(
        minWidth,
        double.infinity,
      ),
      painter.height.ceilToDouble().clamp(flagSize, double.infinity),
    );
    painter.dispose();
    return size;
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        '$waveNumber',
        style: _textStyle(context),
        maxLines: 1,
        softWrap: false,
      ),
      if (isFlagWave)
        Padding(
          padding: const EdgeInsets.only(left: _flagGap),
          child: Icon(
            Icons.flag,
            size: flagSize,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
    ],
  );
}

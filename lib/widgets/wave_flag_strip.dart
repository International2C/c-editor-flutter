import 'dart:math' as math;

import 'package:c_editor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const _minimumTooltipTargetSize = 44.0;
const _majorTickHeight = 12.0;
const _minorTickHeight = 7.0;

/// A wave ruler, following the game's right-to-left wave order.
///
/// Every wave has a tick. The first, final and flag waves have longer ticks
/// and labels. The ruler scrolls horizontally when the labels need more room.
class WaveFlagStrip extends StatefulWidget {
  const WaveFlagStrip({
    super.key,
    required this.waveCount,
    required this.isFlagWave,
    required this.color,
    this.width = 640,
    this.stripHeight = 4,
    this.flagSize = 26,
  });

  final int waveCount;
  final bool Function(int waveNumber) isFlagWave;
  final Color color;

  /// Preferred maximum width; narrower parents use all available space.
  final double width;
  final double stripHeight;
  final double flagSize;

  @override
  State<WaveFlagStrip> createState() => _WaveFlagStripState();
}

class _WaveFlagStripState extends State<WaveFlagStrip> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.waveCount;
    if (count <= 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    String waveCountLabel(int waves) =>
        l10n?.waveGeneratorWaveCountSummary(waves) ?? 'Total waves: $waves';
    final totalLabel = waveCountLabel(count);
    String waveLabel(int wave) =>
        l10n?.customZombieWaveItem(wave) ?? 'Wave $wave';
    final flagLabel = l10n?.waveFlagLabel ?? 'Flag wave';
    final style = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final flags = [
      for (var wave = count; wave >= 1; wave--)
        if (widget.isFlagWave(wave)) wave,
    ];
    final flagSet = flags.toSet();
    final segmentEnds = {count, ...flags}.toList()..sort();
    final markedWaves = {1, ...segmentEnds};
    final marks = markedWaves.toList().reversed.toList();
    final labelSizes = <Size>[];
    for (final wave in marks) {
      final painter = TextPainter(
        text: TextSpan(text: waveLabel(wave), style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        locale: Localizations.maybeLocaleOf(context),
        maxLines: 1,
      )..layout();
      labelSizes.add(painter.size);
      painter.dispose();
    }
    final labelHeight = labelSizes.map((s) => s.height).reduce(math.max);
    final flagTargetSize = math.max(_minimumTooltipTargetSize, widget.flagSize);
    final inset = math.max(
      flagTargetSize / 2,
      labelSizes.map((s) => s.width).reduce(math.max) / 2,
    );

    // Keep ticks distinct and reserve enough room for single-line labels
    // and flag hover targets, including at larger text scales.
    var minimumWaveSpacing = 8.0;
    for (var i = 1; i < marks.length; i++) {
      final gap = marks[i - 1] - marks[i];
      final needed = (labelSizes[i - 1].width + labelSizes[i].width) / 2 + 12;
      minimumWaveSpacing = math.max(minimumWaveSpacing, needed / gap);
    }
    for (var i = 1; i < flags.length; i++) {
      final gap = flags[i - 1] - flags[i];
      minimumWaveSpacing = math.max(minimumWaveSpacing, flagTargetSize / gap);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = math.min(
            constraints.maxWidth.isFinite ? constraints.maxWidth : widget.width,
            widget.width,
          );
          final contentWidth = math.max(
            viewportWidth,
            inset * 2 + (count - 1) * minimumWaveSpacing,
          );
          final trackWidth = math.max(0.0, contentWidth - inset * 2);
          final scrolls = contentWidth > viewportWidth + 0.5;
          final labelTop = flagTargetSize + widget.stripHeight + 8;
          final contentHeight = labelTop + labelHeight + 4;
          final waveSpacing = count == 1 ? 0.0 : trackWidth / (count - 1);
          final finalWaveX = count == 1 ? contentWidth / 2 : inset;
          double waveX(int wave) => finalWaveX + (count - wave) * waveSpacing;
          final trackInset = math.max(0.0, inset - widget.stripHeight / 2);
          final segmentTargetHeight = math.max(
            _minimumTooltipTargetSize,
            widget.stripHeight,
          );
          final segmentTop =
              flagTargetSize + (widget.stripHeight - segmentTargetHeight) / 2;

          // A flag at wave 1 still needs a tappable part of the track.
          double segmentBoundary(int wave) =>
              wave == 1 ? waveX(1) - waveSpacing / 2 : waveX(wave);

          Widget tooltip(String message, Widget child) => Tooltip(
            message: message,
            waitDuration: const Duration(milliseconds: 300),
            triggerMode: TooltipTriggerMode.longPress,
            child: child,
          );

          Widget segment(int index) {
            final first = index == 0 ? 1 : segmentEnds[index - 1] + 1;
            final last = segmentEnds[index];
            final label = first == last
                ? waveLabel(first)
                : '${waveLabel(first)} – ${waveLabel(last)}';
            return Positioned(
              left: last == count ? 0 : segmentBoundary(last),
              right: first == 1 ? 0 : contentWidth - segmentBoundary(first - 1),
              top: segmentTop,
              height: segmentTargetHeight,
              child: tooltip(
                '$label\n${waveCountLabel(last - first + 1)}',
                ColoredBox(
                  key: ValueKey('waveFlagStripSegment-$last'),
                  color: Colors.transparent,
                ),
              ),
            );
          }

          final ruler = SizedBox(
            width: contentWidth,
            height: contentHeight,
            child: Stack(
              children: [
                Positioned(
                  left: trackInset,
                  right: trackInset,
                  top: flagTargetSize,
                  height: widget.stripHeight,
                  child: DecoratedBox(
                    key: const ValueKey('waveFlagStripTrack'),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(
                        widget.stripHeight / 2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: flagTargetSize - _majorTickHeight,
                  left: 0,
                  right: 0,
                  height: _majorTickHeight,
                  child: CustomPaint(
                    key: const ValueKey('waveFlagStripTicks'),
                    painter: _WaveTicksPainter(
                      color: widget.color,
                      waveCount: count,
                      finalWaveX: finalWaveX,
                      waveSpacing: waveSpacing,
                      markedWaves: markedWaves,
                    ),
                  ),
                ),
                for (var i = 0; i < segmentEnds.length; i++) segment(i),
                // The flagpole covers its tick down to the track.
                for (final wave in flags)
                  Positioned(
                    left: waveX(wave) - flagTargetSize / 2,
                    top: 0,
                    width: flagTargetSize,
                    height: flagTargetSize,
                    child: tooltip(
                      '$flagLabel · ${waveLabel(wave)}\n$totalLabel',
                      ColoredBox(
                        key: ValueKey('waveFlagStripFlag-$wave'),
                        color: Colors.transparent,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: CustomPaint(
                            size: Size(flagTargetSize, widget.flagSize),
                            painter: const _WaveFlagPainter(),
                          ),
                        ),
                      ),
                    ),
                  ),
                for (var i = 0; i < marks.length; i++)
                  Positioned(
                    left: waveX(marks[i]) - labelSizes[i].width / 2,
                    top: labelTop,
                    child: tooltip(
                      '${flagSet.contains(marks[i]) ? '$flagLabel · ' : ''}'
                      '${waveLabel(marks[i])}\n$totalLabel',
                      Text(
                        waveLabel(marks[i]),
                        key: ValueKey('waveFlagStripLabel-${marks[i]}'),
                        style: style,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
              ],
            ),
          );
          return Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: viewportWidth,
              child: Semantics(
                label: totalLabel,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: scrolls,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    padding: EdgeInsets.only(bottom: scrolls ? 14 : 0),
                    child: ruler,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WaveFlagPainter extends CustomPainter {
  const _WaveFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final poleX = size.width / 2;
    final top = size.height / 8;
    final bannerWidth = math.min(poleX, size.height * 0.7);
    final foldX = poleX + bannerWidth * 0.6;
    final foldSize = size.height / 12;
    final bottom = size.height * 0.6;
    final paint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = size.height / 10;
    canvas.drawLine(Offset(poleX, top), Offset(poleX, size.height), paint);
    canvas.drawPath(
      Path()
        ..moveTo(poleX, top)
        ..lineTo(foldX, top)
        ..lineTo(foldX + foldSize, top + foldSize)
        ..lineTo(poleX + bannerWidth, top + foldSize)
        ..lineTo(poleX + bannerWidth, bottom + foldSize)
        ..lineTo(foldX, bottom + foldSize)
        ..lineTo(foldX - foldSize, bottom)
        ..lineTo(poleX, bottom)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(_WaveFlagPainter oldDelegate) => false;
}

class _WaveTicksPainter extends CustomPainter {
  const _WaveTicksPainter({
    required this.color,
    required this.waveCount,
    required this.finalWaveX,
    required this.waveSpacing,
    required this.markedWaves,
  });

  final Color color;
  final int waveCount;
  final double finalWaveX;
  final double waveSpacing;
  final Set<int> markedWaves;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var wave = waveCount; wave >= 1; wave--) {
      final x = finalWaveX + (waveCount - wave) * waveSpacing;
      final height = markedWaves.contains(wave) ? size.height : _minorTickHeight;
      canvas.drawLine(
        Offset(x, size.height - height),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveTicksPainter oldDelegate) =>
      color != oldDelegate.color ||
      waveCount != oldDelegate.waveCount ||
      finalWaveX != oldDelegate.finalWaveX ||
      waveSpacing != oldDelegate.waveSpacing ||
      markedWaves != oldDelegate.markedWaves;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models/GravityGeneratorWaveActionPropsData.dart';

/// Plant mode uses relative cells around (0, 0); grid mode uses the full lawn.
class GravityRangePreview extends StatelessWidget {
  const GravityRangePreview({
    super.key,
    required this.data,
    required this.rows,
    required this.cols,
    this.onTargetChanged,
  });

  final GravityGeneratorWaveActionPropsData data;
  final int rows;
  final int cols;
  final void Function(int col, int row)? onTargetChanged;

  @override
  Widget build(BuildContext context) {
    final gridMode = data.targetType == 'grid';
    final target = gridMode
        ? Offset(
            (data.targetGrid?.mx ?? 0).toDouble(),
            (data.targetGrid?.my ?? 0).toDouble(),
          )
        : Offset.zero;
    final range = Rect.fromLTWH(
      target.dx + data.range.mX,
      target.dy + data.range.mY,
      math.max(0, data.range.mWidth).toDouble(),
      math.max(0, data.range.mHeight).toDouble(),
    );
    final bounds = gridMode
        ? Rect.fromLTWH(0, 0, cols.toDouble(), rows.toDouble())
        : Rect.fromLTRB(
            math.min(0, range.left),
            math.min(0, range.top),
            math.max(1, range.right),
            math.max(1, range.bottom),
          );
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = (width * bounds.height / bounds.width).clamp(
              72.0,
              360.0,
            );
            return GestureDetector(
              onTapUp: gridMode && onTargetChanged != null
                  ? (details) {
                      final col = (details.localPosition.dx / width * cols)
                          .floor()
                          .clamp(0, cols - 1);
                      final row = (details.localPosition.dy / height * rows)
                          .floor()
                          .clamp(0, rows - 1);
                      onTargetChanged!(col, row);
                    }
                  : null,
              child: CustomPaint(
                key: const ValueKey('gravityRangeCanvas'),
                size: Size(width, height),
                painter: GravityRangePainter(
                  bounds: bounds,
                  range: range,
                  target: target,
                  fieldColor: data.gravityLevel == 'heavy'
                      ? Colors.green
                      : Colors.red,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  gridColor: theme.colorScheme.outline,
                  markerColor: theme.colorScheme.onSurface,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GravityRangePainter extends CustomPainter {
  const GravityRangePainter({
    required this.bounds,
    required this.range,
    required this.target,
    required this.fieldColor,
    required this.backgroundColor,
    required this.gridColor,
    required this.markerColor,
  });

  final Rect bounds;
  final Rect range;
  final Offset target;
  final Color fieldColor;
  final Color backgroundColor;
  final Color gridColor;
  final Color markerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / bounds.width;
    final sy = size.height / bounds.height;
    Offset point(double x, double y) =>
        Offset((x - bounds.left) * sx, (y - bounds.top) * sy);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    canvas.drawRect(
      Rect.fromPoints(
        point(range.left, range.top),
        point(range.right, range.bottom),
      ),
      Paint()..color = fieldColor.withValues(alpha: 0.55),
    );
    final line = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    // Imported offsets may be very large. Bound drawing work without changing the data.
    final xStep = math.max(1, (bounds.width / 100).ceil());
    final yStep = math.max(1, (bounds.height / 100).ceil());
    for (var x = bounds.left; x <= bounds.right; x += xStep) {
      canvas.drawLine(point(x, bounds.top), point(x, bounds.bottom), line);
    }
    for (var y = bounds.top; y <= bounds.bottom; y += yStep) {
      canvas.drawLine(point(bounds.left, y), point(bounds.right, y), line);
    }
    final center = point(target.dx + 0.5, target.dy + 0.5);
    final radius = (math.min(sx, sy) * 0.22).clamp(3.0, 12.0);
    final marker = Paint()
      ..color = markerColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, Paint()..color = backgroundColor);
    canvas.drawCircle(center, radius, marker);
    canvas.drawLine(
      center - Offset(radius * 1.5, 0),
      center + Offset(radius * 1.5, 0),
      marker,
    );
    canvas.drawLine(
      center - Offset(0, radius * 1.5),
      center + Offset(0, radius * 1.5),
      marker,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(GravityRangePainter old) =>
      bounds != old.bounds ||
      range != old.range ||
      target != old.target ||
      fieldColor != old.fieldColor ||
      backgroundColor != old.backgroundColor ||
      gridColor != old.gridColor ||
      markerColor != old.markerColor;
}

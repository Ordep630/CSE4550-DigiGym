import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dot_matrix_text.dart';

/// A supplied percentage only; never derives completion from a profile or plan.
class SegmentedProgressRing extends StatelessWidget {
  final double progress;
  final double diameter;

  SegmentedProgressRing({
    super.key,
    required double progress,
    this.diameter = 148,
  }) : progress = _validate(progress);

  static double _validate(double progress) {
    if (!progress.isFinite || progress < 0 || progress > 100) {
      throw ArgumentError.value(
        progress,
        'progress',
        'Use a percentage from 0 to 100',
      );
    }
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    // Display whole percentages; painting retains the exact supplied progress.
    // Three digits (100) are the largest display, including fractional inputs.
    final label = progress.round().toString();
    final theme = Theme.of(context);
    final size = diameter;
    final innerWidth = size * .64;
    final innerHeight = size * .64;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 12,
      color: theme.colorScheme.onSurfaceVariant,
    );
    final labelPainter = TextPainter(
      text: TextSpan(text: 'Complete', style: labelStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final labelHeight =
        labelPainter.height * math.min(1.0, innerWidth / labelPainter.width);
    labelPainter.dispose();
    // One fixed height for every value at these constraints. No value-specific
    // FittedBox: 0, 25, 75 and 100 all use identical digit dots and spacing.
    final digitHeight = math.min(
      MediaQuery.textScalerOf(context).scale(44),
      math.min(
        innerWidth / DotMatrixPainter.widthFor('100%', 1),
        innerHeight - labelHeight - 4,
      ),
    );
    return Semantics(
      label: '$label% complete',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: SegmentedProgressPainter(
            progress: progress,
            activeColor: theme.colorScheme.primary,
          ),
          child: Center(
            child: SizedBox(
              width: innerWidth,
              height: innerHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    key: const ValueKey('progress-percentage-bounds'),
                    height: digitHeight,
                    child: DotMatrixText(
                      key: const ValueKey('progress-percentage'),
                      text: '$label%',
                      height: digitHeight,
                      scaleWithText: false,
                      softenedDigits: true,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Complete', style: labelStyle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints inactive segments first, with fractional fill in the final active tick.
class SegmentedProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  static const segmentCount = 40;

  const SegmentedProgressPainter({
    required this.progress,
    required this.activeColor,
    this.inactiveColor = const Color(0xFF2B3530),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = math.min(size.width, size.height);
    final thickness = diameter * .065;
    final radius = (diameter - thickness) / 2;
    final length = 2 * math.pi * radius / segmentCount * .70;
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: thickness,
      height: length,
    );
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(length * .38));
    final paint = Paint()..color = inactiveColor;
    for (var index = 0; index < segmentCount; index++) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(-math.pi / 2 + index * 2 * math.pi / segmentCount);
      canvas.translate(radius, 0);
      paint.color = inactiveColor;
      canvas.drawRRect(shape, paint);
      final fraction = (progress / 100 * segmentCount - index).clamp(0.0, 1.0);
      if (fraction > 0) {
        canvas.clipRect(
          Rect.fromLTRB(
            rect.left,
            rect.top,
            rect.right,
            rect.top + rect.height * fraction,
          ),
        );
        paint.color = activeColor;
        canvas.drawRRect(shape, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(SegmentedProgressPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      activeColor != oldDelegate.activeColor ||
      inactiveColor != oldDelegate.inactiveColor;
}

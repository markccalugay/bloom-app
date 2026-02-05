import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../quiet_breath_constants.dart';

/// Draws a radial ring where the active arc fills 0→360° based on [phaseProgress].
class QuietBreathRingPainter extends CustomPainter {
  final double phaseProgress;  // 0..1 across entire session
  final Color trackColor;
  final Color phaseColor;

  const QuietBreathRingPainter({
    required this.phaseProgress,
    required this.trackColor,
    required this.phaseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Geometry: ring just outside the ellipse
    final ellipseRadius = kQBCircleSize / 2;
    final ringRadius = ellipseRadius + kQBRingOuterPadding + kQBRingThickness / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = kQBRingThickness
      ..strokeCap = StrokeCap.round;

    final active = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = kQBRingThickness
      ..strokeCap = StrokeCap.round;

    // Neutral track
    canvas.drawCircle(center, ringRadius, track);

    // Active sweep: 0..2π (start at 12 o’clock)
    final rect = Rect.fromCircle(center: center, radius: ringRadius);
    final sweep = (phaseProgress.clamp(0.0, 1.0)) * 2 * math.pi;
    if (sweep > 0) {
      canvas.drawArc(rect, -math.pi / 2, sweep, false, active);
    }
  }

  @override
  bool shouldRepaint(covariant QuietBreathRingPainter old) {
    return old.phaseProgress != phaseProgress ||
           old.trackColor != trackColor ||
           old.phaseColor != phaseColor;
  }
}
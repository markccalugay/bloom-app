import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../quiet_breath_constants.dart';

class QuietBreathWavePainter extends CustomPainter {
  final double phase;     // 0..2π horizontally animated
  final double progress;  // 0..1 water fill from bottom to top
  final double introT;    // 0..1 intro drop progress (0=full, 1=done)

  final Color waveColorMain;
  final Color waveColorDim;
  final Color ellipseBackgroundColor;

  QuietBreathWavePainter({
    required this.phase,
    required this.progress,
    required this.introT,
    required this.waveColorMain,
    required this.waveColorDim,
    required this.ellipseBackgroundColor,
  }) : assert(progress >= 0 && progress <= 1),
       assert(introT >= 0 && introT <= 1);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 1 || size.height <= 1) return;

    // Mask to a circle
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipPath(Path()..addOval(rect));

    // === Circle background fill ===
    final backgroundPaint = Paint()
      ..color = ellipseBackgroundColor.withValues(alpha: kQBCircleBackgroundOpacity)
      ..style = PaintingStyle.fill;

    // Fill the entire clipped circle before drawing waves
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      backgroundPaint,
    );

    // Optional: circle outline (slightly brighter for clarity)
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: kQBCircleBorderOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = kQBCircleBorderWidth;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      borderPaint,
    );

    // Compute baseline (water level) with intro-drop vs session-fill
    // introDrop: 1->0 (starts full, quickly drops to bottom)
    final introDrop = 1.0 - introT;
    final sessionFill = progress.clamp(0.0, 1.0);
    final effective = math.max(sessionFill, introDrop).clamp(0.0, 1.0);

    final waterY =
        size.height * (1.0 - (kQBWaterMin + (kQBWaterMax - kQBWaterMin) * effective));

    // Wave params
    final amp = kQBWaveAmplitude;
    final freq = (kQBWaveFrequencyBase * kQBWaveCyclesAcross) / size.width;
    final phaseFront = phase;
    final phaseBack = phase + kQBWavePhaseShift; // now π for complementary stacking
    final backYOffset = kQBWaveBackYOffset; // vertical lift of back wave

    // Build front wave
    final pathFront = Path()..moveTo(0, waterY);
    for (double x = -1; x <= size.width + 1; x += 0.5) {
      final y = waterY + amp * math.sin(freq * x + phaseFront);
      if (y.isFinite) pathFront.lineTo(x, y);
    }
    pathFront
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Build back wave (same amplitude, higher baseline)
    final baseBack = waterY + backYOffset;
    final pathBack = Path()..moveTo(0, baseBack);
    for (double x = -1; x <= size.width + 1; x += 0.5) {
      final y = baseBack + amp * math.sin(freq * x - phaseBack);
      if (y.isFinite) pathBack.lineTo(x, y);
    }
    pathBack
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final frontPaint = Paint()..color = waveColorMain.withValues(alpha: kQBFrontWaveAlpha);
    final backPaint  = Paint()..color = waveColorDim.withValues(alpha: kQBBackWaveAlpha);

    // Layering: configurable draw order
    if (kQBBackWaveOnTop) {
      canvas.drawPath(pathFront, frontPaint);
      canvas.drawPath(pathBack, backPaint);
    } else {
      canvas.drawPath(pathBack, backPaint);
      canvas.drawPath(pathFront, frontPaint);
    }
  }

  @override
  bool shouldRepaint(covariant QuietBreathWavePainter old) =>
      old.phase != phase || 
      old.progress != progress || 
      old.introT != introT ||
      old.waveColorMain != waveColorMain ||
      old.waveColorDim != waveColorDim ||
      old.ellipseBackgroundColor != ellipseBackgroundColor;
}

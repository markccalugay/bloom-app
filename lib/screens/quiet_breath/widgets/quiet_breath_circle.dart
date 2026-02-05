import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';
import '../controllers/quiet_breath_controller.dart';
import '../painters/quiet_breath_wave_painter.dart';
import '../painters/quiet_breath_ring_painter.dart';
import '../quiet_breath_constants.dart';

class QuietBreathCircle extends StatelessWidget {
  final QuietBreathController controller;
  const QuietBreathCircle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: controller.listenable,
      child: const SizedBox.expand(),
      builder: (context, child) {
        final ringSize = kQBCircleSize + 2 * (kQBRingOuterPadding + kQBRingThickness);
        
        final ringTrackColor = theme.brightness == Brightness.light
            ? Colors.black.withValues(alpha: 0.08)
            : QLColors.ringTrack;
        
        final ellipseBgColor = theme.brightness == Brightness.dark
            ? QLColors.ironGray
            : QLColors.paleStone;

        final waveDim = theme.colorScheme.primary.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.6 : 0.3,
        );

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radial ring (neutral track + active sweep by phase)
              SizedBox(
                width: ringSize,
                height: ringSize,
                child: CustomPaint(
                  painter: QuietBreathRingPainter(
                    phaseProgress: controller.phaseProgress,
                    trackColor: ringTrackColor,
                    phaseColor: controller.phaseColor,
                  ),
                ),
              ),
              // Inner ellipse + waves
              SizedBox(
                width: kQBCircleSize,
                height: kQBCircleSize,
                child: CustomPaint(
                  painter: QuietBreathWavePainter(
                    phase: controller.wavePhase,
                    progress: controller.sessionProgress,
                    introT: controller.introT,
                    waveColorMain: theme.colorScheme.primary,
                    waveColorDim: waveDim,
                    ellipseBackgroundColor: ellipseBgColor,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
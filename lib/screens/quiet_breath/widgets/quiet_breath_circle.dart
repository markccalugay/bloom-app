import 'package:flutter/material.dart';
import '../controllers/quiet_breath_controller.dart';
import '../painters/quiet_breath_wave_painter.dart';
import '../painters/quiet_breath_ring_painter.dart';
import '../quiet_breath_constants.dart';

class QuietBreathCircle extends StatelessWidget {
  final QuietBreathController controller;
  const QuietBreathCircle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.listenable,
      child: const SizedBox.expand(),
      builder: (context, child) {
        final ringSize = kQBCircleSize + 2 * (kQBRingOuterPadding + kQBRingThickness);
        final phaseIndex = controller.currentPhaseIndex;
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
                    phaseIndex: phaseIndex,
                    phaseProgress: controller.phaseProgress,
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
                    progress: controller.phaseProgress,
                    introT: controller.introT,
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
import 'package:flutter/material.dart';
import '../controllers/quiet_breath_controller.dart';
import '../quiet_breath_constants.dart';

/// Top header + instructional text for the Quiet Breath screen.
class QuietBreathTimerTitle extends StatelessWidget {
  final QuietBreathController controller;
  const QuietBreathTimerTitle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Header
    final String header = controller.isPlaying
        ? 'Find your quiet.'
        : (controller.isFresh ? 'Ready when you are.' : 'Paused.');

    // Instruction (phase-synced when playing)
    final String instruction = controller.isPlaying
        ? controller.phaseLabel
        : (controller.isFresh
            ? 'Press Start to begin.'
            : 'Tap Resume to continue.');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: kQBHeaderTopGap),
        Text(
          header,
          style: const TextStyle(
            color: kQBTextColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: kQBHeaderToInstructionGap),
        Text(
          instruction,
          style: TextStyle(
            color: kQBTextColor.withValues(alpha: 0.80),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
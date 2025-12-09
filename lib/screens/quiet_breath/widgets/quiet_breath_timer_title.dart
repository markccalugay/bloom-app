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
    String instruction;
    if (controller.isPlaying) {
      switch (controller.boxPhaseIndex) {
        case 0:
          instruction = 'Inhale slowly.';
          break;
        case 1:
          instruction = 'Hold steady.';
          break;
        case 2:
          instruction = 'Exhale gently.';
          break;
        default:
          instruction = 'Hold steady.';
      }
    } else if (controller.isFresh) {
      instruction = 'Press Start to begin.';
    } else {
      instruction = 'Tap Resume to continue.';
    }

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
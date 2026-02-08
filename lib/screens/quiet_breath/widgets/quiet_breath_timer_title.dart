import 'package:flutter/material.dart';
import '../controllers/quiet_breath_controller.dart';
import '../quiet_breath_constants.dart';

/// Top header + instructional text for the Quiet Breath screen.
class QuietBreathTimerTitle extends StatelessWidget {
  final QuietBreathController controller;
  const QuietBreathTimerTitle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

    // ANIMATION CALCULATIONS
    // Reset animations to original values if the session is fully finished.
    // Otherwise, calculate progress based on the first cycle.
    final bool isSessionComplete = !controller.isPlaying && controller.sessionProgress >= 1.0;
    
    final double cycle1Progress = isSessionComplete
        ? 0.0
        : (controller.sessionProgress * controller.targetCycles).clamp(0.0, 1.0);

    // Fade out "Find your quiet." specifically.
    // If paused or fresh, we keep it at 1.0.
    final double headerOpacity =
        (header == 'Find your quiet.') ? (1.0 - cycle1Progress) : 1.0;

    // Increase instruction size from 16.8 to 21.0 during cycle 1.
    // We keep the larger size for the rest of the session.
    final double instructionSize = 16.8 + (4.2 * cycle1Progress);

    // RHYTHMIC FADING CALCULATIONS
    // We want the text to fade out ~500ms before the phase ends and fade back in 
    // at the start of the next phase. This ensures zero overlap.
    double instructionOpacity = 1.0;
    if (controller.isPlaying) {
      final double progress = controller.phaseProgress;
      final double phaseDuration = controller.contract.phases[controller.phaseIndex].seconds.toDouble();
      
      // Use a 500ms window, but clamp it so it doesn't exceed 40% of the phase duration
      // (important for very fast phases like in Cold Resolve).
      final double fadePercentage = (0.5 / phaseDuration).clamp(0.0, 0.4);
      
      if (progress < fadePercentage) {
        // Fade In
        instructionOpacity = Curves.easeInOut.transform(progress / fadePercentage);
      } else if (progress > (1.0 - fadePercentage)) {
        // Fade Out
        instructionOpacity = Curves.easeInOut.transform((1.0 - progress) / fadePercentage);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: headerOpacity,
          child: Text(
            header,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: kQBHeaderToInstructionGap),
        Opacity(
          opacity: instructionOpacity,
          child: Text(
            instruction,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: instructionSize,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
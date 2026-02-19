import 'package:flutter/material.dart';
import 'package:bloom_app/data/affirmations/affirmations_model.dart';
import '../controllers/bloom_breath_controller.dart';
import '../bloom_breath_constants.dart';

/// Top header + instructional text for the Bloom Breath screen.
class BloomBreathTimerTitle extends StatelessWidget {
  final BloomBreathController controller;
  final List<Affirmation> affirmations;

  const BloomBreathTimerTitle({
    super.key,
    required this.controller,
    this.affirmations = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGuided = affirmations.isNotEmpty && controller.isPlaying;

    // Header logic
    String header;
    if (isGuided) {
      final int index = (controller.sessionProgress * affirmations.length)
          .floor()
          .clamp(0, affirmations.length - 1);
      header = affirmations[index].text;
    } else {
      header = controller.isPlaying
          ? 'Find your quiet.'
          : (controller.isFresh ? 'Ready when you are.' : 'Paused.');
    }

    // Instruction (phase-synced when playing)
    final String instruction = controller.isPlaying
        ? controller.phaseLabel
        : (controller.isFresh
            ? 'Press Start to begin.'
            : 'Tap Resume to continue.');

    // ANIMATION CALCULATIONS
    final bool isSessionComplete =
        !controller.isPlaying && controller.sessionProgress >= 1.0;

    final double cycle1Progress = isSessionComplete
        ? 0.0
        : (controller.sessionProgress * controller.targetCycles).clamp(0.0, 1.0);

    // Header Opacity
    double headerOpacity = 1.0;
    if (isGuided) {
      // Cycle-based fading for affirmations
      final double cycleProgress = (controller.sessionProgress * controller.targetCycles) % 1.0;
      
      // Use the same 500ms fade logic as instructions but smoothed
      if (cycleProgress < 0.1) {
        headerOpacity = cycleProgress / 0.1;
      } else if (cycleProgress > 0.9) {
        headerOpacity = (1.0 - cycleProgress) / 0.1;
      }
    } else {
      // Original logic for non-guided sessions
      headerOpacity =
          (header == 'Find your quiet.') ? (1.0 - cycle1Progress) : 1.0;
    }

    // Increase instruction size from 16.8 to 21.0 during cycle 1.
    final double instructionSize = 16.8 + (4.2 * cycle1Progress);

    // RHYTHMIC FADING CALCULATIONS for instructions
    double instructionOpacity = 1.0;
    if (controller.isPlaying) {
      final double progress = controller.phaseProgress;
      final double phaseDuration = controller
          .contract.phases[controller.phaseIndex].seconds
          .toDouble();

      final double fadePercentage = (0.5 / phaseDuration).clamp(0.0, 0.4);

      if (progress < fadePercentage) {
        instructionOpacity =
            Curves.easeInOut.transform(progress / fadePercentage);
      } else if (progress > (1.0 - fadePercentage)) {
        instructionOpacity =
            Curves.easeInOut.transform((1.0 - progress) / fadePercentage);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 80, // Fixed height for header to prevent jumping
          child: Opacity(
            opacity: headerOpacity,
            child: Center(
              child: Text(
                header,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: isGuided ? 26 : 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
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
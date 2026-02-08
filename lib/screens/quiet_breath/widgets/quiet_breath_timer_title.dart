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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          // Use Interval curves to ensure fade-out completes before fade-in starts.
          switchInCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
          switchOutCurve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            instruction,
            key: ValueKey<String>(instruction),
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
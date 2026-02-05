import 'package:flutter/material.dart';
import '../controllers/quiet_breath_controller.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';

/// Bottom primary control button (Start / Pause / Resume)
class QuietBreathControls extends StatelessWidget {
  final QuietBreathController controller;
  final bool hasStarted;
  final bool isPlaying;
  const QuietBreathControls({
    super.key,
    required this.controller,
    required this.hasStarted,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.listenable,
      builder: (_, _) {
        if (!hasStarted) {
          return QLPrimaryButton(
            label: 'Start Quiet Time',
            onPressed: controller.toggle,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

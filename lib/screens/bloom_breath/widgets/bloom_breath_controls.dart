import 'package:flutter/material.dart';
import '../controllers/bloom_breath_controller.dart';
import 'package:bloom_app/widgets/bloom_primary_button.dart';

/// Bottom primary control button (Start / Pause / Resume)
class BloomBreathControls extends StatelessWidget {
  final BloomBreathController controller;
  final bool hasStarted;
  final bool isPlaying;
  final VoidCallback? onStart;

  const BloomBreathControls({
    super.key,
    required this.controller,
    required this.hasStarted,
    required this.isPlaying,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.listenable,
      builder: (_, _) {
        if (!hasStarted) {
          return BloomPrimaryButton(
            label: 'Start Bloom Time',
            onPressed: onStart,
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

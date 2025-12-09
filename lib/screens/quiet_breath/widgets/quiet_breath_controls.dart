import 'package:flutter/material.dart';
import '../controllers/quiet_breath_controller.dart';
import '../quiet_breath_constants.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';

/// Bottom primary control button (Start / Pause / Resume)
class QuietBreathControls extends StatelessWidget {
  final QuietBreathController controller;
  const QuietBreathControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.listenable,
      builder: (_, _) {
        return QLPrimaryButton(
          label: controller.primaryLabel,
          onPressed: controller.toggle,
          backgroundColor: kQBWaveColorMain,
          textColor: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        );
      },
    );
  }
}

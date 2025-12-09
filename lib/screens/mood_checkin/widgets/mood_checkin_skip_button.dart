import 'package:flutter/material.dart';
import '../mood_checkin_constants.dart';

class MoodCheckinSkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const MoodCheckinSkipButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kMCSkipTopGap),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          'Skip for now',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kMCLowLabelColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
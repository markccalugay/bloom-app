import 'package:flutter/material.dart';
import '../mood_checkin_constants.dart';

class MoodCheckinHeader extends StatelessWidget {
  final String text;

  const MoodCheckinHeader({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: kMCTextColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}
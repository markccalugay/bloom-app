import 'package:flutter/material.dart';

class QuietHomeStreakRow extends StatelessWidget {
  final int streak;

  const QuietHomeStreakRow({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Day $streak of showing up.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
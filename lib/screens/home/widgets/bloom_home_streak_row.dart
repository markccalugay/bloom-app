import 'package:flutter/material.dart';

class BloomHomeStreakRow extends StatelessWidget {
  final int streak;

  const BloomHomeStreakRow({
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
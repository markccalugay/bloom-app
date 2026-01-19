import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';

/// Inline, low-pressure unlock prompt shown inside results flows.
/// Designed to acknowledge progress without interrupting it.
class QuietInlineUnlockCard extends StatelessWidget {
  final VoidCallback onExplore;

  const QuietInlineUnlockCard({
    super.key,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You’ve built momentum.',
              style: textTheme.titleSmall?.copyWith(
                color: onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore deeper breathing practices designed for steadiness, discipline, and recovery.',
              style: textTheme.bodyMedium?.copyWith(
                color: onSurface.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onExplore,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  foregroundColor: QLColors.primaryTeal,
                  textStyle: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Explore deeper practices'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
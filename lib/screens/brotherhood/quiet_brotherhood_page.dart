import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';

/// Placeholder Brotherhood / community page.
/// This gives the bottom nav a real destination and avoids build errors
/// until the full community experience is implemented.
class QuietBrotherhoodPage extends StatelessWidget {
  const QuietBrotherhoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: QLColors.background,
      appBar: AppBar(
        title: const Text('Brotherhood'),
        backgroundColor: QLColors.background,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Brotherhood is coming soon.',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You\'ll be able to share what you\'re going through and encourage other men who are doing the same.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

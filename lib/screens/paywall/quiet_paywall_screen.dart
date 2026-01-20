import 'package:flutter/material.dart';
import '../../theme/ql_theme.dart';

class QuietPaywallScreen extends StatelessWidget {
  const QuietPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: QLColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                'Go Deeper',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Unlock additional breathing practices designed to build discipline, calm, and resilience.',
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Unlock QuietLine+'),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Maybe later',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
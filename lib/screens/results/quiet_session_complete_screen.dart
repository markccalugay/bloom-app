import 'package:flutter/material.dart';
import 'quiet_results_constants.dart';

class QuietSessionCompleteScreen extends StatelessWidget {
  const QuietSessionCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: QuietResultsConstants.horizontalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: QuietResultsConstants.verticalSpacingLarge,
              ),

              // Primary copy
              Text(
                'You came back.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(
                height: QuietResultsConstants.verticalSpacingSmall,
              ),

              Text(
                'That’s discipline.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(
                height: QuietResultsConstants.verticalSpacingLarge,
              ),

              // Subtext
              Text(
                'Calm compounds.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(
                height: QuietResultsConstants.verticalSpacingLarge,
              ),

              // Continue CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
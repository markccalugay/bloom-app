import 'package:flutter/material.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';

import 'quiet_results_constants.dart';
import 'quiet_results_strings.dart';
import 'widgets/quiet_results_streak_badge.dart';
import 'widgets/quiet_results_streak_row.dart';

/// “You showed up again” results screen shown when mood >= 3.
class QuietResultsOkScreen extends StatelessWidget {
  final int streak;
  final bool isNew; // pass true when streak just increased

  const QuietResultsOkScreen({
    super.key,
    required this.streak,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: QuietResultsConstants.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Headline (centered)
              Text(
                QuietResultsStrings.okHeadline,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.left,
              ),

              const SizedBox(height: 8),

              // Subcopy (centered)
              Text(
                QuietResultsStrings.okSub,
                style: textTheme.bodyMedium?.copyWith(
                  color: (textTheme.bodyMedium?.color ?? Colors.white)
                      .withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.left,
              ),

              const Spacer(),

              // Center block: day label, big flame, small flames
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Day X of your quiet streak.
                    Text(
                      QuietResultsStrings.dayOfStreak(streak),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(
                      height: QuietResultsConstants.verticalSpacingMedium,
                    ),

                    // Big SVG flame badge
                    QuietResultsStreakBadge(
                      streak: streak,
                      isNew: isNew,
                    ),

                    const SizedBox(
                      height: QuietResultsConstants.verticalSpacingSmall,
                    ),

                    // Small flame row
                    QuietResultsStreakRow(streak: streak),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom primary button, matching design
              QLPrimaryButton(
                label: QuietResultsStrings.continueButton,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const QuietShellScreen(),
                    ),
                    (route) => false,
                  );
                },
                margin: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                  bottom: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
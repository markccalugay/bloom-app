import 'package:flutter/material.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'quiet_results_constants.dart';
import 'quiet_results_strings.dart';
import 'package:quietline_app/screens/quiet_breath/quiet_breath_screen.dart';
import 'package:quietline_app/services/support_call_service.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';

const bool kDistressResultsEnabled = false;

/// Distress results screen shown when mood < 3.
class QuietResultsNotOkScreen extends StatelessWidget {
  const QuietResultsNotOkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDistressResultsEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const QuietShellScreen(),
          ),
        );
      });

      return const Scaffold(body: SizedBox.shrink());
    }

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

              // Headline
              Text(
                QuietResultsStrings.notOkHeadline,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.left,
              ),

              // More breathing room under headline
              const SizedBox(
                height: QuietResultsConstants.verticalSpacingMedium,
              ),

              // Merged microcopy
              Text(
                '${QuietResultsStrings.notOkSubLine1} ${QuietResultsStrings.notOkSubLine2}',
                style: textTheme.bodyMedium?.copyWith(
                  color: (textTheme.bodyMedium?.color ?? Colors.white)
                      .withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.left,
              ),

              const SizedBox(
                height: QuietResultsConstants.verticalSpacingLarge,
              ),

              // Soft decorative wave (slightly smaller height)
              Center(
                child: Container(
                  width: 140,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        QuietResultsConstants.softWaveColor
                            .withValues(alpha: 0.0),
                        QuietResultsConstants.softWaveColor
                            .withValues(alpha: 1.0),
                        QuietResultsConstants.softWaveColor
                            .withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: QuietResultsConstants.verticalSpacingMedium,
              ),

              const Spacer(),

              // Primary button: Ground again
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: QLPrimaryButton(
                    label: QuietResultsStrings.groundButton,
                    onPressed: () {
                      // Start a brand new quiet session with a fresh sessionId.
                      final newSessionId = DateTime.now().toIso8601String();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => QuietBreathScreen(
                            sessionId: newSessionId,
                          ),
                        ),
                      );
                    },
                    margin: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(
                height: QuietResultsConstants.verticalSpacingSmall,
              ),

              // Supportive line under grounding
              Text(
                "We’ll guide you through a short reset.",
                style: textTheme.bodySmall?.copyWith(
                  color: (textTheme.bodySmall?.color ?? Colors.white)
                      .withValues(alpha: 0.8),
                ),
              ),

              const SizedBox(
                height: QuietResultsConstants.verticalSpacingMedium,
              ),

              // Secondary button: 988 (white background + red 988 text)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: QLPrimaryButton(
                    label: QuietResultsStrings.call988Button,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Call 988?'),
                          content: const Text(
                            'This will open your phone\'s dialer to call 988 for crisis support. '
                            'If you are in immediate danger, please call your local emergency number.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Call 988'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await SupportCallService.call988();
                      }
                    },
                    margin: EdgeInsets.zero,
                    backgroundColor: Colors.white,
                    textColor: const Color(0xFFDD4A48),
                  ),
                ),
              ),

              const SizedBox(
                height: QuietResultsConstants.verticalSpacingSmall,
              ),

              // Reassurance under 988
              Text(
                "If talking would help, support is there 24/7.",
                style: textTheme.bodySmall?.copyWith(
                  color: (textTheme.bodySmall?.color ?? Colors.white)
                      .withValues(alpha: 0.8),
                ),
              ),

              // Footer safety copy
              Text(
                QuietResultsStrings.footer988,
                style: textTheme.bodySmall?.copyWith(
                  color: (textTheme.bodySmall?.color ?? Colors.white)
                      .withValues(alpha: 0.8),
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
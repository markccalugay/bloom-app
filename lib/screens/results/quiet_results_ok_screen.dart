import 'package:flutter/material.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/data/affirmations/affirmations_unlock_service.dart';
import 'package:quietline_app/data/affirmations/affirmations_model.dart';

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
                onPressed: () async {
                  if (isNew) {
                    final unlockService = AffirmationsUnlockService.instance;
                    await unlockService.unlockIfEligibleForToday(streak);
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuietAffirmationUnlockedScreen(streak: streak),
                      ),
                    );
                    return;
                  }

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

/// Post-results interstitial shown only when a new streak day is earned.
/// It reveals the newly unlocked affirmation for that day.
class QuietAffirmationUnlockedScreen extends StatefulWidget {
  final int streak;

  const QuietAffirmationUnlockedScreen({
    super.key,
    required this.streak,
  });

  @override
  State<QuietAffirmationUnlockedScreen> createState() =>
      _QuietAffirmationUnlockedScreenState();
}

class _QuietAffirmationUnlockedScreenState
    extends State<QuietAffirmationUnlockedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  late final Future<Affirmation?> _affirmationFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _affirmationFuture = AffirmationsUnlockService.instance.getUnlockedForStreak(widget.streak);

    // Start animation on first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatMonthDayYear(DateTime now) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[now.month - 1];
    return '$month ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final unlockedLabel =
        'Unlocked on Day ${widget.streak} ${_formatMonthDayYear(DateTime.now())}';

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

              Text(
                'New affirmation unlocked',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                unlockedLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: (textTheme.bodyMedium?.color ?? Colors.white)
                      .withValues(alpha: 0.85),
                ),
              ),

              const Spacer(),

              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: FutureBuilder<Affirmation?>
                          (
                        future: _affirmationFuture,
                        builder: (context, snapshot) {
                          final text = snapshot.data?.text ?? 'You showed up today.';

                          return Text(
                            text,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

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
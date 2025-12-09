import 'package:flutter/material.dart';

import '../home/widgets/quiet_home_app_bar.dart';
import '../home/widgets/quiet_home_streak_row.dart';
import '../home/widgets/quiet_home_affirmations_card.dart';
import 'package:quietline_app/data/affirmations/affirmations_service.dart';

/// QuietLine Home screen body.
///
/// NOTE:
/// - This widget does NOT include the bottom navigation bar.
///   That lives in `QuietShellScreen` with `QLBottomNav`.
/// - For now it only needs the current streak; affirmations
///   are stubbed with a placeholder string.
class QuietHomeScreen extends StatelessWidget {
  final int streak;
  final VoidCallback? onMenu;

  const QuietHomeScreen({
    super.key,
    required this.streak,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final service = const AffirmationsService();
    final todayAffirmation = service.getTodayCore();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top app bar (hamburger)
            QuietHomeAppBar(
              onMenuTap: () {
                // Delegate to shell / parent if provided.
                onMenu?.call();
              },
            ),

            const SizedBox(height: 24),

            // Streak row
            QuietHomeStreakRow(streak: streak),

            const SizedBox(height: 24),

            if (todayAffirmation != null)
              QuietHomeAffirmationsCard(
                title: todayAffirmation.text,
                unlockedLabel: 'Unlocked today',
                onTap: () {
                  // TODO: navigate to affirmation detail / library.
                },
              ),

            // Spacer pushes content up, leaving room for bottom nav
            const Spacer(),

            // Optional microcopy or footer can go here later.
            // For now, keep it clean.
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

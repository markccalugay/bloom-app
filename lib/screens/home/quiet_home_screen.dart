import 'package:flutter/material.dart';

import '../home/widgets/quiet_home_app_bar.dart';
import '../home/widgets/quiet_home_streak_row.dart';
import '../home/widgets/quiet_home_affirmations_card.dart';
import 'package:quietline_app/data/affirmations/affirmations_service.dart';
import 'package:quietline_app/widgets/quiet_home_ingot_background.dart';

const double kHomeHorizontalPadding = 16.0;
const double kHomeSectionSpacing = 24.0;
const double kHomeBottomSpacing = 16.0;

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
      child: Stack(
        children: [
          const QuietHomeIngotBackground(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
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

                const SizedBox(height: kHomeSectionSpacing),

                // Streak row
                QuietHomeStreakRow(streak: streak),

                const SizedBox(height: kHomeSectionSpacing),

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
                const SizedBox(height: kHomeBottomSpacing),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../home/widgets/quiet_home_app_bar.dart';
import '../home/widgets/quiet_home_streak_row.dart';
import '../home/widgets/quiet_home_affirmations_card.dart';
import 'package:quietline_app/data/affirmations/affirmations_service.dart';
import 'package:quietline_app/widgets/quiet_home_ingot_background.dart';

const double kHomeHorizontalPadding = 16.0;
const double kHomeTopSpacing = 20.0;          // space between app bar and streak
const double kHomeStreakToCardSpacing = 56.0; // space between streak and affirmation card
const double kHomeBottomSpacing = 16.0; 

String _formatToday() {
  final now = DateTime.now();
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
  final day = now.day; // no leading zero for this style
  final year = now.year;

  return '$month $day, $year';
}

Widget _buildHomeBody({
  required BuildContext context,
  required int streak,
  required String unlockedLabel,
  required String? affirmationText,
  required VoidCallback? onMenu,
}) {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuietHomeAppBar(
            onMenuTap: () {
              onMenu?.call();
            },
          ),

          const SizedBox(height: kHomeTopSpacing),

          QuietHomeStreakRow(streak: streak),

          const SizedBox(height: 40.0),

          const QuietHomeIngotBackground(),

          const SizedBox(height: 32.0),

          if (affirmationText != null)
            QuietHomeAffirmationsCard(
              title: affirmationText,
              unlockedLabel: unlockedLabel,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuietAffirmationFullscreenScreen(
                      text: affirmationText,
                      unlockedLabel: unlockedLabel,
                    ),
                  ),
                );
              },
            ),

          const Spacer(),
          const SizedBox(height: kHomeBottomSpacing),
        ],
      ),
    ),
  );
}

/// QuietLine Home screen body.
///
/// NOTE:
/// - This widget does NOT include the bottom navigation bar.
///   That lives in `QuietShellScreen` with `QLBottomNav`.
/// - For now it only needs the current streak; affirmations
///   are stubbed with a placeholder string.
class QuietHomeScreen extends StatefulWidget {
  final int streak;
  final VoidCallback? onMenu;

  const QuietHomeScreen({
    super.key,
    required this.streak,
    this.onMenu,
  });

  @override
  State<QuietHomeScreen> createState() => _QuietHomeScreenState();
}

class _QuietHomeScreenState extends State<QuietHomeScreen> {

  @override
  Widget build(BuildContext context) {
    final service = const AffirmationsService();

    // Home should not "pretend" an affirmation is unlocked.
    // Day 0 (FTUE) should return null; Day 1 -> core_001, etc.
    final todayAffirmation = service.getHomeCoreForStreakDay(widget.streak);

    final int day = widget.streak < 0 ? 0 : widget.streak;
    final String unlockedLabel = 'Unlocked on Day $day ${_formatToday()}';

    return _buildHomeBody(
      context: context,
      streak: widget.streak,
      unlockedLabel: unlockedLabel,
      affirmationText: todayAffirmation?.text,
      onMenu: widget.onMenu,
    );
  }
}

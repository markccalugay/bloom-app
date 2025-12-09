import 'package:flutter/material.dart';
import 'package:quietline_app/screens/home/quiet_home_screen.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_screen.dart';
import 'package:quietline_app/screens/brotherhood/quiet_brotherhood_page.dart';
import 'package:quietline_app/screens/quiet_breath/quiet_breath_screen.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_strings.dart';
import 'package:quietline_app/widgets/navigation/ql_bottom_nav.dart';
import 'package:quietline_app/widgets/navigation/ql_side_menu.dart';
import 'package:quietline_app/services/web_launch_service.dart';
import 'package:quietline_app/services/support_call_service.dart';
import 'package:quietline_app/screens/account/quiet_account_screen.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';

/// Root shell that hosts the bottom navigation and top-level tabs.
class QuietShellScreen extends StatefulWidget {
  const QuietShellScreen({super.key});

  @override
  State<QuietShellScreen> createState() => _QuietShellScreenState();
}

class _QuietShellScreenState extends State<QuietShellScreen> {
  int _currentIndex = 0;
  bool _isMenuOpen = false;
  int? _streak; // null = loading / unknown

  final _web = WebLaunchService();

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    try {
      final value = await QuietStreakService.getCurrentStreak();
      if (!mounted) return;
      setState(() {
        _streak = value;
      });
    } catch (_) {
      // If anything goes wrong, keep _streak as null/0 silently for MVP.
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        // Home: streak + affirmations
        return QuietHomeScreen(
          streak: _streak ?? 0,
          onMenu: _toggleMenu,
        );
      case 2:
        // Brotherhood / community
        return QuietBrotherhoodPage();
      default:
        return QuietHomeScreen(
          streak: _streak ?? 0,
          onMenu: _toggleMenu,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double menuWidth = 280.0;

    return Stack(
      children: [
        // Main scaffold with bottom nav and tab content
        Scaffold(
          body: _buildBody(),
          bottomNavigationBar: QLBottomNav(
            currentIndex: _currentIndex,
            onItemSelected: (index) {
              if (index == 1) {
                // Center QuietLine logo → start a new session flow beginning
                // at the pre mood check-in screen, with a fresh sessionId.
                final sessionId =
                    'session-${DateTime.now().millisecondsSinceEpoch}';

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MoodCheckinScreen(
                      mode: MoodCheckinMode.pre,
                      sessionId: sessionId,
                      onSubmit: (_) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                QuietBreathScreen(sessionId: sessionId),
                          ),
                        );
                      },
                      // onSkip is optional; controller handles navigation.
                      onSkip: null,
                    ),
                  ),
                );
              } else {
                // Left and right icons behave as true tabs (Home / Brotherhood).
                setState(() {
                  _currentIndex = index;
                });
              }
            },
          ),
        ),

        // Dimmed scrim when menu is open; tap to close
        if (_isMenuOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),

        // Slide-in side menu from the left
        AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          left: _isMenuOpen ? 0 : -menuWidth,
          width: menuWidth,
          child: QLSideMenu(
            displayName: 'Quiet guest',
            onClose: _toggleMenu,
            onOpenAccount: () {
              _toggleMenu();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QuietAccountScreen()),
              );
            },
            onNavigateBrotherhood: () {
              setState(() {
                _currentIndex = 2;
                _isMenuOpen = false;
              });
            },
            onNavigateAffirmations: () {
              setState(() {
                _currentIndex = 0;
                _isMenuOpen = false;
              });
            },
            onOpenAbout: _web.openAbout,
            onOpenWebsite: _web.openWebsite,
            onOpenSupport: _web.openSupport,
            onCall988: SupportCallService.call988,
            onOpenPrivacy: _web.openPrivacy,
            onOpenTerms: _web.openTerms,
          ),
        ),
      ],
    );
  }
}

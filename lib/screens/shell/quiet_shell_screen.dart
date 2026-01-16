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
import 'package:quietline_app/screens/affirmations/quiet_affirmations_library_screen.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';

import 'package:quietline_app/core/reminder/reminder_service.dart';

import 'package:quietline_app/data/user/user_service.dart';

import 'package:quietline_app/core/feature_flags.dart';

import 'package:quietline_app/services/first_launch_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
  String _displayName = 'Quiet guest';

  // Geometry measurement for Quiet Time button
  Rect? _quietTimeButtonRect;
  bool _didMeasureQuietTimeButton = false;

  bool _homeHintLoaded = false;
  bool _showHomeHint = false;

  bool _reminderPromptEligible = false;
  bool _checkedReminderEligibility = false;

  bool _showReminderPrompt = false;

  final _web = WebLaunchService();

  @override
  void initState() {
    super.initState();
    _loadStreak();
    _loadDisplayName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureQuietTimeButtonIfNeeded();
    });
  }

  Future<void> _loadStreak() async {
    try {
      final value = await QuietStreakService.getCurrentStreak();
      if (!mounted) return;
      setState(() {
        _streak = value;
      });
      await _loadHomeHintState();
    } catch (_) {
      // If anything goes wrong, keep _streak as null/0 silently for MVP.
    }
  }

  Future<void> _loadDisplayName() async {
    try {
      final user = await UserService.instance.getOrCreateUser();
      if (!mounted) return;
      setState(() {
        _displayName = user.username;
      });
    } catch (_) {
      // Silent fallback for MVP.
      if (!mounted) return;
      setState(() {
        _displayName = 'Quiet guest';
      });
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _measureQuietTimeButtonIfNeeded() {
    if (_didMeasureQuietTimeButton) return;

    final context = QLBottomNav.quietTimeButtonKey.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final topLeft = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() {
      _quietTimeButtonRect = topLeft & size;
      _didMeasureQuietTimeButton = true;
    });
  }

  Future<void> _loadHomeHintState() async {
    if (_homeHintLoaded) return;

    final hasSeen =
        await FirstLaunchService.instance.hasSeenHomeHint();

    if (!mounted) return;

    setState(() {
      _homeHintLoaded = true;
      _showHomeHint = (_streak ?? 0) >= 1 && !hasSeen;
    });

    // After home hint logic settles, check reminder eligibility if needed.
    if (!_checkedReminderEligibility && !_showHomeHint) {
      final prefs = await SharedPreferences.getInstance();
      final reminderService = ReminderService(prefs);

      final eligible = reminderService.shouldShowReminderPrompt(
        ftueCompleted: true,
        quietTimeSessionCount: _streak ?? 0,
      );
      if (!mounted) return;
      setState(() {
        _reminderPromptEligible = eligible;
        _checkedReminderEligibility = true;
      });

      if (_reminderPromptEligible) {
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (!mounted) return;
          // Do not show if Home hint is visible or already dismissed today
          if (_showHomeHint) return;
          setState(() {
            _showReminderPrompt = true;
          });
        });
      }
    }
  }

  Future<void> _dismissHomeHint() async {
    await FirstLaunchService.instance.markHomeHintSeen();
    if (!mounted) return;
    setState(() {
      _showHomeHint = false;
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

  Widget _buildHomeHintOverlay() {
    if (_quietTimeButtonRect == null || !_showHomeHint) {
      return const SizedBox.shrink();
    }

    final rect = _quietTimeButtonRect!;
    final double ringPadding = 12.0;
    final double ringSize =
        (rect.width > rect.height ? rect.width : rect.height) + ringPadding * 2;

    return Positioned.fill(
      child: Stack(
        children: [
          // Dimmed scrim; tap anywhere to dismiss (logic wired later)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dismissHomeHint,
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),

          // Spotlight ring centered on the Quiet Time button
          Positioned(
            left: rect.center.dx - ringSize / 2,
            top: rect.center.dy - ringSize / 2,
            width: ringSize,
            height: ringSize,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2FE6D2),
                    width: 3,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F141A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2A3340),
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Well done.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You just did the hardest part; starting.\n\n'
                        'Use Quiet Time anytime you need a reset.\n'
                        'Tap the button at the bottom to begin.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: Color(0xFFB9C3CF),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tap anywhere to continue',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8A99),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderPrompt() {
    if (!_showReminderPrompt) return const SizedBox.shrink();

    return Positioned(
      left: 16,
      right: 16,
      bottom: 96,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F141A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A3340)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Build a quiet habit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A short daily reminder can help you return to Quiet Time when you need it most.',
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: Color(0xFFB9C3CF),
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final reminderService = ReminderService(prefs);
                    await reminderService.markReminderPromptSeen();
                    if (!mounted) return;
                    setState(() {
                      _showReminderPrompt = false;
                    });
                  },
                  child: const Text(
                    'Later',
                    style: TextStyle(color: Color(0xFF7F8A99)),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2FE6D2),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final reminderService = ReminderService(prefs);
                    await reminderService.markReminderEnabled();
                    if (!mounted) return;
                    setState(() {
                      _showReminderPrompt = false;
                    });
                  },
                  child: const Text('Set a reminder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
            onItemSelected: (index) async {
              if (index == 1) {
                // Center QuietLine logo → start a new session.
                final sessionId =
                    'session-${DateTime.now().millisecondsSinceEpoch}';

                // MVP: mood check-ins are disabled. Keep the code path behind a flag
                // so we can reconnect in V2 by flipping FeatureFlags.moodCheckInsEnabled.
                if (!FeatureFlags.moodCheckInsEnabled) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuietBreathScreen(
                        sessionId: sessionId,
                        streak: _streak ?? 0,
                      ),
                    ),
                  );

                  // When the session flow finishes and we return here, reload streak
                  // so Home reflects the latest value.
                  if (!mounted) return;
                  await _loadStreak();
                  return;
                }

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MoodCheckinScreen(
                      mode: MoodCheckinMode.pre,
                      sessionId: sessionId,
                      onSubmit: (_) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuietBreathScreen(
                              sessionId: sessionId,
                              streak: _streak ?? 0,
                            ),
                          ),
                        );
                      },
                      // onSkip is optional; controller handles navigation.
                      onSkip: null,
                    ),
                  ),
                );

                // When the session flow finishes and we return here, reload streak
                // so Home reflects the latest value.
                if (!mounted) return;
                await _loadStreak();
              } else {
                // Left and right icons behave as true tabs (Home / Brotherhood).
                setState(() {
                  _currentIndex = index;
                });
              }
            },
          ),
        ),

        _buildHomeHintOverlay(),

        _buildReminderPrompt(),

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
            displayName: _displayName,
            onClose: _toggleMenu,
            onOpenAccount: () async {
              _toggleMenu();
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QuietAccountScreen()),
              );

              // If the user updated their display name, refresh it when we return.
              if (!mounted) return;
              await _loadDisplayName();
            },
            onNavigateBrotherhood: () {
              setState(() {
                _currentIndex = 2;
                _isMenuOpen = false;
              });
            },
            onNavigateAffirmations: () async {
              // Close the menu first.
              if (_isMenuOpen) {
                setState(() {
                  _isMenuOpen = false;
                });
              }

              // Open the Affirmations Library as a pushed screen.
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuietAffirmationsLibraryScreen(),
                ),
              );
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

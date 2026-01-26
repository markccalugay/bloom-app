import 'package:flutter/material.dart';
import 'package:quietline_app/screens/home/quiet_home_screen.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_screen.dart';
import 'package:quietline_app/screens/brotherhood/quiet_brotherhood_page.dart';
import 'package:quietline_app/screens/quiet_breath/quiet_breath_screen.dart';
import 'package:quietline_app/screens/quiet_breath/models/breath_phase_contracts.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_strings.dart';
import 'package:quietline_app/widgets/navigation/ql_bottom_nav.dart';
import 'package:quietline_app/widgets/navigation/ql_side_menu.dart';
import 'package:quietline_app/widgets/time_picker/quiet_time_picker_sheet.dart';
import 'package:quietline_app/services/web_launch_service.dart';
import 'package:quietline_app/services/support_call_service.dart';
import 'package:quietline_app/screens/account/quiet_account_screen.dart';
import 'package:quietline_app/screens/affirmations/quiet_affirmations_library_screen.dart';
import 'package:quietline_app/screens/practices/quiet_practice_library_screen.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';

import 'package:quietline_app/core/reminder/reminder_service.dart';
import 'package:quietline_app/widgets/reminder/reminder_prompt_card.dart';

import 'package:quietline_app/data/user/user_service.dart';

import 'package:quietline_app/core/feature_flags.dart';

import 'package:quietline_app/services/first_launch_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';


/// Root shell that hosts the bottom navigation and top-level tabs.
class QuietShellScreen extends StatefulWidget {
  const QuietShellScreen({super.key});

  @override
  State<QuietShellScreen> createState() => _QuietShellScreenState();
}

class _QuietShellScreenState extends State<QuietShellScreen> {
  // Ownership of the Quiet Time button key (non-static)
  final GlobalKey _quietTimeButtonKey = GlobalKey();
  int _currentIndex = 0;
  bool _isMenuOpen = false;
  int? _streak; // null = loading / unknown
  String _displayName = 'Quiet guest';

  TimeOfDay? _reminderTime;
  String _reminderLabel = 'Daily reminder · Not set';

  // Geometry measurement for Quiet Time button
  Rect? _quietTimeButtonRect;
  bool _didMeasureQuietTimeButton = false;

  bool _homeHintLoaded = false;
  bool _showHomeHint = false;


  final _web = WebLaunchService();

  @override
  void initState() {
    super.initState();
    _loadStreak();
    _loadDisplayName();
    _loadReminderState();
  }
  Future<void> _loadReminderState() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminderHour');
    final minute = prefs.getInt('reminderMinute');

    if (hour == null || minute == null) {
      if (!mounted) return;
      setState(() {
        _reminderTime = null;
        _reminderLabel = 'Daily reminder · Not set';
      });
      return;
    }

    final time = TimeOfDay(hour: hour, minute: minute);
    if (!mounted) return;
    setState(() {
      _reminderTime = time;
      _reminderLabel = 'Daily reminder · ${time.format(context)}';
    });
  }

  Future<void> _editReminderTime() async {
    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuietTimePickerSheet(
        initialTime: _reminderTime,
      ),
    );

    if (picked == null) return;

    final prefs = await SharedPreferences.getInstance();
    final reminderService = ReminderService(prefs);
    await reminderService.enableReminder(time: picked);

    await _loadReminderState();
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

  void _maybeMeasureQuietTimeButton() {
    if (_didMeasureQuietTimeButton) return;
    if (_currentIndex != 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureQuietTimeButtonIfNeeded();
    });
  }

  void _measureQuietTimeButtonIfNeeded() {
    if (_didMeasureQuietTimeButton) return;

    final context = _quietTimeButtonKey.currentContext;
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

    if (!_showHomeHint) {
      _maybeScheduleReminderPrompt();
    }
  }

  Future<void> _maybeScheduleReminderPrompt() async {
    if (_currentIndex != 0) {
      return;
    }
    // Only schedule if home hint is not showing and prompt isn't already shown.
    if (_showHomeHint) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final reminderService = ReminderService(prefs);
    final eligible = reminderService.shouldShowReminderPrompt(
      ftueCompleted: true,
      quietTimeSessionCount: _streak ?? 0,
    );
    if (!eligible) return;
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (_currentIndex != 0) return;
      if (!mounted) return;
      if (_showHomeHint) return;
      _showReminderModal();
    });
  }

  Future<void> _showReminderModal() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderService = ReminderService(prefs);

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ReminderPromptModalCard(
          actions: ReminderPromptActions(
            onLater: () async {
              await reminderService.markReminderPromptSeen();
              if (!mounted) return;
              Navigator.of(this.context).pop();
            },
            onEnable: () async {
              Navigator.of(context).pop();
              if (!mounted) return;
              final picked = await showModalBottomSheet<TimeOfDay>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const QuietTimePickerSheet(),
              );

              if (picked == null) {
                await reminderService.markReminderPromptSeen();
                return;
              }

              await reminderService.enableReminder(time: picked);
            },
          ),
        );
      },
    );
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

    return Stack(
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
    );
  }



  @override
  Widget build(BuildContext context) {
    const double menuWidth = 280.0;

    _maybeMeasureQuietTimeButton();

    return Stack(
      children: [
        // Main scaffold with bottom nav and tab content
        Scaffold(
          body: _buildBody(),
          bottomNavigationBar: QLBottomNav(
            quietTimeButtonKey: _quietTimeButtonKey,
            currentIndex: _currentIndex,
            onItemSelected: (index) async {
              if (index == 1) {
                // Center QuietLine logo → start a new session.
                final sessionId =
                    'session-${DateTime.now().millisecondsSinceEpoch}';

                // MVP: mood check-ins are disabled. Keep the code path behind a flag
                // so we can reconnect in V2 by flipping FeatureFlags.moodCheckInsEnabled.
                if (!FeatureFlags.moodCheckInsEnabled) {
                  if (kDebugMode) {
                    debugPrint(
                      '[QuietTime] Session started | ${DateTime.now().toIso8601String()}',
                    );
                  }
                  // NOTE: Shell launches always default to Core Quiet.
                  // Practice-selected sessions must pass an explicit contract via navigation.
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuietBreathScreen(
                        sessionId: sessionId,
                        streak: _streak ?? 0,
                        contract: coreQuietContract, // Explicit default for Shell-launched sessions
                      ),
                    ),
                  );

                  // When the session flow finishes and we return here, reload streak
                  // so Home reflects the latest value.
                  if (!mounted) return;
                  await _loadStreak();
                  if (kDebugMode) {
                    debugPrint(
                      '[QuietTime] Session ended | streak=${_streak ?? "unknown"} | ${DateTime.now().toIso8601String()}',
                    );
                  }
                  return;
                }

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MoodCheckinScreen(
                      mode: MoodCheckinMode.pre,
                      sessionId: sessionId,
                      onSubmit: (_) {
                        if (kDebugMode) {
                          debugPrint(
                            '[QuietTime] Session started | ${DateTime.now().toIso8601String()}',
                          );
                        }
                        // NOTE: Shell launches always default to Core Quiet.
                        // Practice-selected sessions must pass an explicit contract via navigation.
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuietBreathScreen(
                              sessionId: sessionId,
                              streak: _streak ?? 0,
                              contract: coreQuietContract, // Explicit default for Shell-launched sessions
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
                if (kDebugMode) {
                  debugPrint(
                    '[QuietTime] Session ended | streak=${_streak ?? "unknown"} | ${DateTime.now().toIso8601String()}',
                  );
                }
              } else {
                // Left and right icons behave as true tabs (Home / Brotherhood).
                setState(() {
                  _currentIndex = index;
                });
              }
            },
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: _buildHomeHintOverlay(),
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
            displayName: _displayName,
            reminderLabel: _reminderLabel,
            onEditReminder: () async {
              _toggleMenu();
              await _editReminderTime();
            },


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
            onNavigatePractices: () async {
              // Close the menu first.
              if (_isMenuOpen) {
                setState(() {
                  _isMenuOpen = false;
                });
              }

              // Open the Practice Library.
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuietPracticeLibraryScreen(),
                ),
              );
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

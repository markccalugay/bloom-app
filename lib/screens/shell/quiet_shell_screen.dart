import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quietline_app/screens/home/quiet_home_screen.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_screen.dart';
import 'package:quietline_app/screens/brotherhood/quiet_brotherhood_page.dart';
import 'package:quietline_app/screens/quiet_breath/quiet_breath_screen.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_strings.dart';
import 'package:quietline_app/widgets/navigation/ql_bottom_nav.dart';
import 'package:quietline_app/widgets/navigation/ql_side_menu.dart';
import 'package:quietline_app/widgets/theme/quiet_theme_selection_sheet.dart';
import 'package:quietline_app/widgets/time_picker/quiet_time_picker_sheet.dart';
import 'package:quietline_app/services/web_launch_service.dart';
import 'package:quietline_app/services/support_call_service.dart';
import 'package:quietline_app/screens/account/quiet_account_screen.dart';
import 'package:quietline_app/screens/affirmations/quiet_affirmations_library_screen.dart';
import 'package:quietline_app/screens/practices/quiet_practice_library_screen.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';
import 'package:quietline_app/screens/forge/quiet_armor_room_screen.dart';

import 'package:quietline_app/core/reminder/reminder_service.dart';
import 'package:quietline_app/core/practices/practice_access_service.dart';
import 'package:quietline_app/core/feature_flags.dart';
import 'package:quietline_app/core/theme/theme_service.dart';
import 'package:quietline_app/data/user/user_service.dart';
import 'package:quietline_app/widgets/reminder/reminder_prompt_card.dart';

import 'package:quietline_app/services/first_launch_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';


enum _CoachingStep {
  none,
  quietTimeButton,
  mentalToughness,
  sideMenuArrow,
  sideMenuOpen,
}

/// Root shell that hosts the bottom navigation and top-level tabs.
class QuietShellScreen extends StatefulWidget {
  const QuietShellScreen({super.key});

  @override
  State<QuietShellScreen> createState() => _QuietShellScreenState();
}

class _QuietShellScreenState extends State<QuietShellScreen> {
  // Ownership of the Quiet Time button key (non-static)
  final GlobalKey _quietTimeButtonKey = GlobalKey();
  final GlobalKey _sideMenuButtonKey = GlobalKey(); // Added key for side menu highlight
  int _currentIndex = 0;
  bool _isMenuOpen = false;
  int? _streak; // null = loading / unknown
  String _displayName = 'Quiet guest';
  String _avatarId = 'viking';

  TimeOfDay? _reminderTime;
  String _reminderLabel = 'Daily reminder · Not set';

  // Geometry measurement for Quiet Time button
  Rect? _quietTimeButtonRect;
  Rect? _sideMenuButtonRect; // Added rect for side menu
  bool _didMeasureQuietTimeButton = false;
  bool _didMeasureSideMenuButton = false;

  bool _homeHintLoaded = false;
  _CoachingStep _coachingStep = _CoachingStep.none;

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
        _avatarId = user.avatarId;
      });
    } catch (_) {
      // Silent fallback for MVP.
      if (!mounted) return;
      setState(() {
        _displayName = 'Quiet guest';
        _avatarId = 'viking';
      });
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen && _coachingStep == _CoachingStep.sideMenuArrow) {
        _coachingStep = _CoachingStep.sideMenuOpen;
      }
    });
  }

  void _maybeMeasureQuietTimeButton() {
    if (_didMeasureQuietTimeButton && _didMeasureSideMenuButton) return;
    if (_currentIndex != 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureButtonsIfNeeded();
    });
  }

  void _measureButtonsIfNeeded() {
    if (!_didMeasureQuietTimeButton) {
      final context = _quietTimeButtonKey.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final topLeft = renderBox.localToGlobal(Offset.zero);
          final size = renderBox.size;
          setState(() {
            _quietTimeButtonRect = topLeft & size;
            _didMeasureQuietTimeButton = true;
          });
        }
      }
    }

    if (!_didMeasureSideMenuButton) {
      final context = _sideMenuButtonKey.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final topLeft = renderBox.localToGlobal(Offset.zero);
          final size = renderBox.size;
          setState(() {
            _sideMenuButtonRect = topLeft & size;
            _didMeasureSideMenuButton = true;
          });
        }
      }
    }
  }

  Future<void> _loadHomeHintState() async {
    if (_homeHintLoaded) return;

    final hasSeen =
        await FirstLaunchService.instance.hasSeenHomeHint();

    if (!mounted) return;

    setState(() {
      _homeHintLoaded = true;
      if ((_streak ?? 0) >= 1 && !hasSeen) {
        _coachingStep = _CoachingStep.quietTimeButton;
      } else {
        _coachingStep = _CoachingStep.none;
      }
    });

    if (_coachingStep == _CoachingStep.none) {
      _maybeScheduleReminderPrompt();
    }
  }

  Future<void> _maybeScheduleReminderPrompt() async {
    if (_currentIndex != 0) {
      return;
    }
    // Only schedule if home hint is not showing and prompt isn't already shown.
    if (_coachingStep != _CoachingStep.none) {
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
      if (_coachingStep != _CoachingStep.none) return;
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
    // PROGRESSION: This is called when the user taps the overlay
    if (_coachingStep == _CoachingStep.quietTimeButton) {
      HapticFeedback.lightImpact();
      setState(() => _coachingStep = _CoachingStep.mentalToughness);
    } else if (_coachingStep == _CoachingStep.mentalToughness) {
      HapticFeedback.lightImpact();
      setState(() => _coachingStep = _CoachingStep.sideMenuArrow);
    } else if (_coachingStep == _CoachingStep.sideMenuArrow) {
      // Step: pointing to side menu.
    }
  }

  Future<void> _navigateToPractices() async {
    // Close the menu if it's open.
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
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        // Home: streak + affirmations
        return QuietHomeScreen(
          streak: _streak ?? 0,
          onMenu: _toggleMenu,
          onPracticeTap: _navigateToPractices,
          menuButtonKey: _sideMenuButtonKey,
        );
      case 2:
        // Brotherhood / community
        return QuietBrotherhoodPage();
      default:
        return QuietHomeScreen(
          streak: _streak ?? 0,
          onMenu: _toggleMenu,
          onPracticeTap: _navigateToPractices,
        );
    }
  }

  Widget _buildHomeHintOverlay() {
    if (_coachingStep == _CoachingStep.none) {
      return const SizedBox.shrink();
    }

    // Step 1: Quiet Time Button Spotlight
    if (_coachingStep == _CoachingStep.quietTimeButton) {
      if (_quietTimeButtonRect == null) return const SizedBox.shrink();
      return _buildSpotlightOverlay(
        rect: _quietTimeButtonRect!,
        title: 'Well done.',
        body: 'You just did the hardest part; starting.\n\n'
            'Use Quiet Time anytime you need a reset.\n'
            'Tap the button at the bottom to begin.',
      );
    }

    // Step 2: Mental Toughness Explanation
    if (_coachingStep == _CoachingStep.mentalToughness) {
      return _buildMessageOverlay(
        title: 'Building Resilience',
        body: 'Whenever you complete a session, you are building towards mental toughness.\n\n'
            'Keep showing up and you will see your progress become something tangible.',
      );
    }

    // Step 3: Side Menu Arrow
    if (_coachingStep == _CoachingStep.sideMenuArrow) {
      if (_sideMenuButtonRect == null) return const SizedBox.shrink();
      return _buildSpotlightOverlay(
        rect: _sideMenuButtonRect!,
        title: 'Your Armor',
        body: 'Open the menu to see what you are building.',
        showArrow: true,
        // Interactions are blocked except for the menu button itself.
        // We'll handle this by NOT having a full screen GestureDetector here,
        // or by having one that ignores the menu button rect.
        barrierDismissible: false,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSpotlightOverlay({
    required Rect rect,
    required String title,
    required String body,
    bool showArrow = false,
    bool barrierDismissible = true,
  }) {
    final double holePadding = 12.0;
    final Rect holeRect = rect.inflate(holePadding);

    return Stack(
      children: [
        // Top blocker
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          height: holeRect.top,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: barrierDismissible ? _dismissHomeHint : null,
            child: Container(color: Colors.black.withValues(alpha: 0.65)),
          ),
        ),
        // Bottom blocker
        Positioned(
          left: 0,
          top: holeRect.bottom,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: barrierDismissible ? _dismissHomeHint : null,
            child: Container(color: Colors.black.withValues(alpha: 0.65)),
          ),
        ),
        // Left blocker
        Positioned(
          left: 0,
          top: holeRect.top,
          width: holeRect.left,
          height: holeRect.height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: barrierDismissible ? _dismissHomeHint : null,
            child: Container(color: Colors.black.withValues(alpha: 0.65)),
          ),
        ),
        // Right blocker
        Positioned(
          left: holeRect.right,
          top: holeRect.top,
          right: 0,
          height: holeRect.height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: barrierDismissible ? _dismissHomeHint : null,
            child: Container(color: Colors.black.withValues(alpha: 0.65)),
          ),
        ),

        // Spotlight ring
        Positioned(
          left: rect.center.dx - (rect.width / 2 + holePadding),
          top: rect.center.dy - (rect.height / 2 + holePadding),
          width: rect.width + holePadding * 2,
          height: rect.height + holePadding * 2,
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              child: _CoachingCard(
                title: title,
                body: body,
                onTap: barrierDismissible ? _dismissHomeHint : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageOverlay({required String title, required String body}) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _dismissHomeHint,
          child: Container(color: Colors.black.withValues(alpha: 0.75)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _CoachingCard(
              title: title,
              body: body,
              onTap: _dismissHomeHint,
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
                        contract: PracticeAccessService.instance.getActiveContract(), // Use active practice
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
                              contract: PracticeAccessService.instance.getActiveContract(), // Use active practice
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
            avatarId: _avatarId,
            onClose: _toggleMenu,
            highlightArmorRoom: _coachingStep == _CoachingStep.sideMenuArrow || _coachingStep == _CoachingStep.sideMenuOpen,
            onOpenAccount: () async {
              _toggleMenu();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuietAccountScreen(
                    reminderLabel: _reminderLabel,
                    onEditReminder: _editReminderTime,
                    currentThemeLabel:
                        ThemeService.instance.currentThemeLabel,
                    onOpenThemeSelection: () async {
                      await showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => const QuietThemeSelectionSheet(),
                      );
                    },
                    onSettingsChanged: () {
                      if (mounted) setState(() {});
                    },
                  ),
                ),
              );

              // Refresh states when returning.
              if (!mounted) return;
              await _loadDisplayName();
              await _loadReminderState();
            },
            onNavigateBrotherhood: () {
              setState(() {
                _currentIndex = 2;
                _isMenuOpen = false;
              });
            },
            onNavigatePractices: _navigateToPractices,
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
            onNavigateArmorRoom: () async {
              final navigator = Navigator.of(context);

              // Final step of Home FTUE: user navigates to Armor.
              // We mark the Home tutorial as "seen" now so it won't repeat.
              await FirstLaunchService.instance.markHomeHintSeen();

              if (_isMenuOpen) {
                setState(() {
                  _isMenuOpen = false;
                });
              }

              // Update state so the overlay is gone if they return via back button
              // (though Armor Room uses pushAndRemoveUntil for its dismissal,
              // it's safer to clear it here too).
              setState(() {
                _coachingStep = _CoachingStep.none;
              });

              if (!mounted) return;
              await navigator.push(
                MaterialPageRoute(
                  builder: (_) => const QuietArmorRoomScreen(),
                ),
              );
            },
            onOpenAbout: _web.openAbout,
            onOpenWebsite: _web.openWebsite,
            onOpenSupport: _web.openSupport,
            onCall988: SupportCallService.call988,
            onOpenPrivacy: _web.openPrivacy,
            onOpenTerms: _web.openTerms,
            onOpenWhatsNew: _web.openWhatsNew,
          ),
        ),
      ],
    );
  }
}

class _CoachingCard extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback? onTap;

  const _CoachingCard({required this.title, required this.body, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F141A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A3340),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFFB9C3CF),
                decoration: TextDecoration.none,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Tap to continue',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2FE6D2),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

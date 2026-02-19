import 'package:flutter/material.dart';
import 'package:bloom_app/screens/home/bloom_home_screen.dart';
import 'package:bloom_app/screens/brotherhood/bloom_brotherhood_page.dart';
import 'package:bloom_app/screens/bloom_breath/bloom_breath_screen.dart';
import 'package:bloom_app/widgets/navigation/bloom_bottom_nav.dart';
import 'package:bloom_app/widgets/navigation/bloom_side_menu.dart';
import 'package:bloom_app/widgets/theme/bloom_theme_selection_sheet.dart';
import 'package:bloom_app/widgets/time_picker/bloom_time_picker_sheet.dart';
import 'package:bloom_app/services/web_launch_service.dart';
import 'package:bloom_app/services/support_call_service.dart';
import 'package:bloom_app/screens/account/bloom_account_screen.dart';
import 'package:bloom_app/screens/affirmations/bloom_affirmations_library_screen.dart';
import 'package:bloom_app/screens/practices/bloom_practice_library_screen.dart';
import 'package:bloom_app/core/reminder/reminder_service.dart';
import 'package:bloom_app/core/practices/practice_access_service.dart';import 'package:bloom_app/core/theme/theme_service.dart';

import 'package:bloom_app/widgets/reminder/reminder_prompt_card.dart';
import 'package:bloom_app/screens/shell/bloom_shell_controller.dart';
import 'package:bloom_app/screens/shell/widgets/coaching_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BloomShellScreen extends StatefulWidget {
  const BloomShellScreen({super.key});

  @override
  State<BloomShellScreen> createState() => _BloomShellScreenState();
}

class _BloomShellScreenState extends State<BloomShellScreen> {
  final GlobalKey _bloomTimeButtonKey = GlobalKey();
  final BloomShellController _controller = BloomShellController();
  final _web = WebLaunchService();

  Rect? _bloomTimeButtonRect;
  bool _didMeasureBloomTimeButton = false;

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) {
      if (mounted) {
        _controller.updateReminderState(context);
        _maybeScheduleReminderPrompt();
      }
    });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _editReminderTime() async {
    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BloomTimePickerSheet(
        initialTime: _controller.reminderTime,
      ),
    );

    if (picked == null) return;

    final prefs = await SharedPreferences.getInstance();
    final reminderService = ReminderService(prefs);
    await reminderService.enableReminder(time: picked);

    if (mounted) {
      await _controller.updateReminderState(context);
    }
  }

  void _maybeMeasureBloomTimeButton() {
    if (_didMeasureBloomTimeButton) return;
    if (_controller.currentIndex != 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureButtonsIfNeeded();
    });
  }

  void _measureButtonsIfNeeded() {
    if (!_didMeasureBloomTimeButton) {
      final context = _bloomTimeButtonKey.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final topLeft = renderBox.localToGlobal(Offset.zero);
          final size = renderBox.size;
          setState(() {
            _bloomTimeButtonRect = topLeft & size;
            _didMeasureBloomTimeButton = true;
          });
        }
      }
    }
  }

  Future<void> _maybeScheduleReminderPrompt() async {
    if (_controller.currentIndex != 0) return;
    if (_controller.coachingStep != CoachingStep.none) return;

    final prefs = await SharedPreferences.getInstance();
    final reminderService = ReminderService(prefs);
    final eligible = reminderService.shouldShowReminderPrompt(
      ftueCompleted: true,
      bloomTimeSessionCount: _controller.streak ?? 0,
    );
    if (!eligible) return;

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (_controller.currentIndex != 0) return;
      if (!mounted) return;
      if (_controller.coachingStep != CoachingStep.none) return;
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
              if (!context.mounted) return;
              final picked = await showModalBottomSheet<TimeOfDay>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const BloomTimePickerSheet(),
              );

              if (picked == null) {
                await reminderService.markReminderPromptSeen();
                return;
              }

              await reminderService.enableReminder(time: picked);
              if (context.mounted) {
                await _controller.updateReminderState(context);
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _navigateToPractices() async {
    _controller.closeMenu();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BloomPracticeLibraryScreen(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_controller.currentIndex) {
      case 0:
        return BloomHomeScreen(
          streak: _controller.streak ?? 0,
          onMenu: _controller.toggleMenu,
          onPracticeTap: _navigateToPractices,
        );
      case 2:
        return BloomBrotherhoodPage();
      default:
        return BloomHomeScreen(
          streak: _controller.streak ?? 0,
          onMenu: _controller.toggleMenu,
          onPracticeTap: _navigateToPractices,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double menuWidth = 280.0;
    _maybeMeasureBloomTimeButton();

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: _buildBody(),
          bottomNavigationBar: BloomBottomNav(
            bloomTimeButtonKey: _bloomTimeButtonKey,
            currentIndex: _controller.currentIndex,
            onItemSelected: (index) async {
              if (index == 1) {
                final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BloomBreathScreen(
                      sessionId: sessionId,
                      streak: _controller.streak ?? 0,
                      contract: PracticeAccessService.instance.getActiveContract(),
                    ),
                  ),
                );

                if (!mounted) return;
                await _controller.loadStreak();
              } else {
                _controller.currentIndex = index;
              }
            },
          ),
        ),

        CoachingOverlay(
          step: _controller.coachingStep,
          spotlightRect: _bloomTimeButtonRect,
          onDismiss: _controller.dismissHomeHint,
        ),

        if (_controller.isMenuOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _controller.toggleMenu,
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          left: _controller.isMenuOpen ? 0 : -menuWidth,
          width: menuWidth,
          child: BloomSideMenu(
            displayName: _controller.displayName,
            avatarId: _controller.avatarId,
            onClose: _controller.toggleMenu,
            onOpenAccount: () async {
              _controller.closeMenu();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BloomAccountScreen(
                    reminderLabel: _controller.reminderLabel,
                    onEditReminder: _editReminderTime,
                    currentThemeLabel: ThemeService.instance.currentThemeLabel,
                    onOpenThemeSelection: () async {
                      await showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => const BloomThemeSelectionSheet(),
                      );
                    },
                    onSettingsChanged: () {
                      if (mounted) setState(() {});
                    },
                  ),
                ),
              );

              if (!mounted) return;
              await _controller.initialize();
              if (context.mounted) {
                _controller.updateReminderState(context);
              }

            },
            onNavigateBrotherhood: () {
              _controller.currentIndex = 2;
              _controller.closeMenu();
            },
            onNavigatePractices: _navigateToPractices,
            onNavigateAffirmations: () async {
              _controller.closeMenu();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BloomAffirmationsLibraryScreen(),
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

import 'package:flutter/material.dart';
import 'package:quietline_app/core/services/haptic_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';
import 'package:quietline_app/data/user/user_service.dart';
import 'package:quietline_app/services/first_launch_service.dart';

enum CoachingStep {
  none,
  quietTimeButton,
  mentalToughness,
}

class QuietShellController extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isMenuOpen = false;
  int? _streak;
  String _displayName = 'Quiet guest';
  String _avatarId = 'viking';
  TimeOfDay? _reminderTime;
  String _reminderLabel = 'Daily reminder · Not set';
  CoachingStep _coachingStep = CoachingStep.none;
  bool _homeHintLoaded = false;

  int get currentIndex => _currentIndex;
  bool get isMenuOpen => _isMenuOpen;
  int? get streak => _streak;
  String get displayName => _displayName;
  String get avatarId => _avatarId;
  TimeOfDay? get reminderTime => _reminderTime;
  String get reminderLabel => _reminderLabel;
  CoachingStep get coachingStep => _coachingStep;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleMenu() {
    _isMenuOpen = !_isMenuOpen;
    notifyListeners();
  }

  void closeMenu() {
    if (_isMenuOpen) {
      _isMenuOpen = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    await _loadStreak();
    await _loadDisplayName();
    await _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminderHour');
    final minute = prefs.getInt('reminderMinute');

    if (hour == null || minute == null) {
      _reminderTime = null;
      _reminderLabel = 'Daily reminder · Not set';
    } else {
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _reminderLabel = 'Daily reminder · Set'; // Placeholder until UI updates with context
    }
    notifyListeners();
  }


  // Helper for formatting without context (simplified for now or will pass context)
  String formatTime(BuildContext context, TimeOfDay time) {
     return time.format(context);
  }

  Future<void> updateReminderState(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminderHour');
    final minute = prefs.getInt('reminderMinute');

    if (hour == null || minute == null) {
      _reminderTime = null;
      _reminderLabel = 'Daily reminder · Not set';
    } else {
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      if (context.mounted) {
        _reminderLabel = 'Daily reminder · ${_reminderTime!.format(context)}';
      }
    }
    notifyListeners();
  }


  Future<void> loadStreak() async {
    try {
      _streak = await QuietStreakService.getCurrentStreak();
      notifyListeners();
      await _loadHomeHintState();
    } catch (_) {}
  }

  // Internal because it's called by loadStreak
  Future<void> _loadStreak() => loadStreak();

  Future<void> _loadDisplayName() async {
    try {
      final user = await UserService.instance.getOrCreateUser();
      _displayName = user.username;
      _avatarId = user.avatarId;
    } catch (_) {
      _displayName = 'Quiet guest';
      _avatarId = 'viking';
    }
    notifyListeners();
  }

  Future<void> _loadHomeHintState() async {
    if (_homeHintLoaded) return;
    final hasSeen = await FirstLaunchService.instance.hasSeenHomeHint();
    _homeHintLoaded = true;
    if ((_streak ?? 0) >= 1 && !hasSeen) {
      _coachingStep = CoachingStep.quietTimeButton;
    } else {
      _coachingStep = CoachingStep.none;
    }
    notifyListeners();
  }

  Future<void> dismissHomeHint() async {
    if (_coachingStep == CoachingStep.quietTimeButton) {
      HapticService.light();
      _coachingStep = CoachingStep.mentalToughness;
    } else if (_coachingStep == CoachingStep.mentalToughness) {
      HapticService.light();
      _coachingStep = CoachingStep.none;
      await FirstLaunchService.instance.markHomeHintSeen();
    }
    notifyListeners();
  }
}

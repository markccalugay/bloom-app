import 'package:flutter/material.dart';
import '../../theme/ql_theme.dart';
import '../backup/backup_coordinator.dart';
import '../entitlements/premium_entitlement.dart';
import '../services/user_preferences_service.dart';

class ThemeService extends ChangeNotifier {
  ThemeService._();
  static final ThemeService instance = ThemeService._();


  
  ThemeVariant _variant = ThemeVariant.midnight;
  bool _isInitialized = false;

  ThemeVariant get variant => _variant;

  String get currentThemeLabel {
    switch (_variant) {
      case ThemeVariant.midnight:
        return 'Theme · Midnight (Teal)';
      case ThemeVariant.morning:
        return 'Theme · Morning (Light)';
      case ThemeVariant.charcoal:
        return 'Theme · Charcoal (Gray)';
    }
  }

  static String getLabel(ThemeVariant v) {
    switch (v) {
      case ThemeVariant.midnight:
        return 'Midnight';
      case ThemeVariant.morning:
        return 'Morning';
      case ThemeVariant.charcoal:
        return 'Charcoal';
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Listen to preferences service
    UserPreferencesService.instance.addListener(_updateFromPrefs);
    _updateFromPrefs();
    
    _isInitialized = true;
    notifyListeners();
  }

  void _updateFromPrefs() {
    final pref = UserPreferencesService.instance.themeMode;
    switch (pref) {
      case ThemeModePreference.midnight:
        _variant = ThemeVariant.midnight;
        break;
      case ThemeModePreference.morning:
        _variant = ThemeVariant.morning;
        break;
      case ThemeModePreference.charcoal:
        _variant = ThemeVariant.charcoal;
        break;
    }
    notifyListeners();
  }

  Future<void> cycleTheme() async {
    final nextIndex = (_variant.index + 1) % ThemeVariant.values.length;
    await setTheme(ThemeVariant.values[nextIndex]);
  }

  Future<void> setTheme(ThemeVariant v) async {
    _variant = v;
    
    ThemeModePreference pref;
    switch (v) {
      case ThemeVariant.midnight:
        pref = ThemeModePreference.midnight;
        break;
      case ThemeVariant.morning:
        pref = ThemeModePreference.morning;
        break;
      case ThemeVariant.charcoal:
        pref = ThemeModePreference.charcoal;
        break;
    }
    
    await UserPreferencesService.instance.setThemeMode(pref);
    
    // Trigger backup if Premium
    if (PremiumEntitlement.instance.isPremium) {
      BackupCoordinator.instance.runBackup();
    }

    notifyListeners();
  }

  ThemeData get themeData => QLTheme.getTheme(_variant);
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/ql_theme.dart';
import '../backup/backup_coordinator.dart';
import '../entitlements/premium_entitlement.dart';

class ThemeService extends ChangeNotifier {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const String _themeKey = 'user_theme_variant';
  
  ThemeVariant _variant = ThemeVariant.quietLine;
  bool _isInitialized = false;

  ThemeVariant get variant => _variant;

  String get currentThemeLabel {
    switch (_variant) {
      case ThemeVariant.quietLine:
        return 'Theme · QuietLine Teal';
      case ThemeVariant.quietLineLight:
        return 'Theme · QuietLine Light';
    }
  }

  static String getLabel(ThemeVariant v) {
    switch (v) {
      case ThemeVariant.quietLine:
        return 'QuietLine Teal';
      case ThemeVariant.quietLineLight:
        return 'QuietLine Light';
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_themeKey);
    
    if (savedIndex != null && savedIndex < ThemeVariant.values.length) {
      _variant = ThemeVariant.values[savedIndex];
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> cycleTheme() async {
    final nextIndex = (_variant.index + 1) % ThemeVariant.values.length;
    await setTheme(ThemeVariant.values[nextIndex]);
  }

  Future<void> setTheme(ThemeVariant v) async {
    _variant = v;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _variant.index);
    
    // Trigger backup if Premium
    if (PremiumEntitlement.instance.isPremium) {
      BackupCoordinator.instance.runBackup();
    }

    notifyListeners();
  }

  ThemeData get themeData => QLTheme.getTheme(_variant);
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModePreference { midnight, morning, charcoal }

class UserPreferencesService extends ChangeNotifier {
  static final UserPreferencesService instance = UserPreferencesService._internal();
  UserPreferencesService._internal();

  late SharedPreferences _prefs;

  // Keys
  static const _hapticEnabledKey = 'pref_haptic_enabled';
  static const _hapticIntensityKey = 'pref_haptic_intensity';
  static const _themeModeKey = 'pref_theme_mode';
  static const _volumeKey = 'pref_volume';

  // Defaults
  bool _hapticEnabled = true;
  double _hapticIntensity = 1.0; // 0.5 to 1.5 scaling
  ThemeModePreference _themeMode = ThemeModePreference.midnight;
  double _volume = 0.5;

  // Getters
  bool get hapticEnabled => _hapticEnabled;
  double get hapticIntensity => _hapticIntensity;
  ThemeModePreference get themeMode => _themeMode;
  double get volume => _volume;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    _hapticEnabled = _prefs.getBool(_hapticEnabledKey) ?? true;
    _hapticIntensity = _prefs.getDouble(_hapticIntensityKey) ?? 1.0;
    _volume = _prefs.getDouble(_volumeKey) ?? 0.5;
    
    final themeStr = _prefs.getString(_themeModeKey);
    _themeMode = ThemeModePreference.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeModePreference.midnight,
    );
    
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    await _prefs.setBool(_hapticEnabledKey, value);
    notifyListeners();
  }

  Future<void> setHapticIntensity(double value) async {
    _hapticIntensity = value.clamp(0.5, 1.5);
    await _prefs.setDouble(_hapticIntensityKey, _hapticIntensity);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModePreference mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _prefs.setDouble(_volumeKey, _volume);
    notifyListeners();
  }
}

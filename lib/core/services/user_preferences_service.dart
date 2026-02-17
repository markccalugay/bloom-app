import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quietline_app/screens/practice/models/custom_session_config.dart';

enum ThemeModePreference { midnight, morning }

class UserPreferencesService extends ChangeNotifier {
  static final UserPreferencesService instance = UserPreferencesService._internal();
  UserPreferencesService._internal();

  late SharedPreferences _prefs;

  // Keys
  static const _hapticEnabledKey = 'pref_haptic_enabled';
  static const _hapticIntensityKey = 'pref_haptic_intensity';
  static const _themeModeKey = 'pref_theme_mode';
  // Custom Mixes
  static const _customMixesKey = 'pref_custom_mixes';
  List<CustomSessionConfig> _customMixes = [];
  List<CustomSessionConfig> get customMixes => _customMixes;

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

  // Intro Flags
  static const _hasSeenMixIntroKey = 'pref_has_seen_mix_intro';
  bool _hasSeenMixIntro = false;
  bool get hasSeenMixIntro => _hasSeenMixIntro;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    _hapticEnabled = _prefs.getBool(_hapticEnabledKey) ?? true;
    _hapticIntensity = _prefs.getDouble(_hapticIntensityKey) ?? 1.0;
    _volume = _prefs.getDouble(_volumeKey) ?? 0.5;
    
    _hasSeenMixIntro = _prefs.getBool(_hasSeenMixIntroKey) ?? false;
    
    final themeStr = _prefs.getString(_themeModeKey);
    _themeMode = ThemeModePreference.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeModePreference.midnight,
    );
     
    _loadCustomMixes();
    
    // Default Mix if none exist
    if (_customMixes.isEmpty) {
      await saveCustomMix(CustomSessionConfig(
        id: 'default_morning_reset',
        name: 'Morning Reset',
        breathPatternId: 'core_quiet',
        soundscapeId: 'river_steady',
        durationSeconds: 300, // 5 min
      ));
    }
    
    notifyListeners();
  }

  Future<void> setHasSeenMixIntro() async {
    _hasSeenMixIntro = true;
    await _prefs.setBool(_hasSeenMixIntroKey, true);
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

  Future<void> saveCustomMix(CustomSessionConfig config) async {
    // Remove existing if overwriting (by ID)
    _customMixes.removeWhere((c) => c.id == config.id);
    _customMixes.add(config);
    
    final List<String> jsonList = _customMixes.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_customMixesKey, jsonList);
    notifyListeners();
  }

  Future<void> deleteCustomMix(String id) async {
    _customMixes.removeWhere((c) => c.id == id);
    final List<String> jsonList = _customMixes.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_customMixesKey, jsonList);
    notifyListeners();
  }

  void _loadCustomMixes() {
    final List<String>? jsonList = _prefs.getStringList(_customMixesKey);
    if (jsonList != null) {
      _customMixes = jsonList
          .map((s) => CustomSessionConfig.fromJson(jsonDecode(s)))
          .toList();
    }
  }
}

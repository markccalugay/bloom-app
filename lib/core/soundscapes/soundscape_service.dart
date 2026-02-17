import 'dart:async';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:just_audio/just_audio.dart' as ja;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_assets.dart';
import 'soundscape_models.dart';

class SoundscapeService extends ChangeNotifier {
  static final SoundscapeService instance = SoundscapeService._internal();
  SoundscapeService._internal();

  final ja.AudioPlayer _bgPlayer = ja.AudioPlayer();
  final ap.AudioPlayer _sfxPlayer = ap.AudioPlayer();

  static const String _activeSoundscapeKey = 'ql_soundscape_id';
  static const String _volumeKey = 'ql_soundscape_volume';
  static const String _muteKey = 'ql_soundscape_muted';
  static const String _sfxVolumeKey = 'ql_sfx_volume';
  static const String _sfxMuteKey = 'ql_sfx_muted';

  Soundscape _activeSoundscape = allSoundscapes[0]; // River Steady
  double _volume = 1.0; // 0.0 to 1.0
  bool _isMuted = false;
  double _sfxVolume = 1.0;
  bool _isSfxMuted = false;
  bool _isPlaying = false;
  bool _isWelcomeHomePlaying = false;
  
  Timer? _fadeTimer;

  bool get isWelcomeHomePlaying => _isWelcomeHomePlaying;

  Soundscape get activeSoundscape => _activeSoundscape;
  double get volume => _volume;
  bool get isMuted => _isMuted;
  double get sfxVolume => _sfxVolume;
  bool get isSfxMuted => _isSfxMuted;
  bool get isPlaying => _isPlaying;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedId = prefs.getString(_activeSoundscapeKey);
    if (savedId != null) {
      _activeSoundscape = allSoundscapes.firstWhere(
        (s) => s.id == savedId,
        orElse: () => allSoundscapes[0],
      );
    }

    _volume = prefs.getDouble(_volumeKey) ?? 1.0;
    _isMuted = prefs.getBool(_muteKey) ?? false;
    _sfxVolume = prefs.getDouble(_sfxVolumeKey) ?? 1.0;
    _isSfxMuted = prefs.getBool(_sfxMuteKey) ?? false;

    // Use native looping for seamless playback on supported platforms via just_audio.
    await _bgPlayer.setLoopMode(ja.LoopMode.all);
    
    // PRE-LOAD the initial asset
    await _bgPlayer.setAsset(_activeSoundscape.assetPath);
    
    await _updatePlayerVolume();
    notifyListeners();
  }

  Future<void> setSoundscape(Soundscape soundscape) async {
    _activeSoundscape = soundscape;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeSoundscapeKey, soundscape.id);
    
    // Load the new asset immediately
    await _bgPlayer.setAsset(soundscape.assetPath);
    
    if (_isPlaying) {
      await play(fadeIn: false); // Switch track immediately if already playing
    }
    
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, _volume);
    await _updatePlayerVolume();
    notifyListeners();
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_muteKey, _isMuted);
    await _updatePlayerVolume();
    
    // If we unmuted and it's marked as "playing" but player stopped, kick it.
    if (!_isMuted && _isPlaying && !_bgPlayer.playing) {
       _bgPlayer.play();
    }
    
    notifyListeners();
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sfxVolumeKey, _sfxVolume);
    notifyListeners();
  }

  Future<void> toggleSfxMute() async {
    _isSfxMuted = !_isSfxMuted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sfxMuteKey, _isSfxMuted);
    notifyListeners();
  }

  Future<void> _updatePlayerVolume() async {
    final effectiveVolume = _isMuted ? 0.0 : _volume;
    await _bgPlayer.setVolume(effectiveVolume);
  }

  Future<void> play({bool fadeIn = true}) async {
    final targetVolume = _isMuted ? 0.0 : _volume;
    
    // If already playing and volume is already at target, don't re-trigger fade
    if (_isPlaying && _bgPlayer.playing && (_bgPlayer.volume - targetVolume).abs() < 0.01) {
      return;
    }

    _isPlaying = true;
    _fadeTimer?.cancel();
    
    if (fadeIn) {
      await _bgPlayer.setVolume(0);
      await _bgPlayer.play();
      
      const steps = 10;
      const stepDuration = Duration(milliseconds: 500 ~/ steps);
      double currentStep = 0.0;
      
      _fadeTimer = Timer.periodic(stepDuration, (timer) {
        currentStep++;
        final newVolume = (currentStep / steps) * targetVolume;
        _bgPlayer.setVolume(newVolume);
        
        if (currentStep >= steps) {
          timer.cancel();
          _updatePlayerVolume();
        }
      });
    } else {
      await _updatePlayerVolume();
      await _bgPlayer.play();
    }
    notifyListeners();
  }

  Future<void> stop({bool fadeOut = true}) async {
    _isPlaying = false;
    _fadeTimer?.cancel();

    if (fadeOut) {
      const steps = 10;
      const stepDuration = Duration(milliseconds: 500 ~/ steps);
      double currentStep = steps.toDouble();
      final startVolume = _bgPlayer.volume;

      _fadeTimer = Timer.periodic(stepDuration, (timer) {
        currentStep--;
        final newVolume = (currentStep / steps) * startVolume;
        _bgPlayer.setVolume(newVolume);
        
        if (currentStep <= 0) {
          timer.cancel();
          _bgPlayer.stop();
        }
      });
    } else {
      await _bgPlayer.stop();
    }
    notifyListeners();
  }

  Future<void> pause() async {
    // Background audio continues unless explicitly stopped.
  }

  Future<void> resume() async {
    if (!_isPlaying) {
      await play();
    }
  }

  Future<void> playCountdown(int value) async {
    switch (value) {
      case 1:
        await playSfx(AppAssets.countdown1);
        break;
      case 2:
        await playSfx(AppAssets.countdown2);
        break;
      case 3:
        await playSfx(AppAssets.countdown3);
        break;
    }
  }

  Future<void> playWelcomeHome() async {
    _isWelcomeHomePlaying = true;
    notifyListeners();
    
    // ql_bgm_welcome_home.wav is ~45 seconds
    await playSfx(AppAssets.welcomeHomeBgm);
    
    // Wait for the SFX to finish before resetting the state
    await _sfxPlayer.onPlayerComplete.first;
    
    _isWelcomeHomePlaying = false;
    notifyListeners();
  }

  Future<void> playSfx(String assetPath) async {
    await _sfxPlayer.setVolume(_isSfxMuted ? 0 : _sfxVolume);
    await _sfxPlayer.play(ap.AssetSource(assetPath.replaceFirst('assets/', '')));
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}

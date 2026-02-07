import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'soundscape_models.dart';

class SoundscapeService extends ChangeNotifier {
  static final SoundscapeService instance = SoundscapeService._internal();
  SoundscapeService._internal();

  final AudioPlayer _player1 = AudioPlayer();
  final AudioPlayer _player2 = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  bool _usePlayer1 = true;
  AudioPlayer get _currentPlayer => _usePlayer1 ? _player1 : _player2;
  AudioPlayer get _nextPlayer => _usePlayer1 ? _player2 : _player1;

  static const String _activeSoundscapeKey = 'ql_soundscape_id';
  static const String _volumeKey = 'ql_soundscape_volume';
  static const String _muteKey = 'ql_soundscape_muted';
  static const String _sfxVolumeKey = 'ql_sfx_volume';
  static const String _sfxMuteKey = 'ql_sfx_muted';

  Soundscape _activeSoundscape = allSoundscapes[1]; // River Steady
  double _volume = 1.0; // 0.0 to 1.0
  bool _isMuted = false;
  double _sfxVolume = 1.0;
  bool _isSfxMuted = false;
  bool _isPlaying = false;
  
  Timer? _fadeTimer;
  StreamSubscription? _completionSub;

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
        orElse: () => allSoundscapes[1],
      );
    }

    _volume = prefs.getDouble(_volumeKey) ?? 1.0;
    _isMuted = prefs.getBool(_muteKey) ?? false;
    _sfxVolume = prefs.getDouble(_sfxVolumeKey) ?? 1.0;
    _isSfxMuted = prefs.getBool(_sfxMuteKey) ?? false;

    // Set both players to NOT loop automatically, as we'll manage it manually
    // for seamless double-buffering if needed (or at least alternating).
    await _player1.setReleaseMode(ReleaseMode.release);
    await _player2.setReleaseMode(ReleaseMode.release);
    
    await _updatePlayerVolume();
    notifyListeners();
  }

  Future<void> setSoundscape(Soundscape soundscape) async {
    _activeSoundscape = soundscape;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeSoundscapeKey, soundscape.id);
    
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
    await _player1.setVolume(effectiveVolume);
    await _player2.setVolume(effectiveVolume);
  }

  Future<void> _setupNextLoop() async {
    _completionSub?.cancel();
    // Use onPositionChanged to trigger the next player slightly before the end.
    // This handles cases where onPlayerComplete has a slight delay.
    _completionSub = _currentPlayer.onPositionChanged.listen((position) async {
      if (!_isPlaying) return;
      
      final duration = await _currentPlayer.getDuration();
      if (duration == null) return;

      // Trigger the next player 100ms before the current one ends.
      // This is a common strategy for gapless playback with multiple players.
      final remaining = duration.inMilliseconds - position.inMilliseconds;
      if (remaining <= 100 && remaining > 0) {
        _completionSub?.cancel(); // Prevent multiple triggers
        
        _usePlayer1 = !_usePlayer1;
        final source = AssetSource(_activeSoundscape.assetPath.replaceFirst('assets/', ''));
        
        await _nextPlayer.stop(); 
        await _currentPlayer.play(source);
        await _nextPlayer.setSource(source);
        
        _setupNextLoop();
      }
    });

    // Fallback: still listen for completion just in case position events are missed or lag.
    _currentPlayer.onPlayerComplete.first.then((_) async {
       if (!_isPlaying || _completionSub == null) return;
       // If we reach here and it's still playing, it means the position check missed.
       _usePlayer1 = !_usePlayer1;
       final source = AssetSource(_activeSoundscape.assetPath.replaceFirst('assets/', ''));
       await _nextPlayer.stop();
       await _currentPlayer.play(source);
       _setupNextLoop();
    });
  }

  Future<void> play({bool fadeIn = true}) async {
    _isPlaying = true;
    _fadeTimer?.cancel();
    
    final source = AssetSource(_activeSoundscape.assetPath.replaceFirst('assets/', ''));

    if (fadeIn) {
      await _currentPlayer.setVolume(0);
      await _currentPlayer.play(source);
      _setupNextLoop();
      
      const steps = 20;
      const stepDuration = Duration(milliseconds: 1000 ~/ steps);
      double currentStep = 0.0;
      
      _fadeTimer = Timer.periodic(stepDuration, (timer) {
        currentStep++;
        final targetVolume = _isMuted ? 0.0 : _volume;
        final newVolume = (currentStep / steps) * targetVolume;
        _currentPlayer.setVolume(newVolume);
        
        if (currentStep >= steps) {
          timer.cancel();
          _updatePlayerVolume();
        }
      });
    } else {
      await _updatePlayerVolume();
      await _currentPlayer.play(source);
      _setupNextLoop();
    }
    notifyListeners();
  }

  Future<void> stop({bool fadeOut = true}) async {
    _isPlaying = false;
    _fadeTimer?.cancel();
    _completionSub?.cancel();

    if (fadeOut) {
      const steps = 20;
      const stepDuration = Duration(milliseconds: 1000 ~/ steps);
      double currentStep = steps.toDouble();
      final startVolume = _isMuted ? 0.0 : _volume;

      _fadeTimer = Timer.periodic(stepDuration, (timer) {
        currentStep--;
        final newVolume = (currentStep / steps) * startVolume;
        _currentPlayer.setVolume(newVolume);
        _nextPlayer.setVolume(newVolume);
        
        if (currentStep <= 0) {
          timer.cancel();
          _player1.stop();
          _player2.stop();
        }
      });
    } else {
      await _player1.stop();
      await _player2.stop();
    }
    notifyListeners();
  }

  Future<void> pause() async {
    // Note: Request said soundscapes should CONTINUE to loop during session pause.
    // So this method might not be used by the controller, but good to have.
    // We'll keep it playing unless fully stopped.
  }

  Future<void> resume() async {
    if (!_isPlaying) {
      await play();
    }
  }

  Future<void> playCountdown(int value) async {
    if (value < 1 || value > 3) return;
    
    final path = 'sfx/ql_sfx_countdown_$value.wav';
    await playSfx(path);
  }

  Future<void> playSfx(String assetPath) async {
    await _sfxPlayer.setVolume(_isSfxMuted ? 0 : _sfxVolume);
    await _sfxPlayer.play(AssetSource(assetPath));
  }
}

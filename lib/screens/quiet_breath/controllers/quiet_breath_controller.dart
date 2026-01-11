import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../quiet_breath_constants.dart';

/// Central brain for the Quiet Breath screen.
/// Manages: play/pause, wave phase, rising water, countdown timer.
class QuietBreathController extends ChangeNotifier {
  late final AnimationController _waveCtrl;
  late final AnimationController _riseCtrl;
  late final AnimationController _introCtrl;
  late final AnimationController _boxCtrl; // 0..1 over 16s box-breath cycle

  // Cycle-based session target
  int _targetCycles = kQBCyclesBaseline; // can be set from streak later
  int get targetCycles => _targetCycles;
  set targetCycles(int n) => setTargetCycles(n);
  int get _sessionTotalSeconds =>
      _targetCycles * kQBBoxCycleSec; // cycles * 16s

  Timer? _countdown;
  bool _isPlaying = false;
  int _secondsLeft = 0; // initialized in constructor based on cycles

  bool _sessionCompleted = false; // NEW: to avoid double-calling completion

  /// Called when the full session (all target cycles) has completed.
  VoidCallback? onSessionComplete;

  QuietBreathController({required TickerProvider vsync}) {
    _waveCtrl = AnimationController(
      vsync: vsync,
      duration: kQBWaveLoopDuration,
    );
    _riseCtrl =
        AnimationController(
          vsync: vsync,
          duration: Duration(seconds: _sessionTotalSeconds),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && !_sessionCompleted) {
            _sessionCompleted = true;
            // End the session exactly when the fill finishes.
            pause();
            final cb = onSessionComplete;
            if (cb != null) cb();
          }
        });

    _secondsLeft = _sessionTotalSeconds; // initialize from cycles
    _introCtrl = AnimationController(
      vsync: vsync,
      duration: kQBIntroDropDuration,
    )..value = 0.0; // 0 = looks full before start
    _boxCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: kQBBoxCycleSec), // now 16s
    )..value = 0.0;
  }

  // Exposed state
  bool get isPlaying => _isPlaying;
  int get secondsLeft => _secondsLeft;

  /// True when never started in this run (pre-Start)
  bool get isFresh =>
      !_isPlaying && _riseCtrl.value == 0.0 && _introCtrl.value == 0.0;

  // Animation inputs for painter
  double get phase => _waveCtrl.value * 2 * math.pi;
  double get progress => _riseCtrl.value; // 0..1 -> bottom..top
  double get introT =>
      _introCtrl.value; // 0..1, 0 = full at rest, 1 = drop complete

  // --- Box breathing phase tracking (for radial ring & instructions) ---
  double get boxT => _boxCtrl.value; // 0..1 in current 16-second cycle
  int get boxSecond =>
      (boxT * kQBBoxCycleSec).floor().clamp(0, kQBBoxCycleSec - 1);

  /// 0 = Inhale, 1 = Hold, 2 = Exhale, 3 = Hold (second)
  int get boxPhaseIndex {
    final segLen = kQBBoxCycleSec / 4; // 4s each segment
    final idx = (boxSecond / segLen).floor();
    return idx.clamp(0, 3);
  }

  /// 0..1 progress within the current 4-second phase
  double get boxPhaseProgress {
    final segLen = kQBBoxCycleSec / 4; // 4.0
    final phaseStart = boxPhaseIndex * segLen;
    final cycleTime = boxT * kQBBoxCycleSec; // 0..16
    final local = (cycleTime - phaseStart).clamp(0.0, segLen);
    return (local / segLen).clamp(0.0, 1.0);
  }

  String get boxPhaseLabel =>
      const ['Inhale', 'Hold', 'Exhale', 'Hold'][boxPhaseIndex];
  Color get boxPhaseColor => const [
    kQBColorInhale,
    kQBColorHold,
    kQBColorExhale,
    kQBColorHold,
  ][boxPhaseIndex];

  // UI label for the primary control button
  String get primaryLabel {
    if (_isPlaying) return 'Pause';
    final started = _secondsLeft < _sessionTotalSeconds;
    return started ? 'Resume' : 'Start';
  }

  Listenable get listenable =>
      Listenable.merge([_waveCtrl, _riseCtrl, _introCtrl, _boxCtrl, this]);

  void play() {
    if (_isPlaying) return;
    _isPlaying = true;

    // Waves should always animate while playing or paused
    if (_waveCtrl.status == AnimationStatus.completed ||
        _waveCtrl.value >= 1.0) {
      _waveCtrl.reset();
    }
    if (!_waveCtrl.isAnimating) {
      _waveCtrl.repeat();
    }

    // If this is the first start, run the intro drop.
    final isFreshStart =
        _secondsLeft == _sessionTotalSeconds && _introCtrl.value == 0.0;
    if (isFreshStart) {
      _introCtrl.forward(from: 0.0);
    }

    // Prepare/continue rising water
    if (_riseCtrl.status == AnimationStatus.completed ||
        _riseCtrl.value >= 1.0) {
      _riseCtrl.reset();
      _secondsLeft = _sessionTotalSeconds;
      _sessionCompleted = false; // NEW: allow a new full session
    }
    _riseCtrl.forward();

    if (!_boxCtrl.isAnimating) {
      _boxCtrl.repeat();
    }

    // Countdown (for internal state only; completion is driven by _riseCtrl)
    _countdown ??= Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPlaying || _sessionCompleted) return;
      if (_secondsLeft > 0) {
        _secondsLeft--;
        notifyListeners();
      }
      // No "else" block here – _riseCtrl's completion is the source of truth.
    });

    notifyListeners();
  }

  void pause() {
    if (!_isPlaying) return;
    _isPlaying = false;

    // Pause fill; keep waves moving.
    _riseCtrl.stop(canceled: false);

    // Smoothly animate the radial ring back to empty instead of snapping.
    final current = _boxCtrl.value;
    _boxCtrl.stop(canceled: false);
    if (current > 0.0) {
      _boxCtrl.animateBack(
        0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }

    notifyListeners();
  }

  void toggle() => _isPlaying ? pause() : play();

  /// DEBUG: Immediately completes the session without waiting for timers.
  /// Used only for development/testing.
  void completeSessionImmediately() {
    if (_sessionCompleted) return;

    _sessionCompleted = true;

    // Stop all running animations/timers
    _countdown?.cancel();
    _countdown = null;

    _isPlaying = false;

    _waveCtrl.stop();
    _riseCtrl.stop();
    _introCtrl.stop();
    _boxCtrl.stop();

    // Jump progress to the end to simulate a finished session
    _riseCtrl.value = 1.0;
    _secondsLeft = 0;

    notifyListeners();

    final cb = onSessionComplete;
    if (cb != null) cb();
  }

  /// Update the target number of box-breath cycles for a session.
  void setTargetCycles(int n) {
    final clamped = n.clamp(1, 12);
    _targetCycles = clamped;
    // Update rising fill duration to match new total session length.
    _riseCtrl.duration = Duration(seconds: _sessionTotalSeconds);
    // If idle (not playing), reset remaining seconds to full session length.
    if (!_isPlaying) {
      _secondsLeft = _sessionTotalSeconds;
      notifyListeners();
    }
  }

  void reset() {
    pause();
    _waveCtrl.reset();
    _riseCtrl.reset();
    _introCtrl.reset();
    _boxCtrl.value = 0.0;
    _secondsLeft = _sessionTotalSeconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _waveCtrl.dispose();
    _riseCtrl.dispose();
    _introCtrl.dispose();
    _boxCtrl.dispose();
    super.dispose();
  }
}

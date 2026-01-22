import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../quiet_breath_constants.dart';
import '../models/breath_phase_contracts.dart';
import '../../../theme/ql_theme.dart';

/// Central brain for the Quiet Breath screen.
/// Manages: play/pause, wave phase, rising water, countdown timer.
class QuietBreathController extends ChangeNotifier {
  // Active breathing practice contract (default = Core Quiet)
  BreathingPracticeContract _contract = coreQuietContract;

  // Derived phases from the active contract
  List<BreathPhaseContract> get _phases => _contract.phases;

  int get _cycleSeconds =>
      _phases.fold(0, (sum, p) => sum + p.seconds);

  late final AnimationController _waveCtrl;
  late final AnimationController _riseCtrl;
  late final AnimationController _introCtrl;
  late final AnimationController _boxCtrl; // 0..1 over breathing cycle

  // Cycle-based session target
  int _targetCycles = kQBCyclesBaseline; // can be set from streak later
  int get targetCycles => _targetCycles;
  set targetCycles(int n) => setTargetCycles(n);


  int get _sessionTotalSeconds => _targetCycles * _cycleSeconds;

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
      duration: Duration(seconds: _cycleSeconds),
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
  /// Numeric phase used by wave painter (semantic-safe)
  double get wavePhase => phase;
  /// Continuous time value for smooth wave animation (never resets)
  double get waveT => _waveCtrl.value;
  double get progress => _riseCtrl.value; // 0..1 -> bottom..top
  /// Overall session progress (0.0 → 1.0), monotonic across the entire session.
  /// Used for smooth background animations (waves), independent of breathing phases.
  double get sessionProgress => _riseCtrl.value;
  double get introT =>
      _introCtrl.value; // 0..1, 0 = full at rest, 1 = drop complete

  // --- Breathing phase tracking (for radial ring & instructions) ---

  int get phaseIndex {
    final elapsed = _boxCtrl.value * _cycleSeconds;
    int acc = 0;
    for (int i = 0; i < _phases.length; i++) {
      acc += _phases[i].seconds;
      if (elapsed < acc) return i;
    }
    return _phases.length - 1;
  }

  int get currentPhaseIndex => phaseIndex;

  double get phaseProgress {
    final elapsed = _boxCtrl.value * _cycleSeconds;
    int start = 0;
    for (int i = 0; i < phaseIndex; i++) {
      start += _phases[i].seconds;
    }
    final local = (elapsed - start).clamp(0.0, _phases[phaseIndex].seconds.toDouble());
    return local / _phases[phaseIndex].seconds;
  }

  double get currentPhaseProgress => phaseProgress;

  BreathPhaseType get currentPhase => _phases[phaseIndex].type;

  String get phaseLabel => QLTheme.labelForPhase(currentPhase);

  Color get phaseColor => QLTheme.colorForPhase(currentPhase);

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
      _boxCtrl.repeat(
        min: 0.0,
        max: 1.0,
        period: Duration(seconds: _cycleSeconds),
      );
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

  /// Switch the active breathing practice.
  /// This resets timing safely without touching animation structure.
  void setContract(BreathingPracticeContract contract) {
    assert(contract.phases.isNotEmpty, 'Breathing contract must have phases');

    _contract = contract;

    // Update cycle count from the contract
    _targetCycles = contract.cycles;

    // Update durations to match new contract
    _boxCtrl.duration = Duration(seconds: _cycleSeconds);
    _riseCtrl.duration = Duration(seconds: _sessionTotalSeconds);

    // Reset session state if not actively playing
    if (!_isPlaying) {
      _boxCtrl.value = 0.0;
      _riseCtrl.value = 0.0;
      _secondsLeft = _sessionTotalSeconds;
      _sessionCompleted = false;
    }

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
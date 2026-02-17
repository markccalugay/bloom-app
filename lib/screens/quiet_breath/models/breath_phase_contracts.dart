/// Breath phase domain models and canonical practice contracts.
///
/// This file defines *what* a breathing practice is.
/// Execution (timers, animation, loops) is handled elsewhere.
///
/// Design rules:
/// - Pure data only (no timers, no controllers, no widgets)
/// - Explicit phase semantics
/// - Readable, debuggable, and extensible

//library breath_phase_contracts;

// ignore_for_file: dangling_library_doc_comments

/// High‑level semantic meaning of a breath phase.
enum BreathPhaseType {
  inhale,
  hold,
  exhale,
  rest,

  // Advanced / non‑cyclical phases (used later by Cold Resolve)
  power,
  retention,
  recovery,
}

/// A single breathing phase definition.
///
/// This is the canonical contract that all practices are built from.
class BreathPhaseContract {
  final BreathPhaseType type;
  final int seconds;

  const BreathPhaseContract({
    required this.type,
    required this.seconds,
  });
}

/// A full breathing practice definition.
///
/// This describes *what* a practice is, not how it runs.
/// Execution is handled by the breath controller.
class BreathingPracticeContract {
  final String id;
  final String name;
  final List<BreathPhaseContract> phases;

  /// Number of times the phase list should repeat.
  /// For non-cyclical practices (e.g. Cold Resolve), this may be ignored.
  final int cycles;

  /// Whether this practice is considered advanced.
  final bool isAdvanced;

  /// Whether this practice requires a premium subscription.
  final bool isPremium;

  const BreathingPracticeContract({
    required this.id,
    required this.name,
    required this.phases,
    required this.cycles,
    this.isAdvanced = false,
    this.isPremium = false,
  });
}

/* -------------------------------------------------------------------------- */
/*                          PRACTICE CONTRACTS                                */
/* -------------------------------------------------------------------------- */

const BreathingPracticeContract coreQuietContract =
    BreathingPracticeContract(
  id: 'core_quiet',
  name: 'Core Quiet',
  cycles: 3,
  phases: [
    BreathPhaseContract(type: BreathPhaseType.inhale, seconds: 4),
    BreathPhaseContract(type: BreathPhaseType.hold, seconds: 4),
    BreathPhaseContract(type: BreathPhaseType.exhale, seconds: 4),
    BreathPhaseContract(type: BreathPhaseType.rest, seconds: 4),
  ],
  isPremium: false,
);

const BreathingPracticeContract steadyDisciplineContract =
    BreathingPracticeContract(
  id: 'steady_discipline',
  name: 'Steady Discipline',
  cycles: 5,
  phases: [
    BreathPhaseContract(type: BreathPhaseType.inhale, seconds: 5),
    BreathPhaseContract(type: BreathPhaseType.hold, seconds: 5),
    BreathPhaseContract(type: BreathPhaseType.exhale, seconds: 5),
  ],
  isPremium: true,
);

const BreathingPracticeContract monkCalmContract =
    BreathingPracticeContract(
  id: 'monk_calm',
  name: 'Monk Calm',
  cycles: 6,
  phases: [
    BreathPhaseContract(type: BreathPhaseType.inhale, seconds: 4),
    BreathPhaseContract(type: BreathPhaseType.exhale, seconds: 6),
    BreathPhaseContract(type: BreathPhaseType.rest, seconds: 2),
  ],
  isPremium: true,
);

const BreathingPracticeContract navyCalmContract =
    BreathingPracticeContract(
  id: 'navy_calm',
  name: 'Navy Calm',
  cycles: 4,
  phases: [
    BreathPhaseContract(type: BreathPhaseType.inhale, seconds: 4),
    BreathPhaseContract(type: BreathPhaseType.hold, seconds: 7),
    BreathPhaseContract(type: BreathPhaseType.exhale, seconds: 8),
  ],
  isPremium: true,
);

const BreathingPracticeContract athleteFocusContract =
    BreathingPracticeContract(
  id: 'athlete_focus',
  name: 'Athlete Focus',
  cycles: 10,
  phases: [
    BreathPhaseContract(type: BreathPhaseType.inhale, seconds: 3),
    BreathPhaseContract(type: BreathPhaseType.exhale, seconds: 3),
  ],
  isPremium: true,
);

/* -------------------------------------------------------------------------- */
/*                              COLD RESOLVE                                  */
/* -------------------------------------------------------------------------- */

/// Cold Resolve (Wim Hof–inspired, simplified)
///
/// NOTE:
/// This is a simplified, cycle-based version that fits the existing
/// QuietLine breathing framework.
/// Inspired by Wim Hof Method, but NOT a canonical implementation.
///
/// TODO(mark): Revisit advanced round-based Cold Resolve with
/// power breathing + retention when a dedicated execution model exists.
const BreathingPracticeContract coldResolveContract =
    BreathingPracticeContract(
  id: 'cold_resolve',
  name: 'Cold Resolve',
  cycles: 30,
  isAdvanced: true,
  isPremium: true,
  phases: [
    BreathPhaseContract(type: BreathPhaseType.inhale, seconds: 2),
    BreathPhaseContract(type: BreathPhaseType.exhale, seconds: 2),
  ],
);

/// Canonical list of all breathing practices.
const List<BreathingPracticeContract> allBreathingPractices = [
  coreQuietContract,
  steadyDisciplineContract,
  monkCalmContract,
  navyCalmContract,
  athleteFocusContract,
  coldResolveContract,
];

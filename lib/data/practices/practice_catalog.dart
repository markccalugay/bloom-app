import 'practice_model.dart';

class PracticeCatalog {
  static const coreQuiet = Practice(
    id: 'core_quiet',
    title: 'Core Quiet',
    description: 'A simple 90-second breathing reset.',
    tier: PracticeTier.free,
  );

  static const steadyDiscipline = Practice(
    id: 'steady_discipline',
    title: 'Steady Discipline',
    description: 'Build consistency and self-control through breath.',
    tier: PracticeTier.premium,
  );

  static const monkCalm = Practice(
    id: 'monk_calm',
    title: 'Monk Calm',
    description: 'Deep, slow breathing inspired by monastic practice.',
    tier: PracticeTier.premium,
  );

  static const navyCalm = Practice(
    id: 'navy_calm',
    title: 'Navy Calm',
    description: 'Controlled breathing for stress tolerance and composure.',
    tier: PracticeTier.premium,
  );

  static const athleteFocus = Practice(
    id: 'athlete_focus',
    title: 'Athlete Focus',
    description: 'Performance breathing for focus and recovery.',
    tier: PracticeTier.premium,
  );

  static const coldResolve = Practice(
    id: 'cold_resolve',
    title: 'Cold Resolve',
    description: 'Breath control to build resilience under discomfort.',
    tier: PracticeTier.premium,
  );

  static const all = <Practice>[
    coreQuiet,
    steadyDiscipline,
    monkCalm,
    navyCalm,
    athleteFocus,
    coldResolve,
  ];
}
import 'practice_model.dart';
import 'package:bloom_app/screens/bloom_breath/models/breath_phase_contracts.dart';

class PracticeCatalog {
  static const coreBloom = Practice(
    id: 'core_bloom',
    title: 'Core Bloom',
    description: 'A simple 90-second breathing reset.',
    tier: PracticeTier.free,
    contract: coreBloomContract,
  );

  static const steadyDiscipline = Practice(
    id: 'steady_discipline',
    title: 'Steady Discipline',
    description: 'Build consistency and self-control through breath.',
    tier: PracticeTier.premium,
    contract: steadyDisciplineContract,
  );

  static const monkCalm = Practice(
    id: 'monk_calm',
    title: 'Monk Calm',
    description: 'Deep, slow breathing inspired by monastic practice.',
    tier: PracticeTier.premium,
    contract: monkCalmContract,
  );

  static const serenity478 = Practice(
    id: 'serenity_478',
    title: 'Serenity 4-7-8',
    description: 'Deeply relaxing breath to reduce anxiety and promote inner peace.',
    tier: PracticeTier.premium,
    contract: serenity478Contract,
  );

  static const athleteFocus = Practice(
    id: 'athlete_focus',
    title: 'Athlete Focus',
    description: 'Performance breathing for focus and recovery.',
    tier: PracticeTier.premium,
    contract: athleteFocusContract,
  );

  static const coldResolve = Practice(
    id: 'cold_resolve',
    title: 'Cold Resolve',
    description: 'Breath control to build resilience under discomfort.',
    tier: PracticeTier.premium,
    contract: coldResolveContract,
  );

  static const all = <Practice>[
    coreBloom,
    steadyDiscipline,
    monkCalm,
    serenity478,
    athleteFocus,
    coldResolve,
  ];
}
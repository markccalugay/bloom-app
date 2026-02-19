import '../../screens/bloom_breath/models/breath_phase_contracts.dart';

/// A Reset Pack combines a specific breathing rhythm with a themed affirmation pool.
class ResetPack {
  final String id;
  final String name;
  final String description;
  final BreathingPracticeContract contract;
  final String affirmationPackId;
  final bool isPremium;

  const ResetPack({
    required this.id,
    required this.name,
    required this.description,
    required this.contract,
    required this.affirmationPackId,
    this.isPremium = true,
  });
}

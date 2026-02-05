/// A single affirmation.
class Affirmation {
  final String id;      // e.g. "core_001"
  final String packId;  // e.g. "core"
  final String text;
  final bool isPremium;

  const Affirmation({
    required this.id,
    required this.packId,
    required this.text,
    this.isPremium = false,
  });
}

/// A pack of affirmations (Core, Christmas, etc.).
class AffirmationPack {
  final String id;          // e.g. "core", "christmas"
  final String name;        // e.g. "Core Affirmations"
  final String? description;
  final bool isSeasonal;

  const AffirmationPack({
    required this.id,
    required this.name,
    this.description,
    this.isSeasonal = false,
  });
}
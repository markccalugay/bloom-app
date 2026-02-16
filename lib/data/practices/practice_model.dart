import 'package:flutter/foundation.dart';
import 'package:quietline_app/screens/quiet_breath/models/breath_phase_contracts.dart';

enum PracticeTier {
  free,
  premium,
}

@immutable
class Practice {
  final String id;
  final String title;
  final String description;
  final PracticeTier tier;
  final BreathingPracticeContract contract;

  const Practice({
    required this.id,
    required this.title,
    required this.description,
    required this.tier,
    required this.contract,
  });
}
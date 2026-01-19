import 'package:flutter/foundation.dart';

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

  const Practice({
    required this.id,
    required this.title,
    required this.description,
    required this.tier,
  });
}
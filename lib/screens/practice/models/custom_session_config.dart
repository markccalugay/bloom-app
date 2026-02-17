

class CustomSessionConfig {
  final String id;
  final String name;
  final String breathPatternId;
  final String soundscapeId;
  final int durationSeconds;
  
  // Optional: Volume overrides
  final double? volume;
  final double? sfxVolume;

  const CustomSessionConfig({
    required this.id,
    required this.name,
    required this.breathPatternId,
    required this.soundscapeId,
    required this.durationSeconds,
    this.volume,
    this.sfxVolume,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breathPatternId': breathPatternId,
      'soundscapeId': soundscapeId,
      'durationSeconds': durationSeconds,
      'volume': volume,
      'sfxVolume': sfxVolume,
    };
  }

  factory CustomSessionConfig.fromJson(Map<String, dynamic> json) {
    return CustomSessionConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      breathPatternId: json['breathPatternId'] as String,
      soundscapeId: json['soundscapeId'] as String,
      durationSeconds: json['durationSeconds'] as int,
      volume: (json['volume'] as num?)?.toDouble(),
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble(),
    );
  }
}

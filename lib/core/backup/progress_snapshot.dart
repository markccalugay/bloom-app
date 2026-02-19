import 'package:bloom_app/data/forge/forge_service.dart';
import 'package:bloom_app/screens/practice/models/custom_session_config.dart';

class ProgressSnapshot {
  final int schemaVersion;
  final int streak;
  final int totalBloomTimeSeconds;
  final int totalSessions;
  final List<String> unlockedAffirmationIds;
  final String currentArmorSet;
  final List<String> unlockedArmorPieces;
  final String ironStage;
  final int polishedIngotCount;
  final String themeVariant;
  final int? reminderHour;
  final int? reminderMinute;
  final bool hasEnabledReminder;
  final Map<String, int> practiceUsage;
  final int? memberSince; // Timestamp in milliseconds
  
  // Settings & Preferences
  final bool hapticEnabled;
  final double hapticIntensity;
  final double volume;
  final String themeMode;
  final List<CustomSessionConfig> customMixes;

  ProgressSnapshot({
    required this.schemaVersion,
    required this.streak,
    required this.totalBloomTimeSeconds,
    required this.totalSessions,
    required this.unlockedAffirmationIds,
    required this.currentArmorSet,
    required this.unlockedArmorPieces,
    required this.ironStage,
    required this.polishedIngotCount,
    required this.themeVariant,
    this.reminderHour,
    this.reminderMinute,
    required this.hasEnabledReminder,
    required this.practiceUsage,
    this.memberSince,
    required this.hapticEnabled,
    required this.hapticIntensity,
    required this.volume,
    required this.themeMode,
    required this.customMixes,
  });

  Map<String, dynamic> toJson() {
    return {
      'schema_version': schemaVersion,
      'streak': streak,
      'total_bloom_time_seconds': totalBloomTimeSeconds,
      'total_sessions': totalSessions,
      'unlocked_affirmation_ids': unlockedAffirmationIds,
      'current_armor_set': currentArmorSet,
      'unlocked_armor_pieces': unlockedArmorPieces,
      'iron_stage': ironStage,
      'polished_ingot_count': polishedIngotCount,
      'theme_variant': themeVariant,
      'reminder_hour': reminderHour,
      'reminder_minute': reminderMinute,
      'has_enabled_reminder': hasEnabledReminder,
      'practice_usage': practiceUsage,
      'member_since': memberSince,
      'haptic_enabled': hapticEnabled,
      'haptic_intensity': hapticIntensity,
      'volume': volume,
      'theme_mode': themeMode,
      'custom_mixes': customMixes.map((e) => e.toJson()).toList(),
    };
  }

  factory ProgressSnapshot.fromJson(Map<String, dynamic> json) {
    return ProgressSnapshot(
      schemaVersion: json['schema_version'] ?? 2,
      streak: json['streak'] ?? 0,
      totalBloomTimeSeconds: json['total_bloom_time_seconds'] ?? 0,
      totalSessions: json['total_sessions'] ?? 0,
      unlockedAffirmationIds: List<String>.from(json['unlocked_affirmation_ids'] ?? []),
      currentArmorSet: json['current_armor_set'] ?? ArmorSet.knight.name,
      unlockedArmorPieces: List<String>.from(json['unlocked_armor_pieces'] ?? []),
      ironStage: json['iron_stage'] ?? IronStage.raw.name,
      polishedIngotCount: json['polished_ingot_count'] ?? 0,
      themeVariant: json['theme_variant'] ?? 'bloom',
      reminderHour: json['reminder_hour'],
      reminderMinute: json['reminder_minute'],
      hasEnabledReminder: json['has_enabled_reminder'] ?? false,
      practiceUsage: Map<String, int>.from(json['practice_usage'] ?? {}),
      memberSince: json['member_since'],
      hapticEnabled: json['haptic_enabled'] ?? true,
      hapticIntensity: (json['haptic_intensity'] ?? 1.0).toDouble(),
      volume: (json['volume'] ?? 0.5).toDouble(),
      themeMode: json['theme_mode'] ?? 'midnight',
      customMixes: (json['custom_mixes'] as List? ?? [])
          .map((e) => CustomSessionConfig.fromJson(e))
          .toList(),
    );
  }
}

// lib/data/mood/mood_checkin_record.dart

import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_strings.dart';
// ^ This is where your MoodCheckinMode enum already lives (pre / post).

/// Immutable data model representing a single mood check-in.
///
/// This is platform-agnostic: safe for iOS, Android, web.
class MoodCheckinRecord {
  final String id;              // Unique ID for this record
  final MoodCheckinMode mode;   // pre / post
  final int score;              // 1..10 from the slider
  final DateTime timestamp;     // When this was recorded
  final String? sessionId;      // Optional: link pre & post for same session

  const MoodCheckinRecord({
    required this.id,
    required this.mode,
    required this.score,
    required this.timestamp,
    this.sessionId,
  });

  /// Convenience helper to create a new record with a generated UUID.
  factory MoodCheckinRecord.newEntry({
    required MoodCheckinMode mode,
    required int score,
    String? sessionId,
    DateTime? timestamp,
  }) {
    final uuid = const Uuid();
    return MoodCheckinRecord(
      id: uuid.v4(),
      mode: mode,
      score: score,
      timestamp: timestamp ?? DateTime.now().toUtc(),
      sessionId: sessionId,
    );
  }

  /// Convert to a JSON-ready Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mode': _modeToString(mode),
      'score': score,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
    };
  }

  /// Convert a Map back into a MoodCheckinRecord.
  factory MoodCheckinRecord.fromMap(Map<String, dynamic> map) {
    return MoodCheckinRecord(
      id: map['id'] as String,
      mode: _modeFromString(map['mode'] as String),
      score: map['score'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      sessionId: map['sessionId'] as String?,
    );
  }

  /// Encode to a JSON string (for storage in SharedPreferences).
  String toJson() => jsonEncode(toMap());

  /// Decode from a JSON string.
  factory MoodCheckinRecord.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return MoodCheckinRecord.fromMap(map);
  }

  /// Create a copy with overrides (handy later if we need to edit entries).
  MoodCheckinRecord copyWith({
    String? id,
    MoodCheckinMode? mode,
    int? score,
    DateTime? timestamp,
    String? sessionId,
  }) {
    return MoodCheckinRecord(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      score: score ?? this.score,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

// ----- helpers for mode <-> string mapping -----

String _modeToString(MoodCheckinMode mode) {
  switch (mode) {
    case MoodCheckinMode.pre:
      return 'pre';
    case MoodCheckinMode.post:
      return 'post';
  }
}

MoodCheckinMode _modeFromString(String value) {
  switch (value) {
    case 'pre':
      return MoodCheckinMode.pre;
    case 'post':
      return MoodCheckinMode.post;
    default:
      // Fallback: if bad data ever sneaks in, assume pre.
      return MoodCheckinMode.pre;
  }
}
// import 'package:flutter/foundation.dart';

/// Immutable user model used across Bloom.
/// 
/// MVP behavior:
/// - Users start as anonymous.
/// - Usernames + avatarIndex are assigned automatically.
/// - Later we can extend this model for real auth (Apple/Google/email).
class BloomUser {
  final String id;              // internal unique user ID
  final String displayName;     // "Calm River 218"
  final int avatarIndex;        // which default avatar to show
  final bool isAnonymous;       // true until they sign in later

  const BloomUser({
    required this.id,
    required this.displayName,
    required this.avatarIndex,
    required this.isAnonymous,
  });

  /// Create a modified copy – useful for future profile editing.
  BloomUser copyWith({
    String? id,
    String? displayName,
    int? avatarIndex,
    bool? isAnonymous,
  }) {
    return BloomUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  /// Convert model → Map (for persistence later)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarIndex': avatarIndex,
      'isAnonymous': isAnonymous,
    };
  }

  /// Convert Map → model
  factory BloomUser.fromJson(Map<String, dynamic> json) {
    return BloomUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      avatarIndex: json['avatarIndex'] as int? ?? 0,
      isAnonymous: json['isAnonymous'] as bool? ?? true,
    );
  }
}
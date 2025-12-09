import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple local user profile for QuietLine.
/// For MVP this is an anonymous local user; later we can
/// attach real auth IDs to it.
class UserProfile {
  final String id;        // stable internal ID (local for now)
  final String username;  // e.g. "Quiet Ember 472"
  final String avatarId;  // e.g. "avatar_3"

  const UserProfile({
    required this.id,
    required this.username,
    required this.avatarId,
  });

  Map<String, String> toJson() => {
        'id': id,
        'username': username,
        'avatarId': avatarId,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarId: json['avatarId'] as String,
    );
  }
}

class UserService {
  // Singleton
  UserService._internal();
  static final UserService instance = UserService._internal();

  // SharedPreferences keys
  static const _keyId = 'ql_user_id';
  static const _keyUsername = 'ql_user_username';
  static const _keyAvatarId = 'ql_user_avatar_id';

  UserProfile? _cachedProfile;

  /// Get existing user if stored, otherwise create a new anonymous profile.
  Future<UserProfile> getOrCreateUser() async {
    if (_cachedProfile != null) return _cachedProfile!;

    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyId);
    final username = prefs.getString(_keyUsername);
    final avatarId = prefs.getString(_keyAvatarId);

    if (id != null && username != null && avatarId != null) {
      _cachedProfile =
          UserProfile(id: id, username: username, avatarId: avatarId);
      return _cachedProfile!;
    }

    // Nothing stored yet → create a fresh anonymous profile.
    final newProfile = _generateAnonymousProfile();
    await _saveProfile(prefs, newProfile);
    _cachedProfile = newProfile;

    if (kDebugMode) {
      debugPrint(
          '[UserService] Created new anonymous user: ${newProfile.username} (${newProfile.id})');
    }

    return newProfile;
  }

  /// Update and persist the profile (e.g., after they rename themselves
  /// or pick a custom avatar).
  Future<void> updateProfile(UserProfile profile) async {
    _cachedProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    await _saveProfile(prefs, profile);
  }

  // --- Internal helpers ------------------------------------------------------

  UserProfile _generateAnonymousProfile() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = Random(now);

    // Internal ID – local for now, later this can be a server/user ID.
    final id = 'user_$now';

    const adjectives = [
      'quiet',
      'still',
      'steady',
      'soft',
      'calm',
      'gentle',
      'grounded',
    ];

    const nouns = [
      'ember',
      'river',
      'oak',
      'wave',
      'stone',
      'pine',
      'horizon',
    ];

    final adjective = adjectives[rand.nextInt(adjectives.length)];
    final noun = nouns[rand.nextInt(nouns.length)];
    final number = rand.nextInt(900) + 100; // 100–999

    // You can change this format to kebab-case if you prefer.
    final username =
        '${_capitalize(adjective)} ${_capitalize(noun)} $number'; // e.g. "Quiet Ember 472"

    // Simple avatar ID – later map this to an actual asset.
    final avatarId = 'avatar_${rand.nextInt(6) + 1}'; // avatar_1 .. avatar_6

    return UserProfile(
      id: id,
      username: username,
      avatarId: avatarId,
    );
  }

  Future<void> _saveProfile(
    SharedPreferences prefs,
    UserProfile profile,
  ) async {
    await prefs.setString(_keyId, profile.id);
    await prefs.setString(_keyUsername, profile.username);
    await prefs.setString(_keyAvatarId, profile.avatarId);
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
import 'package:flutter/foundation.dart';
import 'package:bloom_app/core/api/backend_service.dart';
import 'package:bloom_app/core/auth/auth_service.dart';
import 'package:bloom_app/core/backup/progress_snapshot.dart';
import 'package:bloom_app/core/reminder/reminder_service.dart';
import 'package:bloom_app/core/storekit/storekit_service.dart';
import 'package:bloom_app/core/theme/theme_service.dart';
import 'package:bloom_app/data/affirmations/affirmations_unlock_service.dart';
import 'package:bloom_app/data/forge/forge_service.dart';
import 'package:bloom_app/data/streak/bloom_streak_repository.dart';
import 'package:bloom_app/theme/bloom_theme.dart';
import 'package:bloom_app/core/auth/user_model.dart';
import 'package:bloom_app/data/user/user_service.dart';
import 'package:bloom_app/core/services/user_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BackupCoordinator {
  static late BackupCoordinator instance;

  final BackendService backendService;
  final AuthService authService;
  final BloomStreakRepository streakRepo;
  final ForgeService forgeService;
  final AffirmationsUnlockService affirmationsService;
  final ThemeService themeService;
  final ReminderService reminderService;

  BackupCoordinator({
    required this.backendService,
    required this.authService,
    required this.streakRepo,
    required this.forgeService,
    required this.affirmationsService,
    required this.themeService,
    required this.reminderService,
  });

  Future<void> runBackup() async {
    // Get all connected users (Apple, Google, etc.)
    final connectedUsers = authService.connectedUsersNotifier.value;
    if (connectedUsers.isEmpty) return;

    final snapshot = await createSnapshot();
    
    int successCount = 0;
    for (final user in connectedUsers) {
      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('Authentication token missing. Please sign in again.');
      }
      
      await backendService.backup(idToken: idToken, snapshot: snapshot);
      successCount++;
    }

    if (successCount > 0) {
      debugPrint('[BACKUP] Backup successful to $successCount providers');
    }
  }

  Future<void> runRestore() async {
    final connectedUsers = authService.connectedUsersNotifier.value;
    if (connectedUsers.isEmpty) return;

    ProgressSnapshot? bestSnapshot;
    
    for (final user in connectedUsers) {
      final idToken = await user.getIdToken();
      if (idToken == null) continue; // Skip providers without tokens for restore
      
      final snapshot = await backendService.restore(idToken: idToken);
      if (snapshot != null) {
        // Simple resolution strategy: Use the one with more quiet time
        if (bestSnapshot == null || snapshot.totalBloomTimeSeconds > bestSnapshot.totalBloomTimeSeconds) {
          bestSnapshot = snapshot;
        }
      }
    }

    if (bestSnapshot != null) {
      await applySnapshot(bestSnapshot);
      // Restore purchases to ensure premium status is synced
      try {
        await StoreKitService.instance.restorePurchases();
      } catch (e) {
        debugPrint('[RESTORE] Failed to restore purchases: $e');
      }
      debugPrint('[RESTORE] Restore successful');
    } else {
      debugPrint('[RESTORE] No backup found on any provider');
    }
  }

  Future<ProgressSnapshot?> checkForRemoteSnapshot(AuthenticatedUser user) async {
    try {
      final idToken = await user.getIdToken();
      if (idToken == null) return null;
      return await backendService.restore(idToken: idToken);
    } catch (e) {
      debugPrint('[BACKUP] Check remote failed: $e');
      return null;
    }
  }

  Future<ProgressSnapshot> createSnapshot() async {
    final streak = await streakRepo.getCurrentStreak();
    final totalSeconds = await streakRepo.getTotalSeconds();
    final totalSessions = await streakRepo.getTotalSessions();
    final unlockedAffirmations = await affirmationsService.getUnlockedIds();
    final practiceUsage = await streakRepo.getPracticeUsage();
    
    final forgeState = forgeService.state;
    final reminderState = reminderService.loadState();
    
    final prefs = await SharedPreferences.getInstance();
    final int? hour = prefs.getInt('reminderHour');
    final int? minute = prefs.getInt('reminderMinute');
    
    // Get memberSince from user profile
    final userProfile = await UserService.instance.getOrCreateUser();
    final memberSince = userProfile.createdAt.millisecondsSinceEpoch;

    final prefService = UserPreferencesService.instance;

    return ProgressSnapshot(
      schemaVersion: 2,
      streak: streak,
      totalBloomTimeSeconds: totalSeconds,
      totalSessions: totalSessions,
      unlockedAffirmationIds: unlockedAffirmations.toList(),
      currentArmorSet: forgeState.currentSet.name,
      unlockedArmorPieces: forgeState.unlockedPieces.map((e) => e.name).toList(),
      ironStage: forgeState.ironStage.name,
      polishedIngotCount: forgeState.polishedIngotCount,
      themeVariant: themeService.variant.name,
      reminderHour: hour,
      reminderMinute: minute,
      hasEnabledReminder: reminderState.hasEnabledReminder,
      practiceUsage: practiceUsage,
      memberSince: memberSince,
      hapticEnabled: prefService.hapticEnabled,
      hapticIntensity: prefService.hapticIntensity,
      volume: prefService.volume,
      themeMode: prefService.themeMode.name,
      customMixes: prefService.customMixes,
    );
  }

  Future<void> applySnapshot(ProgressSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Streak
    await prefs.setInt('bloom_streak_count', snapshot.streak);
    await prefs.setInt('bloom_total_seconds', snapshot.totalBloomTimeSeconds);
    await prefs.setInt('bloom_total_sessions', snapshot.totalSessions);
    // We don't have last_date in snapshot, but we can set it to today to avoid lost streak
    await prefs.setString('bloom_streak_last_date', DateTime.now().toIso8601String().split('T').first);
    
    // 1b. Practice Usage (Favorites)
    if (snapshot.practiceUsage.isNotEmpty) {
      final List<String> encoded = snapshot.practiceUsage.entries
          .map((e) => '${e.key}:${e.value}')
          .toList();
      await prefs.setStringList('bloom_practice_usage', encoded);
    }

    // 2. Affirmations
    await prefs.setStringList('unlocked_affirmation_ids', snapshot.unlockedAffirmationIds);

    // 3. Forge
    final setIdx = ArmorSet.values.indexWhere((e) => e.name == snapshot.currentArmorSet);
    await prefs.setInt('bloom_forge_set', setIdx != -1 ? setIdx : 0);
    
    final stageIdx = IronStage.values.indexWhere((e) => e.name == snapshot.ironStage);
    await prefs.setInt('bloom_forge_iron_stage', stageIdx != -1 ? stageIdx : 0);
    
    await prefs.setStringList('bloom_forge_unlocked_pieces', snapshot.unlockedArmorPieces);
    await prefs.setInt('bloom_forge_ingot_count', snapshot.polishedIngotCount);
    await prefs.setInt('bloom_forge_total_sessions', snapshot.totalSessions);
    await prefs.setBool('bloom_forge_has_seen_explanation', true);

    // 4. Theme
    final themeIdx = ThemeVariant.values.indexWhere((e) => e.name == snapshot.themeVariant);
    if (themeIdx != -1) {
      await prefs.setInt('user_theme_variant', themeIdx);
    }

    // 5. Reminders
    if (snapshot.reminderHour != null) {
      await prefs.setInt('reminderHour', snapshot.reminderHour!);
    }
    if (snapshot.reminderMinute != null) {
      await prefs.setInt('reminderMinute', snapshot.reminderMinute!);
    }
    await prefs.setBool('hasEnabledReminder', snapshot.hasEnabledReminder);
    
    // 6. User Profile (Member Since)
    if (snapshot.memberSince != null) {
      final userProfile = await UserService.instance.getOrCreateUser();
      final remoteCreatedAt = DateTime.fromMillisecondsSinceEpoch(snapshot.memberSince!);
      // Update local profile with remote creation date
      final updatedProfile = UserProfile(
        id: userProfile.id,
        username: userProfile.username, 
        avatarId: userProfile.avatarId,
        createdAt: remoteCreatedAt,
      );
      await UserService.instance.updateProfile(updatedProfile);
    }

    // 7. Preferences & Custom Mixes
    await prefs.setBool('pref_haptic_enabled', snapshot.hapticEnabled);
    await prefs.setDouble('pref_haptic_intensity', snapshot.hapticIntensity);
    await prefs.setDouble('pref_volume', snapshot.volume);
    await prefs.setString('pref_theme_mode', snapshot.themeMode);
    
    final List<String> mixesJson = snapshot.customMixes.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList('pref_custom_mixes', mixesJson);

    // Reload all services
    await forgeService.initialize();
    await themeService.initialize();
    await UserPreferencesService.instance.initialize();
  }
}

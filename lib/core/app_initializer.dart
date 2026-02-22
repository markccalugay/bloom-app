import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloom_app/core/storekit/storekit_service.dart';
import 'package:bloom_app/core/entitlements/premium_entitlement.dart';
import 'package:bloom_app/core/theme/theme_service.dart';
import 'package:bloom_app/core/soundscapes/soundscape_service.dart';
import 'package:bloom_app/core/timezone/timezone_service.dart';
import 'package:bloom_app/data/streak/bloom_streak_local_store.dart';
import 'package:bloom_app/data/streak/bloom_streak_repository.dart';
import 'package:bloom_app/data/streak/bloom_streak_service.dart';
import 'package:bloom_app/core/practices/practice_access_service.dart';
import 'package:bloom_app/data/forge/forge_service.dart';
import 'package:bloom_app/core/reminder/reminder_service.dart';
import 'package:bloom_app/core/api/backend_service.dart';
import 'package:bloom_app/core/backup/backup_coordinator.dart';
import 'package:bloom_app/core/auth/auth_service.dart';
import 'package:bloom_app/data/affirmations/affirmations_unlock_service.dart';
import 'package:bloom_app/core/config/app_config.dart';
import 'package:bloom_app/core/services/user_preferences_service.dart';
import 'package:bloom_app/core/services/bloom_logger.dart';
import 'package:bloom_app/core/services/bloom_debug_actions.dart';
import 'package:bloom_app/core/notifications/notification_service.dart';
import 'package:bloom_app/core/services/mood_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bloom_app/core/config/supabase_config.dart';

class AppInitializer {
  static Future<ReminderService> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Core services
    await StoreKitService.instance.initialize();
    await PremiumEntitlement.instance.initialize();
    await ThemeService.instance.initialize();
    await SoundscapeService.instance.initialize();
    await TimezoneService.initialize();
    await UserPreferencesService.instance.initialize();
    await MoodService.instance.initialize();

    // Supabase - Disconnected temporarily
    /*
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    */

    final prefs = await SharedPreferences.getInstance();
    
    // Streak & Data
    final bloomStreakRepo = BloomStreakRepository(
      localStore: BloomStreakLocalStore(prefs),
    );
    BloomStreakService.repo = bloomStreakRepo;

    await PracticeAccessService.instance.initialize();
    await ForgeService.instance.initialize();
    
    final reminderService = ReminderService(prefs);

    // Backup & Restore
    final backendService = BackendService(
      baseUrl: AppConfig.backendBaseUrl,
    );
    
    BackupCoordinator.instance = BackupCoordinator(
      backendService: backendService,
      authService: AuthService.instance,
      streakRepo: bloomStreakRepo,
      forgeService: ForgeService.instance,
      affirmationsService: AffirmationsUnlockService.instance,
      themeService: ThemeService.instance,
      reminderService: reminderService,
    );

    debugPrint('[BOOT] Services initialized. Premium=${PremiumEntitlement.instance.isPremium}');
    
    if (kDebugMode) {
      BloomLogger.instance.setupGlobalRedirect();
      _registerGlobalDebugActions(reminderService, bloomStreakRepo, prefs);
    }
    
    return reminderService;
  }

  static void _registerGlobalDebugActions(
    ReminderService reminderService,
    BloomStreakRepository streakRepo,
    SharedPreferences prefs,
  ) {
    final actions = BloomDebugActions.instance;

    actions.registerAction('Trigger Reminder (3s)', () async {
      final notificationService = NotificationService();
      await notificationService.initialize();
      // Using rebuildDaily with current time + offset isn't ideal for "instant" testing
      // but we can schedule a one-off if we had a showImmediate method.
      // For now, let's just log and rebuild daily for 1 min from now.
      final now = DateTime.now().add(const Duration(minutes: 1));
      await notificationService.rebuildDaily(
        time: TimeOfDay(hour: now.hour, minute: now.minute),
      );
      BloomLogger.instance.info('Reminder scheduled for ${now.hour}:${now.minute}');
    }, isGlobal: true);

    actions.registerAction('Reset Streak', () async {
      await streakRepo.clearStreak();
      BloomLogger.instance.warning('Streak reset to 0');
    }, isGlobal: true);

    actions.registerAction('Toggle Premium', () {
      final isPremium = StoreKitService.instance.isPremium.value;
      StoreKitService.instance.isPremium.value = !isPremium;
      BloomLogger.instance.info('Premium toggled to: ${!isPremium}');
    }, isGlobal: true);

    actions.registerAction('Unlock All', () async {
      // We don't have a bulk unlock method, but we can unlock today's or force a state
      // For now, let's just log.
      BloomLogger.instance.info('Unlock All triggered (Mock)');
    }, isGlobal: true);

    actions.registerAction('Clear All Data', () async {
      await prefs.clear();
      BloomLogger.instance.error('ALL DATA CLEARED. Restart app for clean state.');
    }, isGlobal: true);
  }
}

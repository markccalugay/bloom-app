import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import 'package:quietline_app/core/entitlements/premium_entitlement.dart';
import 'package:quietline_app/core/theme/theme_service.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';
import 'package:quietline_app/core/timezone/timezone_service.dart';
import 'package:quietline_app/data/streak/quiet_streak_local_store.dart';
import 'package:quietline_app/data/streak/quiet_streak_repository.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';
import 'package:quietline_app/core/practices/practice_access_service.dart';
import 'package:quietline_app/data/forge/forge_service.dart';
import 'package:quietline_app/core/reminder/reminder_service.dart';
import 'package:quietline_app/core/api/backend_service.dart';
import 'package:quietline_app/core/backup/backup_coordinator.dart';
import 'package:quietline_app/core/auth/auth_service.dart';
import 'package:quietline_app/data/affirmations/affirmations_unlock_service.dart';
import 'package:quietline_app/core/config/app_config.dart';
import 'package:quietline_app/core/services/user_preferences_service.dart';

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

    final prefs = await SharedPreferences.getInstance();
    
    // Streak & Data
    final quietStreakRepo = QuietStreakRepository(
      localStore: QuietStreakLocalStore(prefs),
    );
    QuietStreakService.repo = quietStreakRepo;

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
      streakRepo: quietStreakRepo,
      forgeService: ForgeService.instance,
      affirmationsService: AffirmationsUnlockService.instance,
      themeService: ThemeService.instance,
      reminderService: reminderService,
    );

    debugPrint('[BOOT] Services initialized. Premium=${PremiumEntitlement.instance.isPremium}');
    
    return reminderService;
  }
}

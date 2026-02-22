import 'package:flutter/material.dart';
import 'bloom_account_strings.dart';
import 'package:bloom_app/core/services/haptic_service.dart';
import 'package:intl/intl.dart';
import 'package:bloom_app/core/app_restart.dart';
import 'package:bloom_app/core/auth/auth_service.dart';
import 'package:bloom_app/core/auth/user_model.dart';
import 'package:bloom_app/core/backup/backup_coordinator.dart';
import 'package:bloom_app/core/entitlements/premium_entitlement.dart';
import 'package:bloom_app/core/soundscapes/soundscape_service.dart';
import 'package:bloom_app/core/storekit/storekit_service.dart';
import 'package:bloom_app/data/affirmations/affirmations_packs.dart';
import 'package:bloom_app/data/streak/bloom_streak_service.dart';
import 'package:bloom_app/data/user/user_service.dart';
import 'package:bloom_app/screens/account/bloom_edit_profile_screen.dart';
import 'package:bloom_app/screens/account/remote_data_found_screen.dart';
import 'package:bloom_app/screens/account/widgets/mindful_days_heatmap.dart';
import 'package:bloom_app/screens/account/widgets/soundscape_selection_modal.dart';
import 'package:bloom_app/core/services/mood_service.dart';
import 'package:bloom_app/screens/paywall/bloom_paywall_screen.dart';
import 'package:bloom_app/screens/partners/strength_partner_screen.dart';
import 'package:bloom_app/screens/bloom_breath/models/breath_phase_contracts.dart';
import 'package:bloom_app/core/services/user_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:bloom_app/screens/account/mixes/my_mixes_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Simple MVP account screen.
/// Shows the anonymous user's display name.
class BloomAccountScreen extends StatefulWidget {
  final String reminderLabel;
  final VoidCallback onEditReminder;
  final String currentThemeLabel;
  final VoidCallback onOpenThemeSelection;
  final VoidCallback? onSettingsChanged;

  const BloomAccountScreen({
    super.key,
    required this.reminderLabel,
    required this.onEditReminder,
    required this.currentThemeLabel,
    required this.onOpenThemeSelection,
    this.onSettingsChanged,
  });

  @override
  State<BloomAccountScreen> createState() => _BloomAccountScreenState();
}

class _BloomAccountScreenState extends State<BloomAccountScreen> {
  late final Future<UserProfile> _userFuture;
  late final Future<Map<String, dynamic>> _metricsFuture;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _userFuture = UserService.instance.getOrCreateUser();
    _metricsFuture = _loadMetrics();
    AuthService.instance.silentSignIn();
  }

  Future<Map<String, dynamic>> _loadMetrics() async {
    final streak = await BloomStreakService.getCurrentStreak();
    final sessions = await BloomStreakService.getTotalSessions();
    final seconds = await BloomStreakService.getTotalSeconds();
    final dates = await BloomStreakService.getSessionDates();
    final usage = await BloomStreakService.getPracticeUsage();
    return {
      'streak': streak,
      'sessions': sessions,
      'seconds': seconds,
      'dates': dates,
      'usage': usage, // usage is Map<String, int>
    };
  }

  String _formatDuration(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '$mins minutes, $secs seconds';
  }

  String _formatMemberSince(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  Future<void> _handleSignIn(Future<AuthenticatedUser?> Function() signInMethod) async {
    final user = await signInMethod();
    if (user != null && mounted) {
      // Check for remote data
      final remoteSnapshot = await BackupCoordinator.instance.checkForRemoteSnapshot(user);
      
      if (remoteSnapshot != null && mounted) {
         // Conflict found - navigate to resolution screen
         await Navigator.of(context).push(
           MaterialPageRoute(
             builder: (context) => RemoteDataFoundScreen(
               user: user,
               remoteSnapshot: remoteSnapshot,
               onRestoreCompleted: () {
                 Navigator.of(context).pop();
                 if (mounted) {
                   setState(() { _metricsFuture = _loadMetrics(); });
                   AppRestart.restart(context);
                 }
               },
               onKeepLocalCompleted: () {
                 Navigator.of(context).pop();
                 if (mounted) {
                   setState(() { _metricsFuture = _loadMetrics(); });
                 }
               },
             ),
           ),
         );
      } else {
        // No remote data or check failed - just refresh
        if (mounted) {
          setState(() {
            _metricsFuture = _loadMetrics();
          });
        }
      }
    }
  }

  Future<void> _handleDataWipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          BloomAccountStrings.wipeAllData,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          BloomAccountStrings.wipeDataWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              BloomAccountStrings.cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              BloomAccountStrings.wipeData,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await AuthService.instance.signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (!mounted) return;
        AppRestart.restart(context);
      } catch (e) {
        debugPrint('[ACCOUNT] Error during data wipe: $e');
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Error clearing data. Please try again.')),
          );
        }
      }
    }
  }

  String _getIntensityLabel(double value) {
    if (value < 0.8) return 'Light';
    if (value > 1.2) return 'Deep';
    return 'Medium';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final iconColor = theme.colorScheme.primary;
    final Color baseTextColor = textTheme.bodyMedium?.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(BloomAccountStrings.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<UserProfile>(
            future: _userFuture,
            builder: (context, snapshot) {
              // -------- Loading state --------
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // -------- Error state --------
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 64),
                    child: Text(
                      'We had trouble loading your account details.\n'
                      'You\'re still anonymous and can use Bloom as normal.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              final user = snapshot.data!;
              final displayName = user.username;
              final avatarId = user.avatarId;
              final memberSince = _formatMemberSince(user.createdAt);

              // Map avatarId to emoji (shared logic from UserService)
              final emoji = avatarPresets[avatarId] ?? '👤';

              // -------- Normal content --------
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // Avatar
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Display name
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),


                    // Member Since
                    Text(
                      'You’re anonymous to other members.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: baseTextColor.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Member Since
                    Text(
                      'Member since $memberSince',
                      style: textTheme.labelSmall?.copyWith(
                        color: baseTextColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Edit Profile Button
                    OutlinedButton(
                      onPressed: () async {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => const BloomEditProfileScreen(),
                          ),
                        );
                        if (updated == true) {
                          if (!context.mounted) return;
                          AppRestart.restart(context); // Simple way to refresh everything
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: baseTextColor.withValues(alpha: 0.1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        BloomAccountStrings.editProfile,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: baseTextColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ValueListenableBuilder<bool>(
                      valueListenable: StoreKitService.instance.isPremium,
                      builder: (context, isPremium, _) {
                        if (isPremium) return const SizedBox.shrink();
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const BloomPaywallScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            minimumSize: const Size(200, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            BloomAccountStrings.unlockPremium,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    ValueListenableBuilder<bool>(
                      valueListenable: StoreKitService.instance.isPremium,
                      builder: (context, isPremium, _) {
                        return FutureBuilder<Map<String, dynamic>>(
                          future: _metricsFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox.shrink();
                            final metrics = snapshot.data!;
                            final streak = metrics['streak'] as int;
                            final sessions = metrics['sessions'] as int;
                            final seconds = metrics['seconds'] as int;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  BloomAccountStrings.metrics,
                                  style: textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: baseTextColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _MetricRow(
                                  label: 'Current Streak',
                                  value: '$streak days',
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 12),
                                _MetricRow(
                                  label: 'Sessions Completed',
                                  value: '$sessions',
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 12),
                                _MetricRow(
                                  label: 'Total Bloom Time',
                                  value: _formatDuration(seconds),
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 12),
                                _MetricRow(
                                  label: 'Affirmations Collected',
                                  value: '${streak > 0 ? streak : 0}/${coreAffirmations.length}',
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 32),

                                // Mindful Days Heatmap
                                Text(
                                  BloomAccountStrings.mindfulDays,
                                  style: textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: baseTextColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: baseTextColor.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: MindfulDaysHeatmap(
                                    sessionDates: metrics['dates'] as List<String>,
                                    baseTextColor: baseTextColor,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Mood Reflection
                                Text(
                                  'MOOD REFLECTION',
                                  style: textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: baseTextColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: baseTextColor.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: ListenableBuilder(
                                    listenable: MoodService.instance,
                                    builder: (context, _) {
                                      final logs = MoodService.instance.getLogsForLastWeek();
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildMoodTrendGraph(theme, logs),
                                          const SizedBox(height: 24),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(child: _buildMostCalmDay(theme, logs)),
                                              const SizedBox(width: 16),
                                              Expanded(child: _buildStressReductionMetric(theme, logs)),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Soundscapes Section
                                Text(
                                  BloomAccountStrings.soundscapes,
                                  style: textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: baseTextColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListenableBuilder(
                                  listenable: SoundscapeService.instance,
                                  builder: (context, _) {
                                    final soundService = SoundscapeService.instance;
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: baseTextColor.withValues(alpha: 0.08),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Active: ${soundService.activeSoundscape.name}',
                                                    style: textTheme.bodyMedium?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      color: baseTextColor,
                                                    ),
                                                  ),
                                                  if (soundService.isMuted)
                                                    Text(
                                                      'Muted',
                                                      style: textTheme.bodySmall?.copyWith(
                                                        color: Colors.redAccent.withValues(alpha: 0.7),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    backgroundColor: Colors.transparent,
                                                    builder: (context) => const SoundscapeSelectionModal(),
                                                  );
                                                },
                                                child: Text(
                                                  BloomAccountStrings.change,
                                                  style: TextStyle(
                                                    color: theme.colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Icon(
                                                soundService.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                                size: 20,
                                                color: baseTextColor.withValues(alpha: 0.4),
                                              ),
                                              Expanded(
                                                child: SliderTheme(
                                                  data: SliderTheme.of(context).copyWith(
                                                    trackHeight: 4,
                                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                                  ),
                                                  child: Slider(
                                                    value: soundService.volume,
                                                    onChanged: (val) {
                                                      HapticService.selection();
                                                      soundService.setVolume(val);
                                                    },
                                                    activeColor: theme.colorScheme.primary,
                                                    inactiveColor: baseTextColor.withValues(alpha: 0.1),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${(soundService.volume * 100).toInt()}%',
                                                style: textTheme.labelSmall?.copyWith(
                                                  color: baseTextColor.withValues(alpha: 0.4),
                                                  fontFeatures: [const FontFeature.tabularFigures()],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          InkWell(
                                            onTap: () => soundService.toggleMute(),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child: Checkbox(
                                                      value: soundService.isMuted,
                                                      onChanged: (_) => soundService.toggleMute(),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Mute Soundscape',
                                                    style: textTheme.bodySmall?.copyWith(
                                                      color: baseTextColor.withValues(alpha: 0.7),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 32),

                                // Sound Effects Section
                                Text(
                                  BloomAccountStrings.soundEffects,
                                  style: textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: baseTextColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListenableBuilder(
                                  listenable: SoundscapeService.instance,
                                  builder: (context, _) {
                                    final soundService = SoundscapeService.instance;
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: baseTextColor.withValues(alpha: 0.08),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Clicks, Taps & Countdown',
                                                style: textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: baseTextColor,
                                                ),
                                              ),
                                              if (soundService.isSfxMuted)
                                                Text(
                                                  'Muted',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: Colors.redAccent.withValues(alpha: 0.7),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Icon(
                                                soundService.isSfxMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                                size: 20,
                                                color: baseTextColor.withValues(alpha: 0.4),
                                              ),
                                              Expanded(
                                                child: SliderTheme(
                                                  data: SliderTheme.of(context).copyWith(
                                                    trackHeight: 4,
                                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                                  ),
                                                  child: Slider(
                                                    value: soundService.sfxVolume,
                                                    onChanged: (val) {
                                                      HapticService.selection();
                                                      soundService.setSfxVolume(val);
                                                    },
                                                    activeColor: theme.colorScheme.primary,
                                                    inactiveColor: baseTextColor.withValues(alpha: 0.1),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${(soundService.sfxVolume * 100).toInt()}%',
                                                style: textTheme.labelSmall?.copyWith(
                                                  color: baseTextColor.withValues(alpha: 0.4),
                                                  fontFeatures: [const FontFeature.tabularFigures()],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          InkWell(
                                            onTap: () => soundService.toggleSfxMute(),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child: Checkbox(
                                                      value: soundService.isSfxMuted,
                                                      onChanged: (_) => soundService.toggleSfxMute(),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Mute Sound Effects',
                                                    style: textTheme.bodySmall?.copyWith(
                                                      color: baseTextColor.withValues(alpha: 0.7),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 32),

                                // Favorite Practices
                                Text(
                                  BloomAccountStrings.favoritePractices,
                                  style: textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: baseTextColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildFavoritePractices(metrics['usage'] as Map<String, int>, baseTextColor, theme),
                                const SizedBox(height: 48),
                              ],
                            );
                          },
                        );
                      },
                    ),

                  // --- MIXES SECTION ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PERSONALIZATION',
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                          color: baseTextColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PreferenceTile(
                      icon: Icons.tune_rounded,
                      label: 'My Mixes',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MyMixesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),


                  // --- PREFERENCES SECTION ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        BloomAccountStrings.preferences,
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                          color: baseTextColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _PreferenceTile(
                      icon: Icons.notifications_none_rounded,
                      label: widget.reminderLabel,
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: () {
                        widget.onEditReminder();
                        widget.onSettingsChanged?.call();
                      },
                    ),
                    const SizedBox(height: 12),
                    _PreferenceTile(
                      icon: Icons.palette_outlined,
                      label: widget.currentThemeLabel,
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: () {
                        widget.onOpenThemeSelection();
                        widget.onSettingsChanged?.call();
                      },
                    ),
                    const SizedBox(height: 12),
                    _PreferenceTile(
                      icon: Icons.credit_card_outlined,
                      label: 'Manage Subscription',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: () async {
                         final url = Uri.parse('https://apps.apple.com/account/subscriptions');
                         if (await canLaunchUrl(url)) {
                           await launchUrl(url);
                         }
                      },
                    ),
                    const SizedBox(height: 32),

                    // --- HAPTIC SETTINGS ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Silent Pulse (Haptics)',
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                          color: baseTextColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: UserPreferencesService.instance,
                      builder: (context, _) {
                        final prefs = UserPreferencesService.instance;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: baseTextColor.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Breath-synced Haptics',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: baseTextColor,
                                    ),
                                  ),
                                  Switch(
                                    value: prefs.hapticEnabled,
                                    onChanged: (val) {
                                      HapticService.selection();
                                      prefs.setHapticEnabled(val);
                                    },
                                    activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                                    activeThumbColor: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                              if (prefs.hapticEnabled) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Intensity',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: baseTextColor.withValues(alpha: 0.6),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.vibration, size: 16),
                                    Expanded(
                                      child: Slider(
                                        value: prefs.hapticIntensity,
                                        min: 0.5,
                                        max: 1.5,
                                        onChanged: (val) {
                                          prefs.setHapticIntensity(val);
                                        },
                                        onChangeEnd: (val) {
                                          HapticService.silentPulse(intensity: val);
                                        },
                                      ),
                                    ),
                                    Text(
                                      _getIntensityLabel(prefs.hapticIntensity),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // --- DATA MANAGEMENT ---
                    const SizedBox(height: 24),
                    ListenableBuilder(
                      listenable: AuthService.instance.connectedUsersNotifier,
                      builder: (context, _) {
                        final googleUser = AuthService.instance.googleUser;
                        final appleUser = AuthService.instance.appleUser;
                        final isDark = Theme.of(context).brightness == Brightness.dark;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              BloomAccountStrings.syncAndBackup,
                              style: textTheme.labelSmall?.copyWith(
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                                color: baseTextColor.withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            /*
                            // 1. Apple Section
                            if (appleUser != null)
                              _ConnectedProviderCard(
                                providerName: 'Apple',
                                email: appleUser.email ?? 'Connected',
                                icon: Icons.apple,
                                onDisconnect: () async {
                                  await AuthService.instance.signOutApple();
                                  if (context.mounted) {
                                     setState(() { _metricsFuture = _loadMetrics(); });
                                  }
                                },
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: SignInWithAppleButton(
                                  onPressed: () => _handleSignIn(() => AuthService.instance.signInWithApple()),
                                  style: isDark 
                                      ? SignInWithAppleButtonStyle.white 
                                      : SignInWithAppleButtonStyle.black,
                                  height: 50,
                                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                            */

                            /*
                            // 2. Google Section
                            if (googleUser != null)
                              Padding(
                                padding: EdgeInsets.only(top: appleUser != null ? 8.0 : 0),
                                child: _ConnectedProviderCard(
                                  providerName: 'Google',
                                  email: googleUser.email ?? 'Connected',
                                  icon: Icons.cloud_circle, 
                                  onDisconnect: () async {
                                    await AuthService.instance.signOutGoogle();
                                    if (context.mounted) {
                                       setState(() { _metricsFuture = _loadMetrics(); });
                                    }
                                  },
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleSignIn(() => AuthService.instance.signInWithGoogle()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(color: Colors.black12),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                    height: 20,
                                  ),
                                  label: const Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 19,
                                      fontFamily: 'SF Pro Text',
                                    ),
                                  ),
                                ),
                              ),
                            */
                            /*
                            if (googleUser != null || appleUser != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: _isSyncing 
                                  ? const Center(child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ))
                                  : OutlinedButton.icon(
                                      onPressed: () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        setState(() => _isSyncing = true);
                                        try {
                                          await BackupCoordinator.instance.runBackup();
                                          messenger.showSnackBar(
                                            const SnackBar(content: Text('Progress synced to cloud')),
                                          );
                                        } catch (e) {
                                          debugPrint('[SYNC] Manual sync error: $e');
                                          
                                          // Handle missing token (common for cached Apple users)
                                          if (e.toString().contains('Authentication token missing')) {
                                            final auth = AuthService.instance;
                                            if (auth.appleUser != null) {
                                              // Prompt for Apple Re-auth
                                              final user = await auth.signInWithApple();
                                              if (user != null) {
                                                // Retry once after successful re-auth
                                                try {
                                                  await BackupCoordinator.instance.runBackup();
                                                  messenger.showSnackBar(
                                                    const SnackBar(content: Text('Progress synced to cloud')),
                                                  );
                                                  return;
                                                } catch (retryErr) {
                                                  debugPrint('[SYNC] Retry failed: $retryErr');
                                                }
                                              }
                                            }
                                          }
                                          
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text('Sync failed: ${e.toString().replaceAll('Exception: ', '')}'),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        } finally {
                                          if (mounted) setState(() => _isSyncing = false);
                                        }
                                      },
                                      icon: const Icon(Icons.sync_rounded, size: 18),
                                      label: const Text('Sync to Cloud Now'),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 44),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                              ),
                            */
                            const SizedBox(height: 24),
                            _buildSectionHeader(theme, 'MEMBERSHIP'),
                            _buildActionItem(
                              context,
                              icon: Icons.people_outline,
                              label: 'Strength Partner',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const StrengthPartnerScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 12),

                            // 3. Data Wipe - Always visible
                            Center(
                              child: TextButton(
                                onPressed: _handleDataWipe,
                                child: Text(
                                  'Data Wipe',
                                  style: TextStyle(
                                    color: Colors.redAccent.withValues(alpha: 0.7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritePractices(
    Map<String, int> usage,
    Color baseTextColor,
    ThemeData theme,
  ) {
    if (usage.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: baseTextColor.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Text(
            'Start a session to see favorites.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: baseTextColor.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    final isPremium = PremiumEntitlement.instance.isPremium;
    final int limit = isPremium ? 3 : 1;

    final sortedUsage = usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topPractices = sortedUsage.take(limit).toList();

    return Column(
      children: topPractices.map((entry) {
        final practice = allBreathingPractices.firstWhere(
          (p) => p.id == entry.key,
          orElse: () => BreathingPracticeContract(
            id: entry.key,
            name: 'Unknown',
            phases: [],
            cycles: 0,
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _MetricRow(
            label: practice.name,
            value: '${entry.value} times',
            textColor: baseTextColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodTrendGraph(ThemeData theme, List<MoodLogEntry> logs) {
    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Keep practicing to see your mood trends.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final currentWeekday = now.weekday; 
    
    final moodByDay = List.generate(7, (_) => <int>[]);
    for (final log in logs) {
      final dayIndex = log.timestamp.weekday - 1; 
      moodByDay[dayIndex].add(log.moodValue);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final avgMood = moodByDay[i].isEmpty 
                ? 0.0 
                : moodByDay[i].reduce((a, b) => a + b) / moodByDay[i].length;
            
            final isCurrentDay = i == (currentWeekday - 1);

            return Column(
              children: [
                Container(
                  height: 100,
                  width: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentDay ? theme.colorScheme.primary.withValues(alpha: 0.4) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      if (avgMood > 0)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: avgMood * 20, 
                          width: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.6),
                                theme.colorScheme.primary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dayLabels[i],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isCurrentDay ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMostCalmDay(ThemeData theme, List<MoodLogEntry> logs) {
    if (logs.isEmpty) return const SizedBox.shrink();

    final moodByDay = List.generate(7, (_) => <int>[]);
    for (final log in logs) {
      moodByDay[log.timestamp.weekday - 1].add(log.moodValue);
    }

    double maxMood = -1;
    int bestDayIndex = -1;

    for (int i = 0; i < 7; i++) {
       if (moodByDay[i].isNotEmpty) {
         final avg = moodByDay[i].reduce((a, b) => a + b) / moodByDay[i].length;
         if (avg > maxMood) {
           maxMood = avg;
           bestDayIndex = i;
         }
       }
    }

    if (bestDayIndex == -1) return const SizedBox.shrink();

    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return Row(
      children: [
        Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Most Calm Day',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              dayNames[bestDayIndex],
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStressReductionMetric(ThemeData theme, List<MoodLogEntry> logs) {
    if (logs.length < 2) return const SizedBox.shrink();

    // Sort logs by time (should already be somewhat sorted but let's be sure)
    final sortedLogs = List<MoodLogEntry>.from(logs);
    sortedLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Compare average of first 3 entries vs last 3 entries
    final firstCount = sortedLogs.length >= 3 ? 3 : sortedLogs.length ~/ 2;
    if (firstCount == 0) return const SizedBox.shrink();

    final firstAvg = sortedLogs.take(firstCount).map((e) => e.moodValue).reduce((a, b) => a + b) / firstCount;
    final lastAvg = sortedLogs.reversed.take(firstCount).map((e) => e.moodValue).reduce((a, b) => a + b) / firstCount;

    // "Reduction" actually means current mood (lastAvg) is higher than starting mood (firstAvg)
    // Formula: ((last - first) / first) * 100
    // We'll call this the "Bloom Effect"
    final delta = ((lastAvg - firstAvg) / firstAvg) * 100;
    final displayDelta = delta.clamp(0.0, 1000.0).toStringAsFixed(0);

    return Row(
      children: [
        Icon(Icons.trending_up_rounded, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bloom Effect',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '+$displayDelta%',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final baseTextColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _PreferenceTile(
        icon: icon,
        label: label,
        iconColor: theme.colorScheme.primary,
        textColor: baseTextColor,
        onTap: onTap,
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _PreferenceTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: textColor.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: textColor.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectedProviderCard extends StatelessWidget {
  final String providerName;
  final String email;
  final IconData icon;
  final VoidCallback onDisconnect;

  const _ConnectedProviderCard({
    required this.providerName,
    required this.email,
    required this.icon,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseTextColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: baseTextColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: baseTextColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  providerName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: baseTextColor.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onDisconnect,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
            child: const Text(BloomAccountStrings.disconnect),
          ),
        ],
      ),
    );
  }
}

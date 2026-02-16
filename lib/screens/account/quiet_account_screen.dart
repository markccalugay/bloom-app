import 'package:flutter/material.dart';
import 'quiet_account_strings.dart';
import 'package:quietline_app/core/services/haptic_service.dart';
import 'package:intl/intl.dart';
import 'package:quietline_app/core/app_restart.dart';
import 'package:quietline_app/core/auth/auth_service.dart';
import 'package:quietline_app/core/auth/user_model.dart';
import 'package:quietline_app/core/backup/backup_coordinator.dart';
import 'package:quietline_app/core/entitlements/premium_entitlement.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import 'package:quietline_app/data/affirmations/affirmations_packs.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';
import 'package:quietline_app/data/user/user_service.dart';
import 'package:quietline_app/screens/account/quiet_edit_profile_screen.dart';
import 'package:quietline_app/screens/account/remote_data_found_screen.dart';
import 'package:quietline_app/screens/account/widgets/mindful_days_heatmap.dart';
import 'package:quietline_app/screens/account/widgets/soundscape_selection_modal.dart';
import 'package:quietline_app/screens/paywall/quiet_paywall_screen.dart';
import 'package:quietline_app/screens/quiet_breath/models/breath_phase_contracts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Simple MVP account screen.
/// Shows the anonymous user's display name.
class QuietAccountScreen extends StatefulWidget {
  final String reminderLabel;
  final VoidCallback onEditReminder;
  final String currentThemeLabel;
  final VoidCallback onOpenThemeSelection;
  final VoidCallback? onSettingsChanged;

  const QuietAccountScreen({
    super.key,
    required this.reminderLabel,
    required this.onEditReminder,
    required this.currentThemeLabel,
    required this.onOpenThemeSelection,
    this.onSettingsChanged,
  });

  @override
  State<QuietAccountScreen> createState() => _QuietAccountScreenState();
}

class _QuietAccountScreenState extends State<QuietAccountScreen> {
  late final Future<UserProfile> _userFuture;
  late final Future<Map<String, dynamic>> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = UserService.instance.getOrCreateUser();
    _metricsFuture = _loadMetrics();
    AuthService.instance.silentSignIn();
  }

  Future<Map<String, dynamic>> _loadMetrics() async {
    final streak = await QuietStreakService.getCurrentStreak();
    final sessions = await QuietStreakService.getTotalSessions();
    final seconds = await QuietStreakService.getTotalSeconds();
    final dates = await QuietStreakService.getSessionDates();
    final usage = await QuietStreakService.getPracticeUsage();
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
          QuietAccountStrings.wipeAllData,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          QuietAccountStrings.wipeDataWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              QuietAccountStrings.cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              QuietAccountStrings.wipeData,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      AppRestart.restart(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final iconColor = theme.colorScheme.primary;
    final Color baseTextColor = textTheme.bodyMedium?.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(QuietAccountStrings.title),
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
                      'You\'re still anonymous and can use QuietLine as normal.',
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
                            builder: (context) => const QuietEditProfileScreen(),
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
                        QuietAccountStrings.editProfile,
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
                                builder: (context) => const QuietPaywallScreen(),
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
                            QuietAccountStrings.unlockPremium,
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
                                  QuietAccountStrings.metrics,
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
                                  label: 'Total Quiet Time',
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
                                  QuietAccountStrings.mindfulDays,
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

                                // Soundscapes Section
                                Text(
                                  QuietAccountStrings.soundscapes,
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
                                                  QuietAccountStrings.change,
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
                                  QuietAccountStrings.soundEffects,
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
                                  QuietAccountStrings.favoritePractices,
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

                    // --- PREFERENCES SECTION ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        QuietAccountStrings.preferences,
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
                              QuietAccountStrings.syncAndBackup,
                              style: textTheme.labelSmall?.copyWith(
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                                color: baseTextColor.withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
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
            child: const Text(QuietAccountStrings.disconnect),
          ),
        ],
      ),
    );
  }
}

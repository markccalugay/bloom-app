import 'package:flutter/material.dart';
import 'bloom_account_strings.dart';
import 'package:bloom_app/core/services/haptic_service.dart';
import 'package:intl/intl.dart';
import 'package:bloom_app/core/app_restart.dart';
import 'package:bloom_app/core/auth/auth_service.dart';
import 'package:bloom_app/core/entitlements/premium_entitlement.dart';
import 'package:bloom_app/core/soundscapes/soundscape_service.dart';
import 'package:bloom_app/core/storekit/storekit_service.dart';
import 'package:bloom_app/data/affirmations/affirmations_packs.dart';
import 'package:bloom_app/data/streak/bloom_streak_service.dart';
import 'package:bloom_app/data/user/user_service.dart';
import 'package:bloom_app/screens/account/bloom_edit_profile_screen.dart';
import 'package:bloom_app/screens/account/widgets/mindful_days_heatmap.dart';
import 'package:bloom_app/screens/account/widgets/soundscape_selection_modal.dart';
import 'package:bloom_app/screens/paywall/bloom_paywall_screen.dart';
import 'package:bloom_app/screens/partners/strength_partner_screen.dart';
import 'package:bloom_app/screens/bloom_breath/models/breath_phase_contracts.dart';
import 'package:bloom_app/core/services/user_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloom_app/screens/account/mixes/my_mixes_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bloom_app/screens/account/widgets/account_widgets.dart';
import 'package:bloom_app/screens/account/widgets/mood_reflection_section.dart';

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


  Future<void> _handleDataWipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
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
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                BloomAccountStrings.wipeData,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
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
    final Color baseTextColor = theme.colorScheme.onSurface;

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
                                MetricRow(
                                  label: 'Current Streak',
                                  value: '$streak days',
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 12),
                                MetricRow(
                                  label: 'Sessions Completed',
                                  value: '$sessions',
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 12),
                                MetricRow(
                                  label: 'Total Bloom Time',
                                  value: _formatDuration(seconds),
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 12),
                                MetricRow(
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

                                MoodReflectionSection(baseTextColor: baseTextColor),
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
                                                        color: theme.colorScheme.error.withValues(alpha: 0.7),
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
                                                    backgroundColor: theme.colorScheme.surface,
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
                                                    color: theme.colorScheme.error.withValues(alpha: 0.7),
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
                    PreferenceTile(
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

                    PreferenceTile(
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
                    PreferenceTile(
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
                    PreferenceTile(
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                    color: theme.colorScheme.error.withValues(alpha: 0.7),
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
          child: MetricRow(
            label: practice.name,
            value: '${entry.value} times',
            textColor: baseTextColor,
          ),
        );
      }).toList(),
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
    final baseTextColor = theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: PreferenceTile(
        icon: icon,
        label: label,
        iconColor: theme.colorScheme.primary,
        textColor: baseTextColor,
        onTap: onTap,
      ),
    );
  }
}



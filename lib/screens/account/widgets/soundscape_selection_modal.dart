import 'package:flutter/material.dart';
import 'package:bloom_app/core/services/haptic_service.dart';
import 'package:bloom_app/core/soundscapes/soundscape_models.dart';
import 'package:bloom_app/core/soundscapes/soundscape_service.dart';
import 'package:bloom_app/core/entitlements/premium_entitlement.dart';
import 'package:bloom_app/screens/paywall/bloom_paywall_screen.dart';

class SoundscapeSelectionModal extends StatelessWidget {
  const SoundscapeSelectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium = PremiumEntitlement.instance.isPremium;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'SOUNDSCAPES',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildSectionHeader(theme, 'CORE SOUNDSCAPES'),
                ...allSoundscapes.where((s) => !s.isPremium).map((s) => _buildSoundscapeTile(context, theme, s, isPremium)),
                const SizedBox(height: 16),
                _buildSectionHeader(theme, 'BLOOM+ SOUNDSCAPES'),
                ...allSoundscapes.where((s) => s.isPremium).map((s) => _buildSoundscapeTile(context, theme, s, isPremium)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildSoundscapeTile(BuildContext context, ThemeData theme, Soundscape soundscape, bool isPremium) {
    final isActive = SoundscapeService.instance.activeSoundscape.id == soundscape.id;
    final isLocked = soundscape.isPremium && !isPremium;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(
        isActive ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      title: Row(
        children: [
          Text(
            soundscape.name,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isLocked ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : null,
            ),
          ),
          if (isLocked) ...[
            const SizedBox(width: 8),
            Icon(Icons.lock_outline, size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
          ],
        ],
      ),
      subtitle: isActive 
        ? Text('Active', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600))
        : null,
      onTap: () => _handleSelection(context, soundscape, isLocked),
    );
  }

  Future<void> _handleSelection(BuildContext context, Soundscape soundscape, bool isLocked) async {
    if (isLocked) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const BloomPaywallScreen()));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Change Soundscape?'),
        content: Text('Would you like to switch to ${soundscape.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.selection();
              Navigator.pop(context, false);
            },
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              HapticService.selection();
              Navigator.pop(context, true);
            },
            child: Text('Confirm', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await SoundscapeService.instance.setSoundscape(soundscape);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:quietline_app/core/services/haptic_service.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import 'package:quietline_app/core/services/user_preferences_service.dart';
import 'package:quietline_app/core/soundscapes/soundscape_models.dart';
import 'package:quietline_app/screens/paywall/quiet_paywall_screen.dart';
import 'package:quietline_app/screens/practice/models/custom_session_config.dart';
import 'package:quietline_app/screens/quiet_breath/models/breath_phase_contracts.dart';
import 'package:uuid/uuid.dart';

class CustomMixScreen extends StatefulWidget {
  final CustomSessionConfig? existingConfig;

  const CustomMixScreen({super.key, this.existingConfig});

  @override
  State<CustomMixScreen> createState() => _CustomMixScreenState();
}

class _CustomMixScreenState extends State<CustomMixScreen> {
  late String _name;
  late BreathingPracticeContract _selectedPractice;
  late Soundscape _selectedSoundscape;
  
  // Preset durations in seconds: 90s, 3m, 5m, 10m, 20m
  final List<int> _durationPresets = [90, 180, 300, 600, 1200];
  int _selectedDurationIndex = 2; // Default to 5m (Index 2)

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existingConfig != null) {
      final config = widget.existingConfig!;
      _name = config.name;
      _selectedPractice = allBreathingPractices.firstWhere(
        (p) => p.id == config.breathPatternId,
        orElse: () => allBreathingPractices.first,
      );
      _selectedSoundscape = allSoundscapes.firstWhere(
        (s) => s.id == config.soundscapeId,
        orElse: () => allSoundscapes.first,
      );
      
      // Find closest preset
      final existingSeconds = widget.existingConfig!.durationSeconds;
      int closestIndex = 0;
      int minDiff = 999999;
      for (int i = 0; i < _durationPresets.length; i++) {
        final diff = (existingSeconds - _durationPresets[i]).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestIndex = i;
        }
      }
      _selectedDurationIndex = closestIndex;
    } else {
      _name = '';
      _selectedPractice = allBreathingPractices.first;
      _selectedSoundscape = allSoundscapes.first;
      _selectedDurationIndex = 2; // Default to 5m
    }
  }

  void _handlePracticeSelection(BreathingPracticeContract practice) {
    if (practice.isPremium && !StoreKitService.instance.isPremium.value) {
      _showPaywallPrompt(
        'Premium Practice',
        '${practice.name} is a QuietLine+ feature.\nUpgrade to unlock unlimited access.',
      );
      return;
    }
    
    setState(() => _selectedPractice = practice);
  }

  void _showPaywallPrompt(String title, String message) {
    HapticService.selection();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuietPaywallScreen()),
              );
            },
            child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _saveMix() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final config = CustomSessionConfig(
      id: widget.existingConfig?.id ?? const Uuid().v4(),
      name: _name,
      breathPatternId: _selectedPractice.id,
      soundscapeId: _selectedSoundscape.id,
      durationSeconds: _durationPresets[_selectedDurationIndex],
    );

    UserPreferencesService.instance.saveCustomMix(config);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Using a modal-style layout
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingConfig == null ? 'New Mix' : 'Edit Mix'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _saveMix,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Name Input
            TextFormField(
              initialValue: _name,
              style: theme.textTheme.titleLarge,
              decoration: const InputDecoration(
                labelText: 'Mix Name',
                hintText: 'e.g., Morning Calm',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
              onSaved: (v) => _name = v!,
            ),
            const SizedBox(height: 32),

            // Duration Selector
            Text(
              'DURATION',
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _durationPresets.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final seconds = _durationPresets[index];
                  final label = seconds < 60 ? '${seconds}s' : '${seconds ~/ 60}m';
                  final isSelected = index == _selectedDurationIndex;
                  final isPremium = seconds > 180; // 5m, 10m, 20m are premium
                  final isLocked = isPremium && !StoreKitService.instance.isPremium.value;
                  
                  return _SelectionCard(
                    title: label,
                    isSelected: isSelected,
                    isLocked: isLocked,
                    onTap: () {
                      if (isLocked) {
                        _showPaywallPrompt(
                          'Extended Duration',
                          'Sessions longer than 3 minutes are a QuietLine+ feature.\nUpgrade to unlock up to 20 minutes.',
                        );
                        return;
                      }
                      setState(() => _selectedDurationIndex = index);
                      HapticService.selection();
                    },
                    color: isSelected ? theme.colorScheme.primary : theme.cardColor,
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),

            // Soundscape Selector
            Text(
              'AUDIO ENVIRONMENT',
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allSoundscapes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final sound = allSoundscapes[index];
                  final isSelected = sound.id == _selectedSoundscape.id;
                  final isLocked = sound.isPremium && !StoreKitService.instance.isPremium.value;

                  return _SelectionCard(
                    title: sound.name,
                    subtitle: sound.isPremium ? 'Premium' : 'Free',
                    isSelected: isSelected,
                    isLocked: isLocked,
                    onTap: () {
                      if (isLocked) {
                        _showPaywallPrompt(
                          'Premium Environment',
                          '${sound.name} is a QuietLine+ feature.\nUpgrade to unlock all audio environments.',
                        );
                        return;
                      }
                      setState(() => _selectedSoundscape = sound);
                    },
                    color: isSelected ? theme.colorScheme.primary : theme.cardColor,
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Breath Pattern Selector
            Text(
              'BREATHING PATTERN',
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allBreathingPractices.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final practice = allBreathingPractices[index];
                  final isSelected = practice.id == _selectedPractice.id;
                  return _SelectionCard(
                    title: practice.name,
                    subtitle: practice.isPremium ? 'Premium' : 'Free',
                    isSelected: isSelected,
                    onTap: () => _handlePracticeSelection(practice),
                    color: isSelected ? theme.colorScheme.primary : theme.cardColor,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;
  final Color color;

  const _SelectionCard({
    required this.title,
    this.subtitle,
    required this.isSelected,
    this.isLocked = false,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLocked) ...[
              Icon(Icons.lock_outline, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(height: 4),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : null,
              ),
            ),
            if (subtitle != null && !isLocked) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Colors.white70 : null,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

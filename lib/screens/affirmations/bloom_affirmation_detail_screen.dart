import 'package:flutter/material.dart';
import 'package:bloom_app/data/affirmations/affirmations_model.dart';
import 'package:bloom_app/data/affirmations/affirmation_pack_theme.dart';

/// Fullscreen detail view for a single affirmation.
/// - Big centered text
/// - Dark gradient card with stroke
/// - "Unlocked…" text at the bottom-left
/// - Simple Save (heart) toggle on the bottom-right
class BloomAffirmationDetailScreen extends StatefulWidget {
  final Affirmation affirmation;
  final String? unlockedLabel;
  final bool initiallySaved; // future: wire to real favorites

  const BloomAffirmationDetailScreen({
    super.key,
    required this.affirmation,
    this.unlockedLabel,
    this.initiallySaved = false,
  });

  @override
  State<BloomAffirmationDetailScreen> createState() =>
      _BloomAffirmationDetailScreenState();
}

class _BloomAffirmationDetailScreenState
    extends State<BloomAffirmationDetailScreen> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.initiallySaved;
  }

  void _toggleSaved() {
    setState(() {
      _isSaved = !_isSaved;
    });

    final message =
        _isSaved ? 'Added to your saved affirmations.' : 'Removed from saved.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final onSurface = theme.colorScheme.onSurface;

    final packTheme = AffirmationPackTheme.forPack(widget.affirmation.packId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Main affirmation card area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: packTheme.borderColor,
                      width: 1.5,
                    ),
                    gradient: packTheme.backgroundGradient,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Center(
                    child: Text(
                      widget.affirmation.text,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom row: unlocked label + save button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.unlockedLabel != null)
                    Expanded(
                      child: Text(
                        widget.unlockedLabel!,
                        style: textTheme.bodySmall?.copyWith(
                          color: (textTheme.bodySmall?.color ?? Colors.white)
                              .withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  IconButton(
                    icon: Icon(
                      _isSaved ? Icons.favorite : Icons.favorite_border,
                      color: _isSaved
                          ? theme.colorScheme.primary
                          : onSurface.withValues(alpha: 0.8),
                    ),
                    onPressed: _toggleSaved,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
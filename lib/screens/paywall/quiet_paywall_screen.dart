import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import 'package:url_launcher/url_launcher.dart';

class QuietPaywallScreen extends StatefulWidget {
  const QuietPaywallScreen({super.key});

  @override
  State<QuietPaywallScreen> createState() => _QuietPaywallScreenState();
}

class _QuietPaywallScreenState extends State<QuietPaywallScreen> {
  bool _isProcessing = false;
  bool _hasClosed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ValueListenableBuilder<bool>(
      valueListenable: StoreKitService.instance.isPremium,
      builder: (context, isPremium, _) {
        if (isPremium && !_hasClosed) {
          _hasClosed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 100,
            leading: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Back',
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'QuietLine+ Premium',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'QuietLine+ Premium supports long-term discipline, calm, and resilience through structured breathwork and progress-based rewards.',
                    style: textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'What’s included',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBullet(context, 'All guided breathing practices, including discipline, calm, and focus protocols'),
                  _buildBullet(context, 'Progress-based unlocks tied to streaks and consistency'),
                  _buildBullet(context, 'Full access to the Armor Room to mark your discipline over time'),
                  const SizedBox(height: 60),
                  
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'QuietLine+ Premium',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$4.99 per month',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Subscription automatically renews unless canceled at least 24 hours before the end of the current period.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isPremium || _isProcessing)
                          ? null
                          : () async {
                              HapticFeedback.selectionClick();
                              setState(() => _isProcessing = true);
                              await StoreKitService.instance.purchasePremium();
                              if (mounted) setState(() => _isProcessing = false);
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Unlock QuietLine+ Premium',
                              style: textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Stay with free for now',
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegalButton(
                        label: 'Restore',
                        onTap: () async {
                          setState(() => _isProcessing = true);
                          await StoreKitService.instance.restorePurchases();
                          if (mounted) setState(() => _isProcessing = false);
                        },
                      ),
                      _LegalSeparator(),
                      _LegalButton(
                        label: 'Terms',
                        onTap: () => launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/')),
                      ),
                      _LegalSeparator(),
                      _LegalButton(
                        label: 'Privacy',
                        onTap: () => launchUrl(Uri.parse('https://quietline.app/privacy')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle_outline,
              size: 18,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LegalButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            decoration: TextDecoration.underline,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _LegalSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      '•',
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
    );
  }
}
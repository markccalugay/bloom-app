import 'package:flutter/material.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import '../../theme/ql_theme.dart';

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
          backgroundColor: QLColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'Go Deeper',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unlock additional breathing practices designed to build discipline, calm, and resilience.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: (isPremium || _isProcessing)
                        ? null
                        : () async {
                            setState(() => _isProcessing = true);
                            await StoreKitService.instance.purchasePremium();
                            if (mounted) setState(() => _isProcessing = false);
                          },
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isPremium ? 'QuietLine+ Unlocked' : 'Unlock QuietLine+',
                          ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              setState(() => _isProcessing = true);
                              await StoreKitService.instance.restorePurchases();
                              if (mounted) setState(() => _isProcessing = false);
                            },
                      child: Text(
                        'Restore Purchases',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Maybe later',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
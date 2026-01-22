import 'package:flutter/material.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import '../../theme/ql_theme.dart';

class QuietPaywallScreen extends StatelessWidget {
  const QuietPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: StoreKitService.instance.isPremium,
      builder: (context, isPremium, _) {
        if (isPremium) {
          // Close paywall automatically once premium is unlocked
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
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
                    onPressed: isPremium
                        ? null
                        : () async {
                            await StoreKitService.instance.purchasePremium();
                          },
                    child: Text(
                      isPremium ? 'QuietLine+ Unlocked' : 'Unlock QuietLine+',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await StoreKitService.instance.restorePurchases();
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
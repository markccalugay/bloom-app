import 'package:flutter/material.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import 'package:quietline_app/core/services/haptic_service.dart';
import 'package:url_launcher/url_launcher.dart';

class QuietPaywallScreen extends StatefulWidget {
  const QuietPaywallScreen({super.key});

  @override
  State<QuietPaywallScreen> createState() => _QuietPaywallScreenState();
}

class _QuietPaywallScreenState extends State<QuietPaywallScreen> {
  bool _isProcessing = false;
  String _selectedProductId = 'quietline.premium.yearly';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: StoreKitService.instance.isPremium,
      builder: (context, isPremium, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: isPremium 
                ? _buildPremiumStatus(context)
                : _buildPricingFlow(context),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cancel anytime in Settings.',
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 40),
        
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
    );
  }

  Widget _buildPremiumStatus(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.verified,
            size: 64,
            color: const Color(0xFF4FA095), // Calm Teal
          ),
          const SizedBox(height: 24),
          Text(
            'You’re on QuietLine Premium',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your commitment to calm is active.\nManage your subscription in your device settings.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Return Home',
                style: textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingFlow(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Text(
          'Commit to your calm',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 32),
        
        // Pricing Tiers
        _PricingCard(
          productId: 'quietline.premium.yearly',
          title: 'Yearly',
          priceDisplay: '\$49.99',
          intervalLabel: '/ year',
          secondaryPrice: '\$4.16 per month',
          tagline: 'Train for a full year.',
          isHighlighted: true,
          isSelected: _selectedProductId == 'quietline.premium.yearly',
          onTap: () {
            HapticService.selection();
            setState(() => _selectedProductId = 'quietline.premium.yearly');
          },
        ),
        const SizedBox(height: 12),
        _PricingCard(
          productId: 'quietline.premium.monthly.v2',
          title: 'Monthly',
          priceDisplay: '\$6.99',
          intervalLabel: '/ month',
          tagline: 'For steady momentum.',
          isSelected: _selectedProductId == 'quietline.premium.monthly.v2',
          onTap: () {
            HapticService.selection();
            setState(() => _selectedProductId = 'quietline.premium.monthly.v2');
          },
        ),
        const SizedBox(height: 12),
        _PricingCard(
          productId: 'quietline.premium.weekly',
          title: 'Weekly',
          priceDisplay: '\$2.99',
          intervalLabel: '/ week',
          tagline: 'Flexible access.',
          isSelected: _selectedProductId == 'quietline.premium.weekly',
          onTap: () {
            HapticService.selection();
            setState(() => _selectedProductId = 'quietline.premium.weekly');
          },
        ),
        
        const SizedBox(height: 48),

        // Shared Feature List
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Includes',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(context, 'Premium guided practices'),
        
        const SizedBox(height: 48),
        
        // CTA Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () async {
                    HapticService.selection();
                    setState(() => _isProcessing = true);
                    await StoreKitService.instance.purchasePremium(_selectedProductId);
                    if (mounted) setState(() => _isProcessing = false);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FA095), // Calm Teal
              elevation: 4,
              shadowColor: const Color(0xFF4FA095).withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 18),
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
                    _getCTAButtonText(),
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cancel anytime in Settings.',
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 40),
        
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
    );
  }

  String _getCTAButtonText() {
    if (_selectedProductId == 'quietline.premium.yearly') return 'Start Yearly';
    if (_selectedProductId == 'quietline.premium.monthly.v2') return 'Start Monthly';
    return 'Start Weekly';
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 16,
            color: const Color(0xFF4FA095), // Calm Teal
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String productId;
  final String title;
  final String priceDisplay;
  final String intervalLabel;
  final String? secondaryPrice;
  final String tagline;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _PricingCard({
    required this.productId,
    required this.title,
    required this.priceDisplay,
    required this.intervalLabel,
    this.secondaryPrice,
    required this.tagline,
    required this.isSelected,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final accentColor = theme.colorScheme.primary; 

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias, // Ensure children respect the border radius
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            if (isHighlighted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor,
                ),
                child: Center(
                  child: Text(
                    'Most chosen',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: isSelected ? 1.0 : 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tagline,
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: isSelected ? 0.8 : 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (isSelected) ...[
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: priceDisplay,
                                      style: textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    TextSpan(
                                      text: intervalLabel,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (secondaryPrice != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  secondaryPrice!,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (productId == 'quietline.premium.yearly') ...[
                     const SizedBox(height: 12),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                       decoration: BoxDecoration(
                         color: accentColor.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(6),
                       ),
                       child: Text(
                         'Save 40%',
                         style: textTheme.labelSmall?.copyWith(
                           color: accentColor,
                           fontWeight: FontWeight.w800,
                         ),
                       ),
                     ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String productId;
  final String title;
  final String priceDisplay;
  final String intervalLabel;
  final String? secondaryPrice;
  final String tagline;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _PricingCard({
    required this.productId,
    required this.title,
    required this.priceDisplay,
    required this.intervalLabel,
    this.secondaryPrice,
    required this.tagline,
    required this.isSelected,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final accentColor = theme.colorScheme.primary; 

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias, // Ensure children respect the border radius
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            if (isHighlighted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor,
                ),
                child: Center(
                  child: Text(
                    'Most chosen',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: isSelected ? 1.0 : 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tagline,
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: isSelected ? 0.8 : 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (isSelected) ...[
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: priceDisplay,
                                      style: textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    TextSpan(
                                      text: intervalLabel,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (secondaryPrice != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  secondaryPrice!,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (productId == 'quietline.premium.yearly') ...[
                     const SizedBox(height: 12),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                       decoration: BoxDecoration(
                         color: accentColor.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(6),
                       ),
                       child: Text(
                         'Save 40%',
                         style: textTheme.labelSmall?.copyWith(
                           color: accentColor,
                           fontWeight: FontWeight.w800,
                         ),
                       ),
                     ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
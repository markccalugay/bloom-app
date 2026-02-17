import 'package:flutter/material.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import 'package:quietline_app/core/services/haptic_service.dart';
import 'package:quietline_app/core/services/quiet_analytics.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<bool>(
      valueListenable: StoreKitService.instance.isPremium,
      builder: (context, isPremium, _) {
        return Scaffold(
          body: Stack(
            children: [
              // 1. Dynamic Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A), // Slate 900
                            const Color(0xFF1E293B), // Slate 800
                            const Color(0xFF0F172A),
                          ]
                        : [
                            const Color(0xFFE2E8F0), // Slate 200
                            const Color(0xFFF8FAFC), // Slate 50
                            const Color(0xFFE2E8F0),
                          ],
                  ),
                ),
              ),

              // 2. Content
              SafeArea(
                child: Column(
                  children: [
                    // Header with Close Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: isPremium
                            ? _buildPremiumStatus(context)
                            : _buildPricingFlow(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumStatus(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Premium Active',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your commitment to calm is verified.\nEnjoy unlimited access to all practices.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 60),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Return Home'),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingFlow(BuildContext context) {
    final theme = Theme.of(context);
    
    // DYNAMIC TRIAL LOGIC
    // 1. Only Yearly is eligible for trial in UI
    // 2. Must actually have an intro offer from StoreKit
    final isYearly = _selectedProductId == 'quietline.premium.yearly';
    final hasIntroOffer = StoreKitService.instance.hasIntroductoryOffer(_selectedProductId);
    final isTrialEligible = isYearly && hasIntroOffer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Section
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'QUIETLINE+ PREMIUM',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Unlock your\nfull potential.',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.1,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 40),

        // Features List
        _buildFeatureRow(context, Icons.graphic_eq, 'Unlimited Audio Environments'),
        _buildFeatureRow(context, Icons.psychology, 'Advanced Mood Insights'),
        _buildFeatureRow(context, Icons.timer, 'Extended Session Durations'),
        _buildFeatureRow(context, Icons.people_outline, 'Strength Partner Access'),
        
        const SizedBox(height: 48),

        // Pricing Cards
        _PricingCard(
          productId: 'quietline.premium.yearly',
          title: 'Annual',
          priceDisplay: '\$49.99',
          intervalLabel: '/ year',
          secondaryPrice: '\$4.16 / month',
          saveLabel: 'SAVE 40%',
          isSelected: _selectedProductId == 'quietline.premium.yearly',
          onTap: () {
            HapticService.selection();
            setState(() => _selectedProductId = 'quietline.premium.yearly');
          },
        ),
        const SizedBox(height: 16),
        _PricingCard(
          productId: 'quietline.premium.monthly.v2',
          title: 'Monthly',
          priceDisplay: '\$6.99',
          intervalLabel: '/ month',
          secondaryPrice: 'Flexible commitment',
          isSelected: _selectedProductId == 'quietline.premium.monthly.v2',
          onTap: () {
            HapticService.selection();
            setState(() => _selectedProductId = 'quietline.premium.monthly.v2');
          },
        ),
        const SizedBox(height: 16),
        // Anchor Pricing (Weekly)
        _PricingCard(
          productId: 'quietline.premium.weekly',
          title: 'Weekly',
          priceDisplay: '\$2.99',
          intervalLabel: '/ week',
          secondaryPrice: 'Short-term',
          isSelected: _selectedProductId == 'quietline.premium.weekly',
          onTap: () {
            HapticService.selection();
            setState(() => _selectedProductId = 'quietline.premium.weekly');
          },
        ),

        const SizedBox(height: 40),

        // Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () async {
                    HapticService.selection();
                    
                    // Analytics
                    await QuietAnalytics.instance.logPurchaseAttempt(
                      tier: _selectedProductId.split('.').last, // 'yearly', 'monthly', 'weekly'
                      trialAvailable: isTrialEligible,
                    );

                    setState(() => _isProcessing = true);
                    await StoreKitService.instance.purchasePremium(_selectedProductId);
                    if (mounted) setState(() => _isProcessing = false);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FA6A1), // QuietAqua (Teal) always
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    isYearly 
                        ? 'Start 7-Day Free Trial' 
                        : 'Subscribe Now',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white, // Enforce White text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        
        
        const SizedBox(height: 16),
        // Dynamic Subtext
        if (isYearly)
           Text(
            'Free for 7 days. Then \$49.99/year. Cancel anytime.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          )
        else if (_selectedProductId.contains('monthly'))
          Text(
            '\$6.99/month. Cancel anytime.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          )
        else if (_selectedProductId.contains('weekly'))
          Text(
            '\$2.99/week. Cancel anytime.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

        const SizedBox(height: 32),
        
        // Footer Links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FooterLink(
              label: 'Restore',
              onTap: () async {
                setState(() => _isProcessing = true);
                await StoreKitService.instance.restorePurchases();
                if (mounted) setState(() => _isProcessing = false);
              },
            ),
            _FooterDot(),
            _FooterLink(
              label: 'Terms',
              onTap: () => launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/')),
            ),
            _FooterDot(),
            _FooterLink(
              label: 'Privacy',
              onTap: () => launchUrl(Uri.parse('https://quietline.app/privacy')),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
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
  final String secondaryPrice;
  final String? saveLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _PricingCard({
    required this.productId,
    required this.title,
    required this.priceDisplay,
    required this.intervalLabel,
    required this.secondaryPrice,
    this.saveLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected 
        ? theme.colorScheme.primary 
        : theme.colorScheme.onSurface.withValues(alpha: 0.1);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (saveLabel != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            saveLabel!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    secondaryPrice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceDisplay,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  intervalLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FooterDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '•',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
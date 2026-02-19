import 'package:flutter/material.dart';
import 'package:bloom_app/screens/shell/bloom_shell_controller.dart';

class CoachingOverlay extends StatelessWidget {
  final CoachingStep step;
  final Rect? spotlightRect;
  final VoidCallback onDismiss;

  const CoachingOverlay({
    super.key,
    required this.step,
    this.spotlightRect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (step == CoachingStep.none) return const SizedBox.shrink();

    if (step == CoachingStep.bloomTimeButton) {
      if (spotlightRect == null) return const SizedBox.shrink();
      return _buildSpotlightOverlay(
        rect: spotlightRect!,
        title: 'Well done.',
        body: 'You just did the hardest part; starting.\n\n'
            'Use Bloom Time anytime you need a reset.\n'
            'Tap the button at the bottom to begin.',
      );
    }

    if (step == CoachingStep.mentalToughness) {
      return _buildMessageOverlay(
        title: 'Building Resilience',
        body: 'Whenever you complete a session, you are building towards mental toughness.\n\n'
            'Keep showing up and you will see your progress become something tangible.',
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSpotlightOverlay({
    required Rect rect,
    required String title,
    required String body,
  }) {
    const double holePadding = 12.0;
    final Rect holeRect = rect.inflate(holePadding);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: CustomPaint(
              painter: _SpotlightPainter(holeRect: holeRect),
            ),
          ),
        ),
        // Spotlight ring
        Positioned(
          left: rect.center.dx - (rect.width / 2 + holePadding),
          top: rect.center.dy - (rect.height / 2 + holePadding),
          width: rect.width + holePadding * 2,
          height: rect.height + holePadding * 2,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2FE6D2),
                  width: 3,
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              child: _CoachingCard(
                title: title,
                body: body,
                onTap: onDismiss,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageOverlay({required String title, required String body}) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onDismiss,
          child: Container(color: Colors.black.withValues(alpha: 0.75)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _CoachingCard(
              title: title,
              body: body,
              onTap: onDismiss,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect holeRect;

  _SpotlightPainter({required this.holeRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.65);
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addOval(holeRect);
    
    final combinedPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );
    
    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CoachingCard extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback? onTap;

  const _CoachingCard({required this.title, required this.body, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F141A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A3340),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFFB9C3CF),
                decoration: TextDecoration.none,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Tap to continue',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2FE6D2),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

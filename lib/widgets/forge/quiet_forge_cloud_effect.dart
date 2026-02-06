import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';

class QuietForgeCloudEffect extends StatefulWidget {
  const QuietForgeCloudEffect({super.key});

  @override
  State<QuietForgeCloudEffect> createState() => QuietForgeCloudEffectState();
}

class QuietForgeCloudEffectState extends State<QuietForgeCloudEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.5).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 40),
      TweenSequenceItem(tween: ConstantTween<double>(1.5), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 2.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 40),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    ]).animate(_controller);
  }

  Future<void> show() async {
    await _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value == 0 || _controller.value == 1) {
          return const SizedBox.shrink();
        }
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: CustomPaint(
              painter: _CloudPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = QLColors.armorIronLight.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    // Draw several overlapping circles to form a "cloud"
    final cloudRadius = size.width * 0.3;
    
    canvas.drawCircle(center, cloudRadius, paint);
    canvas.drawCircle(center + const Offset(-40, -30), cloudRadius * 0.8, paint);
    canvas.drawCircle(center + const Offset(40, -20), cloudRadius * 0.9, paint);
    canvas.drawCircle(center + const Offset(-20, 40), cloudRadius * 0.85, paint);
    canvas.drawCircle(center + const Offset(30, 30), cloudRadius * 0.75, paint);
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => false;
}

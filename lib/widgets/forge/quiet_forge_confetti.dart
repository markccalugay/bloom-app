import 'dart:math' as math;
import 'package:flutter/material.dart';

class QuietForgeConfetti extends StatefulWidget {
  const QuietForgeConfetti({super.key});

  @override
  State<QuietForgeConfetti> createState() => QuietForgeConfettiState();
}

class QuietForgeConfettiState extends State<QuietForgeConfetti> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiPiece> _pieces = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  void burst() {
    _pieces.clear();
    final colors = [
      const Color(0xFF4FA6A1), // quietAqua
      const Color(0xFFE8D1A7), // desertSand
      const Color(0xFF3F8E89), // calmTeal
      const Color(0xFFA17E57), // warmBronze
    ];

    for (int i = 0; i < 40; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = _random.nextDouble() * 200 + 100;
      _pieces.add(_ConfettiPiece(
        x0: (_random.nextDouble() - 0.5) * 20,
        y0: (_random.nextDouble() - 0.5) * 20,
        angle: angle,
        speed: speed,
        size: _random.nextDouble() * 6 + 4,
        spin: _random.nextDouble() * 10 - 5,
        color: colors[_random.nextInt(colors.length)],
      ));
    }
    _controller.forward(from: 0.0);
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
        return CustomPaint(
          painter: _ConfettiPainter(
            progress: _controller.value,
            pieces: _pieces,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ConfettiPiece {
  final double x0;
  final double y0;
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;

  const _ConfettiPiece({
    required this.x0,
    required this.y0,
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> pieces;

  _ConfettiPainter({
    required this.progress,
    required this.pieces,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final t = progress;
    final gravity = 400.0;

    for (final p in pieces) {
      final vx = math.cos(p.angle) * p.speed;
      final vy = math.sin(p.angle) * p.speed;

      final x = center.dx + p.x0 + vx * t;
      final y = center.dy + p.y0 + vy * t + 0.5 * gravity * t * t;

      final alpha = (1.0 - t).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: alpha);

      final rotation = p.spin * t;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size * 1.4,
          height: p.size,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

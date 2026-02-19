import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bloom_app/theme/bloom_theme.dart';

class BloomIngotParticles extends StatefulWidget {
  const BloomIngotParticles({super.key});

  @override
  State<BloomIngotParticles> createState() => _BloomIngotParticlesState();
}

class _BloomIngotParticlesState extends State<BloomIngotParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Initialize particles
    for (int i = 0; i < 15; i++) {
      _particles.add(_createParticle());
    }
  }

  _Particle _createParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 2 + 1,
      velocity: _random.nextDouble() * 0.2 + 0.1,
      opacity: _random.nextDouble() * 0.5 + 0.2,
    );
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
        for (var p in _particles) {
          p.update();
          if (p.y < 0) {
            p.reset(_random);
          }
        }
        return CustomPaint(
          painter: _ParticlePainter(_particles),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double velocity;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.velocity,
    required this.opacity,
  });

  void update() {
    y -= velocity * 0.02;
  }

  void reset(math.Random random) {
    x = random.nextDouble();
    y = 1.0;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var p in particles) {
      final pos = Offset(p.x * size.width, p.y * size.height);
      // Use armorForgeGlow for a subtle "warmth" coming from the ingot/armor
      paint.color = BloomColors.armorForgeGlow.withValues(alpha: p.opacity * (p.y * 0.5)); 
      canvas.drawCircle(pos, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

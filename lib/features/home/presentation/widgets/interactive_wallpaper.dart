import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Data model for a single floating particle
// ─────────────────────────────────────────────
class _Particle {
  double x, y;        // position in [0,1] normalized space
  double vx, vy;      // velocity (normalized per second)
  double radius;      // px
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
  });
}

// ─────────────────────────────────────────────
//  Main widget
// ─────────────────────────────────────────────
class InteractiveWallpaper extends StatefulWidget {
  const InteractiveWallpaper({super.key});

  @override
  State<InteractiveWallpaper> createState() => _InteractiveWallpaperState();
}

class _InteractiveWallpaperState extends State<InteractiveWallpaper>
    with TickerProviderStateMixin {
  static const int _particleCount = 60;
  static const double _repelRadius = 150.0;
  static const double _connectRadius = 100.0;
  static const double _glowRadius = 300.0;

  late final AnimationController _particleController;
  late final AnimationController _glowController;

  final List<_Particle> _particles = [];
  Offset _mousePos = const Offset(-9999, -9999);
  final Random _rng = Random();
  Size _cachedSize = Size.zero;

  @override
  void initState() {
    super.initState();

    // Particle movement controller — drives the time value for physics
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Grid glow pulse controller — 0 → 1 → 0
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _spawnParticles();

    // Advance physics every frame
    _particleController.addListener(_tickParticles);
  }

  void _spawnParticles() {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_randomParticle());
    }
  }

  _Particle _randomParticle() {
    final angle = _rng.nextDouble() * 2 * pi;
    final speed = 0.012 + _rng.nextDouble() * 0.025; // normalized/s
    return _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      vx: cos(angle) * speed,
      vy: sin(angle) * speed,
      radius: 0.5 + _rng.nextDouble() * 2.5,
      opacity: 0.15 + _rng.nextDouble() * 0.45,
    );
  }

  double _prevValue = 0.0;

  void _tickParticles() {
    final dt = (_particleController.value - _prevValue).abs();
    // Handle wrap-around (0.0 after 1.0)
    final actualDt = dt > 0.5 ? 1.0 - dt : dt;
    _prevValue = _particleController.value;

    if (!mounted) return;
    if (_cachedSize.isEmpty) return; // size not yet known

    for (final p in _particles) {
      p.x += p.vx * actualDt;
      p.y += p.vy * actualDt;

      // Loop when out of bounds
      if (p.x < -0.05) p.x = 1.05;
      if (p.x > 1.05) p.x = -0.05;
      if (p.y < -0.05) p.y = 1.05;
      if (p.y > 1.05) p.y = -0.05;
    }
  }

  @override
  void dispose() {
    _particleController.removeListener(_tickParticles);
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cache size safely — called during layout, never dirty
        _cachedSize = constraints.biggest;
        return MouseRegion(
          onHover: (event) => setState(() => _mousePos = event.localPosition),
          onExit: (_) => setState(() => _mousePos = const Offset(-9999, -9999)),
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_particleController, _glowController]),
              builder: (context, _) {
                return CustomPaint(
                  painter: _WallpaperPainter(
                    particles: _particles,
                    mousePos: _mousePos,
                    glowValue: _glowController.value,
                    repelRadius: _repelRadius,
                    connectRadius: _connectRadius,
                    glowRadius: _glowRadius,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  CustomPainter
// ─────────────────────────────────────────────
class _WallpaperPainter extends CustomPainter {
  final List<_Particle> particles;
  final Offset mousePos;
  final double glowValue;    // 0..1 (pulsing)
  final double repelRadius;
  final double connectRadius;
  final double glowRadius;

  static const Color _accentGreen = Color(0xFF00FF88);
  static const Color _white = Colors.white;

  _WallpaperPainter({
    required this.particles,
    required this.mousePos,
    required this.glowValue,
    required this.repelRadius,
    required this.connectRadius,
    required this.glowRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background gradient
    _drawBackground(canvas, size);

    // 2. Radial mouse glow
    _drawMouseGlow(canvas, size);

    // 3. Perspective grid
    _drawGrid(canvas, size);

    // 4. Connection lines between nearby particles
    _drawConnections(canvas, size);

    // 5. Particles (with repulsion applied visually)
    _drawParticles(canvas, size);
  }

  // ── Background ──────────────────────────────
  void _drawBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0a0a0f),
          Color(0xFF0d1117),
          Color(0xFF0a0a0f),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  // ── Mouse radial glow ────────────────────────
  void _drawMouseGlow(Canvas canvas, Size size) {
    if (mousePos.dx < 0) return;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          _accentGreen.withAlpha(18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: mousePos, radius: glowRadius));
    canvas.drawCircle(mousePos, glowRadius, paint);
  }

  // ── Perspective grid ─────────────────────────
  void _drawGrid(Canvas canvas, Size size) {
    // Base pulse: opacity 0.03 → 0.08
    final baseOpacity = 0.03 + glowValue * 0.05;
    const cols = 20;
    const rows = 14;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    final basePaint = Paint()
      ..color = _accentGreen.withAlpha((baseOpacity * 255).round())
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (int i = 0; i <= cols; i++) {
      final x = i * cellW;
      final distToMouse = (mousePos.dx - x).abs();
      final proximity = (1.0 - (distToMouse / (size.width * 0.4)).clamp(0, 1));
      final lineOpacity = baseOpacity + proximity * 0.12;
      final lw = 0.5 + proximity * 1.5;

      final paint = Paint()
        ..color = _accentGreen.withAlpha((lineOpacity * 255).round())
        ..strokeWidth = lw
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (int j = 0; j <= rows; j++) {
      final y = j * cellH;
      final distToMouse = (mousePos.dy - y).abs();
      final proximity = (1.0 - (distToMouse / (size.height * 0.4)).clamp(0, 1));
      final lineOpacity = baseOpacity + proximity * 0.12;
      final lw = 0.5 + proximity * 1.5;

      final paint = Paint()
        ..color = _accentGreen.withAlpha((lineOpacity * 255).round())
        ..strokeWidth = lw
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Ignore basePaint (just suppress unused warning)
    basePaint.color;
  }

  // ── Connection lines ─────────────────────────
  void _drawConnections(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final pA = particles[i];
      final pxA = pA.x * size.width;
      final pyA = pA.y * size.height;

      for (int j = i + 1; j < particles.length; j++) {
        final pB = particles[j];
        final pxB = pB.x * size.width;
        final pyB = pB.y * size.height;

        final dx = pxB - pxA;
        final dy = pyB - pyA;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < connectRadius) {
          final fade = 1.0 - dist / connectRadius;

          // Boost if near mouse
          final midX = (pxA + pxB) / 2;
          final midY = (pyA + pyB) / 2;
          final dm = sqrt(
            pow(mousePos.dx - midX, 2) + pow(mousePos.dy - midY, 2),
          );
          final mouseFactor = dm < 150
              ? (1.0 - dm / 150) * 0.8
              : 0.0;

          final opacity = (fade * 0.18 + mouseFactor * 0.3).clamp(0.0, 1.0);
          final strokeW = 0.5 + mouseFactor * 1.0;
          final color = dm < 150
              ? Color.lerp(_white, _accentGreen, mouseFactor)!
              : _white;

          final paint = Paint()
            ..color = color.withAlpha((opacity * 255).round())
            ..strokeWidth = strokeW
            ..style = PaintingStyle.stroke;

          canvas.drawLine(Offset(pxA, pyA), Offset(pxB, pyB), paint);
        }
      }
    }
  }

  // ── Particles ────────────────────────────────
  void _drawParticles(Canvas canvas, Size size) {
    for (final p in particles) {
      double px = p.x * size.width;
      double py = p.y * size.height;

      // Repel from mouse
      final dx = px - mousePos.dx;
      final dy = py - mousePos.dy;
      final dist = sqrt(dx * dx + dy * dy);

      double drawX = px;
      double drawY = py;
      double extraGlow = 0.0;

      if (dist < repelRadius && dist > 0) {
        final force = (1.0 - dist / repelRadius);
        drawX += (dx / dist) * force * 30;
        drawY += (dy / dist) * force * 30;
        extraGlow = force;
      }

      final color = extraGlow > 0.3
          ? Color.lerp(_white, _accentGreen, extraGlow)!
          : _white;
      final opacity = (p.opacity + extraGlow * 0.4).clamp(0.0, 1.0);
      final radius = p.radius + extraGlow * 1.5;

      // Subtle glow behind
      if (extraGlow > 0.1) {
        final glowPaint = Paint()
          ..color = _accentGreen.withAlpha((extraGlow * 40).round())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(drawX, drawY), radius * 2.5, glowPaint);
      }

      final paint = Paint()
        ..color = color.withAlpha((opacity * 255).round())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(drawX, drawY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WallpaperPainter old) => true;
}

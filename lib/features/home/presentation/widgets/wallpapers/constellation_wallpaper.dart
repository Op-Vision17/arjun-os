import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class _Star {
  double x, y;
  final double size;
  final double twinkleSpeed;
  final double twinkleOffset;
  double vx, vy;
  final Color color;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.twinkleOffset,
    required this.color,
    this.vx = 0,
    this.vy = 0,
  });
}

class _ShootingStar {
  double x, y;
  double angle;
  final double speed;
  double progress;
  final double tailLength;
  bool isActive;

  _ShootingStar({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.tailLength,
    this.progress = 0,
    this.isActive = false,
  });
}

class ConstellationWallpaper extends StatefulWidget {
  const ConstellationWallpaper({super.key});

  @override
  State<ConstellationWallpaper> createState() => _ConstellationWallpaperState();
}

class _ConstellationWallpaperState extends State<ConstellationWallpaper>
    with TickerProviderStateMixin {
  final List<_Star> _stars = [];
  late _ShootingStar _shootingStar;
  Offset _mousePos = const Offset(-9999, -9999);
  final Random _rng = Random();
  Size _cachedSize = Size.zero;
  Timer? _shootingTimer;

  late final AnimationController _twinkleController;
  late final AnimationController _moveController;

  @override
  void initState() {
    super.initState();

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();

    _moveController.addListener(_tick);

    _spawnStars();
    _shootingStar = _ShootingStar(
      x: 0, y: 0, angle: 0, speed: 0.01, tailLength: 0.2, isActive: false,
    );

    _shootingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _launchShootingStar());
  }

  void _spawnStars() {
    _stars.clear();
    for (int i = 0; i < 80; i++) {
      final roll = _rng.nextDouble();
      Color color;
      if (roll < 0.7) {
        color = Colors.white;
      } else if (roll < 0.9) {
        color = const Color(0xFFCAE9FF);
      } else {
        color = const Color(0xFFFFF9C4);
      }
      _stars.add(_Star(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: 1.0 + _rng.nextDouble() * 3.0,
        twinkleSpeed: 0.5 + _rng.nextDouble() * 2.5,
        twinkleOffset: _rng.nextDouble() * 2 * pi,
        color: color,
      ));
    }
  }

  void _launchShootingStar() {
    if (!mounted) return;
    final edge = _rng.nextInt(3); // 0=top, 1=left, 2=right
    double sx, sy, angle;
    if (edge == 0) {
      sx = _rng.nextDouble();
      sy = 0.0;
      angle = pi / 6 + _rng.nextDouble() * pi / 3; // downward
    } else if (edge == 1) {
      sx = 0.0;
      sy = _rng.nextDouble() * 0.5;
      angle = -pi / 6 + _rng.nextDouble() * pi / 3;
    } else {
      sx = 1.0;
      sy = _rng.nextDouble() * 0.5;
      angle = pi - pi / 6 + _rng.nextDouble() * pi / 3;
    }
    setState(() {
      _shootingStar = _ShootingStar(
        x: sx, y: sy,
        angle: angle,
        speed: 0.008 + _rng.nextDouble() * 0.007,
        tailLength: 0.15 + _rng.nextDouble() * 0.10,
        progress: 0,
        isActive: true,
      );
    });
  }

  void _tick() {
    if (!mounted) return;

    // Move shooting star
    if (_shootingStar.isActive) {
      _shootingStar.progress += _shootingStar.speed;
      _shootingStar.x += cos(_shootingStar.angle) * _shootingStar.speed;
      _shootingStar.y += sin(_shootingStar.angle) * _shootingStar.speed;
      if (_shootingStar.progress >= 1.0 ||
          _shootingStar.x < -0.1 ||
          _shootingStar.x > 1.1 ||
          _shootingStar.y > 1.1) {
        _shootingStar.isActive = false;
      }
    }

    // Mouse attraction for nearby stars
    if (_mousePos.dx > 0 && !_cachedSize.isEmpty) {
      for (final star in _stars) {
        final dx = _mousePos.dx;
        final dy = _mousePos.dy;
        final mx = dx / _cachedSize.width;
        final my = dy / _cachedSize.height;
        final dist = sqrt(pow(mx - star.x, 2) + pow(my - star.y, 2));
        if (dist < 0.15) {
          star.vx = _lerp(star.vx, (mx - star.x) * 0.001, 0.05);
          star.vy = _lerp(star.vy, (my - star.y) * 0.001, 0.05);
          star.x = (star.x + star.vx).clamp(0.0, 1.0);
          star.y = (star.y + star.vy).clamp(0.0, 1.0);
        } else {
          star.vx = _lerp(star.vx, 0, 0.02);
          star.vy = _lerp(star.vy, 0, 0.02);
        }
      }
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void dispose() {
    _shootingTimer?.cancel();
    _moveController.removeListener(_tick);
    _twinkleController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _cachedSize = constraints.biggest;
        return MouseRegion(
          onHover: (e) => setState(() => _mousePos = e.localPosition),
          onExit: (_) => setState(() => _mousePos = const Offset(-9999, -9999)),
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_twinkleController, _moveController]),
              builder: (_, __) => CustomPaint(
                painter: _ConstellationPainter(
                  stars: _stars,
                  shootingStar: _shootingStar,
                  mousePos: _mousePos,
                  twinkleValue: _twinkleController.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  final List<_Star> stars;
  final _ShootingStar shootingStar;
  final Offset mousePos;
  final double twinkleValue;

  static const double _connDist = 180.0;

  _ConstellationPainter({
    required this.stars,
    required this.shootingStar,
    required this.mousePos,
    required this.twinkleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF000008), Color(0xFF00001a), Color(0xFF000008)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Offset.zero & size),
    );

    // Convert stars to pixel positions
    final pxStars = stars.map((s) => Offset(s.x * size.width, s.y * size.height)).toList();

    // Connection lines between nearby stars
    for (int i = 0; i < stars.length; i++) {
      for (int j = i + 1; j < stars.length; j++) {
        final dist = (pxStars[i] - pxStars[j]).distance;
        if (dist < _connDist) {
          final opacity = (1.0 - dist / _connDist) * 0.15;
          canvas.drawLine(
            pxStars[i],
            pxStars[j],
            Paint()
              ..color = Colors.white.withAlpha((opacity * 255).round())
              ..strokeWidth = 0.5
              ..style = PaintingStyle.stroke,
          );
        }
      }
    }

    // Mouse connections
    if (mousePos.dx > 0) {
      for (int i = 0; i < stars.length; i++) {
        final dist = (mousePos - pxStars[i]).distance;
        if (dist < 200) {
          final opacity = (1.0 - dist / 200) * 0.6;
          canvas.drawLine(
            mousePos,
            pxStars[i],
            Paint()
              ..color = const Color(0xFF00FFFF).withAlpha((opacity * 255).round())
              ..strokeWidth = 1.0
              ..style = PaintingStyle.stroke,
          );
        }
      }
      // Mouse glow dot
      canvas.drawCircle(mousePos, 3, Paint()..color = const Color(0xFF00FFFF));
      canvas.drawCircle(mousePos, 8, Paint()..color = const Color(0xFF00FFFF).withAlpha(51));
    }

    // Draw stars with twinkle
    for (int i = 0; i < stars.length; i++) {
      final star = stars[i];
      final twinkle = sin(twinkleValue * star.twinkleSpeed * 2 * pi + star.twinkleOffset);
      final opacity = 0.4 + (twinkle + 1) / 2 * 0.6;
      final sz = star.size * (0.8 + (twinkle + 1) / 2 * 0.4);

      // Glow
      canvas.drawCircle(
        pxStars[i],
        sz * 2,
        Paint()
          ..color = star.color.withAlpha((opacity * 0.3 * 255).round())
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sz),
      );
      // Core
      canvas.drawCircle(
        pxStars[i],
        sz,
        Paint()..color = star.color.withAlpha((opacity * 255).round()),
      );
    }

    // Shooting star
    if (shootingStar.isActive) {
      final headPx = Offset(shootingStar.x * size.width, shootingStar.y * size.height);
      final tailPx = Offset(
        headPx.dx - cos(shootingStar.angle) * shootingStar.tailLength * size.width,
        headPx.dy - sin(shootingStar.angle) * shootingStar.tailLength * size.height,
      );

      final tailPaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, Colors.white.withAlpha(0)],
        ).createShader(Rect.fromPoints(headPx, tailPx))
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(headPx, tailPx, tailPaint);

      canvas.drawCircle(headPx, 2, Paint()..color = Colors.white);
      canvas.drawCircle(headPx, 5, Paint()..color = Colors.white.withAlpha(76));
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) => true;
}

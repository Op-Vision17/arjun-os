import 'dart:math';
import 'package:flutter/material.dart';

/// Data model for an anchor node forming the "ARJUN" typography.
class _LetterNode {
  final double targetX; // Normalized [0, 1] base X
  final double targetY; // Normalized [0, 1] base Y
  final int letterIndex; // 0: A, 1: R, 2: J, 3: U, 4: N
  final double baseRadius;
  final Color baseColor;

  double currentX;
  double currentY;
  double vx = 0;
  double vy = 0;

  _LetterNode({
    required this.targetX,
    required this.targetY,
    required this.letterIndex,
    required this.baseRadius,
    required this.baseColor,
  })  : currentX = targetX,
        currentY = targetY;
}

/// Floating cyber rune / star dust in ambient background.
class _StarDust {
  double x, y;
  double vx, vy;
  double size;
  double opacity;
  double pulseSpeed;
  double pulseOffset;

  _StarDust({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.pulseSpeed,
    required this.pulseOffset,
  });
}

class ArjunWallpaper extends StatefulWidget {
  const ArjunWallpaper({super.key});

  @override
  State<ArjunWallpaper> createState() => _ArjunWallpaperState();
}

class _ArjunWallpaperState extends State<ArjunWallpaper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final List<_LetterNode> _nodes = [];
  final List<_StarDust> _dustParticles = [];
  Offset _mousePos = const Offset(-9999, -9999);
  double _mouseSpeed = 0.0;
  final Random _rng = Random(42);

  static const List<Color> _cyberPalette = [
    Color(0xFF00F2FE), // Electric Cyan
    Color(0xFF4FACFE), // Cyber Blue
    Color(0xFF9B51E0), // Neon Purple
    Color(0xFFFF007F), // Vivid Magenta
    Color(0xFF00FF88), // Laser Emerald
    Color(0xFFFFD700), // Plasma Gold
  ];

  @override
  void initState() {
    super.initState();
    _generateTypographyNodes();
    _generateStarDust();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )
      ..addListener(_tickPhysics)
      ..repeat();
  }

  void _generateStarDust() {
    _dustParticles.clear();
    for (int i = 0; i < 90; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 0.003 + _rng.nextDouble() * 0.012;
      _dustParticles.add(
        _StarDust(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          size: 1.0 + _rng.nextDouble() * 2.5,
          opacity: 0.2 + _rng.nextDouble() * 0.6,
          pulseSpeed: 1.0 + _rng.nextDouble() * 2.5,
          pulseOffset: _rng.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  void _generateTypographyNodes() {
    _nodes.clear();

    // Normalized letter coordinates centered in screen [0..1]
    // Word: "A R J U N"
    // Center is (0.5, 0.5), total width ~ 0.68, height ~ 0.22
    const double startX = 0.16;
    const double letterWidth = 0.11;
    const double letterSpacing = 0.035;
    const double topY = 0.38;
    const double bottomY = 0.62;
    const double midY = (topY + bottomY) / 2;

    void addLineNodes({
      required double x1,
      required double y1,
      required double x2,
      required double y2,
      required int steps,
      required int letterIdx,
      required Color color,
      double radius = 2.5,
    }) {
      for (int i = 0; i <= steps; i++) {
        final t = i / steps;
        final nx = x1 + (x2 - x1) * t;
        final ny = y1 + (y2 - y1) * t;
        _nodes.add(
          _LetterNode(
            targetX: nx,
            targetY: ny,
            letterIndex: letterIdx,
            baseRadius: radius,
            baseColor: color,
          ),
        );
      }
    }

    void addArcNodes({
      required double centerX,
      required double centerY,
      required double radiusX,
      required double radiusY,
      required double startAngle,
      required double sweepAngle,
      required int steps,
      required int letterIdx,
      required Color color,
      double radius = 2.5,
    }) {
      for (int i = 0; i <= steps; i++) {
        final t = i / steps;
        final angle = startAngle + sweepAngle * t;
        final nx = centerX + cos(angle) * radiusX;
        final ny = centerY + sin(angle) * radiusY;
        _nodes.add(
          _LetterNode(
            targetX: nx,
            targetY: ny,
            letterIndex: letterIdx,
            baseRadius: radius,
            baseColor: color,
          ),
        );
      }
    }

    // ── Letter 0: 'A' ───────────────────────────
    double x = startX;
    final cA = _cyberPalette[0];
    // Left diagonal
    addLineNodes(x1: x + letterWidth / 2, y1: topY, x2: x, y2: bottomY, steps: 16, letterIdx: 0, color: cA);
    // Right diagonal
    addLineNodes(x1: x + letterWidth / 2, y1: topY, x2: x + letterWidth, y2: bottomY, steps: 16, letterIdx: 0, color: cA);
    // Crossbar
    addLineNodes(x1: x + letterWidth * 0.25, y1: midY + 0.02, x2: x + letterWidth * 0.75, y2: midY + 0.02, steps: 10, letterIdx: 0, color: cA, radius: 2.2);

    // ── Letter 1: 'R' ───────────────────────────
    x += letterWidth + letterSpacing;
    final cR = _cyberPalette[1];
    // Left stem
    addLineNodes(x1: x, y1: topY, x2: x, y2: bottomY, steps: 18, letterIdx: 1, color: cR);
    // Top bar & loop
    addArcNodes(centerX: x + letterWidth * 0.35, centerY: (topY + midY) / 2, radiusX: letterWidth * 0.55, radiusY: (midY - topY) / 2, startAngle: -pi / 2, sweepAngle: pi, steps: 16, letterIdx: 1, color: cR);
    // Middle bar
    addLineNodes(x1: x, y1: midY, x2: x + letterWidth * 0.35, y2: midY, steps: 6, letterIdx: 1, color: cR);
    // Diagonal leg
    addLineNodes(x1: x + letterWidth * 0.35, y1: midY, x2: x + letterWidth, y2: bottomY, steps: 14, letterIdx: 1, color: cR);

    // ── Letter 2: 'J' ───────────────────────────
    x += letterWidth + letterSpacing;
    final cJ = _cyberPalette[2];
    // Top bar
    addLineNodes(x1: x + letterWidth * 0.2, y1: topY, x2: x + letterWidth, y2: topY, steps: 12, letterIdx: 2, color: cJ);
    // Vertical stem
    addLineNodes(x1: x + letterWidth * 0.75, y1: topY, x2: x + letterWidth * 0.75, y2: bottomY - 0.05, steps: 14, letterIdx: 2, color: cJ);
    // Bottom curve
    addArcNodes(centerX: x + letterWidth * 0.38, centerY: bottomY - 0.05, radiusX: letterWidth * 0.37, radiusY: 0.05, startAngle: 0, sweepAngle: pi * 0.9, steps: 14, letterIdx: 2, color: cJ);

    // ── Letter 3: 'U' ───────────────────────────
    x += letterWidth + letterSpacing;
    final cU = _cyberPalette[3];
    // Left vertical
    addLineNodes(x1: x, y1: topY, x2: x, y2: bottomY - 0.05, steps: 14, letterIdx: 3, color: cU);
    // Right vertical
    addLineNodes(x1: x + letterWidth, y1: topY, x2: x + letterWidth, y2: bottomY - 0.05, steps: 14, letterIdx: 3, color: cU);
    // Bottom arc
    addArcNodes(centerX: x + letterWidth / 2, centerY: bottomY - 0.05, radiusX: letterWidth / 2, radiusY: 0.05, startAngle: 0, sweepAngle: pi, steps: 16, letterIdx: 3, color: cU);

    // ── Letter 4: 'N' ───────────────────────────
    x += letterWidth + letterSpacing;
    final cN = _cyberPalette[4];
    // Left vertical
    addLineNodes(x1: x, y1: topY, x2: x, y2: bottomY, steps: 18, letterIdx: 4, color: cN);
    // Diagonal
    addLineNodes(x1: x, y1: topY, x2: x + letterWidth, y2: bottomY, steps: 20, letterIdx: 4, color: cN);
    // Right vertical
    addLineNodes(x1: x + letterWidth, y1: topY, x2: x + letterWidth, y2: bottomY, steps: 18, letterIdx: 4, color: cN);
  }

  void _tickPhysics() {
    if (!mounted) return;

    // Ambient dust movement
    for (final d in _dustParticles) {
      d.x += d.vx;
      d.y += d.vy;
      if (d.x < -0.05) d.x = 1.05;
      if (d.x > 1.05) d.x = -0.05;
      if (d.y < -0.05) d.y = 1.05;
      if (d.y > 1.05) d.y = -0.05;
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_tickPhysics);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          if (_mousePos.dx >= 0) {
            final dx = event.localPosition.dx - _mousePos.dx;
            final dy = event.localPosition.dy - _mousePos.dy;
            _mouseSpeed = sqrt(dx * dx + dy * dy).clamp(0, 80);
          }
          _mousePos = event.localPosition;
        });
      },
      onExit: (_) {
        setState(() {
          _mousePos = const Offset(-9999, -9999);
          _mouseSpeed = 0;
        });
      },
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return CustomPaint(
              painter: _ArjunTypographyPainter(
                nodes: _nodes,
                dustParticles: _dustParticles,
                mousePos: _mousePos,
                mouseSpeed: _mouseSpeed,
                time: _animController.value * 2 * pi,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _ArjunTypographyPainter extends CustomPainter {
  final List<_LetterNode> nodes;
  final List<_StarDust> dustParticles;
  final Offset mousePos;
  final double mouseSpeed;
  final double time;

  _ArjunTypographyPainter({
    required this.nodes,
    required this.dustParticles,
    required this.mousePos,
    required this.mouseSpeed,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Deep Cyber Nebula Background
    _drawDeepSpaceBackground(canvas, rect, size);

    // 2. Ambient Cyber Grid Horizon
    _drawPerspectiveGrid(canvas, size);

    // 3. Floating Star Dust & Cyber Runes
    _drawStarDust(canvas, size);

    // 4. Cursor Hologram Shockwave Aura
    _drawCursorEnergy(canvas, size);

    // 5. Kinetic Typography "ARJUN" Nodes & Beams
    _drawTypographyMatrix(canvas, size);
  }

  void _drawDeepSpaceBackground(Canvas canvas, Rect rect, Size size) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFF03050C),
          Color(0xFF070B18),
          Color(0xFF090414),
          Color(0xFF02040A),
        ],
        stops: const [0.0, 0.4, 0.75, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Aurora plasma clouds in background
    final aurora1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.3),
        radius: 0.85,
        colors: [
          const Color(0xFF00F2FE).withValues(alpha: 0.08 + sin(time) * 0.03),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, aurora1);

    final aurora2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, 0.4),
        radius: 0.9,
        colors: [
          const Color(0xFF9B51E0).withValues(alpha: 0.09 + cos(time * 0.8) * 0.03),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, aurora2);
  }

  void _drawPerspectiveGrid(Canvas canvas, Size size) {
    final gridOpacity = 0.03 + (sin(time * 2) * 0.015).abs();
    final gridPaint = Paint()
      ..color = const Color(0xFF00F2FE).withValues(alpha: gridOpacity)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    const int cols = 24;
    final cellW = size.width / cols;
    for (int i = 0; i <= cols; i++) {
      final x = i * cellW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    const int rows = 16;
    final cellH = size.height / rows;
    for (int j = 0; j <= rows; j++) {
      final y = j * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawStarDust(Canvas canvas, Size size) {
    for (final d in dustParticles) {
      final px = d.x * size.width;
      final py = d.y * size.height;
      final pulse = (sin(time * d.pulseSpeed + d.pulseOffset) + 1) / 2;
      final alpha = (d.opacity * 0.6 + pulse * 0.4).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFF4FACFE),
          const Color(0xFFFF007F),
          (sin(time + d.pulseOffset) + 1) / 2,
        )!
            .withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(px, py), d.size * (0.8 + pulse * 0.5), paint);
    }
  }

  void _drawCursorEnergy(Canvas canvas, Size size) {
    if (mousePos.dx < 0) return;

    final cursorGlowRadius = 180.0 + mouseSpeed * 1.5;
    final cursorPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00F2FE).withValues(alpha: 0.22),
          const Color(0xFF9B51E0).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromCircle(center: mousePos, radius: cursorGlowRadius),
      );
    canvas.drawCircle(mousePos, cursorGlowRadius, cursorPaint);

    // Orbiting particle ring around cursor
    final ringPaint = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(mousePos, 28.0 + sin(time * 4) * 4, ringPaint);
  }

  void _drawTypographyMatrix(Canvas canvas, Size size) {
    const double repelRadius = 220.0;
    const double springStiffness = 0.12;
    const double damping = 0.82;

    final renderedPoints = <Offset>[];
    final nodeColors = <Color>[];

    // Compute physics & updated positions for each letter node
    for (final node in nodes) {
      final tx = node.targetX * size.width;
      final ty = node.targetY * size.height;

      // Elastic pull back to target anchor position
      final fx = (tx - (node.currentX * size.width)) * springStiffness;
      final fy = (ty - (node.currentY * size.height)) * springStiffness;

      node.vx = (node.vx + fx) * damping;
      node.vy = (node.vy + fy) * damping;

      // Mouse magnetic repulsion / interaction
      if (mousePos.dx >= 0) {
        final curX = node.currentX * size.width;
        final curY = node.currentY * size.height;
        final dx = curX - mousePos.dx;
        final dy = curY - mousePos.dy;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < repelRadius && dist > 0.001) {
          final factor = (1.0 - (dist / repelRadius));
          final force = pow(factor, 1.8) * (50.0 + mouseSpeed * 0.8);
          node.vx += (dx / dist) * force;
          node.vy += (dy / dist) * force;
        }
      }

      // Update current position
      node.currentX += node.vx / size.width;
      node.currentY += node.vy / size.height;

      final p = Offset(node.currentX * size.width, node.currentY * size.height);
      renderedPoints.add(p);

      // Dynamic color shift based on proximity to mouse and time
      final dMouse = (mousePos.dx >= 0)
          ? (p - mousePos).distance
          : 9999.0;
      final hoverGlow = (1.0 - (dMouse / repelRadius)).clamp(0.0, 1.0);

      final dynamicColor = Color.lerp(
        node.baseColor,
        const Color(0xFF00FF88),
        hoverGlow,
      )!;
      nodeColors.add(dynamicColor);
    }

    // Draw connected laser beams between adjacent nodes of the same letter
    for (int i = 0; i < nodes.length; i++) {
      final pA = renderedPoints[i];
      final nodeA = nodes[i];

      for (int j = i + 1; j < nodes.length; j++) {
        final nodeB = nodes[j];
        if (nodeA.letterIndex != nodeB.letterIndex) continue;

        final pB = renderedPoints[j];
        final dist = (pB - pA).distance;

        // Connect nearby nodes
        if (dist < 42.0) {
          final alpha = ((1.0 - (dist / 42.0)) * 0.65).clamp(0.0, 1.0);
          final beamPaint = Paint()
            ..color = nodeColors[i].withValues(alpha: alpha)
            ..strokeWidth = 1.2
            ..style = PaintingStyle.stroke;
          canvas.drawLine(pA, pB, beamPaint);
        }
      }
    }

    // Draw nodes with outer aura glow and sharp core
    for (int i = 0; i < renderedPoints.length; i++) {
      final p = renderedPoints[i];
      final color = nodeColors[i];
      final node = nodes[i];

      final dMouse = (mousePos.dx >= 0) ? (p - mousePos).distance : 9999.0;
      final hoverGlow = (1.0 - (dMouse / repelRadius)).clamp(0.0, 1.0);

      // Outer glow circle
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.35 + hoverGlow * 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 + hoverGlow * 6.0);
      canvas.drawCircle(p, node.baseRadius * (1.8 + hoverGlow * 1.5), glowPaint);

      // Inner glowing core
      final corePaint = Paint()
        ..color = Color.lerp(Colors.white, color, 0.3)!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, node.baseRadius * (0.9 + hoverGlow * 0.6), corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArjunTypographyPainter oldDelegate) => true;
}

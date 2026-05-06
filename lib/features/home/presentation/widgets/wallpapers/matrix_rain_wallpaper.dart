import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Data model for a single matrix column
// ─────────────────────────────────────────────
class _MatrixColumn {
  double x;
  double y;
  final double speed;
  final int length;
  List<String> chars;
  final double opacity;

  static const String _pool =
      'ｦｱｳｴｵｶｷｹｺｻｼｽｾｿﾀﾂﾃﾅﾆﾇﾈﾊﾋﾎﾏﾐﾑﾒﾓﾔﾕﾗﾘﾙﾚﾛﾜﾝ0123456789ABCDEF@#\$%';

  _MatrixColumn({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.chars,
    required this.opacity,
  });

  void update(double screenHeight, Random rng) {
    y += speed;
    if (y > screenHeight + length * 20) {
      y = -(length * 20.0);
    }
    // Randomly mutate 1–2 characters in the trail
    final mutations = 1 + rng.nextInt(2);
    for (int m = 0; m < mutations; m++) {
      final idx = rng.nextInt(chars.length);
      chars[idx] = _pool[rng.nextInt(_pool.length)];
    }
  }

  static _MatrixColumn random(int colIndex, double screenHeight, Random rng) {
    final length = 8 + rng.nextInt(13); // 8..20
    final pool = _pool;
    final chars = List.generate(
      length,
      (_) => pool[rng.nextInt(pool.length)],
    );
    return _MatrixColumn(
      x: colIndex * 20.0,
      y: -(rng.nextDouble() * screenHeight * 1.5),
      speed: 2.0 + rng.nextDouble() * 4.0, // 2..6
      length: length,
      chars: chars,
      opacity: 0.5 + rng.nextDouble() * 0.5, // 0.5..1.0
    );
  }
}

// ─────────────────────────────────────────────
//  Main widget
// ─────────────────────────────────────────────
class MatrixRainWallpaper extends StatefulWidget {
  const MatrixRainWallpaper({super.key});

  @override
  State<MatrixRainWallpaper> createState() => _MatrixRainWallpaperState();
}

class _MatrixRainWallpaperState extends State<MatrixRainWallpaper>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_MatrixColumn> _columns = [];
  final Random _rng = Random();
  Size _cachedSize = Size.zero;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();

    _controller.addListener(_tick);
  }

  void _initColumns(Size size) {
    _columns.clear();
    final colCount = (size.width / 20).ceil() + 1;
    for (int i = 0; i < colCount; i++) {
      _columns.add(_MatrixColumn.random(i, size.height, _rng));
    }
    _cachedSize = size;
    _initialized = true;
  }

  void _tick() {
    if (!mounted) return;
    final size = _cachedSize;
    if (size.isEmpty) return;

    if (!_initialized || size != _cachedSize) {
      _initColumns(size);
    }

    for (final col in _columns) {
      col.update(size.height, _rng);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _cachedSize = constraints.biggest;
        return Stack(
          children: [
            Container(color: Colors.black),
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _MatrixPainter(columns: _columns),
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  CustomPainter
// ─────────────────────────────────────────────
class _MatrixPainter extends CustomPainter {
  final List<_MatrixColumn> columns;

  _MatrixPainter({required this.columns});

  @override
  void paint(Canvas canvas, Size size) {
    // Solid black background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF000000),
    );

    for (final col in columns) {
      final len = col.length;
      for (int i = 0; i < len; i++) {
        final charY = col.y - i * 20.0;
        // Skip off-screen
        if (charY < -20 || charY > size.height + 20) continue;

        // Color logic
        Color baseColor;
        if (i == 0) {
          baseColor = const Color(0xFFFFFFFF); // bright white head
        } else if (i == 1) {
          baseColor = const Color(0xFF39FF14); // neon green
        } else if (i <= 4) {
          baseColor = const Color(0xFF00CC00); // medium green
        } else if (i <= 8) {
          baseColor = const Color(0xFF009900); // dark green
        } else {
          baseColor = const Color(0xFF003300); // very dark green
        }

        final fadeFactor = 1.0 - i / len;
        final alpha = (col.opacity * fadeFactor * 255).round().clamp(0, 255);

        final tp = TextPainter(
          text: TextSpan(
            text: col.chars[i],
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: baseColor.withAlpha(alpha),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(canvas, Offset(col.x, charY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter old) => true;
}

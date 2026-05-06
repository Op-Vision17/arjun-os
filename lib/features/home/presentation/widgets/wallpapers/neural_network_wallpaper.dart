import 'dart:math';
import 'package:flutter/material.dart';

class _NNNode {
  Offset position;
  bool isActive;
  final Color color;

  _NNNode({required this.position, required this.color, this.isActive = false});
}

class _NNPulse {
  int fromNode;
  int toNode;
  double progress;
  final double speed;
  final Color color;

  _NNPulse({
    required this.fromNode,
    required this.toNode,
    required this.progress,
    required this.speed,
    required this.color,
  });
}

class NeuralNetworkWallpaper extends StatefulWidget {
  const NeuralNetworkWallpaper({super.key});

  @override
  State<NeuralNetworkWallpaper> createState() => _NeuralNetworkWallpaperState();
}

class _NeuralNetworkWallpaperState extends State<NeuralNetworkWallpaper>
    with TickerProviderStateMixin {
  static const List<int> _layers = [4, 6, 8, 6, 4];
  static const List<Color> _layerColors = [
    Color(0xFF9B59B6),
    Color(0xFF8E44AD),
    Color(0xFF6C3483),
    Color(0xFF8E44AD),
    Color(0xFF9B59B6),
  ];

  final List<_NNNode> _nodes = [];
  final List<(int, int)> _connections = [];
  final List<_NNPulse> _pulses = [];
  Offset _mousePos = const Offset(-9999, -9999);
  final Random _rng = Random();
  bool _initialized = false;
  Size _cachedSize = Size.zero;

  late final AnimationController _pulseController;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseController.addListener(_tick);
  }

  void _buildNetwork(Size size) {
    _nodes.clear();
    _connections.clear();
    int offset = 0;
    for (int li = 0; li < _layers.length; li++) {
      final count = _layers[li];
      final layerX = (li + 1) * (size.width / (_layers.length + 1));
      for (int ni = 0; ni < count; ni++) {
        _nodes.add(_NNNode(
          position: Offset(layerX, (ni + 1) * (size.height / (count + 1))),
          color: _layerColors[li],
        ));
      }
      if (li < _layers.length - 1) {
        final toOffset = offset + count;
        for (int fi = 0; fi < count; fi++) {
          for (int ti = 0; ti < _layers[li + 1]; ti++) {
            _connections.add((offset + fi, toOffset + ti));
          }
        }
      }
      offset += count;
    }
    _pulses.clear();
    for (int i = 0; i < 20; i++) _spawnPulse();
    _initialized = true;
    _cachedSize = size;
  }

  void _spawnPulse({int? forceFrom}) {
    if (_connections.isEmpty) return;
    final conn = _connections[_rng.nextInt(_connections.length)];
    _pulses.add(_NNPulse(
      fromNode: forceFrom ?? conn.$1,
      toNode: conn.$2,
      progress: 0.0,
      speed: 0.003 + _rng.nextDouble() * 0.005,
      color: _rng.nextDouble() < 0.3 ? const Color(0xFFE040FB) : Colors.white.withAlpha(200),
    ));
  }

  void _tick() {
    if (!mounted) return;
    final size = _cachedSize;
    if (size.isEmpty) return;
    if (!_initialized || size != _cachedSize) _buildNetwork(size);

    final dead = <_NNPulse>[];
    for (final p in _pulses) {
      p.progress += p.speed;
      if (p.progress >= 1.0) { dead.add(p); _spawnPulse(); }
    }
    _pulses.removeWhere(dead.contains);

    for (int i = 0; i < _nodes.length; i++) {
      final was = _nodes[i].isActive;
      _nodes[i].isActive = (_nodes[i].position - _mousePos).distance < 80;
      if (!was && _nodes[i].isActive) _spawnPulse(forceFrom: i);
    }
  }

  @override
  void dispose() {
    _pulseController.removeListener(_tick);
    _pulseController.dispose();
    _glowController.dispose();
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
              animation: Listenable.merge([_pulseController, _glowController]),
              builder: (_, __) => CustomPaint(
                painter: _NeuralPainter(
                  nodes: _nodes,
                  connections: _connections,
                  pulses: _pulses,
                  glowValue: _glowController.value,
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

class _NeuralPainter extends CustomPainter {
  final List<_NNNode> nodes;
  final List<(int, int)> connections;
  final List<_NNPulse> pulses;
  final double glowValue;

  _NeuralPainter({required this.nodes, required this.connections, required this.pulses, required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = const RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [Color(0xFF1a0030), Color(0xFF0a0008)],
      ).createShader(Offset.zero & size),
    );
    if (nodes.isEmpty) return;

    final connP = Paint()..color = const Color(0xFF6c3483).withAlpha(76)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    for (final (fi, ti) in connections) {
      if (fi < nodes.length && ti < nodes.length) canvas.drawLine(nodes[fi].position, nodes[ti].position, connP);
    }

    for (final p in pulses) {
      if (p.fromNode >= nodes.length || p.toNode >= nodes.length) continue;
      final pos = Offset.lerp(nodes[p.fromNode].position, nodes[p.toNode].position, p.progress)!;
      canvas.drawCircle(pos, 4, Paint()..color = p.color);
      canvas.drawCircle(pos, 8, Paint()..color = p.color.withAlpha(76));
      if (p.progress > 0.05) {
        final trail = Offset.lerp(nodes[p.fromNode].position, nodes[p.toNode].position, p.progress - 0.05)!;
        canvas.drawCircle(trail, 2, Paint()..color = p.color.withAlpha(128));
      }
    }

    for (final node in nodes) {
      final gr = 8.0 + glowValue * 4;
      canvas.drawCircle(node.position, gr * 2, Paint()..color = node.color.withAlpha(51));
      canvas.drawCircle(node.position, node.isActive ? 12.0 : 8.0, Paint()..color = node.color);
      canvas.drawCircle(node.position, 3, Paint()..color = Colors.white.withAlpha(204));
    }
  }

  @override
  bool shouldRepaint(covariant _NeuralPainter old) => true;
}

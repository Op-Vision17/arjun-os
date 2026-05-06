import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CursorGlowOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const CursorGlowOverlay({super.key, required this.child});

  @override
  ConsumerState<CursorGlowOverlay> createState() => _CursorGlowOverlayState();
}

class _CursorGlowOverlayState extends ConsumerState<CursorGlowOverlay> {
  Offset _cursorPos = Offset.zero;
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentColorProvider);

    return MouseRegion(
      onHover: (event) {
        setState(() {
          _cursorPos = event.localPosition;
          _isVisible = true;
        });
      },
      onExit: (_) => setState(() => _isVisible = false),
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          if (_isVisible)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              left: _cursorPos.dx - 100,
              top: _cursorPos.dy - 100,
              child: IgnorePointer(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.15),
                        accent.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent,
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

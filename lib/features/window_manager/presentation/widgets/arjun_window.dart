import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/open_window.dart';
import '../../domain/providers/window_manager_notifier.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/core/presentation/responsive_layout.dart';

class ArjunWindow extends ConsumerWidget {
  final OpenWindow window;

  const ArjunWindow({super.key, required this.window});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(windowManagerProvider.notifier);
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    // Desktop gestures for dragging
    void onPanUpdate(DragUpdateDetails details) {
      if (window.isMaximized || isMobile) return;
      notifier.updatePosition(
        window.id,
        window.position + details.delta,
      );
    }

    // Desktop gestures for resizing
    void onResize(DragUpdateDetails details, {bool top = false, bool bottom = false, bool left = false, bool right = false}) {
      if (window.isMaximized || isMobile || isTablet) return;
      double newWidth = window.size.width;
      double newHeight = window.size.height;
      double newX = window.position.dx;
      double newY = window.position.dy;

      if (right) newWidth += details.delta.dx;
      if (bottom) newHeight += details.delta.dy;
      if (left) {
        newWidth -= details.delta.dx;
        newX += details.delta.dx;
      }
      if (top) {
        newHeight -= details.delta.dy;
        newY += details.delta.dy;
      }

      // Minimum size constraints
      if (newWidth < 200) {
        newX -= (200 - newWidth);
        newWidth = 200;
      }
      if (newHeight < 100) {
        newY -= (100 - newHeight);
        newHeight = 100;
      }

      notifier.updateSize(window.id, Size(newWidth, newHeight));
      notifier.updatePosition(window.id, Offset(newX, newY));
    }

    final isMaximizedOrFull = window.isMaximized || isMobile || isTablet;

    Widget windowBody;

    if (isMobile) {
      // ─────────────────────────────────────────────────────────────
      // MOBILE NATIVE APP VIEW (Smartphone Full-Screen App Screen)
      // ─────────────────────────────────────────────────────────────
      windowBody = Container(
        color: theme.panelBackground,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Mobile Top Navigation Bar
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.borderColor.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Back / Close Button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: accent,
                        size: 20,
                      ),
                      tooltip: 'Back to Home',
                      onPressed: () => notifier.minimizeWindow(window.id),
                    ),
                    const SizedBox(width: 4),
                    // App Icon
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(window.icon, size: 16, color: accent),
                    ),
                    const SizedBox(width: 10),
                    // App Title
                    Expanded(
                      child: Text(
                        window.title,
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Minimize to Background Button
                    IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: theme.textMuted,
                        size: 26,
                      ),
                      tooltip: 'Minimize',
                      onPressed: () => notifier.minimizeWindow(window.id),
                    ),
                  ],
                ),
              ),

              // Full Screen App Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 72), // Leave space for bottom nav
                  child: window.content,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // ─────────────────────────────────────────────────────────────
      // DESKTOP / TABLET macOS-STYLE FLOATING WINDOW
      // ─────────────────────────────────────────────────────────────
      windowBody = TapRegion(
        onTapOutside: (event) {
          // Keep desktop tap outside behavior if desired
        },
        child: GestureDetector(
          onTapDown: (_) => notifier.bringToFront(window.id),
          child: RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                color: theme.panelBackground,
                borderRadius: isMaximizedOrFull ? BorderRadius.zero : BorderRadius.circular(12),
                border: isMaximizedOrFull ? null : Border.all(color: theme.borderColor, width: 1),
                boxShadow: isMaximizedOrFull
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
              ),
              child: Column(
                children: [
                  // Desktop Title Bar
                  GestureDetector(
                    onPanUpdate: onPanUpdate,
                    onDoubleTap: () => notifier.maximizeWindow(window.id),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        borderRadius: isMaximizedOrFull
                            ? BorderRadius.zero
                            : const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          // Traffic light buttons
                          Row(
                            children: [
                              _TrafficLight(
                                color: Colors.redAccent,
                                onTap: () => notifier.closeWindow(window.id),
                              ),
                              const SizedBox(width: 8),
                              _TrafficLight(
                                color: Colors.yellowAccent,
                                onTap: () => notifier.minimizeWindow(window.id),
                              ),
                              const SizedBox(width: 8),
                              _TrafficLight(
                                color: Colors.greenAccent,
                                onTap: () => notifier.maximizeWindow(window.id),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Icon(window.icon, size: 16, color: theme.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              window.title,
                              style: TextStyle(
                                color: theme.textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: ClipRRect(
                      borderRadius: isMaximizedOrFull
                          ? BorderRadius.zero
                          : const BorderRadius.vertical(bottom: Radius.circular(12)),
                      child: window.content,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Apply Animations
    Widget animatedWindow = windowBody;

    if (window.isClosing) {
      animatedWindow = animatedWindow
          .animate(
            onComplete: (_) => notifier.removeWindow(window.id),
          )
          .fadeOut(duration: 250.ms)
          .scale(begin: const Offset(1, 1), end: const Offset(0.8, 0.8), duration: 250.ms);
    } else if (window.isMinimized) {
      if (isMobile) {
        animatedWindow = animatedWindow
            .animate()
            .fadeOut(duration: 250.ms)
            .slideY(begin: 0, end: 0.3, duration: 250.ms);
      } else {
        animatedWindow = animatedWindow
            .animate()
            .fadeOut(duration: 300.ms)
            .scale(begin: const Offset(1, 1), end: const Offset(0.2, 0.2), duration: 300.ms)
            .moveY(begin: 0, end: 300, duration: 300.ms);
      }
    } else {
      if (isMobile) {
        animatedWindow = animatedWindow
            .animate()
            .fadeIn(duration: 250.ms)
            .slideY(begin: 0.15, end: 0, duration: 250.ms, curve: Curves.easeOutCubic);
      } else {
        animatedWindow = animatedWindow
            .animate()
            .fadeIn(duration: 300.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            );
      }
    }

    // Desktop resize handles
    if (!isMaximizedOrFull && !window.isMinimized && !window.isClosing) {
      animatedWindow = Stack(
        children: [
          animatedWindow,
          // Edges
          Positioned(top: 0, left: 10, right: 10, height: 5, child: MouseRegion(cursor: SystemMouseCursors.resizeUpDown, child: GestureDetector(onPanUpdate: (d) => onResize(d, top: true)))),
          Positioned(bottom: 0, left: 10, right: 10, height: 5, child: MouseRegion(cursor: SystemMouseCursors.resizeUpDown, child: GestureDetector(onPanUpdate: (d) => onResize(d, bottom: true)))),
          Positioned(left: 0, top: 10, bottom: 10, width: 5, child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: GestureDetector(onPanUpdate: (d) => onResize(d, left: true)))),
          Positioned(right: 0, top: 10, bottom: 10, width: 5, child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: GestureDetector(onPanUpdate: (d) => onResize(d, right: true)))),
          // Corners
          Positioned(left: 0, top: 0, width: 10, height: 10, child: MouseRegion(cursor: SystemMouseCursors.resizeUpLeftDownRight, child: GestureDetector(onPanUpdate: (d) => onResize(d, top: true, left: true)))),
          Positioned(right: 0, top: 0, width: 10, height: 10, child: MouseRegion(cursor: SystemMouseCursors.resizeUpRightDownLeft, child: GestureDetector(onPanUpdate: (d) => onResize(d, top: true, right: true)))),
          Positioned(left: 0, bottom: 0, width: 10, height: 10, child: MouseRegion(cursor: SystemMouseCursors.resizeUpRightDownLeft, child: GestureDetector(onPanUpdate: (d) => onResize(d, bottom: true, left: true)))),
          Positioned(right: 0, bottom: 0, width: 10, height: 10, child: MouseRegion(cursor: SystemMouseCursors.resizeUpLeftDownRight, child: GestureDetector(onPanUpdate: (d) => onResize(d, bottom: true, right: true)))),
        ],
      );
    }

    return animatedWindow;
  }
}

class _TrafficLight extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _TrafficLight({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

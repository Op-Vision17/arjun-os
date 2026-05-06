import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/features/window_manager/domain/models/open_window.dart';
import 'package:arjun_os/features/window_manager/domain/providers/window_manager_notifier.dart';
import 'package:arjun_os/features/terminal/presentation/terminal_app.dart' deferred as terminal;
import 'package:arjun_os/core/presentation/widgets/deferred_loader.dart';

class DesktopDock extends ConsumerWidget {
  const DesktopDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void openApp(String title, IconData icon, Widget content) {
      ref.read(windowManagerProvider.notifier).openWindow(OpenWindow(
            title: title,
            icon: icon,
            content: content,
          ));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80, // Increased height
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DockIcon(icon: Icons.folder, label: 'Files', color: Colors.blueAccent, onTap: () {}),
                _DockIcon(icon: Icons.web, label: 'Browser', color: Colors.redAccent, onTap: () {}),
                _DockIcon(
                  icon: Icons.terminal,
                  label: 'Terminal',
                  color: Colors.black,
                  onTap: () => openApp(
                    'Terminal', 
                    Icons.terminal, 
                    DeferredLoader(loader: terminal.loadLibrary, builder: (_) => terminal.TerminalApp()),
                  ),
                ),
                _DockIcon(icon: Icons.settings, label: 'Settings', color: Colors.grey, onTap: () {}),
                
                // Dynamic running apps section
                if (ref.watch(windowManagerProvider).isNotEmpty) ...[
                  const VerticalDivider(color: Colors.white24, indent: 16, endIndent: 16, width: 32),
                  ...ref.watch(windowManagerProvider).map((window) {
                    return _DockIcon(
                      icon: window.icon,
                      label: window.title,
                      color: Colors.deepPurpleAccent,
                      hasIndicator: true,
                      isMinimized: window.isMinimized,
                      onTap: () {
                        if (window.isMinimized) {
                          ref.read(windowManagerProvider.notifier).restoreWindow(window.id);
                        } else {
                          ref.read(windowManagerProvider.notifier).bringToFront(window.id);
                        }
                      },
                    );
                  }),
                ],

                const VerticalDivider(color: Colors.white24, indent: 16, endIndent: 16, width: 32),
                _DockIcon(icon: Icons.delete_outline, label: 'Trash', color: Colors.white, onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool hasIndicator;
  final bool isMinimized;

  const _DockIcon({
    required this.icon, 
    required this.label, 
    required this.color, 
    required this.onTap,
    this.hasIndicator = false,
    this.isMinimized = false,
  });

  @override
  State<_DockIcon> createState() => _DockIconState();
}

class _DockIconState extends State<_DockIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 150), // Snappier
        curve: Curves.easeOutBack, // Mac-like bounce
        tween: Tween<double>(begin: 1.0, end: _isHovered ? 1.4 : 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            alignment: Alignment.bottomCenter,
            child: child,
          );
        },
        child: Tooltip(
          message: widget.label,
          waitDuration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          textStyle: const TextStyle(color: Colors.white, fontSize: 12),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 56, // Bigger icons
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: widget.isMinimized ? 0.3 : 0.8),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (_isHovered)
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.6),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        )
                    ],
                  ),
                  child: Icon(
                    widget.icon, 
                    color: Colors.white.withValues(alpha: widget.isMinimized ? 0.5 : 1.0), 
                    size: 32, // Bigger icon font
                  ),
                ),
                if (widget.hasIndicator)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

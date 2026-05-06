import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/providers/window_manager_notifier.dart';
import 'widgets/arjun_window.dart';
import 'package:arjun_os/core/presentation/responsive_layout.dart';

class WindowManager extends ConsumerWidget {
  const WindowManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windows = ref.watch(windowManagerProvider);

    final screenSize = MediaQuery.of(context).size;
    final isMobile = ResponsiveLayout.isMobile(context);

    return Stack(
      children: [
        for (final window in windows)
          if (!window.isMinimized || window.isClosing) // keep it in stack if animating close
            Builder(
              builder: (context) {
                double left, top, width, height;

                if (window.isMaximized || isMobile) {
                  // On mobile, windows are always effectively "maximized" or full-screen style
                  left = 0;
                  top = isMobile ? 0 : 28; // 28 is the height of the top bar
                  width = screenSize.width;
                  height = screenSize.height - (isMobile ? 0 : 28);
                } else {
                  // Desktop - use window properties but ensure they fit
                  width = window.size.width.clamp(200, screenSize.width * 0.9);
                  height = window.size.height.clamp(100, screenSize.height * 0.8);
                  
                  // If position is default (100,100), center it
                  if (window.position == const Offset(100, 100)) {
                    left = (screenSize.width - width) / 2;
                    top = (screenSize.height - height) / 2;
                  } else {
                    left = window.position.dx;
                    top = window.position.dy;
                  }
                }

                return Positioned(
                  left: left,
                  top: top,
                  width: width,
                  height: height,
                  child: ArjunWindow(
                    key: ValueKey(window.id),
                    window: window,
                  ),
                );
              },
            ),
      ],
    );
  }
}

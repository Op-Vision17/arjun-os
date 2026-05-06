import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/widgets/desktop_wallpaper.dart';
import 'presentation/widgets/top_menu_bar.dart';
import 'presentation/widgets/desktop_dock.dart';
import 'presentation/widgets/desktop_icon_grid.dart';
import 'presentation/widgets/desktop_context_menu.dart';
import 'presentation/widgets/global_input_manager.dart';
import 'presentation/widgets/mobile_launcher.dart';
import 'presentation/widgets/mobile_bottom_nav.dart';
import 'presentation/widgets/cursor_overlay.dart';
import 'presentation/widgets/desktop_power_menu.dart';
import '../window_manager/presentation/window_manager.dart';
import '../window_manager/presentation/widgets/alt_tab_switcher.dart';
import '../command_palette/presentation/command_palette.dart';
import '../notifications/presentation/notification_system.dart';
import 'package:arjun_os/core/presentation/responsive_layout.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isBooted = false;
  final List<String> _bootLines = [
    "Initializing ArjunOS...",
    "Loading system modules...",
    "Connecting repositories...",
    "Fetching projects...",
    "System ready.",
  ];

  @override
  Widget build(BuildContext context) {
    final showPalette = ref.watch(commandPaletteProvider);
    final showAltTab = ref.watch(altTabProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isBooted 
        ? _buildDesktopShell(showPalette, showAltTab, isMobile)
        : _buildBootScreen(),
    );
  }

  Widget _buildBootScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(_bootLines.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "> ${_bootLines[index]}",
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.greenAccent,
                      fontSize: 16,
                    ),
                  ),
                )
                    .animate(delay: (400 * index).ms)
                    .fadeIn(duration: 300.ms)
                    .moveX(begin: -10, end: 0, duration: 300.ms);
              }),
              const SizedBox(height: 32),
              Container(
                height: 4,
                width: double.infinity,
                color: Colors.white24,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 4,
                    width: double.infinity,
                    color: Colors.greenAccent,
                  )
                      .animate(
                        onComplete: (_) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              setState(() => _isBooted = true);
                            }
                          });
                        },
                      )
                      .scaleX(
                        begin: 0,
                        end: 1,
                        duration: 2500.ms,
                        alignment: Alignment.centerLeft,
                        curve: Curves.easeInOut,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopShell(bool showPalette, bool showAltTab, bool isMobile) {
    return SizedBox.expand(
      child: CursorGlowOverlay(
        child: GlobalInputManager(
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Stack(
              children: [
                // 1. Wallpaper Layer
                Positioned.fill(
                  child: GestureDetector(
                    onSecondaryTapDown: (details) {
                      if (!isMobile) {
                        ref.read(contextMenuProvider.notifier).show(details.globalPosition);
                      }
                    },
                    child: const DesktopWallpaper(),
                  ),
                ),
                
                // 2. Main Content (Desktop Grid or Mobile Launcher)
                Positioned.fill(
                  child: FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: isMobile ? const MobileLauncher() : const DesktopIconGrid(),
                  ),
                ),

                // 3. Window Manager (Renders all open windows)
                const Positioned.fill(
                  child: WindowManager(),
                ),

                // 4. Top Menu Bar (Hidden on Mobile)
                if (!isMobile)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: FocusTraversalOrder(
                      order: const NumericFocusOrder(1),
                      child: const TopMenuBar(),
                    ),
                  ),

                // 5. Bottom Control (Dock or Mobile Nav)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FocusTraversalOrder(
                      order: const NumericFocusOrder(3),
                      child: isMobile ? const MobileBottomNav() : const DesktopDock(),
                    ),
                  ),
                ),

                // 6. Context Menu Layer
                if (!isMobile) const DesktopContextMenu(),

                // 7. Notification System
                const NotificationOverlay(),

                // 8. Command Palette Overlay
                if (showPalette)
                  const CommandPalette(),

                // 9. Alt+Tab Switcher Overlay (Hidden on Mobile)
                if (showAltTab && !isMobile)
                  const AltTabSwitcher(),

                // 10. Power Menu Overlay (Hidden on Mobile)
                if (!isMobile)
                  const DesktopPowerMenu(),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'prohibited_dialog.dart';

class DesktopPowerMenu extends ConsumerStatefulWidget {
  const DesktopPowerMenu({super.key});

  @override
  ConsumerState<DesktopPowerMenu> createState() => _DesktopPowerMenuState();
}

class _DesktopPowerMenuState extends ConsumerState<DesktopPowerMenu> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Overlay to close menu when clicking outside
        if (_isOpen)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),

        // The Menu Popup
        Positioned(
          bottom: 70,
          right: 20,
          child: SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: 1.0,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withAlpha(230),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PowerMenuItem(
                        label: 'Restart',
                        icon: Icons.refresh,
                        onTap: () {
                          _toggleMenu();
                          showProhibitedDialog(context, 'Restart');
                        },
                      ),
                      const Divider(color: Colors.white10, height: 1),
                      _PowerMenuItem(
                        label: 'Shut Down',
                        icon: Icons.power_settings_new,
                        color: Colors.redAccent,
                        onTap: () {
                          _toggleMenu();
                          showProhibitedDialog(context, 'Shut Down');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // The Power Icon Button
        Positioned(
          bottom: 20,
          right: 20,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _toggleMenu,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isOpen 
                      ? Colors.redAccent.withAlpha(40) 
                      : Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isOpen ? Colors.redAccent.withAlpha(100) : Colors.white24,
                    width: 1.5,
                  ),
                  boxShadow: _isOpen ? [
                    BoxShadow(
                      color: Colors.redAccent.withAlpha(60),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ] : [],
                ),
                child: Icon(
                  Icons.power_settings_new,
                  color: _isOpen ? Colors.redAccent : Colors.white70,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PowerMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _PowerMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color ?? Colors.white70),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/features/window_manager/domain/models/open_window.dart';
import 'package:arjun_os/features/window_manager/domain/providers/window_manager_notifier.dart';
import 'package:arjun_os/core/presentation/widgets/deferred_loader.dart';

import 'package:arjun_os/features/terminal/presentation/terminal_app.dart' deferred as terminal;
import 'package:arjun_os/features/about/presentation/about_app.dart' deferred as about;

class SystemMonitor extends ConsumerStatefulWidget {
  const SystemMonitor({super.key});

  @override
  ConsumerState<SystemMonitor> createState() => _SystemMonitorState();
}

class _SystemMonitorState extends ConsumerState<SystemMonitor> {
  bool _isHovered = false;
  final math.Random _random = math.Random();
  
  // Timer for flicker effects
  Timer? _flickerTimer;
  int _flickerIndex = -1;

  final List<Map<String, String>> _stats = [
    {'label': 'FUEL', 'value': 'Coffee Powered'},
    {'label': 'DEBUG MODE', 'value': 'Always On'},
    {'label': 'SLEEP CYCLE', 'value': 'Optional'},
    {'label': 'IDE STATE', 'value': 'Open'},
    {'label': 'SHIP MODE', 'value': 'Enabled'},
    {'label': 'SIDE QUESTS', 'value': 'Active'},
    {'label': 'AMBITION', 'value': 'Unlimited'},
    {'label': 'STATUS', 'value': 'Building...'},
  ];

  @override
  void initState() {
    super.initState();
    _startFlicker();
  }

  @override
  void dispose() {
    _flickerTimer?.cancel();
    super.dispose();
  }

  void _startFlicker() {
    _flickerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _flickerIndex = _random.nextInt(_stats.length);
        });
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _flickerIndex = -1;
            });
          }
        });
      }
    });
  }

  void _openApp(String title, IconData icon, Widget content) {
    ref.read(windowManagerProvider.notifier).openWindow(OpenWindow(
          title: title,
          icon: icon,
          content: content,
        ));
  }

  void _showContextMenu(BuildContext context, Offset position) {
    final overlay = Overlay.of(context);
    final RenderBox? overlayRenderBox = overlay.context.findRenderObject() as RenderBox?;
    
    if (overlayRenderBox == null) return;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlayRenderBox.size.width - position.dx,
        overlayRenderBox.size.height - position.dy,
      ),
      color: const Color(0xFF0D1220).withValues(alpha: 0.95),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.2)),
      ),
      items: [
        PopupMenuItem(
          value: 'refresh',
          child: _buildMenuItem(Icons.refresh, 'Refresh'),
        ),
        PopupMenuItem(
          value: 'dev',
          child: _buildMenuItem(Icons.code, 'Developer Mode'),
        ),
        PopupMenuItem(
          value: 'logs',
          child: _buildMenuItem(Icons.terminal, 'View Logs'),
        ),
      ],
    ).then((value) {
      if (value == 'refresh') {
        setState(() {}); // Mock refresh
      } else if (value == 'logs') {
        _openApp(
          'Terminal', 
          Icons.terminal, 
          DeferredLoader(loader: terminal.loadLibrary, builder: (_) => terminal.TerminalApp()),
        );
      }
    });
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.cyanAccent),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.sourceCodePro(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openApp(
          'About Me', 
          Icons.person, 
          DeferredLoader(loader: about.loadLibrary, builder: (_) => about.AboutApp()),
        ),
        onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0)
            ..scale(_isHovered ? 1.02 : 1.0, _isHovered ? 1.02 : 1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E17).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovered ? Colors.cyanAccent : Colors.cyanAccent.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: _isHovered ? 0.25 : 0.1),
                      blurRadius: _isHovered ? 20 : 10,
                      spreadRadius: _isHovered ? 2 : 0,
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    // Scanning Line
                    _buildScanLine(),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SYSTEM.MONITOR',
                              style: GoogleFonts.sourceCodePro(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                            _buildLiveIndicator(),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        
                        // Stats
                        ...List.generate(_stats.length, (index) {
                          final stat = _stats[index];
                          final isFlickering = _flickerIndex == index;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  stat['label']!,
                                  style: GoogleFonts.sourceCodePro(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  stat['value']!,
                                  style: GoogleFonts.sourceCodePro(
                                    color: isFlickering 
                                        ? Colors.cyanAccent.withValues(alpha: 0.4) 
                                        : Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      if (_isHovered)
                                        Shadow(
                                          color: Colors.cyanAccent.withValues(alpha: 0.4),
                                          blurRadius: 4,
                                        )
                                    ],
                                  ),
                                ).animate(
                                  target: isFlickering ? 1 : 0,
                                ).shimmer(duration: const Duration(milliseconds: 200), color: Colors.cyanAccent),
                              ],
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: index * 50), duration: const Duration(milliseconds: 300)).moveX(begin: 10, end: 0);
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ).animate(onPlay: (c) => c.repeat())
         .scale(duration: const Duration(seconds: 1), begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), curve: Curves.easeInOut)
         .fadeIn(duration: const Duration(seconds: 1), begin: 0.5),
        const SizedBox(width: 6),
        Text(
          'LIVE',
          style: GoogleFonts.sourceCodePro(
            color: Colors.redAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScanLine() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container()
            .animate(onPlay: (c) => c.repeat())
            .custom(
              duration: const Duration(seconds: 4),
              builder: (context, value, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: value * 300 - 50, // Arbitrary range to cover height
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyanAccent.withValues(alpha: 0),
                              Colors.cyanAccent.withValues(alpha: 0.4),
                              Colors.cyanAccent.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }
}

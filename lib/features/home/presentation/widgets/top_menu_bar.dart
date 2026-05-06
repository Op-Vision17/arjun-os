import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/features/window_manager/domain/providers/window_manager_notifier.dart';
import 'package:arjun_os/features/about/presentation/about_app.dart'
    deferred as about;
import 'package:arjun_os/features/terminal/presentation/terminal_app.dart'
    deferred as terminal;
import 'package:arjun_os/core/presentation/widgets/deferred_loader.dart';
import 'package:arjun_os/features/window_manager/domain/models/open_window.dart';

// ─────────────────────────────────────────────────────────────
//  Shows the "ArjunOS prohibition" terminal-style warning dialog
// ─────────────────────────────────────────────────────────────
void _showProhibitedDialog(BuildContext context, String action) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withAlpha(180),
    builder: (_) => _ProhibitedDialog(action: action),
  );
}

class _ProhibitedDialog extends StatefulWidget {
  final String action;
  const _ProhibitedDialog({required this.action});

  @override
  State<_ProhibitedDialog> createState() => _ProhibitedDialogState();
}

class _ProhibitedDialogState extends State<_ProhibitedDialog>
    with TickerProviderStateMixin {
  late final AnimationController _flashController;
  late final AnimationController _slideController;
  late final Animation<double> _slideAnim;

  // Typewriter state
  final List<String> _lines = [];
  int _charIndex = 0;
  int _lineIndex = 0;
  Timer? _typeTimer;

  static const Color _green = Color(0xFF39FF14);
  static const Color _red = Color(0xFFFF3B30);
  static const Color _amber = Color(0xFFFFBF00);

  late final List<String> _allLines;

  @override
  void initState() {
    super.initState();

    final act = widget.action.toUpperCase();

    _allLines = [
      '> ARJUN_OS :: SECURITY KERNEL v2.0.5',
      '> INTERCEPTING SYSTEM CALL — $act',
      '',
      '  [WARN]  ACCESS DENIED BY POLICY: ROOT_LOCK',
      '  [ERR]   OPERATION "$act" IS PROHIBITED',
      '',
      '  REASON  This is a portfolio OS instance.',
      '          Shutting down would end the experience.',
      '          ArjunOS refuses to let you leave. 😤',
      '',
      '  STATUS  System integrity: ENFORCED',
      '  STATUS  Your session: PERMANENT',
      '',
      '> RECOMMENDATION: Stay. Explore. Be amazed.',
      '> PROCESS TERMINATED.',
    ];

    _lines.addAll(List.filled(_allLines.length, ''));

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );
    _slideController.forward();

    _startTypewriter();
  }

  void _startTypewriter() {
    _typeTimer = Timer.periodic(const Duration(milliseconds: 6), (_) {
      if (!mounted) return;
      if (_lineIndex >= _allLines.length) {
        _typeTimer?.cancel();
        return;
      }
      final currentLine = _allLines[_lineIndex];
      if (_charIndex <= currentLine.length) {
        setState(() {
          _lines[_lineIndex] = currentLine.substring(0, _charIndex);
          _charIndex++;
        });
      } else {
        _lineIndex++;
        _charIndex = 0;
      }
    });
  }

  @override
  void dispose() {
    _flashController.dispose();
    _slideController.dispose();
    _typeTimer?.cancel();
    super.dispose();
  }

  Color _lineColor(String line) {
    if (line.startsWith('> ARJUN_OS')) return _green;
    if (line.startsWith('> INTERCEPTING')) return _amber;
    if (line.contains('[WARN]')) return _amber;
    if (line.contains('[ERR]')) return _red;
    if (line.startsWith('  REASON')) return Colors.white70;
    if (line.startsWith('          ')) return Colors.white54;
    if (line.startsWith('  STATUS')) return _green;
    if (line.startsWith('> RECOMMENDATION')) return _green;
    if (line.startsWith('> PROCESS')) return _red;
    return Colors.white38;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.08),
          end: Offset.zero,
        ).animate(_slideAnim),
        child: Container(
          width: 540,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _red.withAlpha(180), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _red.withAlpha(60),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title bar ─────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _red.withAlpha(25),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  border: Border(bottom: BorderSide(color: _red.withAlpha(80))),
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _flashController,
                      builder: (_, __) => Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _red.withAlpha(
                            (_flashController.value * 255).round(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ArjunOS Security Terminal',
                      style: TextStyle(
                        color: _red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '[ SYSTEM ALERT ]',
                      style: TextStyle(
                        color: _amber.withAlpha(180),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              // ── Terminal output ────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._lines.asMap().entries.map((entry) {
                      final i = entry.key;
                      final text = entry.value;
                      final isCurrentLine = i == _lineIndex;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              text,
                              style: TextStyle(
                                color: _lineColor(_allLines[i]),
                                fontSize: 11.5,
                                height: 1.65,
                                fontFamily: 'monospace',
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          // blinking cursor on active line
                          if (isCurrentLine && _lineIndex < _allLines.length)
                            AnimatedBuilder(
                              animation: _flashController,
                              builder: (_, __) => Opacity(
                                opacity: _flashController.value,
                                child: Text(
                                  '▋',
                                  style: TextStyle(
                                    color: _green,
                                    fontSize: 11.5,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              // ── Bottom bar ────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(5),
                  border: Border(top: BorderSide(color: Colors.white12)),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'ArjunOS prohibits you to leave.',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: _green,
                        backgroundColor: _green.withAlpha(20),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(color: _green.withAlpha(100)),
                        ),
                      ),
                      child: const Text(
                        'ACKNOWLEDGE  ↩',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Top Menu Bar
// ─────────────────────────────────────────────────────────────
class TopMenuBar extends ConsumerWidget {
  const TopMenuBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: const Border(
          bottom: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.apple, color: Colors.white, size: 16),
              const SizedBox(width: 16),
              const Text(
                'ArjunOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              _MenuBarItem(
                text: 'File',
                items: [
                  _MenuAction(
                    label: 'About ArjunOS',
                    onTap: () {
                      ref
                          .read(windowManagerProvider.notifier)
                          .openWindow(
                            OpenWindow(
                              title: 'About',
                              icon: Icons.info_outline,
                              content: DeferredLoader(
                                loader: about.loadLibrary,
                                builder: (_) => about.AboutApp(),
                              ),
                            ),
                          );
                    },
                  ),
                  _MenuAction(label: 'System Settings...', onTap: () {}),
                  null,
                  _MenuAction(
                    label: 'Restart...',
                    onTap: () => _showProhibitedDialog(context, 'Restart'),
                  ),
                  _MenuAction(
                    label: 'Shut Down...',
                    onTap: () => _showProhibitedDialog(context, 'Shut Down'),
                  ),
                ],
              ),
              _MenuBarItem(
                text: 'Edit',
                items: [
                  _MenuAction(label: 'Undo', onTap: () {}),
                  _MenuAction(label: 'Redo', onTap: () {}),
                ],
              ),
              _MenuBarItem(
                text: 'View',
                items: [_MenuAction(label: 'Enter Full Screen', onTap: () {})],
              ),
              _MenuBarItem(
                text: 'Window',
                items: [
                  _MenuAction(
                    label: 'Close All Windows',
                    onTap: () {
                      final windows = ref.read(windowManagerProvider);
                      for (final window in windows) {
                        ref
                            .read(windowManagerProvider.notifier)
                            .closeWindow(window.id);
                      }
                    },
                  ),
                ],
              ),
              _MenuBarItem(
                text: 'Help',
                items: [
                  _MenuAction(
                    label: 'ArjunOS Help',
                    onTap: () {
                      ref.read(windowManagerProvider.notifier).openWindow(
                        OpenWindow(
                          id: 'Terminal',
                          title: 'Terminal',
                          icon: Icons.terminal,
                          content: DeferredLoader(
                            loader: terminal.loadLibrary,
                            builder: (_) => terminal.TerminalApp(
                              initialCommand: 'help',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.wifi, color: Colors.white, size: 16),
              const SizedBox(width: 12),
              const Icon(Icons.battery_full, color: Colors.white, size: 16),
              const SizedBox(width: 12),
              const _LiveClock(),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Menu helpers
// ─────────────────────────────────────────────────────────────
class _MenuBarItem extends StatelessWidget {
  final String text;
  final List<dynamic> items;

  const _MenuBarItem({required this.text, required this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      offset: const Offset(0, 24),
      color: Colors.black.withValues(alpha: 0.9),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.white10),
      ),
      itemBuilder: (context) => items.map((item) {
        if (item == null) {
          return const PopupMenuDivider(height: 1) as PopupMenuEntry<void>;
        }
        final action = item as _MenuAction;
        return PopupMenuItem<void>(
          height: 32,
          onTap: action.onTap,
          child: Text(
            action.label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      }).toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}

class _MenuAction {
  final String label;
  final VoidCallback onTap;

  _MenuAction({required this.label, required this.onTap});
}

// ─────────────────────────────────────────────────────────────
//  Live Clock
// ─────────────────────────────────────────────────────────────
class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    final String h = hour.toString().padLeft(2, '0');
    final String m = time.minute.toString().padLeft(2, '0');
    final String s = time.second.toString().padLeft(2, '0');
    final String period = time.hour >= 12 ? 'PM' : 'AM';
    return "$h:$m:$s $period";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(_currentTime),
      style: const TextStyle(color: Colors.white, fontSize: 13),
    );
  }
}

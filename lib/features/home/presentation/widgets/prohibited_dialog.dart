import 'dart:async';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  Shows the "ArjunOS prohibition" terminal-style warning dialog
// ─────────────────────────────────────────────────────────────
void showProhibitedDialog(BuildContext context, String action) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withAlpha(180),
    builder: (_) => ProhibitedDialog(action: action),
  );
}

class ProhibitedDialog extends StatefulWidget {
  final String action;
  const ProhibitedDialog({super.key, required this.action});

  @override
  State<ProhibitedDialog> createState() => _ProhibitedDialogState();
}

class _ProhibitedDialogState extends State<ProhibitedDialog>
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
                color: _red.withAlpha(30),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _red.withAlpha(20),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.terminal, color: _red, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'SYSTEM_RESTRICTION_LOG',
                      style: TextStyle(
                        color: _red,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _flashController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _flashController.value > 0.5 ? 1 : 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Terminal Content
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in _lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          line,
                          style: TextStyle(
                            color: _lineColor(line),
                            fontFamily: 'monospace',
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    
                    // Typing Cursor
                    if (_lineIndex < _allLines.length)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 16,
                            color: _green,
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Bottom bar
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
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('ACKNOWLEDGE'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red.withAlpha(40),
                        foregroundColor: Colors.white,
                        side: BorderSide(color: _red.withAlpha(100)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('ABORT'),
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

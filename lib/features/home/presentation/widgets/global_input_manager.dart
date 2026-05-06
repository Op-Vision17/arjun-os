import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/features/command_palette/presentation/command_palette.dart';
import 'package:arjun_os/features/window_manager/presentation/widgets/alt_tab_switcher.dart';
import 'package:arjun_os/features/notifications/presentation/notification_system.dart';

class GlobalInputManager extends ConsumerStatefulWidget {
  final Widget child;
  const GlobalInputManager({super.key, required this.child});

  @override
  ConsumerState<GlobalInputManager> createState() => _GlobalInputManagerState();
}

class _GlobalInputManagerState extends ConsumerState<GlobalInputManager> {
  final FocusNode _focusNode = FocusNode();
  final List<LogicalKeyboardKey> _konamiCode = [
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyA,
  ];
  final List<LogicalKeyboardKey> _inputBuffer = [];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool _isAltPressed = false;

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // 1. Alt+Tab Detection
      if (event.logicalKey == LogicalKeyboardKey.altLeft || event.logicalKey == LogicalKeyboardKey.altRight) {
        _isAltPressed = true;
      }

      if (_isAltPressed && event.logicalKey == LogicalKeyboardKey.tab) {
        ref.read(altTabProvider.notifier).toggle(true);
      }

      // 2. Ctrl+K Detection
      if ((HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed) && 
          event.logicalKey == LogicalKeyboardKey.keyK) {
        ref.read(commandPaletteProvider.notifier).toggle();
      }

      // 3. Konami Code Detection
      _inputBuffer.add(event.logicalKey);
      if (_inputBuffer.length > _konamiCode.length) {
        _inputBuffer.removeAt(0);
      }

      if (_isKonamiSequence()) {
        ref.read(notificationProvider.notifier).show(
          title: 'Cheat Code Activated',
          message: 'Konami sequence detected! 🎮',
          icon: Icons.videogame_asset,
        );
        _inputBuffer.clear();
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.altLeft || event.logicalKey == LogicalKeyboardKey.altRight) {
        _isAltPressed = false;
        ref.read(altTabProvider.notifier).toggle(false);
      }
    }
  }

  bool _isKonamiSequence() {
    if (_inputBuffer.length != _konamiCode.length) return false;
    for (int i = 0; i < _konamiCode.length; i++) {
      if (_inputBuffer[i] != _konamiCode[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}

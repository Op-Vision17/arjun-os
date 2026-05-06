import 'dart:async';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/features/window_manager/domain/providers/window_manager_notifier.dart';
import 'package:arjun_os/features/about/presentation/about_app.dart'
    deferred as about;
import 'package:arjun_os/features/terminal/presentation/terminal_app.dart'
    deferred as terminal;
import 'package:arjun_os/features/settings/presentation/settings_app.dart'
    deferred as settings;
import 'package:arjun_os/core/presentation/widgets/deferred_loader.dart';
import 'package:arjun_os/features/home/presentation/widgets/prohibited_dialog.dart';
import 'package:arjun_os/features/window_manager/domain/models/open_window.dart';

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
                  _MenuAction(
                    label: 'System Settings...',
                    onTap: () {
                      ref.read(windowManagerProvider.notifier).openWindow(
                            OpenWindow(
                              title: 'Settings',
                              icon: Icons.settings,
                              content: DeferredLoader(
                                loader: settings.loadLibrary,
                                builder: (_) => settings.SettingsApp(),
                              ),
                            ),
                          );
                    },
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
                items: [
                  _MenuAction(
                    label: 'Enter Full Screen',
                    onTap: () {
                      web.document.documentElement?.requestFullscreen();
                    },
                  ),
                ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';

class OSNotification {
  final String id;
  final String title;
  final String message;
  final IconData icon;

  OSNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
  });
}

class NotificationNotifier extends Notifier<List<OSNotification>> {
  @override
  List<OSNotification> build() => [];

  void show({required String title, required String message, IconData icon = Icons.notifications}) {
    final notification = OSNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      icon: icon,
    );
    state = [...state, notification];

    Timer(const Duration(seconds: 3), () {
      dismiss(notification.id);
    });
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

final notificationProvider = NotifierProvider<NotificationNotifier, List<OSNotification>>(() => NotificationNotifier());

class NotificationOverlay extends ConsumerWidget {
  const NotificationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    return Positioned(
      top: 40,
      right: 20,
      child: SizedBox(
        width: 300,
        child: Column(
          children: notifications.map((n) {
            return _NotificationCard(
              key: ValueKey(n.id),
              notification: n,
              theme: theme,
              accent: accent,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final OSNotification notification;
  final dynamic theme;
  final Color accent;

  const _NotificationCard({
    super.key,
    required this.notification,
    required this.theme,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.panelBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(notification.icon, color: accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(color: theme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic).fadeIn(duration: 400.ms);
  }
}

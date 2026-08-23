import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/features/window_manager/domain/providers/window_manager_notifier.dart';

class MobileAppSwitcherProvider extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void close() => state = false;
  void open() => state = true;
}

final mobileAppSwitcherProvider =
    NotifierProvider<MobileAppSwitcherProvider, bool>(() => MobileAppSwitcherProvider());

class MobileAppSwitcher extends ConsumerWidget {
  const MobileAppSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);
    final windows = ref.watch(windowManagerProvider);
    final notifier = ref.read(windowManagerProvider.notifier);
    final switcherNotifier = ref.read(mobileAppSwitcherProvider.notifier);

    return GestureDetector(
      onTap: () => switcherNotifier.close(),
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.layers, color: accent, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Active Apps (${windows.length})',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (windows.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          for (final w in windows.toList()) {
                            notifier.removeWindow(w.id);
                          }
                          switcherNotifier.close();
                        },
                        icon: const Icon(Icons.clear_all, size: 18, color: Colors.redAccent),
                        label: const Text(
                          'Close All',
                          style: TextStyle(color: Colors.redAccent, fontSize: 13),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.close, color: theme.textMuted),
                        onPressed: () => switcherNotifier.close(),
                      ),
                  ],
                ),
              ),

              // Content: App Cards
              Expanded(
                child: windows.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.apps_outlined,
                              size: 64,
                              color: theme.textMuted.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No active apps in background',
                              style: TextStyle(
                                color: theme.textMuted,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap an app on the home screen to open it',
                              style: TextStyle(
                                color: theme.textMuted.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: windows.length,
                        itemBuilder: (context, index) {
                          final window = windows[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Dismissible(
                              key: ValueKey('switcher_${window.id}'),
                              direction: DismissDirection.horizontal,
                              onDismissed: (_) {
                                notifier.removeWindow(window.id);
                                if (windows.length <= 1) {
                                  switcherNotifier.close();
                                }
                              },
                              background: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete, color: Colors.redAccent),
                              ),
                              secondaryBackground: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete, color: Colors.redAccent),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  notifier.bringToFront(window.id, isMobile: true);
                                  switcherNotifier.close();
                                },
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: theme.cardBackground,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: accent.withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 54,
                                        height: 54,
                                        decoration: BoxDecoration(
                                          color: accent.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: accent.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Icon(window.icon, color: accent, size: 28),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              window.title,
                                              style: TextStyle(
                                                color: theme.textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              window.isMinimized ? 'Minimized' : 'Running in foreground',
                                              style: TextStyle(
                                                color: window.isMinimized ? theme.textMuted : accent,
                                                fontSize: 12,
                                                fontWeight: window.isMinimized ? FontWeight.normal : FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 22),
                                        color: theme.textMuted,
                                        onPressed: () {
                                          notifier.removeWindow(window.id);
                                          if (windows.length <= 1) {
                                            switcherNotifier.close();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ).animate(delay: (index * 60).ms).fadeIn().slideY(begin: 0.1, end: 0);
                        },
                      ),
              ),

              // Bottom hint
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 8),
                child: Text(
                  'Tap app to resume • Swipe left/right to close',
                  style: TextStyle(
                    color: theme.textMuted.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/features/window_manager/domain/providers/window_manager_notifier.dart';

class AltTabProvider extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle(bool show) => state = show;
}

final altTabProvider = NotifierProvider<AltTabProvider, bool>(() => AltTabProvider());

class AltTabSwitcher extends ConsumerStatefulWidget {
  const AltTabSwitcher({super.key});

  @override
  ConsumerState<AltTabSwitcher> createState() => _AltTabSwitcherState();
}

class _AltTabSwitcherState extends ConsumerState<AltTabSwitcher> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);
    final windows = ref.watch(windowManagerProvider);

    if (windows.isEmpty) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.black45,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.panelBackground.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Switch Windows', style: TextStyle(color: theme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: windows.map((window) {
                  final index = windows.indexOf(window);
                  final isSelected = index == _selectedIndex;

                  return GestureDetector(
                    onTap: () {
                      ref.read(windowManagerProvider.notifier).bringToFront(window.id);
                      ref.read(altTabProvider.notifier).toggle(false);
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? accent.withValues(alpha: 0.1) : theme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? accent : Colors.transparent, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(window.icon, color: isSelected ? accent : theme.textMuted, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            window.title,
                            style: TextStyle(
                              color: isSelected ? accent : theme.textColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Text('Hold Alt + Press Tab to cycle', style: TextStyle(color: theme.textMuted, fontSize: 12)),
            ],
          ),
        ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 200.ms).fadeIn(duration: 200.ms),
      ),
    );
  }
}

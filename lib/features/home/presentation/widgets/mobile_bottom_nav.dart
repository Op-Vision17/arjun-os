import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/features/command_palette/presentation/command_palette.dart';

class MobileBottomNav extends ConsumerWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    return Container(
      height: 70,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.panelBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: theme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.grid_view, color: accent),
            onPressed: () {
              // Stay on launcher
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: theme.textColor),
            onPressed: () => ref.read(commandPaletteProvider.notifier).toggle(),
          ),
          IconButton(
            icon: Icon(Icons.brightness_4, color: theme.textColor),
            onPressed: () {
              final current = ref.read(osThemeTypeProvider);
              final themes = OSThemeType.values;
              final nextIndex = (themes.indexOf(current) + 1) % themes.length;
              ref.read(osThemeTypeProvider.notifier).setTheme(themes[nextIndex]);
            },
          ),
        ],
      ),
    );
  }
}

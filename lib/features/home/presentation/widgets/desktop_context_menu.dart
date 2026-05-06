import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';

class ContextMenuProvider extends Notifier<Offset?> {
  @override
  Offset? build() => null;
  void show(Offset position) => state = position;
  void hide() => state = null;
}

final contextMenuProvider = NotifierProvider<ContextMenuProvider, Offset?>(() => ContextMenuProvider());

class DesktopContextMenu extends ConsumerWidget {
  const DesktopContextMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(contextMenuProvider);
    final theme = ref.watch(osThemeProvider);

    if (position == null) return const SizedBox.shrink();

    return Stack(
      children: [
        // Full screen transparent layer to detect clicks outside
        GestureDetector(
          onTap: () => ref.read(contextMenuProvider.notifier).hide(),
          onSecondaryTap: () => ref.read(contextMenuProvider.notifier).hide(),
          child: Container(color: Colors.transparent),
        ),
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.panelBackground.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.borderColor),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ContextMenuItem(
                  icon: Icons.refresh,
                  label: 'Refresh Desktop',
                  onTap: () {
                    // Mock refresh
                    ref.read(contextMenuProvider.notifier).hide();
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                _ContextMenuItem(
                  icon: Icons.brightness_4,
                  label: 'Next Theme',
                  onTap: () {
                    final current = ref.read(osThemeTypeProvider);
                    final themes = OSThemeType.values;
                    final nextIndex = (themes.indexOf(current) + 1) % themes.length;
                    ref.read(osThemeTypeProvider.notifier).setTheme(themes[nextIndex]);
                    ref.read(contextMenuProvider.notifier).hide();
                  },
                ),
                _ContextMenuItem(
                  icon: Icons.wallpaper,
                  label: 'Next Wallpaper',
                  onTap: () {
                    final current = ref.read(wallpaperProvider);
                    const options = [
                      'constellation',
                      'matrix',
                      'neural',
                      'interactive',
                      'gradient_dark',
                      'gradient_light',
                      'solid_dark',
                    ];
                    final currentIndex = options.indexOf(current);
                    final nextIndex = (currentIndex + 1) % options.length;
                    ref.read(wallpaperProvider.notifier).setWallpaper(options[nextIndex]);
                    ref.read(contextMenuProvider.notifier).hide();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContextMenuItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContextMenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: theme.textColor, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

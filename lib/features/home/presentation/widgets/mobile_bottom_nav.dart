import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/features/command_palette/presentation/command_palette.dart';
import 'package:arjun_os/features/window_manager/domain/providers/window_manager_notifier.dart';
import 'package:arjun_os/features/window_manager/presentation/widgets/mobile_app_switcher.dart';

class MobileBottomNav extends ConsumerWidget {
  const MobileBottomNav({super.key});

  void _showQuickSettings(BuildContext context, WidgetRef ref) {
    final theme = ref.read(osThemeProvider);
    final accent = ref.read(accentColorProvider);
    final currentTheme = ref.read(osThemeTypeProvider);
    final currentWallpaper = ref.read(wallpaperProvider);

    final wallpapers = [
      {'id': 'constellation', 'label': 'Stars', 'icon': Icons.stars},
      {'id': 'matrix', 'label': 'Matrix', 'icon': Icons.terminal},
      {'id': 'neural', 'label': 'Neural', 'icon': Icons.hub},
      {'id': 'interactive', 'label': 'Particles', 'icon': Icons.blur_on},
      {'id': 'gradient_dark', 'label': 'Dark', 'icon': Icons.gradient},
      {'id': 'solid_dark', 'label': 'Solid', 'icon': Icons.rectangle},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.panelBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: theme.borderColor),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Controls',
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.textMuted, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Theme Selector
              Text(
                'Theme Mode',
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: OSThemeType.values.map((t) {
                    final isSelected = t == currentTheme;
                    final name = t.name.toUpperCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          name,
                          style: TextStyle(
                            color: isSelected ? Colors.black : theme.textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: accent,
                        backgroundColor: theme.cardBackground,
                        side: BorderSide(color: isSelected ? accent : theme.borderColor),
                        onSelected: (_) {
                          ref.read(osThemeTypeProvider.notifier).setTheme(t);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Wallpaper Selector
              Text(
                'Wallpaper',
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: wallpapers.map((w) {
                    final isSelected = w['id'] == currentWallpaper;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(wallpaperProvider.notifier).setWallpaper(w['id'] as String);
                          Navigator.pop(context);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accent.withValues(alpha: 0.2)
                                    : theme.cardBackground,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? accent : theme.borderColor,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                w['icon'] as IconData,
                                color: isSelected ? accent : theme.textMuted,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              w['label'] as String,
                              style: TextStyle(
                                color: isSelected ? accent : theme.textMuted,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);
    final windows = ref.watch(windowManagerProvider);
    final isAppSwitcherOpen = ref.watch(mobileAppSwitcherProvider);

    final openWindowsCount = windows.where((w) => !w.isMinimized).length;

    return SafeArea(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.panelBackground.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.borderColor.withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Home Button
            IconButton(
              icon: Icon(
                Icons.home_rounded,
                color: openWindowsCount == 0 && !isAppSwitcherOpen ? accent : theme.textColor,
                size: 26,
              ),
              tooltip: 'Home',
              onPressed: () {
                // Close switcher and minimize all windows to view home screen
                ref.read(mobileAppSwitcherProvider.notifier).close();
                final notifier = ref.read(windowManagerProvider.notifier);
                for (final w in windows) {
                  if (!w.isMinimized) {
                    notifier.minimizeWindow(w.id);
                  }
                }
              },
            ),

            // App Switcher / Multitasking Button
            Badge(
              isLabelVisible: windows.isNotEmpty,
              label: Text(
                '${windows.length}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              backgroundColor: accent,
              offset: const Offset(4, -4),
              child: IconButton(
                icon: Icon(
                  isAppSwitcherOpen ? Icons.grid_view_rounded : Icons.layers_rounded,
                  color: isAppSwitcherOpen ? accent : theme.textColor,
                  size: 24,
                ),
                tooltip: 'Multitasking',
                onPressed: () {
                  ref.read(mobileAppSwitcherProvider.notifier).toggle();
                },
              ),
            ),

            // Spotlight Search
            IconButton(
              icon: Icon(Icons.search_rounded, color: theme.textColor, size: 25),
              tooltip: 'Spotlight Search',
              onPressed: () {
                ref.read(mobileAppSwitcherProvider.notifier).close();
                ref.read(commandPaletteProvider.notifier).toggle();
              },
            ),

            // Control Center / Settings
            IconButton(
              icon: Icon(Icons.tune_rounded, color: theme.textColor, size: 24),
              tooltip: 'Control Center',
              onPressed: () => _showQuickSettings(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

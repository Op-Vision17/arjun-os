import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';

class SettingsApp extends ConsumerWidget {
  const SettingsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);
    final currentThemeType = ref.watch(osThemeTypeProvider);
    final wallpaper = ref.watch(wallpaperProvider);

    final colors = [
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.cyanAccent,
    ];

    final themes = [
      {'type': OSThemeType.dark,     'name': 'Dark',     'color': const Color(0xFF1E1E1E)},
      {'type': OSThemeType.light,    'name': 'Light',    'color': Colors.white},
      {'type': OSThemeType.midnight, 'name': 'Midnight', 'color': Colors.black},
      {'type': OSThemeType.oceanic,  'name': 'Oceanic',  'color': const Color(0xFF1E293B)},
      {'type': OSThemeType.glass,    'name': 'Glass',    'color': Colors.white24},
    ];

    final wallpapers = [
      {'id': 'constellation',  'label': 'Constellation',  'icon': Icons.stars},
      {'id': 'matrix',         'label': 'Matrix Rain',    'icon': Icons.terminal},
      {'id': 'neural',         'label': 'Neural Net',     'icon': Icons.hub},
      {'id': 'interactive',    'label': 'Particles',      'icon': Icons.blur_on},
      {'id': 'gradient_dark',  'label': 'Dark Gradient',  'icon': Icons.gradient},
      {'id': 'gradient_light', 'label': 'Light Gradient', 'icon': Icons.wb_sunny},
      {'id': 'solid_dark',     'label': 'Solid Dark',     'icon': Icons.rectangle},
    ];

    return Container(
      color: theme.panelBackground,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 120),
        children: [
          // ── Title ──────────────────────────────────
          Text(
            'Appearance',
            style: TextStyle(
              color: theme.textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // ── System Theme ───────────────────────────
          Text(
            'System Theme',
            style: TextStyle(
              color: theme.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: themes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final t = themes[index];
                final isSelected = t['type'] == currentThemeType;
                return GestureDetector(
                  onTap: () => ref
                      .read(osThemeTypeProvider.notifier)
                      .setTheme(t['type'] as OSThemeType),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: t['color'] as Color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? accent : theme.borderColor,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 8)]
                              : null,
                        ),
                        child: isSelected ? Icon(Icons.check, color: accent) : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t['name'] as String,
                        style: TextStyle(color: theme.textColor, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // ── Accent Color ───────────────────────────
          Text(
            'Accent Color',
            style: TextStyle(
              color: theme.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            children: colors.map((c) {
              final isSelected = c == accent;
              return GestureDetector(
                onTap: () => ref.read(accentColorProvider.notifier).setColor(c),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: theme.textColor, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 10)]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),

          // ── Wallpaper ──────────────────────────────
          Text(
            'Wallpaper',
            style: TextStyle(
              color: theme.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: wallpapers.map((w) {
              final id = w['id'] as String;
              final label = w['label'] as String;
              final icon = w['icon'] as IconData;
              final isSelected = id == wallpaper;
              return GestureDetector(
                onTap: () =>
                    ref.read(wallpaperProvider.notifier).setWallpaper(id),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? accent : theme.borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? accent.withValues(alpha: 0.1)
                        : theme.cardBackground,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? accent : theme.textMuted,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? accent : theme.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

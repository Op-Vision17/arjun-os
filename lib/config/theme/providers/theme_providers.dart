import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/os_theme.dart';

enum OSThemeType { dark, light, midnight, oceanic, glass }

class OSThemeNotifier extends Notifier<OSThemeType> {
  @override
  OSThemeType build() => OSThemeType.dark;

  void setTheme(OSThemeType type) => state = type;
}

final osThemeTypeProvider = NotifierProvider<OSThemeNotifier, OSThemeType>(
  () => OSThemeNotifier(),
);

final osThemeProvider = Provider<OSTheme>((ref) {
  final type = ref.watch(osThemeTypeProvider);
  switch (type) {
    case OSThemeType.light:
      return OSTheme.light;
    case OSThemeType.midnight:
      return OSTheme.midnight;
    case OSThemeType.oceanic:
      return OSTheme.oceanic;
    case OSThemeType.glass:
      return OSTheme.glass;
    case OSThemeType.dark:
    default:
      return OSTheme.dark;
  }
});

final themeModeProvider = Provider<bool>((ref) {
  return ref.watch(osThemeProvider).isDark;
});

class AccentColorNotifier extends Notifier<Color> {
  @override
  Color build() => Colors.greenAccent;
  void setColor(Color color) => state = color;
}

final accentColorProvider = NotifierProvider<AccentColorNotifier, Color>(
  () => AccentColorNotifier(),
);

class WallpaperNotifier extends Notifier<String> {
  @override
  String build() => 'interactive'; // default
  void setWallpaper(String id) => state = id;
}

final wallpaperProvider = NotifierProvider<WallpaperNotifier, String>(
  () => WallpaperNotifier(),
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'interactive_wallpaper.dart';
import 'wallpapers/matrix_rain_wallpaper.dart';
import 'wallpapers/neural_network_wallpaper.dart';
import 'wallpapers/constellation_wallpaper.dart';

class DesktopWallpaper extends ConsumerWidget {
  const DesktopWallpaper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpaper = ref.watch(wallpaperProvider);

    switch (wallpaper) {
      case 'interactive':
        return const InteractiveWallpaper();
      case 'matrix':
        return const MatrixRainWallpaper();
      case 'neural':
        return const NeuralNetworkWallpaper();
      case 'constellation':
        return const ConstellationWallpaper();
      case 'gradient_dark':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            ),
          ),
        );
      case 'gradient_light':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
            ),
          ),
        );
      case 'solid_dark':
        return Container(color: const Color(0xFF1A1A2E));
      default:
        return const ConstellationWallpaper();
    }
  }
}

import 'package:flutter/material.dart';

class OSTheme {
  final Color background;
  final Color panelBackground;
  final Color cardBackground;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;
  final bool isDark;

  const OSTheme({
    required this.background,
    required this.panelBackground,
    required this.cardBackground,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
    required this.isDark,
  });

  static const OSTheme dark = OSTheme(
    background: Color(0xFF121212),
    panelBackground: Color(0xFF1E1E1E),
    cardBackground: Colors.white10,
    textColor: Colors.white,
    textMuted: Colors.white70,
    borderColor: Colors.white24,
    isDark: true,
  );

  static const OSTheme light = OSTheme(
    background: Color(0xFFF5F5F5),
    panelBackground: Color(0xFFFFFFFF),
    cardBackground: Colors.black12,
    textColor: Colors.black87,
    textMuted: Colors.black54,
    borderColor: Colors.black12,
    isDark: false,
  );

  static const OSTheme midnight = OSTheme(
    background: Color(0xFF000000),
    panelBackground: Color(0xFF0A0A0A),
    cardBackground: Colors.white10,
    textColor: Colors.white,
    textMuted: Colors.white60,
    borderColor: Colors.white12,
    isDark: true,
  );

  static const OSTheme oceanic = OSTheme(
    background: Color(0xFF0F172A),
    panelBackground: Color(0xFF1E293B),
    cardBackground: Colors.white10,
    textColor: Color(0xFFF1F5F9),
    textMuted: Color(0xFF94A3B8),
    borderColor: Color(0xFF334155),
    isDark: true,
  );

  static const OSTheme glass = OSTheme(
    background: Colors.transparent,
    panelBackground: Colors.white10,
    cardBackground: Colors.white10,
    textColor: Colors.white,
    textMuted: Colors.white70,
    borderColor: Colors.white24,
    isDark: true,
  );
}

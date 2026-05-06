import 'package:flutter/material.dart';

class OpenWindow {
  final String id;
  final String title;
  final IconData icon;
  final Widget content;
  final Offset position;
  final Size size;
  final bool isMaximized;
  final bool isMinimized;
  final bool isClosing;

  OpenWindow({
    String? id,
    required this.title,
    required this.icon,
    required this.content,
    this.position = const Offset(100, 100),
    this.size = const Size(600, 400),
    this.isMaximized = false,
    this.isMinimized = false,
    this.isClosing = false,
  }) : id = id ?? title;

  OpenWindow copyWith({
    String? title,
    IconData? icon,
    Widget? content,
    Offset? position,
    Size? size,
    bool? isMaximized,
    bool? isMinimized,
    bool? isClosing,
  }) {
    return OpenWindow(
      id: id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      content: content ?? this.content,
      position: position ?? this.position,
      size: size ?? this.size,
      isMaximized: isMaximized ?? this.isMaximized,
      isMinimized: isMinimized ?? this.isMinimized,
      isClosing: isClosing ?? this.isClosing,
    );
  }
}

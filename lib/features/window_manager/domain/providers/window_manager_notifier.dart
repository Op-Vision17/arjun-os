import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/open_window.dart';

class WindowManagerNotifier extends Notifier<List<OpenWindow>> {
  @override
  List<OpenWindow> build() {
    return [];
  }

  void openWindow(OpenWindow window) {
    // If it's already open, bring to front
    final index = state.indexWhere((w) => w.id == window.id);
    if (index != -1) {
      bringToFront(window.id);
      final w = state.firstWhere((w) => w.id == window.id);
      if (w.isMinimized) {
        _updateWindow(window.id, w.copyWith(isMinimized: false));
      }
      return;
    }
    state = [...state, window];
  }

  void closeWindow(String id) {
    final window = state.firstWhere((w) => w.id == id);
    _updateWindow(id, window.copyWith(isClosing: true));
  }

  void removeWindow(String id) {
    state = state.where((w) => w.id != id).toList();
  }

  void minimizeWindow(String id) {
    final window = state.firstWhere((w) => w.id == id);
    _updateWindow(id, window.copyWith(isMinimized: true));
  }

  void maximizeWindow(String id) {
    final window = state.firstWhere((w) => w.id == id);
    _updateWindow(id, window.copyWith(isMaximized: !window.isMaximized));
    bringToFront(id);
  }
  
  void restoreWindow(String id) {
    final window = state.firstWhere((w) => w.id == id);
    _updateWindow(id, window.copyWith(isMinimized: false));
    bringToFront(id);
  }

  void bringToFront(String id) {
    final index = state.indexWhere((w) => w.id == id);
    if (index == -1) return;

    final window = state[index];
    // Also restore if minimized
    final updatedWindow = window.copyWith(isMinimized: false);
    
    final newState = List<OpenWindow>.from(state)
      ..removeAt(index)
      ..add(updatedWindow);
    state = newState;
  }

  void updatePosition(String id, Offset newPosition) {
    final window = state.firstWhere((w) => w.id == id);
    if (window.isMaximized) return; // Don't move if maximized
    _updateWindow(id, window.copyWith(position: newPosition));
  }

  void updateSize(String id, Size newSize) {
    final window = state.firstWhere((w) => w.id == id);
    if (window.isMaximized) return; // Don't resize if maximized
    _updateWindow(id, window.copyWith(size: newSize));
  }

  void _updateWindow(String id, OpenWindow newWindow) {
    state = [
      for (final w in state)
        if (w.id == id) newWindow else w
    ];
  }
}

final windowManagerProvider = NotifierProvider<WindowManagerNotifier, List<OpenWindow>>(() {
  return WindowManagerNotifier();
});

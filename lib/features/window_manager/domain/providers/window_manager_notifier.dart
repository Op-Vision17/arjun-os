import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/open_window.dart';

class WindowManagerNotifier extends Notifier<List<OpenWindow>> {
  @override
  List<OpenWindow> build() {
    return [];
  }

  void openWindow(OpenWindow window, {bool isMobile = false}) {
    final index = state.indexWhere((w) => w.id == window.id);
    if (index != -1) {
      bringToFront(window.id, isMobile: isMobile);
      return;
    }
    
    if (isMobile) {
      // On mobile, minimize all other open apps so the new one takes foreground
      final updatedList = state.map((w) => w.copyWith(isMinimized: true)).toList();
      state = [...updatedList, window.copyWith(isMinimized: false, isClosing: false)];
    } else {
      state = [...state, window.copyWith(isMinimized: false, isClosing: false)];
    }
  }

  void closeWindow(String id) {
    final index = state.indexWhere((w) => w.id == id);
    if (index == -1) return;
    final window = state[index];
    _updateWindow(id, window.copyWith(isClosing: true));
  }

  void removeWindow(String id) {
    state = state.where((w) => w.id != id).toList();
  }

  void minimizeWindow(String id) {
    final index = state.indexWhere((w) => w.id == id);
    if (index == -1) return;
    final window = state[index];
    _updateWindow(id, window.copyWith(isMinimized: true));
  }

  void maximizeWindow(String id) {
    final index = state.indexWhere((w) => w.id == id);
    if (index == -1) return;
    final window = state[index];
    _updateWindow(id, window.copyWith(isMaximized: !window.isMaximized, isClosing: false));
    bringToFront(id);
  }
  
  void restoreWindow(String id, {bool isMobile = false}) {
    bringToFront(id, isMobile: isMobile);
  }

  void bringToFront(String id, {bool isMobile = false}) {
    final index = state.indexWhere((w) => w.id == id);
    if (index == -1) return;

    final window = state[index];
    final updatedWindow = window.copyWith(isMinimized: false, isClosing: false);
    
    final List<OpenWindow> newState;
    if (isMobile) {
      // On mobile, minimize other windows so only this one is active in foreground
      newState = state.asMap().entries.map((entry) {
        if (entry.key == index) return updatedWindow;
        return entry.value.copyWith(isMinimized: true);
      }).toList()
        ..removeAt(index)
        ..add(updatedWindow);
    } else {
      newState = List<OpenWindow>.from(state)
        ..removeAt(index)
        ..add(updatedWindow);
    }
    state = newState;
  }

  void updatePosition(String id, Offset newPosition) {
    final index = state.indexWhere((w) => w.id == id);
    if (index == -1) return;
    final window = state[index];
    if (window.isMaximized) return;
    _updateWindow(id, window.copyWith(position: newPosition));
  }

  void updateSize(String id, Size newSize) {
    final index = state.indexWhere((w) => w.id == id);
    if (index == -1) return;
    final window = state[index];
    if (window.isMaximized) return;
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

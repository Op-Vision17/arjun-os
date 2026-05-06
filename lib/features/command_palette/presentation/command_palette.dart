import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/features/window_manager/domain/providers/window_manager_notifier.dart';
import 'package:arjun_os/features/window_manager/domain/models/open_window.dart';
import 'package:arjun_os/core/presentation/widgets/deferred_loader.dart';

// App Imports
import 'package:arjun_os/features/terminal/presentation/terminal_app.dart' deferred as terminal;
import 'package:arjun_os/features/projects/presentation/projects_app.dart' deferred as projects;
import 'package:arjun_os/features/about/presentation/about_app.dart' deferred as about;
import 'package:arjun_os/features/skills/presentation/skills_app.dart' deferred as skills;
import 'package:arjun_os/features/experience/presentation/experience_app.dart' deferred as experience;
import 'package:arjun_os/features/settings/presentation/settings_app.dart' deferred as settings;
import 'package:arjun_os/features/resume/presentation/resume_app.dart' deferred as resume;

class CommandPaletteProvider extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void close() => state = false;
}

final commandPaletteProvider = NotifierProvider<CommandPaletteProvider, bool>(() => CommandPaletteProvider());

class PaletteItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onSelect;

  PaletteItem({required this.title, required this.subtitle, required this.icon, required this.onSelect});
}

class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<PaletteItem> _getItems(WidgetRef ref) {
    final List<PaletteItem> items = [
      PaletteItem(
        title: 'Terminal',
        subtitle: 'Open the command line interface',
        icon: Icons.terminal,
        onSelect: () => _openApp(
          ref, 
          'Terminal', 
          Icons.terminal, 
          DeferredLoader(loader: terminal.loadLibrary, builder: (_) => terminal.TerminalApp()),
        ),
      ),
      PaletteItem(
        title: 'Projects',
        subtitle: 'View my portfolio',
        icon: Icons.work,
        onSelect: () => _openApp(
          ref, 
          'Projects', 
          Icons.work, 
          DeferredLoader(loader: projects.loadLibrary, builder: (_) => projects.ProjectsApp()),
        ),
      ),
      PaletteItem(
        title: 'About',
        subtitle: 'Learn more about me',
        icon: Icons.person,
        onSelect: () => _openApp(
          ref, 
          'About', 
          Icons.person, 
          DeferredLoader(loader: about.loadLibrary, builder: (_) => about.AboutApp()),
        ),
      ),
      PaletteItem(
        title: 'Skills',
        subtitle: 'My technical expertise',
        icon: Icons.bolt,
        onSelect: () => _openApp(
          ref, 
          'Skills', 
          Icons.bolt, 
          DeferredLoader(loader: skills.loadLibrary, builder: (_) => skills.SkillsApp()),
        ),
      ),
      PaletteItem(
        title: 'Experience',
        subtitle: 'My professional journey',
        icon: Icons.timeline,
        onSelect: () => _openApp(
          ref, 
          'Experience', 
          Icons.timeline, 
          DeferredLoader(loader: experience.loadLibrary, builder: (_) => experience.ExperienceApp()),
        ),
      ),
      PaletteItem(
        title: 'Settings',
        subtitle: 'Customize the OS',
        icon: Icons.settings,
        onSelect: () => _openApp(
          ref, 
          'Settings', 
          Icons.settings, 
          DeferredLoader(loader: settings.loadLibrary, builder: (_) => settings.SettingsApp()),
        ),
      ),
      PaletteItem(
        title: 'Next Theme',
        subtitle: 'Cycle through available themes',
        icon: Icons.brightness_4,
        onSelect: () {
          final current = ref.read(osThemeTypeProvider);
          final themes = OSThemeType.values;
          final nextIndex = (themes.indexOf(current) + 1) % themes.length;
          ref.read(osThemeTypeProvider.notifier).setTheme(themes[nextIndex]);
          ref.read(commandPaletteProvider.notifier).close();
        },
      ),
    ];

    final query = _controller.text.toLowerCase();
    if (query.isEmpty) return items;

    return items.where((item) => item.title.toLowerCase().contains(query) || item.subtitle.toLowerCase().contains(query)).toList();
  }

  void _openApp(WidgetRef ref, String title, IconData icon, Widget content) {
    final id = title == 'Resume' ? DateTime.now().millisecondsSinceEpoch.toString() : title;
    
    Widget finalContent = content;
    if (title == 'Resume') {
      finalContent = DeferredLoader(
        loader: resume.loadLibrary, 
        builder: (_) => resume.ResumeApp(windowId: id),
      );
    }

    ref.read(windowManagerProvider.notifier).openWindow(OpenWindow(
      id: id,
      title: title,
      icon: icon,
      content: finalContent,
    ));
    ref.read(commandPaletteProvider.notifier).close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);
    final items = _getItems(ref);

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 400),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: theme.panelBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                spreadRadius: 10,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (v) => setState(() => _selectedIndex = 0),
                  onSubmitted: (_) {
                    if (items.isNotEmpty) items[_selectedIndex].onSelect();
                  },
                  style: TextStyle(color: theme.textColor, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Search apps or commands...',
                    hintStyle: TextStyle(color: theme.textMuted),
                    prefixIcon: Icon(Icons.search, color: accent),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('No results found', style: TextStyle(color: theme.textMuted)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = index == _selectedIndex;

                      return MouseRegion(
                        onEnter: (_) => setState(() => _selectedIndex = index),
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: item.onSelect,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? accent.withValues(alpha: 0.1) : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Icon(item.icon, color: isSelected ? accent : theme.textMuted),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          color: isSelected ? accent : theme.textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        item.subtitle,
                                        style: TextStyle(color: theme.textMuted, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.keyboard_return, color: accent, size: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const Divider(height: 1, color: Colors.white12),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ShortcutHint(keyText: '↑↓', label: 'Navigate'),
                    const SizedBox(width: 24),
                    _ShortcutHint(keyText: '↵', label: 'Select'),
                    const SizedBox(width: 24),
                    _ShortcutHint(keyText: 'esc', label: 'Close'),
                  ],
                ),
              ),
            ],
          ),
        ).animate().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 200.ms, curve: Curves.easeOutCubic).fadeIn(duration: 200.ms),
      ),
    );
  }
}

class _ShortcutHint extends StatelessWidget {
  final String keyText;
  final String label;

  const _ShortcutHint({required this.keyText, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(keyText, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

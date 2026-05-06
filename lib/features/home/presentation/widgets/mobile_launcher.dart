import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:arjun_os/features/contact/presentation/contact_app.dart' deferred as contact;
import 'package:arjun_os/features/resume/presentation/resume_app.dart' deferred as resume;
import 'package:arjun_os/features/settings/presentation/settings_app.dart' deferred as settings;

class MobileLauncher extends ConsumerWidget {
  const MobileLauncher({super.key});

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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    final apps = [
      {'title': 'Terminal', 'icon': Icons.terminal, 'app': DeferredLoader(loader: terminal.loadLibrary, builder: (_) => terminal.TerminalApp())},
      {'title': 'Projects', 'icon': Icons.work, 'app': DeferredLoader(loader: projects.loadLibrary, builder: (_) => projects.ProjectsApp())},
      {'title': 'About', 'icon': Icons.person, 'app': DeferredLoader(loader: about.loadLibrary, builder: (_) => about.AboutApp())},
      {'title': 'Skills', 'icon': Icons.bolt, 'app': DeferredLoader(loader: skills.loadLibrary, builder: (_) => skills.SkillsApp())},
      {'title': 'Experience', 'icon': Icons.timeline, 'app': DeferredLoader(loader: experience.loadLibrary, builder: (_) => experience.ExperienceApp())},
      {'title': 'Contact', 'icon': Icons.email, 'app': DeferredLoader(loader: contact.loadLibrary, builder: (_) => contact.ContactApp())},
      {'title': 'Resume', 'icon': Icons.description, 'app': const SizedBox()}, // Special handling in _openApp
      {'title': 'Settings', 'icon': Icons.settings, 'app': DeferredLoader(loader: settings.loadLibrary, builder: (_) => settings.SettingsApp())},
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return GestureDetector(
          onTap: () => _openApp(ref, app['title'] as String, app['icon'] as IconData, app['app'] as Widget),
          child: Container(
            decoration: BoxDecoration(
              color: theme.panelBackground.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.borderColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(app['icon'] as IconData, color: accent, size: 40),
                const SizedBox(height: 12),
                Text(
                  app['title'] as String,
                  style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

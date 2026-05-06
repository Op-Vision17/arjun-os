import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/features/window_manager/domain/models/open_window.dart';
import 'package:arjun_os/features/window_manager/domain/providers/window_manager_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/core/presentation/widgets/deferred_loader.dart';

import 'package:arjun_os/features/terminal/presentation/terminal_app.dart' deferred as terminal;
import 'package:arjun_os/features/projects/presentation/projects_app.dart' deferred as projects;
import 'package:arjun_os/features/about/presentation/about_app.dart' deferred as about;
import 'package:arjun_os/features/skills/presentation/skills_app.dart' deferred as skills;
import 'package:arjun_os/features/experience/presentation/experience_app.dart' deferred as experience;
import 'package:arjun_os/features/contact/presentation/contact_app.dart' deferred as contact;
import 'package:arjun_os/features/resume/presentation/resume_app.dart' deferred as resume;
import 'package:arjun_os/features/settings/presentation/settings_app.dart' deferred as settings;

class DesktopIconGrid extends ConsumerWidget {
  const DesktopIconGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 32, right: 32, bottom: 100),
      child: Wrap(
        spacing: 40, // More spacing
        runSpacing: 40,
        direction: Axis.vertical,
        children: [
          _DesktopIcon(
            icon: Icons.folder,
            label: 'My Files',
            color: Colors.amber,
            onOpen: () => _openApp(ref, 'Files', Icons.folder, const Center(child: Text('File Manager', style: TextStyle(color: Colors.white)))),
          ),
          _DesktopIcon(
            icon: Icons.web,
            label: 'Browser',
            color: Colors.blue,
            onOpen: () => _openApp(ref, 'Browser', Icons.web, const Center(child: Text('Web Browser', style: TextStyle(color: Colors.white)))),
          ),
          _DesktopIcon(
            icon: Icons.terminal,
            label: 'Terminal',
            color: Colors.black,
            onOpen: () => _openApp(
              ref, 
              'Terminal', 
              Icons.terminal, 
              DeferredLoader(loader: terminal.loadLibrary, builder: (_) => terminal.TerminalApp()),
            ),
          ),
          _DesktopIcon(
            icon: Icons.photo,
            label: 'Gallery',
            color: Colors.purple,
            onOpen: () => _openApp(ref, 'Gallery', Icons.photo, const Center(child: Text('Photo Gallery', style: TextStyle(color: Colors.white)))),
          ),
          _DesktopIcon(
            icon: Icons.settings,
            label: 'Settings',
            color: Colors.blueGrey,
            onOpen: () => _openApp(
              ref, 
              'Settings', 
              Icons.settings, 
              DeferredLoader(loader: settings.loadLibrary, builder: (_) => settings.SettingsApp()),
            ),
          ),
          _DesktopIcon(
            icon: Icons.person,
            label: 'About Me',
            color: Colors.teal,
            onOpen: () => _openApp(
              ref, 
              'About', 
              Icons.person, 
              DeferredLoader(loader: about.loadLibrary, builder: (_) => about.AboutApp()),
            ),
          ),
          _DesktopIcon(
            icon: Icons.work,
            label: 'Projects',
            color: Colors.indigo,
            onOpen: () => _openApp(
              ref, 
              'Projects', 
              Icons.work, 
              DeferredLoader(loader: projects.loadLibrary, builder: (_) => projects.ProjectsApp()),
            ),
          ),
          _DesktopIcon(
            icon: Icons.bolt,
            label: 'Skills',
            color: Colors.orange,
            onOpen: () => _openApp(
              ref, 
              'Skills', 
              Icons.bolt, 
              DeferredLoader(loader: skills.loadLibrary, builder: (_) => skills.SkillsApp()),
            ),
          ),
          _DesktopIcon(
            icon: Icons.timeline,
            label: 'Experience',
            color: Colors.red,
            onOpen: () => _openApp(
              ref, 
              'Experience', 
              Icons.timeline, 
              DeferredLoader(loader: experience.loadLibrary, builder: (_) => experience.ExperienceApp()),
            ),
          ),
          _DesktopIcon(
            icon: Icons.email,
            label: 'Contact',
            color: Colors.green,
            onOpen: () => _openApp(
              ref, 
              'Contact', 
              Icons.email, 
              DeferredLoader(loader: contact.loadLibrary, builder: (_) => contact.ContactApp()),
            ),
          ),
          _DesktopIcon(
            icon: Icons.description,
            label: 'Resume',
            color: Colors.deepOrange,
            onOpen: () {
              ref.read(windowManagerProvider.notifier).openWindow(OpenWindow(
                id: 'Resume',
                title: 'Resume',
                icon: Icons.description,
                content: DeferredLoader(
                  loader: resume.loadLibrary, 
                  builder: (_) => resume.ResumeApp(windowId: 'Resume'),
                ),
              ));
            },
          ),
        ],
      ),
    );
  }

  void _openApp(WidgetRef ref, String title, IconData icon, Widget content) {
    final notifier = ref.read(windowManagerProvider.notifier);
    notifier.openWindow(OpenWindow(
      title: title,
      icon: icon,
      content: content,
    ));
  }
}

class _DesktopIcon extends ConsumerStatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onOpen;

  const _DesktopIcon({
    required this.icon, 
    required this.label, 
    required this.color,
    required this.onOpen
  });

  @override
  ConsumerState<_DesktopIcon> createState() => _DesktopIconState();
}

class _DesktopIconState extends ConsumerState<_DesktopIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentColorProvider);
    
    return Semantics(
      label: 'Open ${widget.label} application',
      button: true,
      child: GestureDetector(
        onDoubleTap: widget.onOpen,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 1.0, end: _isHovered ? 1.15 : 1.0),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: RepaintBoundary(
              child: SizedBox(
                width: 120, // Wider for bigger labels
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Container with Glassmorphism
                    Container(
                      width: 80, // Much bigger icons
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color.withValues(alpha: _isHovered ? 0.4 : 0.2),
                            widget.color.withValues(alpha: _isHovered ? 0.2 : 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isHovered 
                              ? widget.color.withValues(alpha: 0.6) 
                              : Colors.white.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: _isHovered ? 0.4 : 0.2),
                            blurRadius: _isHovered ? 20 : 10,
                            spreadRadius: _isHovered ? 2 : 0,
                            offset: Offset(0, _isHovered ? 8 : 4),
                          )
                        ],
                      ),
                      child: Icon(
                        widget.icon, 
                        color: Colors.white.withValues(alpha: 0.9), 
                        size: 44, // Bigger icon font
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Label with better styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isHovered 
                            ? accent.withValues(alpha: 0.9) 
                            : Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isHovered ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.4),
                            blurRadius: 8,
                          )
                        ] : null,
                      ),
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: _isHovered ? Colors.black : Colors.white,
                          fontSize: 13,
                          fontWeight: _isHovered ? FontWeight.bold : FontWeight.w500,
                          shadows: const [
                            Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


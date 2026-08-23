import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:web/web.dart' as web;
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/features/window_manager/domain/providers/window_manager_notifier.dart';
import 'package:arjun_os/features/window_manager/domain/models/open_window.dart';
import 'package:arjun_os/core/presentation/widgets/deferred_loader.dart';
import 'package:arjun_os/features/command_palette/presentation/command_palette.dart';

// App Imports
import 'package:arjun_os/features/terminal/presentation/terminal_app.dart' deferred as terminal;
import 'package:arjun_os/features/projects/presentation/projects_app.dart' deferred as projects;
import 'package:arjun_os/features/about/presentation/about_app.dart' deferred as about;
import 'package:arjun_os/features/skills/presentation/skills_app.dart' deferred as skills;
import 'package:arjun_os/features/experience/presentation/experience_app.dart' deferred as experience;
import 'package:arjun_os/features/contact/presentation/contact_app.dart' deferred as contact;
import 'package:arjun_os/features/resume/presentation/resume_app.dart' deferred as resume;
import 'package:arjun_os/features/settings/presentation/settings_app.dart' deferred as settings;

class MobileLauncher extends ConsumerStatefulWidget {
  const MobileLauncher({super.key});

  @override
  ConsumerState<MobileLauncher> createState() => _MobileLauncherState();
}

class _MobileLauncherState extends ConsumerState<MobileLauncher> {
  late DateTime _currentTime;
  Timer? _timer;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _openApp(WidgetRef ref, String title, IconData icon, Widget content, {String? id}) {
    final windowId = id ?? (title == 'About Me' ? 'About' : title);

    Widget finalContent = content;
    if (windowId == 'Resume') {
      finalContent = DeferredLoader(
        loader: resume.loadLibrary,
        builder: (_) => resume.ResumeApp(windowId: windowId),
      );
    }

    ref.read(windowManagerProvider.notifier).openWindow(
      OpenWindow(
        id: windowId,
        title: title,
        icon: icon,
        content: finalContent,
      ),
      isMobile: true,
    );
  }

  void _openUrl(String url) {
    web.window.open(url, '_blank');
  }

  String _formatTime(DateTime dt) {
    int hour = dt.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }

  String _formatDate(DateTime dt) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    final allApps = [
      {
        'title': 'About Me',
        'subtitle': 'Bio & Philosophy',
        'icon': Icons.person_rounded,
        'gradient': [Colors.purpleAccent, Colors.deepPurple],
        'app': DeferredLoader(loader: about.loadLibrary, builder: (_) => about.AboutApp()),
      },
      {
        'title': 'Projects',
        'subtitle': 'Apps & AI Systems',
        'icon': Icons.rocket_launch_rounded,
        'gradient': [Colors.blueAccent, Colors.indigo],
        'app': DeferredLoader(loader: projects.loadLibrary, builder: (_) => projects.ProjectsApp()),
      },
      {
        'title': 'Skills',
        'subtitle': 'Tech Stack & Tools',
        'icon': Icons.bolt_rounded,
        'gradient': [Colors.amber, Colors.orangeAccent],
        'app': DeferredLoader(loader: skills.loadLibrary, builder: (_) => skills.SkillsApp()),
      },
      {
        'title': 'Experience',
        'subtitle': 'Career & Internships',
        'icon': Icons.timeline_rounded,
        'gradient': [Colors.tealAccent, Colors.teal],
        'app': DeferredLoader(loader: experience.loadLibrary, builder: (_) => experience.ExperienceApp()),
      },
      {
        'title': 'Terminal',
        'subtitle': 'Command Line Interface',
        'icon': Icons.terminal_rounded,
        'gradient': [Colors.greenAccent, Colors.green.shade800],
        'app': DeferredLoader(loader: terminal.loadLibrary, builder: (_) => terminal.TerminalApp()),
      },
      {
        'title': 'Contact',
        'subtitle': 'Get in Touch',
        'icon': Icons.mail_rounded,
        'gradient': [Colors.pinkAccent, Colors.pink.shade700],
        'app': DeferredLoader(loader: contact.loadLibrary, builder: (_) => contact.ContactApp()),
      },
      {
        'title': 'Resume',
        'subtitle': 'Download & View PDF',
        'icon': Icons.description_rounded,
        'gradient': [Colors.cyanAccent, Colors.blueGrey.shade800],
        'app': const SizedBox(),
      },
      {
        'title': 'Settings',
        'subtitle': 'Themes & Wallpapers',
        'icon': Icons.tune_rounded,
        'gradient': [Colors.blueGrey, Colors.grey.shade900],
        'app': DeferredLoader(loader: settings.loadLibrary, builder: (_) => settings.SettingsApp()),
      },
    ];

    final filteredApps = _searchQuery.isEmpty
        ? allApps
        : allApps
            .where((app) =>
                (app['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (app['subtitle'] as String).toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Digital Clock & Date Widget ────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    _formatTime(_currentTime),
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: accent.withValues(alpha: 0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(_currentTime),
                    style: TextStyle(
                      color: theme.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

            const SizedBox(height: 20),

            // ── 2. Developer Bio Hero Widget ──────────────────
            Container(
              decoration: BoxDecoration(
                color: theme.panelBackground.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Glowing Avatar
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.35),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://avatars.githubusercontent.com/Op-Vision17',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: theme.cardBackground,
                              child: Icon(Icons.person, color: accent, size: 30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Arjun Gupta',
                                  style: TextStyle(
                                    color: theme.textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.greenAccent.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(radius: 3, backgroundColor: Colors.greenAccent),
                                      SizedBox(width: 4),
                                      Text(
                                        'Open to Work',
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Flutter Full Stack & AI Engineer',
                              style: TextStyle(
                                color: accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickStat(theme, accent, '2+ Yrs', 'Experience'),
                      _buildQuickStat(theme, accent, '10+', 'Projects'),
                      _buildQuickStat(theme, accent, '25+', 'Skills & AI'),
                      _buildQuickStat(theme, accent, 'B.Tech', 'CS Core'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Action Social Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialBtn(
                          theme: theme,
                          accent: accent,
                          icon: Icons.code,
                          label: 'GitHub',
                          onTap: () => _openUrl('https://github.com/Op-Vision17'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSocialBtn(
                          theme: theme,
                          accent: accent,
                          icon: Icons.link,
                          label: 'LinkedIn',
                          onTap: () => _openUrl('https://linkedin.com/in/arjun-gupta-flutter'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSocialBtn(
                          theme: theme,
                          accent: accent,
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Contact',
                          onTap: () => _openApp(
                            ref,
                            'Contact',
                            Icons.mail_rounded,
                            DeferredLoader(
                              loader: contact.loadLibrary,
                              builder: (_) => contact.ContactApp(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 450.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 20),

            // ── 3. Spotlight App Search Bar ──────────────────
            Container(
              decoration: BoxDecoration(
                color: theme.panelBackground.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: theme.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: TextStyle(color: theme.textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search apps, skills, terminal...',
                        hintStyle: TextStyle(color: theme.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Icon(Icons.close_rounded, color: theme.textMuted, size: 18),
                    )
                  else
                    GestureDetector(
                      onTap: () => ref.read(commandPaletteProvider.notifier).toggle(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.cardBackground,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: theme.borderColor),
                        ),
                        child: Text(
                          '⌘K',
                          style: TextStyle(
                            color: theme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 450.ms, delay: 150.ms),

            const SizedBox(height: 20),

            // ── 4. Smartphone App Grid ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Applications',
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: filteredApps.length,
              itemBuilder: (context, index) {
                final app = filteredApps[index];
                final gradient = app['gradient'] as List<Color>;

                return GestureDetector(
                  onTap: () => _openApp(
                    ref,
                    app['title'] as String,
                    app['icon'] as IconData,
                    app['app'] as Widget,
                  ),
                  child: Column(
                    children: [
                      // Squircle App Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: gradient.first.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          app['icon'] as IconData,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // App Name
                      Text(
                        app['title'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: (index * 40).ms).scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1, 1),
                      duration: 250.ms,
                      curve: Curves.easeOutBack,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(dynamic theme, Color accent, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: theme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialBtn({
    required dynamic theme,
    required Color accent,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: theme.textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

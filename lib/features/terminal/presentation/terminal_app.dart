// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../window_manager/domain/models/open_window.dart';
import '../../window_manager/domain/providers/window_manager_notifier.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/core/presentation/widgets/deferred_loader.dart';

// Deferred app imports
import 'package:arjun_os/features/resume/presentation/resume_app.dart' deferred as resume;
import 'package:arjun_os/features/settings/presentation/settings_app.dart' deferred as settings;

import 'package:arjun_os/features/about/presentation/about_app.dart' deferred as about;
import 'package:arjun_os/features/projects/presentation/projects_app.dart' deferred as projects;
import 'package:arjun_os/features/skills/presentation/skills_app.dart' deferred as skills;
import 'package:arjun_os/features/experience/presentation/experience_app.dart' deferred as experience;
import 'package:arjun_os/features/contact/presentation/contact_app.dart' deferred as contact;

// ─────────────────────────────────────────────────────────────
//  Line types for color coding
// ─────────────────────────────────────────────────────────────
enum _LineType {
  command,   // the prompt line
  header,    // section header / success
  info,      // normal output
  muted,     // dim info
  accent,    // highlighted value
  error,     // error/unknown
  success,   // green success
  separator, // divider line
}

class _TLine {
  final String text;
  final _LineType type;
  bool animated;

  _TLine(this.text, {this.type = _LineType.info, this.animated = false});
}

// ─────────────────────────────────────────────────────────────
//  Widget
// ─────────────────────────────────────────────────────────────
class TerminalApp extends ConsumerStatefulWidget {
  final String? initialCommand;
  const TerminalApp({super.key, this.initialCommand});

  @override
  ConsumerState<TerminalApp> createState() => _TerminalAppState();
}

class _TerminalAppState extends ConsumerState<TerminalApp> {
  final List<_TLine> _lines = [
    _TLine('┌─────────────────────────────────────────────┐', type: _LineType.separator),
    _TLine('│  ArjunOS Terminal  v2.0.0  — Dart/Flutter   │', type: _LineType.header),
    _TLine('│  Session started: ${_nowString()}                │', type: _LineType.muted),
    _TLine('└─────────────────────────────────────────────┘', type: _LineType.separator),
    _TLine(''),
    _TLine('Type "help" to see available commands.', type: _LineType.muted),
    _TLine(''),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _easterEggActive = false;
  final List<String> _history = [];
  int _historyIndex = -1;

  static String _nowString() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2,'0')}:${n.minute.toString().padLeft(2,'0')}';
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialCommand != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleCommand(widget.initialCommand!);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleCommand(String input) {
    if (input.trim().isEmpty) return;

    _history.insert(0, input.trim());
    _historyIndex = -1;

    setState(() {
      _lines.add(_TLine('arjun@os:~\$ $input', type: _LineType.command));
    });

    final parts = input.trim().split(RegExp(r'\s+'));
    final command = parts[0].toLowerCase();
    final args = parts.length > 1 ? parts.sublist(1) : <String>[];

    switch (command) {

      // ── help ──────────────────────────────────────────────
      case 'help':
        _add([
          _TLine(''),
          _TLine('  SYSTEM COMMANDS', type: _LineType.header),
          _TLine('  ─────────────────────────────────────────', type: _LineType.separator),
          _TLine('  help          Show this help menu', type: _LineType.info),
          _TLine('  clear         Clear the terminal', type: _LineType.info),
          _TLine('  whoami        About Arjun Gupta', type: _LineType.info),
          _TLine('  date          Show current date & time', type: _LineType.info),
          _TLine('  echo <text>   Print text to terminal', type: _LineType.info),
          _TLine(''),
          _TLine('  PORTFOLIO COMMANDS', type: _LineType.header),
          _TLine('  ─────────────────────────────────────────', type: _LineType.separator),
          _TLine('  skills        List technical skills', type: _LineType.info),
          _TLine('  projects      List projects', type: _LineType.info),
          _TLine('  experience    Work experience', type: _LineType.info),
          _TLine('  contact       Contact information', type: _LineType.info),
          _TLine('  resume        Open Resume viewer', type: _LineType.info),
          _TLine(''),
          _TLine('  LAUNCH APPS  [ open <app> ]', type: _LineType.header),
          _TLine('  ─────────────────────────────────────────', type: _LineType.separator),
          _TLine('  open about       → About Me', type: _LineType.accent),
          _TLine('  open projects    → Projects', type: _LineType.accent),
          _TLine('  open skills      → Skills', type: _LineType.accent),
          _TLine('  open experience  → Experience', type: _LineType.accent),
          _TLine('  open contact     → Contact', type: _LineType.accent),
          _TLine('  open resume      → Resume', type: _LineType.accent),
          _TLine('  open settings    → Settings', type: _LineType.accent),
          _TLine(''),
          _TLine('  EXTERNAL', type: _LineType.header),
          _TLine('  ─────────────────────────────────────────', type: _LineType.separator),
          _TLine('  github         Open GitHub profile', type: _LineType.info),
          _TLine('  linkedin       Open LinkedIn profile', type: _LineType.info),
          _TLine(''),
        ]);
        break;

      // ── whoami ────────────────────────────────────────────
      case 'whoami':
        _add([
          _TLine(''),
          _TLine('  ██████╗  ARJUN GUPTA', type: _LineType.header),
          _TLine('  ──────────────────────────────────────────', type: _LineType.separator),
          _TLine('  Role      Flutter & Full-Stack Developer', type: _LineType.info),
          _TLine('            AI Engineer & Researcher', type: _LineType.info),
          _TLine('  Location  Ghaziabad, Uttar Pradesh, IN', type: _LineType.muted),
          _TLine('  College   AKGEC — B.Tech CS (Data Science)', type: _LineType.muted),
          _TLine('  Batch     2023 – 2027', type: _LineType.muted),
          _TLine(''),
          _TLine('  Passionate about intelligent, scalable digital', type: _LineType.info),
          _TLine('  products — from multi-agent AI to real-time apps.', type: _LineType.info),
          _TLine(''),
        ]);
        break;

      // ── skills ────────────────────────────────────────────
      case 'skills':
        _add([
          _TLine(''),
          _TLine('  TECHNICAL SKILLS', type: _LineType.header),
          _TLine('  ─────────────────────────────────────────', type: _LineType.separator),
          _TLine('  Languages   Dart, Python, JavaScript, SQL', type: _LineType.info),
          _TLine('  Mobile      Flutter (iOS / Android / Web)', type: _LineType.accent),
          _TLine('  Backend     FastAPI, Node.js, Express', type: _LineType.info),
          _TLine('  AI / ML     CrewAI, LangChain, RAG, Pinecone', type: _LineType.accent),
          _TLine('  Realtime    Agora, Socket.io, WebRTC', type: _LineType.info),
          _TLine('  DevOps      Git, CI/CD, Heroku, Firebase', type: _LineType.muted),
          _TLine('  Databases   PostgreSQL, Redis, MongoDB', type: _LineType.muted),
          _TLine(''),
          _TLine('  → Run  open skills  for interactive view', type: _LineType.success),
          _TLine(''),
        ]);
        break;

      // ── projects ──────────────────────────────────────────
      case 'projects':
        _add([
          _TLine(''),
          _TLine('  PROJECTS', type: _LineType.header),
          _TLine('  ─────────────────────────────────────────', type: _LineType.separator),
          _TLine('  [1] Ingredex     AI-powered ingredient analyzer', type: _LineType.info),
          _TLine('      Stack: Flutter, FastAPI, GPT-4, Barcode Scanner', type: _LineType.muted),
          _TLine(''),
          _TLine('  [2] Tensai       AI Study Copilot', type: _LineType.info),
          _TLine('      Stack: Flutter, CrewAI, RAG, Pinecone', type: _LineType.muted),
          _TLine(''),
          _TLine('  [3] Baat Karo    Real-time Communication Platform', type: _LineType.info),
          _TLine('      Stack: Flutter, Agora, Socket.io, Node.js', type: _LineType.muted),
          _TLine(''),
          _TLine('  [4] ViiSar       Visa Platform UI Components', type: _LineType.info),
          _TLine('      Stack: Flutter, REST APIs, Firebase', type: _LineType.muted),
          _TLine(''),
          _TLine('  [5] KaamDhanda   Worker-Client Matching Platform', type: _LineType.info),
          _TLine('      Stack: Flutter, FastAPI, PostgreSQL, Redis', type: _LineType.muted),
          _TLine(''),
          _TLine('  → Run  open projects  for full details', type: _LineType.success),
          _TLine(''),
        ]);
        break;

      // ── experience ────────────────────────────────────────
      case 'experience':
        _add([
          _TLine(''),
          _TLine('  WORK EXPERIENCE', type: _LineType.header),
          _TLine('  ─────────────────────────────────────────', type: _LineType.separator),
          _TLine('  Blockchain Research Lab          2024', type: _LineType.accent),
          _TLine('  Flutter Developer', type: _LineType.info),
          _TLine('  Real-time communication with Agora & Socket.io', type: _LineType.muted),
          _TLine(''),
          _TLine('  Neenva Innovations               2025', type: _LineType.accent),
          _TLine('  Frontend App Developer Intern', type: _LineType.info),
          _TLine('  Architected ViiSar platform UI components', type: _LineType.muted),
          _TLine(''),
          _TLine('  Nirvighna Services               2025', type: _LineType.accent),
          _TLine('  Flutter App Developer Intern', type: _LineType.info),
          _TLine('  Built KaamDhanda worker-matching app', type: _LineType.muted),
          _TLine(''),
          _TLine('  → Run  open experience  for timeline view', type: _LineType.success),
          _TLine(''),
        ]);
        break;

      // ── contact ───────────────────────────────────────────
      case 'contact':
        _add([
          _TLine(''),
          _TLine('  CONTACT INFO', type: _LineType.header),
          _TLine('  ─────────────────────────────────────────', type: _LineType.separator),
          _TLine('  Email     guptaarjun1711@gmail.com', type: _LineType.accent),
          _TLine('  Phone     +91 7505911991', type: _LineType.info),
          _TLine('  Location  Ghaziabad, Uttar Pradesh, IN', type: _LineType.info),
          _TLine('  GitHub    github.com/Op-Vision17', type: _LineType.muted),
          _TLine('  LinkedIn  linkedin.com/in/arjun-gupta1711', type: _LineType.muted),
          _TLine(''),
          _TLine('  → Run  open contact  for the contact form', type: _LineType.success),
          _TLine(''),
        ]);
        break;

      // ── resume ────────────────────────────────────────────
      case 'resume':
        _add([
          _TLine('Launching Resume viewer…', type: _LineType.success),
          _TLine(''),
        ]);
        _openWindow('Resume', Icons.description,
            DeferredLoader(loader: resume.loadLibrary, builder: (_) => resume.ResumeApp(windowId: 'Resume')),
            id: 'Resume');
        break;

      // ── open <app> ────────────────────────────────────────
      case 'open':
        if (args.isEmpty) {
          _add([_TLine('Usage: open <app>', type: _LineType.error),
                _TLine('Run "help" to see available apps.', type: _LineType.muted)]);
        } else {
          _handleOpen(args[0].toLowerCase());
        }
        break;

      // ── github / linkedin ─────────────────────────────────
      case 'github':
        _add([_TLine('Opening GitHub profile…', type: _LineType.success)]);
        web.window.open('https://github.com/Op-Vision17', '_blank');
        break;

      case 'linkedin':
        _add([_TLine('Opening LinkedIn…', type: _LineType.success)]);
        web.window.open('https://www.linkedin.com/in/arjun-gupta1711', '_blank');
        break;

      // ── date ──────────────────────────────────────────────
      case 'date':
        final now = DateTime.now();
        final days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
        final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        _add([
          _TLine('  ${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}  '
              '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')} IST',
              type: _LineType.accent),
          _TLine(''),
        ]);
        break;

      // ── echo ──────────────────────────────────────────────
      case 'echo':
        final text = args.join(' ');
        _add([_TLine(text.isEmpty ? '' : text, type: _LineType.info), _TLine('')]);
        break;

      // ── clear ─────────────────────────────────────────────
      case 'clear':
        setState(() => _lines.clear());
        break;

      // ── easter egg ────────────────────────────────────────
      case 'konami':
      case 'sudo':
        if (command == 'sudo') {
          _add([
            _TLine('  Permission denied: This is ArjunOS.', type: _LineType.error),
            _TLine('  You are not root. You never were. 😏', type: _LineType.muted),
            _TLine(''),
          ]);
        } else {
          setState(() => _easterEggActive = !_easterEggActive);
          _add([
            _TLine(_easterEggActive ? '  🎮 Easter egg activated!' : '  Easter egg deactivated.', type: _LineType.success),
            _TLine(''),
          ]);
        }
        break;

      // ── matrix ────────────────────────────────────────────
      case 'matrix':
        _add([
          _TLine('  Wake up, Neo…', type: _LineType.accent),
          _TLine('  The Matrix has you.', type: _LineType.header),
          _TLine('  → Switch wallpaper to "Matrix Rain" from Settings.', type: _LineType.muted),
          _TLine(''),
        ]);
        break;

      // ── unknown ───────────────────────────────────────────
      default:
        _add([
          _TLine('  bash: $command: command not found', type: _LineType.error),
          _TLine('  Type "help" for available commands.', type: _LineType.muted),
          _TLine(''),
        ]);
    }

    _controller.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
  }

  void _handleOpen(String appName) {
    switch (appName) {
      case 'about':
      case 'about me':
        _add([_TLine('  Launching About Me…', type: _LineType.success), _TLine('')]);
        _openWindow('About', Icons.person,
            DeferredLoader(loader: about.loadLibrary, builder: (_) => about.AboutApp()));
        break;
      case 'projects':
        _add([_TLine('  Launching Projects…', type: _LineType.success), _TLine('')]);
        _openWindow('Projects', Icons.work,
            DeferredLoader(loader: projects.loadLibrary, builder: (_) => projects.ProjectsApp()));
        break;
      case 'skills':
        _add([_TLine('  Launching Skills…', type: _LineType.success), _TLine('')]);
        _openWindow('Skills', Icons.bolt,
            DeferredLoader(loader: skills.loadLibrary, builder: (_) => skills.SkillsApp()));
        break;
      case 'experience':
        _add([_TLine('  Launching Experience…', type: _LineType.success), _TLine('')]);
        _openWindow('Experience', Icons.timeline,
            DeferredLoader(loader: experience.loadLibrary, builder: (_) => experience.ExperienceApp()));
        break;
      case 'contact':
        _add([_TLine('  Launching Contact…', type: _LineType.success), _TLine('')]);
        _openWindow('Contact', Icons.email,
            DeferredLoader(loader: contact.loadLibrary, builder: (_) => contact.ContactApp()));
        break;
      case 'resume':
        _add([_TLine('  Launching Resume…', type: _LineType.success), _TLine('')]);
        _openWindow('Resume', Icons.description,
            DeferredLoader(loader: resume.loadLibrary, builder: (_) => resume.ResumeApp(windowId: 'Resume')),
            id: 'Resume');
        break;
      case 'settings':
        _add([_TLine('  Launching Settings…', type: _LineType.success), _TLine('')]);
        _openWindow('Settings', Icons.settings,
            DeferredLoader(loader: settings.loadLibrary, builder: (_) => settings.SettingsApp()));
        break;

      default:
        _add([
          _TLine('  open: "$appName" — app not found.', type: _LineType.error),
          _TLine('  Available: about, projects, skills, experience, contact, resume, settings', type: _LineType.muted),
          _TLine(''),
        ]);
    }
  }

  void _add(List<_TLine> lines) {
    setState(() => _lines.addAll(lines));
    _scrollToBottom();
  }

  void _openWindow(String title, IconData icon, Widget content, {String? id}) {
    ref.read(windowManagerProvider.notifier).openWindow(OpenWindow(
      id: id ?? title,
      title: title,
      icon: icon,
      content: content,
    ));
  }

  // ─────────────────────────────────────────────────────────────
  //  Color map
  // ─────────────────────────────────────────────────────────────
  Color _colorFor(_LineType type, Color accent) {
    switch (type) {
      case _LineType.command:   return const Color(0xFF39FF14);  // neon green prompt
      case _LineType.header:    return accent;
      case _LineType.info:      return Colors.white.withAlpha(220);
      case _LineType.muted:     return Colors.white.withAlpha(100);
      case _LineType.accent:    return const Color(0xFF00CFFF);  // cyan
      case _LineType.error:     return const Color(0xFFFF5F56);  // red
      case _LineType.success:   return const Color(0xFF39FF14);  // green
      case _LineType.separator: return Colors.white.withAlpha(40);
    }
  }

  double _fontSizeFor(_LineType type) =>
      type == _LineType.separator ? 11 : 13;

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentColorProvider);

    Widget terminalContent = Container(
      color: const Color(0xFF0A0E17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header bar ──────────────────────────────────────
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              border: Border(
                bottom: BorderSide(color: Colors.white.withAlpha(20)),
              ),
            ),
            child: Row(
              children: [
                Container(width: 10, height: 10,
                    decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10,
                    decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10,
                    decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                const Spacer(),
                Text('arjun@os — terminal',
                    style: TextStyle(
                        color: Colors.white.withAlpha(100),
                        fontSize: 11,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5)),
                const Spacer(),
              ],
            ),
          ),

          // ── Output ──────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(14),
                itemCount: _lines.length,
                itemBuilder: (context, index) {
                  final line = _lines[index];
                  final color = _colorFor(line.type, accent);
                  final size = _fontSizeFor(line.type);

                  // Prefix for command lines
                  Widget widget;
                  if (line.type == _LineType.command) {
                    widget = RichText(
                      text: TextSpan(
                        style: TextStyle(fontFamily: 'monospace', fontSize: size, height: 1.6),
                        children: [
                          TextSpan(text: 'arjun@os', style: TextStyle(color: const Color(0xFF39FF14), fontWeight: FontWeight.bold)),
                          TextSpan(text: ':', style: TextStyle(color: Colors.white.withAlpha(80))),
                          TextSpan(text: '~', style: TextStyle(color: const Color(0xFF00CFFF))),
                          TextSpan(text: '\$ ', style: TextStyle(color: Colors.white.withAlpha(150))),
                          // extract just the input (strip "arjun@os:~$ " prefix added in _handleCommand)
                          TextSpan(
                            text: line.text.replaceFirst('arjun@os:~\$ ', ''),
                            style: TextStyle(color: Colors.white.withAlpha(230), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  } else {
                    widget = Text(
                      line.text,
                      style: TextStyle(
                        color: color,
                        fontFamily: 'monospace',
                        fontSize: size,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    );
                  }

                  if (!line.animated) {
                    line.animated = true;
                    return widget
                        .animate()
                        .fadeIn(duration: 60.ms)
                        .moveX(begin: -6, end: 0, duration: 60.ms);
                  }
                  return widget;
                },
              ),
            ),
          ),

          // ── Input row ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1220),
              border: Border(top: BorderSide(color: Colors.white.withAlpha(18))),
            ),
            child: Row(
              children: [
                // Prompt badge
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                    children: [
                      TextSpan(text: 'arjun@os', style: TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold)),
                      TextSpan(text: ':', style: TextStyle(color: Colors.white38)),
                      TextSpan(text: '~', style: TextStyle(color: Color(0xFF00CFFF))),
                      TextSpan(text: '\$ ', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    cursorColor: const Color(0xFF39FF14),
                    cursorWidth: 7,
                    cursorHeight: 14,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: _handleCommand,
                    onChanged: (_) => _historyIndex = -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (_easterEggActive) {
      terminalContent = terminalContent
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 2.seconds, color: Colors.pinkAccent.withValues(alpha: 0.4), angle: 0.5);
    }

    return terminalContent;
  }
}

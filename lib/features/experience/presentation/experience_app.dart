import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/core/presentation/responsive_layout.dart';

class ExperienceApp extends ConsumerWidget {
  const ExperienceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    
    final experiences = [
      {
        'company': 'Nirvighna Services Pvt. Ltd. (KaamDhanda)',
        'role': 'Flutter App Developer Intern',
        'duration': 'Dec 2025 – March 2026',
        'bullets': [
          'Delivered 2 production-ready cross-platform Flutter apps; integrated REST APIs and scalable state management following agile practices.',
          'Cut feature delivery cycle time by 20% through optimized workflow and reusable components.',
        ],
      },
      {
        'company': 'Neenva Innovations Pvt. Ltd.',
        'role': 'Frontend App Developer Intern',
        'duration': 'April 2025 – June 2025',
        'bullets': [
          'Architected responsive, reusable UI components for the ViiSar Flutter app using Riverpod and OOP principles.',
          'Improved cross-platform rendering consistency by 30% through rigorous testing and UI optimization.',
        ],
      },
      {
        'company': 'Blockchain Research Lab | BRL',
        'role': 'Flutter Developer, Member',
        'duration': 'Dec 2024 – Present',
        'bullets': [
          'Built Flutter apps for blockchain-integrated solutions; embedded real-time communication tools like Agora and Socket.io.',
          'Enhanced user engagement metrics through intuitive UX design and real-time feature implementation.',
        ],
      },
    ];

    return Container(
      color: theme.panelBackground,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          ResponsiveLayout.isMobile(context) ? 20 : 40,
          ResponsiveLayout.isMobile(context) ? 20 : 40,
          ResponsiveLayout.isMobile(context) ? 20 : 40,
          120,
        ),
        itemCount: experiences.length,
        itemBuilder: (context, index) {
          final exp = experiences[index];
          final isLast = index == experiences.length - 1;

          return _ExperienceNode(
            company: exp['company'] as String,
            role: exp['role'] as String,
            duration: exp['duration'] as String,
            bullets: exp['bullets'] as List<String>,
            isLast: isLast,
          ).animate().fadeIn(duration: 400.ms, delay: (index * 200).ms).slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
        },
      ),
    );
  }
}

class _ExperienceNode extends ConsumerStatefulWidget {
  final String company;
  final String role;
  final String duration;
  final List<String> bullets;
  final bool isLast;

  const _ExperienceNode({
    super.key,
    required this.company,
    required this.role,
    required this.duration,
    required this.bullets,
    required this.isLast,
  });

  @override
  ConsumerState<_ExperienceNode> createState() => _ExperienceNodeState();
}

class _ExperienceNodeState extends ConsumerState<_ExperienceNode> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Stack(
        children: [
          // Timeline Line
          if (!widget.isLast)
            Positioned(
              left: 9, // Center of the 20px dot
              top: 40, // Start below the dot
              bottom: -32, // Extend into the next item's padding
              child: Container(
                width: 2,
                color: theme.borderColor,
              ),
            ),
          // Timeline Dot
          Positioned(
            left: 0,
            top: 24,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _isExpanded ? accent : theme.panelBackground,
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 2),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.only(left: 44), // Space for timeline
            child: GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isExpanded ? theme.textColor.withValues(alpha: 0.1) : theme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _isExpanded ? accent.withValues(alpha: 0.3) : Colors.transparent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (context) {
                          final isNarrow = MediaQuery.of(context).size.width < 500;
                          
                          final companyText = Text(
                            widget.company,
                            style: TextStyle(
                              color: theme.textColor, 
                              fontSize: isNarrow ? 18 : 20, 
                              fontWeight: FontWeight.bold
                            ),
                          );
                          
                          final durationText = Text(
                            widget.duration,
                            style: TextStyle(color: accent, fontSize: 13),
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                companyText,
                                const SizedBox(height: 4),
                                durationText,
                              ],
                            );
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: companyText),
                              const SizedBox(width: 16),
                              durationText,
                            ],
                          );
                        }
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.role,
                        style: TextStyle(color: theme.textMuted, fontSize: 16),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _isExpanded
                            ? Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.bullets.map((bullet) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('• ', style: TextStyle(color: accent, fontSize: 16)),
                                          Expanded(
                                            child: Text(bullet, style: TextStyle(color: theme.textMuted, fontSize: 14, height: 1.5)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

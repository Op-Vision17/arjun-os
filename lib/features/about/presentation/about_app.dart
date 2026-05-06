import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/core/presentation/responsive_layout.dart';

class AboutApp extends ConsumerWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    return Container(
      color: theme.panelBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          ResponsiveLayout.isMobile(context) ? 20 : 40,
          ResponsiveLayout.isMobile(context) ? 20 : 40,
          ResponsiveLayout.isMobile(context) ? 20 : 40,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 500;
                
                final avatar = Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(color: accent, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://avatars.githubusercontent.com/Op-Vision17',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.cardBackground,
                          child: Icon(Icons.person, size: 60, color: accent),
                        );
                      },
                    ),
                  ),
                );

                final textContent = Column(
                  crossAxisAlignment: isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arjun Gupta',
                      style: TextStyle(color: theme.textColor, fontSize: 36, fontWeight: FontWeight.bold),
                      textAlign: isNarrow ? TextAlign.center : TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Flutter Full Stack Developer, AI Engineer',
                      style: TextStyle(color: accent, fontSize: 18),
                      textAlign: isNarrow ? TextAlign.center : TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Flutter Developer and AI Engineer passionate about building intelligent, scalable digital products. Specialized in multi-agent AI systems (CrewAI), RAG pipelines with Pinecone, and real-time communication platforms using Agora and Socket.io. Experienced in delivering production-ready cross-platform apps with polished UX and robust backend architectures.',
                      style: TextStyle(color: theme.textMuted, fontSize: 14, height: 1.5),
                      textAlign: isNarrow ? TextAlign.center : TextAlign.left,
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      avatar,
                      const SizedBox(height: 32),
                      textContent,
                    ],
                  );
                }

                return Row(
                  children: [
                    avatar,
                    const SizedBox(width: 32),
                    Expanded(child: textContent),
                  ],
                );
              }
            ),
            const SizedBox(height: 48),

            // Education Cards
            Text('Education', style: TextStyle(color: theme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Column(
              children: [
                // B.Tech
                _EducationCard(
                  icon: Icons.school,
                  degree: 'B.Tech — Computer Science Engineering (Data Science)',
                  institution: 'Ajay Kumar Garg Engineering College',
                  year: '2023 – 2027',
                  badge: 'Pursuing',
                  theme: theme,
                  accent: accent,
                ),
                const SizedBox(height: 16),
                // Intermediate
                _EducationCard(
                  icon: Icons.menu_book,
                  degree: 'Intermediate — Class XII  ·  CBSE Board',
                  institution: 'Vidya Bhavan Public School, Bareilly',
                  year: '2022',
                  badge: '95.4%',
                  theme: theme,
                  accent: accent,
                ),
                const SizedBox(height: 16),
                // High School
                _EducationCard(
                  icon: Icons.auto_stories,
                  degree: 'High School — Class X  ·  CBSE Board',
                  institution: 'Vidya Bhavan Public School, Bareilly',
                  year: '2020',
                  badge: '95.2%',
                  theme: theme,
                  accent: accent,
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Journey Timeline
            Text('Journey', style: TextStyle(color: theme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const _JourneyTimeline(),
          ],
        ),
      ),
    );
  }
}

class _JourneyTimeline extends ConsumerWidget {
  const _JourneyTimeline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    final milestones = [
      {'year': '2023', 'title': 'Started B.Tech', 'desc': 'Began Computer Science (Data Science) at AKGEC.'},
      {'year': '2024', 'title': 'Blockchain Research Lab', 'desc': 'Joined BRL as a Flutter Developer, working on real-time communication.'},
      {'year': '2025', 'title': 'Neenva Innovations', 'desc': 'Interned as a Frontend App Developer, architecting ViiSar components.'},
      {'year': '2025', 'title': 'Nirvighna Services', 'desc': 'Joined KaamDhanda as a Flutter App Developer Intern.'},
    ];

    return Column(
      children: List.generate(milestones.length, (index) {
        final isLast = index == milestones.length - 1;
        final milestone = milestones[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 80,
                    color: accent.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone['year']!,
                      style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      milestone['title']!,
                      style: TextStyle(color: theme.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      milestone['desc']!,
                      style: TextStyle(color: theme.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable Education Card
// ─────────────────────────────────────────────
class _EducationCard extends StatelessWidget {
  final IconData icon;
  final String degree;
  final String institution;
  final String year;
  final String badge;
  final dynamic theme;
  final Color accent;

  const _EducationCard({
    required this.icon,
    required this.degree,
    required this.institution,
    required this.year,
    required this.badge,
    required this.theme,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  degree,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  institution,
                  style: TextStyle(color: theme.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  year,
                  style: TextStyle(color: accent, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


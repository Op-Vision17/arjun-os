import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../domain/providers/projects_provider.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/core/presentation/responsive_layout.dart';

class ProjectsApp extends ConsumerWidget {
  const ProjectsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWindowNarrow = constraints.maxWidth < 700;

        Widget content = Row(
          children: [
            // Left Panel: Project List
            Container(
              width: 250,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: theme.borderColor, width: 1)),
              ),
              child: const _ProjectList(isHorizontal: false),
            ),
            // Right Panel: Project Details
            const Expanded(
              child: _ProjectDetails(),
            ),
          ],
        );

        if (isWindowNarrow) {
          content = Column(
            children: [
              SizedBox(
                height: 120,
                child: const _ProjectList(isHorizontal: true),
              ),
              const Expanded(
                child: _ProjectDetails(),
              ),
            ],
          );
        }

        return Container(
          color: theme.panelBackground,
          child: content,
        );
      }
    );
  }
}

class _ProjectList extends ConsumerWidget {
  final bool isHorizontal;
  const _ProjectList({this.isHorizontal = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final selectedProject = ref.watch(selectedProjectProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final isSelected = selectedProject?.id == project.id;

        return Padding(
          padding: isHorizontal ? const EdgeInsets.only(right: 8.0) : const EdgeInsets.only(bottom: 8.0),
          child: SizedBox(
            width: isHorizontal ? 180 : null,
            child: _ProjectTile(
              project: project,
              isSelected: isSelected,
              onTap: () {
                ref.read(selectedProjectProvider.notifier).setProject(project);
              },
            ),
          ),
        );
      },
    );
  }
}

class _ProjectTile extends ConsumerStatefulWidget {
  final Project project;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProjectTile({
    super.key,
    required this.project,
    required this.isSelected,
    required this.onTap,
  });

  @override
  ConsumerState<_ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends ConsumerState<_ProjectTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(osThemeProvider);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.cardBackground
                : _isHovered
                    ? theme.textColor.withValues(alpha: 0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          transform: Matrix4.translationValues(0, _isHovered && !widget.isSelected ? -2 : 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.project.name,
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.project.tagline,
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectDetails extends ConsumerWidget {
  const _ProjectDetails();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final project = ref.watch(selectedProjectProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: project == null
          ? Center(
              child: Text('Select a project to view details', style: TextStyle(color: theme.textMuted)),
            )
          : _ProjectDetailView(key: ValueKey(project.id), project: project),
    );
  }
}

class _ProjectDetailView extends ConsumerStatefulWidget {
  final Project project;

  const _ProjectDetailView({super.key, required this.project});

  @override
  ConsumerState<_ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends ConsumerState<_ProjectDetailView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.project.name,
            style: TextStyle(color: theme.textColor, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.project.tagline,
            style: TextStyle(color: accent, fontSize: 18),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.project.techStack.map((tech) {
              return Chip(
                label: Text(tech, style: TextStyle(color: theme.textColor, fontSize: 12)),
                backgroundColor: theme.cardBackground,
                side: BorderSide.none,
              );
            }).toList(),
          ),
          if (widget.project.screenshots.isNotEmpty) ...[
            const SizedBox(height: 32),
            // Mobile Screenshot Slider
            SizedBox(
              height: 480,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: widget.project.screenshots.length,
                separatorBuilder: (context, index) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  return AspectRatio(
                    aspectRatio: 9 / 19.5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: theme.textColor.withValues(alpha: 0.1),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          widget.project.screenshots[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: accent,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.cardBackground,
                              child: Icon(Icons.broken_image, color: theme.textMuted),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
          Text('Challenge', style: TextStyle(color: theme.textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.project.challenge, style: TextStyle(color: theme.textMuted, fontSize: 16, height: 1.5)),
          const SizedBox(height: 24),
          Text('Solution', style: TextStyle(color: theme.textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.project.solution, style: TextStyle(color: theme.textMuted, fontSize: 16, height: 1.5)),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ...widget.project.githubRepos.map((repo) {
                return _LinkButton(
                  label: repo.name,
                  icon: repo.name.toLowerCase().contains('backend') 
                      ? Icons.storage 
                      : repo.name.toLowerCase().contains('frontend') 
                          ? Icons.web 
                          : Icons.code,
                  url: repo.url,
                  color: theme.textColor.withValues(alpha: 0.1),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkButton extends ConsumerWidget {
  final String label;
  final IconData icon;
  final String url;
  final Color color;
  final bool isPrimary;

  const _LinkButton({
    required this.label,
    required this.icon,
    required this.url,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);

    return ElevatedButton.icon(
      onPressed: () => web.window.open(url, '_blank'),
      icon: Icon(icon, color: isPrimary ? theme.panelBackground : theme.textColor, size: 18),
      label: Text(label, style: TextStyle(color: isPrimary ? theme.panelBackground : theme.textColor)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: isPrimary ? theme.panelBackground : theme.textColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

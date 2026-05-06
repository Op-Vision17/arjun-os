import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/config/theme/models/os_theme.dart';
import 'package:arjun_os/core/presentation/responsive_layout.dart';

class SelectedSkillCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  void setCategory(String cat) => state = cat;
}

final selectedSkillCategoryProvider = NotifierProvider<SelectedSkillCategoryNotifier, String>(() => SelectedSkillCategoryNotifier());

class Skill {
  final String name;
  final String category;

  Skill(this.name, this.category);
}

final skillsProvider = Provider<List<Skill>>((ref) {
  return [
    // Languages
    Skill('Python', 'Languages'),
    Skill('Dart', 'Languages'),
    Skill('JavaScript', 'Languages'),
    Skill('Java', 'Languages'),
    Skill('C', 'Languages'),
    Skill('SQL', 'Languages'),
    Skill('HTML/CSS', 'Languages'),

    // Frameworks
    Skill('Flutter', 'Frameworks'),
    Skill('FastAPI', 'Frameworks'),
    Skill('Node.js', 'Frameworks'),
    Skill('Express.js', 'Frameworks'),
    Skill('Streamlit', 'Frameworks'),
    Skill('Flask', 'Frameworks'),

    // AI & ML
    Skill('CrewAI', 'AI & ML'),
    Skill('LangChain', 'AI & ML'),
    Skill('LangGraph', 'AI & ML'),
    Skill('RAG', 'AI & ML'),
    Skill('LLM', 'AI & ML'),
    Skill('Pinecone', 'AI & ML'),
    Skill('Machine Learning', 'AI & ML'),
    Skill('Scikit-learn', 'AI & ML'),
    Skill('TensorFlow', 'AI & ML'),
    Skill('Keras', 'AI & ML'),
    Skill('Groq', 'AI & ML'),

    // Backend & Cloud
    Skill('REST API', 'Backend & Cloud'),
    Skill('Socket.io', 'Backend & Cloud'),
    Skill('Firebase', 'Backend & Cloud'),
    Skill('Redis', 'Backend & Cloud'),
    Skill('Heroku', 'Backend & Cloud'),
    Skill('SQLAlchemy', 'Backend & Cloud'),

    // State Management
    Skill('Riverpod', 'State Management'),

    // Tools
    Skill('Git', 'Tools'),
    Skill('CI/CD', 'Tools'),
    Skill('Agile', 'Tools'),
    Skill('VS Code', 'Tools'),
    Skill('Android Studio', 'Tools'),
    Skill('Postman', 'Tools'),
    Skill('Jupyter Notebook', 'Tools'),
  ];
});

class SkillsApp extends ConsumerWidget {
  const SkillsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);
    final isMobile = ResponsiveLayout.isMobile(context);
    final categories = ['All', 'Languages', 'Frameworks', 'Backend & Cloud', 'State Management', 'AI & ML', 'Tools'];
    final selectedCategory = ref.watch(selectedSkillCategoryProvider);
    final allSkills = ref.watch(skillsProvider);
    
    final filteredSkills = selectedCategory == 'All'
        ? allSkills
        : allSkills.where((s) => s.category == selectedCategory).toList();

    Widget leftPanelContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Filter Skills', style: TextStyle(color: theme.textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Select a category to refine the list', style: TextStyle(color: theme.textMuted, fontSize: 13)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = cat == selectedCategory;
            return ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.black : theme.textColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: accent,
              backgroundColor: theme.cardBackground,
              side: BorderSide(color: isSelected ? accent : theme.borderColor),
              onSelected: (_) {
                ref.read(selectedSkillCategoryProvider.notifier).setCategory(cat);
              },
            );
          }).toList(),
        ),
      ],
    );

    Widget skillsGrid = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Technical Proficiency', style: TextStyle(color: theme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: filteredSkills.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              return _SkillCard(skill: skill);
            }).toList(),
          ),
        ],
      ),
    );

    return Container(
      color: theme.panelBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWindowNarrow = constraints.maxWidth < 800;
          
          if (isWindowNarrow) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 16 : 24),
                    child: leftPanelContent,
                  ),
                  skillsGrid,
                ],
              ),
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: theme.borderColor, width: 1)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: leftPanelContent,
                  ),
                ),
                Expanded(
                  child: skillsGrid,
                ),
              ],
            );
          }
        }
      ),
    );
  }
}

class _SkillCard extends ConsumerStatefulWidget {
  final Skill skill;
  const _SkillCard({required this.skill});

  @override
  ConsumerState<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends ConsumerState<_SkillCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _isHovered ? accent.withValues(alpha: 0.2) : theme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? accent : theme.borderColor,
            width: 1.5,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: accent.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForCategory(widget.skill.category),
              size: 20,
              color: _isHovered ? accent : theme.textMuted,
            ),
            const SizedBox(width: 12),
            Text(
              widget.skill.name,
              style: TextStyle(
                color: theme.textColor,
                fontSize: 15,
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ).animate(key: ValueKey(widget.skill.name)).fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutCubic),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Languages': return Icons.code;
      case 'Frameworks': return Icons.architecture;
      case 'Backend & Cloud': return Icons.cloud;
      case 'State Management': return Icons.account_tree;
      case 'AI & ML': return Icons.psychology;
      case 'Tools': return Icons.build;
      default: return Icons.bolt;
    }
  }
}



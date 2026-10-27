import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import '../../window_manager/domain/providers/window_manager_notifier.dart';

enum ResumeType {
  all(
    id: 'all',
    title: 'General (All-Round)',
    shortTitle: 'General',
    subtitle: 'Full-Stack & Software Engineering',
    icon: Icons.article_outlined,
    fileId: '1ZtE2VPK-WafbU0AAE_fy0dAtJ-3N-OxZ',
    fileName: 'arjun_Resume.pdf',
  ),
  flutter(
    id: 'flutter',
    title: 'Flutter Specialist',
    shortTitle: 'Flutter',
    subtitle: 'Flutter & Cross-Platform Mobile Specialist',
    icon: Icons.flutter_dash,
    fileId: '1HAiliy1o21Ysi93et-xogw78vbhTPGXQ',
    fileName: 'arjun_Resume_flutter.pdf',
  );

  final String id;
  final String title;
  final String shortTitle;
  final String subtitle;
  final IconData icon;
  final String fileId;
  final String fileName;

  const ResumeType({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.subtitle,
    required this.icon,
    required this.fileId,
    required this.fileName,
  });

  String get previewUrl => 'https://drive.google.com/file/d/$fileId/preview';
  String get viewUrl => 'https://drive.google.com/file/d/$fileId/view?usp=sharing';
  String get downloadUrl => 'https://drive.google.com/uc?export=download&id=$fileId';
  String get viewType => 'resume-$id-iframe';
}

class ResumeApp extends ConsumerStatefulWidget {
  final String windowId;
  final ResumeType? initialType;
  const ResumeApp({super.key, required this.windowId, this.initialType});

  @override
  ConsumerState<ResumeApp> createState() => _ResumeAppState();
}

class _ResumeAppState extends ConsumerState<ResumeApp> {
  static final Set<String> _registeredViews = {};
  late ResumeType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? ResumeType.all;
    _registerViewFactories();
  }

  void _registerViewFactories() {
    for (final type in ResumeType.values) {
      if (!_registeredViews.contains(type.viewType)) {
        try {
          ui_web.platformViewRegistry.registerViewFactory(type.viewType, (int viewId) {
            final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement
              ..src = type.previewUrl
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%'
              ..setAttribute('allow', 'fullscreen')
              ..title = type.title;
            return iframe;
          });
          _registeredViews.add(type.viewType);
        } catch (_) {
          // Ignore for non-web environments or already registered
        }
      }
    }
  }

  void _downloadPdf() {
    try {
      web.window.open(_selectedType.downloadUrl, '_blank');
    } catch (_) {
      // Fallback
    }
  }

  void _openInDrive() {
    try {
      web.window.open(_selectedType.viewUrl, '_blank');
    } catch (_) {
      // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    return Container(
      color: theme.panelBackground,
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.panelBackground,
              border: Border(bottom: BorderSide(color: theme.borderColor, width: 1)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 680;
                final isVeryNarrow = constraints.maxWidth < 480;

                return Row(
                  children: [
                    // Resume Segmented Selection
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: ResumeType.values.map((type) {
                            final isSelected = type == _selectedType;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  if (_selectedType != type) {
                                    setState(() => _selectedType = type);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isCompact ? 10 : 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? accent.withValues(alpha: 0.18)
                                        : theme.cardBackground.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? accent
                                          : theme.borderColor.withValues(alpha: 0.5),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        type.icon,
                                        size: isCompact ? 16 : 18,
                                        color: isSelected ? accent : theme.textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isCompact ? type.shortTitle : type.title,
                                        style: TextStyle(
                                          color: isSelected ? theme.textColor : theme.textMuted,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          fontSize: isCompact ? 12 : 13,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: accent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Open in Google Drive
                        if (!isVeryNarrow)
                          Tooltip(
                            message: 'Open in Google Drive',
                            child: OutlinedButton.icon(
                              onPressed: _openInDrive,
                              icon: const Icon(Icons.open_in_new_rounded, size: 15),
                              label: Text(
                                isCompact ? 'Drive' : 'Open in Drive',
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.textColor,
                                side: BorderSide(color: theme.borderColor),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: _openInDrive,
                            icon: Icon(Icons.open_in_new_rounded, color: theme.textColor, size: 18),
                            tooltip: 'Open in Google Drive',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),

                        const SizedBox(width: 8),

                        // Download PDF Button
                        ElevatedButton.icon(
                          onPressed: _downloadPdf,
                          icon: Icon(Icons.download_rounded, color: theme.panelBackground, size: 16),
                          label: Text(
                            isCompact ? 'Download' : 'Download PDF',
                            style: TextStyle(
                              color: theme.panelBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 10 : 14,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                          ),
                        ),

                        // Maximize / Full Screen (Desktop only)
                        if (MediaQuery.of(context).size.width >= 600) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              ref.read(windowManagerProvider.notifier).maximizeWindow(widget.windowId);
                            },
                            icon: Icon(Icons.fullscreen, color: theme.textColor, size: 20),
                            tooltip: 'Full Screen',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // Sub-bar showing active resume details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.cardBackground.withValues(alpha: 0.2),
              border: Border(bottom: BorderSide(color: theme.borderColor.withValues(alpha: 0.4))),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 13, color: theme.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_selectedType.title} • ${_selectedType.subtitle}',
                    style: TextStyle(
                      color: theme.textMuted,
                      fontSize: 11,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Google Drive',
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PDF Viewer Area
          Expanded(
            child: Container(
              color: theme.cardBackground,
              child: Stack(
                children: [
                  // Loading background / fallback placeholder
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Loading ${_selectedType.shortTitle} Resume…',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rendering via Google Drive viewer',
                          style: TextStyle(
                            color: theme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Iframes for each resume
                  IndexedStack(
                    index: _selectedType.index,
                    children: ResumeType.values.map((type) {
                      return HtmlElementView(
                        key: ValueKey(type.viewType),
                        viewType: type.viewType,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

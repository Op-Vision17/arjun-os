import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import '../../window_manager/domain/providers/window_manager_notifier.dart';

class ResumeApp extends ConsumerStatefulWidget {
  final String windowId;
  const ResumeApp({super.key, required this.windowId});

  @override
  ConsumerState<ResumeApp> createState() => _ResumeAppState();
}

class _ResumeAppState extends ConsumerState<ResumeApp> {
  final String _viewType = 'resume-pdf-iframe';

  @override
  void initState() {
    super.initState();
    // Register the IFrame
    try {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement
          ..src = 'https://arjun-resume.pages.dev/arjun_Resume.pdf'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });
    } catch (e) {
      // Ignore errors for non-web environments
    }
  }

  void _downloadPdf() {
    web.window.open('https://arjun-resume.pages.dev/arjun_Resume.pdf', '_blank');
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _downloadPdf,
                  icon: Icon(Icons.download, color: theme.panelBackground),
                  label: Text('Download', style: TextStyle(color: theme.panelBackground)),
                  style: ElevatedButton.styleFrom(backgroundColor: accent),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    ref.read(windowManagerProvider.notifier).maximizeWindow(widget.windowId);
                  },
                  icon: Icon(Icons.fullscreen, color: theme.textColor),
                  tooltip: 'Full Screen',
                ),
              ],
            ),
          ),
          // PDF Viewer
          Expanded(
            child: Container(
              color: theme.cardBackground,
              child: const HtmlElementView(viewType: 'resume-pdf-iframe'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:arjun_os/config/theme/providers/theme_providers.dart';
import 'package:arjun_os/core/presentation/responsive_layout.dart';
import 'package:arjun_os/features/notifications/presentation/notification_system.dart';

@JS('sendEmail')
external JSPromise<JSAny> sendEmailJS(
  JSString name,
  JSString email,
  JSString message,
  JSString time,
);

class ContactApp extends ConsumerStatefulWidget {
  const ContactApp({super.key});

  @override
  ConsumerState<ContactApp> createState() => _ContactAppState();
}

class _ContactAppState extends ConsumerState<ContactApp> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _isSending = false;

  Future<void> _send() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);

      try {
        final time = DateTime.now().toLocal().toString();

        await sendEmailJS(
          _nameCtrl.text.toJS,
          _emailCtrl.text.toJS,
          _msgCtrl.text.toJS,
          time.toJS,
        ).toDart;

        // If no exception thrown = success
        ref
            .read(notificationProvider.notifier)
            .show(
              title: 'Message Sent ✓',
              message: 'Thanks ${_nameCtrl.text}! I will get back to you soon.',
              icon: Icons.check_circle,
            );
        _nameCtrl.clear();
        _emailCtrl.clear();
        _msgCtrl.clear();
      } catch (e) {
        ref
            .read(notificationProvider.notifier)
            .show(
              title: 'Send Failed',
              message: 'Could not send. Email me at guptaarjun1711@gmail.com',
              icon: Icons.error,
            );
      } finally {
        if (mounted) setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);
    return Container(
      color: theme.panelBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWindowNarrow = constraints.maxWidth < 750;

          Widget leftPanel = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get in Touch',
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: isWindowNarrow ? 24 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Feel free to reach out for collaborations or just a friendly chat.',
                style: TextStyle(color: theme.textMuted, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _SocialLink(
                icon: Icons.email,
                text: 'guptaarjun1711@gmail.com',
                onTap: () =>
                    web.window.open('mailto:guptaarjun1711@gmail.com', '_self'),
              ),
              const SizedBox(height: 16),
              _SocialLink(
                icon: Icons.code,
                text: 'GitHub',
                onTap: () =>
                    web.window.open('https://github.com/Op-Vision17', '_blank'),
              ),
              const SizedBox(height: 16),
              _SocialLink(
                icon: Icons.work,
                text: 'LinkedIn',
                onTap: () => web.window.open(
                  'https://www.linkedin.com/in/arjun-gupta1711',
                  '_blank',
                ),
              ),
            ],
          );

          Widget rightPanel = Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.borderColor),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    style: TextStyle(color: theme.textColor),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: theme.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: accent),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    style: TextStyle(color: theme.textColor),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: theme.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: accent),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _msgCtrl,
                    style: TextStyle(color: theme.textColor),
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      labelStyle: TextStyle(color: theme.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: accent),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSending ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: accent.withValues(alpha: 0.5),
                    ),
                    child: _isSending
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.panelBackground,
                              ),
                            ),
                          )
                        : Text(
                            'Send Message',
                            style: TextStyle(
                              color: theme.panelBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              ResponsiveLayout.isMobile(context) ? 16 : 32,
            ),
            child: isWindowNarrow
                ? Column(
                    children: [
                      leftPanel,
                      const SizedBox(height: 48),
                      rightPanel,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: leftPanel),
                      const SizedBox(width: 48),
                      Expanded(flex: 2, child: rightPanel),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _SocialLink extends ConsumerWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SocialLink({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(osThemeProvider);
    final accent = ref.watch(accentColorProvider);

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 16),
          Text(text, style: TextStyle(color: theme.textColor, fontSize: 16)),
        ],
      ),
    );
  }
}

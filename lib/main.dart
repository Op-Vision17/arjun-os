import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: ArjunOSApp(),
    ),
  );

  // Remove HTML loader after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final loader = web.document.querySelector('#loading');
    loader?.remove();
  });
}

class ArjunOSApp extends ConsumerWidget {
  const ArjunOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ArjunOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

typedef LibraryLoader = Future<void> Function();

class DeferredLoader extends StatefulWidget {
  final LibraryLoader loader;
  final WidgetBuilder builder;

  const DeferredLoader({
    super.key,
    required this.loader,
    required this.builder,
  });

  @override
  State<DeferredLoader> createState() => _DeferredLoaderState();
}

class _DeferredLoaderState extends State<DeferredLoader> {
  bool _isLoaded = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await widget.loader();
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Text(
          'Failed to load application: $_error',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (!_isLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 2),
            ).animate(onPlay: (controller) => controller.repeat())
             .rotate(duration: 2.seconds),
            const SizedBox(height: 16),
            const Text(
              'Loading App...',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return widget.builder(context);
  }
}

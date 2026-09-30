import 'package:flutter/material.dart';

typedef LibraryLoader = Future<void> Function();

class DeferredLoader extends StatelessWidget {
  final LibraryLoader? loader;
  final WidgetBuilder builder;

  const DeferredLoader({
    super.key,
    this.loader,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';

class SitharaApp extends ConsumerWidget {
  const SitharaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Sithara',
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}

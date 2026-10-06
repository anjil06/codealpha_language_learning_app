import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/services/app_providers.dart';
import 'routes.dart';
import 'theme.dart';

class LinguaLearnApp extends ConsumerStatefulWidget {
  const LinguaLearnApp({super.key});

  @override
  ConsumerState<LinguaLearnApp> createState() => _LinguaLearnAppState();
}

class _LinguaLearnAppState extends ConsumerState<LinguaLearnApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _router = createRouter(storage);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}


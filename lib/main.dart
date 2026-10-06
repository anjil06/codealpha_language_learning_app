import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/app_providers.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';
import 'repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize SharedPreferences storage service
  final storageService = await StorageService.init();

  // Initialize Firebase (safely handles offline / unconfigured environments)
  await FirebaseService.initialize();

  // Pre-load saved user
  final authRepo = AuthRepository(storageService);
  await authRepo.loadSavedUser();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const LinguaLearnApp(),
    ),
  );
}

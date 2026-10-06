import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/storage_service.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/flashcards/flashcards_screen.dart';
import '../features/grammar/grammar_detail_screen.dart';
import '../features/grammar/grammar_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/language_selection_screen.dart';
import '../features/learn/learn_hub_screen.dart';
import '../features/lessons/lesson_detail_screen.dart';
import '../features/lessons/lessons_screen.dart';
import '../features/main_layout/main_navigation_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/practice/practice_hub_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/settings_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/pronunciation/pronunciation_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/vocabulary/vocabulary_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(StorageService storageService) {
  final initialLocation = storageService.isOnboardingCompleted ? '/home' : '/onboarding';

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Standalone modal / detail routes pushed on top of root navigator
      GoRoute(
        path: '/language-select',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/lessons',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LessonsScreen(),
      ),
      GoRoute(
        path: '/lessons/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'l1';
          return LessonDetailScreen(lessonId: id);
        },
      ),
      GoRoute(
        path: '/vocabulary',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VocabularyScreen(),
      ),
      GoRoute(
        path: '/grammar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GrammarScreen(),
      ),
      GoRoute(
        path: '/grammar/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'g1';
          return GrammarDetailScreen(grammarId: id);
        },
      ),
      GoRoute(
        path: '/flashcards',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FlashcardsScreen(),
      ),
      GoRoute(
        path: '/pronunciation',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PronunciationScreen(),
      ),
      GoRoute(
        path: '/quiz/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'q1';
          return QuizScreen(quizId: id);
        },
      ),

      // 5-branch StatefulShellRoute for Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Learn
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearnHubScreen(),
              ),
            ],
          ),
          // Branch 2: Practice
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/practice',
                builder: (context, state) => const PracticeHubScreen(),
              ),
            ],
          ),
          // Branch 3: Progress
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}


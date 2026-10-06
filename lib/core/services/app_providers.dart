import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';
import 'tts_service.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/lesson_repository.dart';
import '../../repositories/vocabulary_repository.dart';
import '../../repositories/quiz_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../models/user_model.dart';
import '../../models/progress_model.dart';
import '../../models/lesson_model.dart';
import '../../models/vocabulary_model.dart';
import '../../models/grammar_model.dart';
import '../../models/quiz_model.dart';
import '../../models/language_model.dart';

// Service Providers (initialized in main.dart via override)
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in ProviderScope');
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final tts = TtsService();
  ref.onDispose(() => tts.dispose());
  return tts;
});

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthRepository(storage);
});

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository();
});

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepository();
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository();
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final auth = ref.watch(authRepositoryProvider);
  return ProgressRepository(storage, auth);
});

// App Settings & State Notifiers using Riverpod Notifier

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    ref.read(storageServiceProvider).setDarkMode(!isDark);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class SelectedLanguageNotifier extends Notifier<String> {
  @override
  String build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.selectedLanguage;
  }

  Future<void> setLanguage(String languageId) async {
    state = languageId;
    await ref.read(storageServiceProvider).setSelectedLanguage(languageId);
  }
}

final selectedLanguageProvider =
    NotifierProvider<SelectedLanguageNotifier, String>(SelectedLanguageNotifier.new);

// Current User State Notifier
class UserStateNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    final authRepo = ref.watch(authRepositoryProvider);
    return authRepo.currentUser;
  }

  void setUser(UserModel? user) {
    state = user;
  }

  Future<void> refresh() async {
    final authRepo = ref.read(authRepositoryProvider);
    state = authRepo.currentUser;
  }
}

final userStateProvider = NotifierProvider<UserStateNotifier, UserModel?>(UserStateNotifier.new);

// Progress State Provider
final progressProvider = FutureProvider<ProgressModel>((ref) async {
  final user = ref.watch(userStateProvider);
  final progressRepo = ref.watch(progressRepositoryProvider);
  final userId = user?.id ?? 'anjil_demo_id';
  return progressRepo.getProgress(userId);
});

// Lessons Future Provider
final lessonsProvider = FutureProvider<List<LessonModel>>((ref) async {
  final lang = ref.watch(selectedLanguageProvider);
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getLessons(languageId: lang);
});

// Grammar Future Provider
final grammarProvider = FutureProvider<List<GrammarModel>>((ref) async {
  final lang = ref.watch(selectedLanguageProvider);
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getGrammarLessons(languageId: lang);
});

// Vocabulary Provider
final vocabularyProvider =
    FutureProvider.family<List<VocabularyModel>, String?>((ref, category) async {
  final lang = ref.watch(selectedLanguageProvider);
  final repo = ref.watch(vocabularyRepositoryProvider);
  return repo.getVocabulary(languageId: lang, category: category);
});

// Quizzes Provider
final quizzesProvider = FutureProvider<List<QuizModel>>((ref) async {
  final lang = ref.watch(selectedLanguageProvider);
  final repo = ref.watch(quizRepositoryProvider);
  return repo.getQuizzes(languageId: lang);
});

// Selected Language Model
final currentLanguageModelProvider = Provider<LanguageModel>((ref) {
  final langId = ref.watch(selectedLanguageProvider);
  return LanguageModel.supportedLanguages.firstWhere(
    (l) => l.id == langId,
    orElse: () => LanguageModel.supportedLanguages.first,
  );
});


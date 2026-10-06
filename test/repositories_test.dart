import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingualearn/core/services/storage_service.dart';
import 'package:lingualearn/repositories/auth_repository.dart';
import 'package:lingualearn/repositories/lesson_repository.dart';
import 'package:lingualearn/repositories/vocabulary_repository.dart';
import 'package:lingualearn/repositories/quiz_repository.dart';
import 'package:lingualearn/repositories/progress_repository.dart';

void main() {
  late StorageService storageService;
  late AuthRepository authRepository;
  late LessonRepository lessonRepository;
  late VocabularyRepository vocabularyRepository;
  late QuizRepository quizRepository;
  late ProgressRepository progressRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    authRepository = AuthRepository(storageService);
    await authRepository.loadSavedUser();
    lessonRepository = LessonRepository();
    vocabularyRepository = VocabularyRepository();
    quizRepository = QuizRepository();
    progressRepository = ProgressRepository(storageService, authRepository);
  });

  group('Repository Functional Tests', () {
    test('LessonRepository returns populated lessons and grammar', () async {
      final lessons = await lessonRepository.getLessons(languageId: 'spanish');
      expect(lessons.length, greaterThanOrEqualTo(5));

      final grammar = await lessonRepository.getGrammarLessons(languageId: 'spanish');
      expect(grammar.length, greaterThanOrEqualTo(3));
    });

    test('VocabularyRepository filters by category and creates flashcard deck', () async {
      final allVocab = await vocabularyRepository.getVocabulary(languageId: 'spanish');
      expect(allVocab.length, greaterThanOrEqualTo(20));

      final greetings = await vocabularyRepository.getVocabulary(
        languageId: 'spanish',
        category: 'Greetings',
      );
      expect(greetings.every((v) => v.category == 'Greetings'), isTrue);

      final deck = vocabularyRepository.getFlashcardDeck(languageId: 'spanish', limit: 10);
      expect(deck.length, 10);
    });

    test('QuizRepository returns quizzes with 10 questions each', () async {
      final quizzes = await quizRepository.getQuizzes(languageId: 'spanish');
      expect(quizzes.length, greaterThanOrEqualTo(3));

      for (final quiz in quizzes) {
        expect(quiz.questions.length, 10);
      }
    });

    test('ProgressRepository awards XP and updates level', () async {
      final user = authRepository.currentUser!;
      final initialXp = user.xp;

      await progressRepository.recordQuizCompleted(
        quizId: 'q1',
        scorePercent: 90,
        wordsCount: 5,
      );

      final updatedUser = authRepository.currentUser!;
      expect(updatedUser.xp, greaterThan(initialXp));
      expect(updatedUser.wordsLearned, user.wordsLearned + 5);
    });
  });
}


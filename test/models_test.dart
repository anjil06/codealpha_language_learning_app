import 'package:flutter_test/flutter_test.dart';
import 'package:lingualearn/core/constants/app_constants.dart';
import 'package:lingualearn/models/language_model.dart';
import 'package:lingualearn/models/lesson_model.dart';
import 'package:lingualearn/models/progress_model.dart';
import 'package:lingualearn/models/quiz_model.dart';
import 'package:lingualearn/models/user_model.dart';
import 'package:lingualearn/models/vocabulary_model.dart';

void main() {
  group('Gamification and Level Calculations', () {
    test('Calculates level correctly based on XP thresholds', () {
      expect(AppConstants.calculateLevel(50), 1);
      expect(AppConstants.getLevelTitle(1), 'Beginner');

      expect(AppConstants.calculateLevel(150), 2);
      expect(AppConstants.getLevelTitle(2), 'Explorer');

      expect(AppConstants.calculateLevel(300), 3);
      expect(AppConstants.getLevelTitle(3), 'Learner');

      expect(AppConstants.calculateLevel(600), 4);
      expect(AppConstants.getLevelTitle(4), 'Speaker');

      expect(AppConstants.calculateLevel(1000), 5);
      expect(AppConstants.getLevelTitle(5), 'Fluent Starter');
    });

    test('Calculates level progress accurately', () {
      expect(AppConstants.getLevelProgress(50), 0.5);
      expect(AppConstants.getLevelProgress(1000), 1.0);
    });
  });

  group('Model Serialization Tests', () {
    test('UserModel serialization and deserialization', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'u123',
        name: 'Anjil',
        email: 'anjil@test.com',
        learningLanguage: 'Spanish',
        xp: 120,
        level: 2,
        streak: 7,
        dailyGoal: 10,
        lessonsCompleted: 8,
        wordsLearned: 30,
        createdAt: now,
      );

      final json = user.toJson();
      final fromJson = UserModel.fromJson(json);

      expect(fromJson.id, user.id);
      expect(fromJson.name, user.name);
      expect(fromJson.email, user.email);
      expect(fromJson.learningLanguage, user.learningLanguage);
      expect(fromJson.xp, user.xp);
      expect(fromJson.level, user.level);
    });

    test('VocabularyModel JSON serialization', () {
      const vocab = VocabularyModel(
        id: 'v1',
        languageId: 'spanish',
        category: 'Greetings',
        word: 'Hola',
        translation: 'Hello',
        pronunciation: 'oh-la',
        exampleSentence: 'Hola amigo',
      );

      final json = vocab.toJson();
      final fromJson = VocabularyModel.fromJson(json);

      expect(fromJson.word, 'Hola');
      expect(fromJson.translation, 'Hello');
      expect(fromJson.pronunciation, 'oh-la');
    });

    test('QuizModel and QuizResultModel accuracy calculation', () {
      final result = QuizResultModel(
        quizId: 'q1',
        quizTitle: 'Greetings Quiz',
        totalQuestions: 10,
        correctCount: 8,
        wrongCount: 2,
        xpEarned: 30,
        wordsLearned: 5,
        currentStreak: 5,
        recommendedLesson: 'Lesson 2',
        completedAt: DateTime(2026, 10, 6),
      );

      expect(result.accuracy, 80.0);
      expect(result.isPassed, true);
    });

    test('LanguageModel supported languages list contains required languages', () {
      final langs = LanguageModel.supportedLanguages;
      final names = langs.map((l) => l.name).toList();

      expect(names, contains('Spanish'));
      expect(names, contains('French'));
      expect(names, contains('German'));
      expect(names, contains('Japanese'));
      expect(names, contains('Korean'));
      expect(names, contains('Hindi'));
      expect(names, contains('Telugu'));
    });
  });
}

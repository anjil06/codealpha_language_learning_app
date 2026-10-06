import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/services/firebase_service.dart';
import '../core/services/storage_service.dart';
import '../models/progress_model.dart';
import 'auth_repository.dart';

class ProgressRepository {
  final StorageService _storageService;
  final AuthRepository _authRepository;

  ProgressRepository(this._storageService, this._authRepository);

  ProgressModel? _currentProgress;
  ProgressModel? get currentProgress => _currentProgress;

  Future<ProgressModel> getProgress(String userId) async {
    // 1. Check in-memory
    if (_currentProgress != null && _currentProgress!.userId == userId) {
      return _currentProgress!;
    }

    // 2. Check local SharedPreferences cache
    final cached = _storageService.getCachedProgress(userId);
    if (cached != null) {
      _currentProgress = cached;
      return cached;
    }

    // 3. Check Firestore
    final firestore = FirebaseService.firestore;
    if (firestore != null) {
      try {
        final doc = await firestore.collection('userProgress').doc(userId).get();
        if (doc.exists && doc.data() != null) {
          final progress = ProgressModel.fromJson(doc.data()!);
          _currentProgress = progress;
          await _storageService.saveProgressCache(progress);
          return progress;
        }
      } catch (e) {
        debugPrint('Firestore fetch progress error: $e');
      }
    }

    // Default initial progress
    final initial = ProgressModel(
      userId: userId,
      completedLessons: ['l1'],
      learnedWords: ['v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'v7', 'v8'],
      completedGrammar: ['g1'],
      quizScores: {'q1': 90},
      streak: 5,
      lastActiveDate: DateTime.now(),
      weeklyActivity: {
        'Mon': 25,
        'Tue': 35,
        'Wed': 15,
        'Thu': 30,
        'Fri': 45,
        'Sat': 20,
        'Sun': 10,
      },
      achievements: ProgressModel.defaultAchievements,
    );

    _currentProgress = initial;
    await _storageService.saveProgressCache(initial);
    return initial;
  }

  Future<void> addXpAndSync(int addedXp, {int wordsDelta = 0, int lessonsDelta = 0}) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    final newXp = user.xp + addedXp;
    final newLevel = AppConstants.calculateLevel(newXp);
    final updatedUser = user.copyWith(
      xp: newXp,
      level: newLevel,
      wordsLearned: user.wordsLearned + wordsDelta,
      lessonsCompleted: user.lessonsCompleted + lessonsDelta,
    );

    await _authRepository.updateUser(updatedUser);
  }

  Future<void> recordLessonCompleted(String lessonId) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    final progress = await getProgress(user.id);
    if (!progress.completedLessons.contains(lessonId)) {
      final updatedList = List<String>.from(progress.completedLessons)..add(lessonId);
      final updatedProgress = progress.copyWith(
        completedLessons: updatedList,
        lastActiveDate: DateTime.now(),
      );
      _currentProgress = updatedProgress;
      await _storageService.saveProgressCache(updatedProgress);
      await _syncToFirestore(updatedProgress);
      await addXpAndSync(AppConstants.xpPerLesson, lessonsDelta: 1);
    }
  }

  Future<void> recordGrammarCompleted(String grammarId) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    final progress = await getProgress(user.id);
    if (!progress.completedGrammar.contains(grammarId)) {
      final updatedList = List<String>.from(progress.completedGrammar)..add(grammarId);
      final updatedProgress = progress.copyWith(
        completedGrammar: updatedList,
        lastActiveDate: DateTime.now(),
      );
      _currentProgress = updatedProgress;
      await _storageService.saveProgressCache(updatedProgress);
      await _syncToFirestore(updatedProgress);
      await addXpAndSync(AppConstants.xpPerGrammarLesson);
    }
  }

  Future<void> recordWordLearned(String wordId) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    final progress = await getProgress(user.id);
    if (!progress.learnedWords.contains(wordId)) {
      final updatedList = List<String>.from(progress.learnedWords)..add(wordId);
      final updatedProgress = progress.copyWith(
        learnedWords: updatedList,
      );
      _currentProgress = updatedProgress;
      await _storageService.saveProgressCache(updatedProgress);
      await _syncToFirestore(updatedProgress);
      await addXpAndSync(AppConstants.xpPerVocabularyWord, wordsDelta: 1);
    }
  }

  Future<void> recordQuizCompleted({
    required String quizId,
    required int scorePercent,
    required int wordsCount,
  }) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    final progress = await getProgress(user.id);
    final updatedScores = Map<String, int>.from(progress.quizScores)..[quizId] = scorePercent;

    // Check achievement for 90% score
    final updatedAchievements = progress.achievements.map((ach) {
      if (ach.id == 'quiz_90' && scorePercent >= 90) {
        return ach.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return ach;
    }).toList();

    final updatedProgress = progress.copyWith(
      quizScores: updatedScores,
      achievements: updatedAchievements,
      lastActiveDate: DateTime.now(),
    );

    _currentProgress = updatedProgress;
    await _storageService.saveProgressCache(updatedProgress);
    await _syncToFirestore(updatedProgress);
    await addXpAndSync(AppConstants.xpPerQuiz, wordsDelta: wordsCount);
  }

  Future<void> _syncToFirestore(ProgressModel progress) async {
    final firestore = FirebaseService.firestore;
    if (firestore != null) {
      try {
        await firestore.collection('userProgress').doc(progress.userId).set(progress.toJson());
      } catch (e) {
        debugPrint('Firestore sync progress warning: $e');
      }
    }
  }
}


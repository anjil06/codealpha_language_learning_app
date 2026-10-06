import 'package:flutter/foundation.dart';
import '../core/constants/sample_data.dart';
import '../core/services/firebase_service.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  List<QuizModel> _quizzes = List.from(SampleData.initialQuizzes);

  Future<List<QuizModel>> getQuizzes({String languageId = 'spanish'}) async {
    final firestore = FirebaseService.firestore;
    if (firestore != null) {
      try {
        final snapshot = await firestore
            .collection('quizzes')
            .where('languageId', isEqualTo: languageId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          _quizzes = snapshot.docs
              .map((doc) => QuizModel.fromJson(doc.data()))
              .toList();
          return _quizzes;
        }
      } catch (e) {
        debugPrint('Firestore fetch quizzes error: $e');
      }
    }

    return _quizzes.where((q) => q.languageId == languageId).toList();
  }

  Future<QuizModel?> getQuizById(String id) async {
    try {
      return _quizzes.firstWhere((q) => q.id == id);
    } catch (_) {
      return _quizzes.isNotEmpty ? _quizzes.first : null;
    }
  }

  Future<QuizModel?> getQuizByLessonId(String lessonId) async {
    try {
      return _quizzes.firstWhere((q) => q.lessonId == lessonId);
    } catch (_) {
      return null;
    }
  }
}


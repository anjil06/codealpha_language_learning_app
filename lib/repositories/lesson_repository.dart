import 'package:flutter/foundation.dart';
import '../core/constants/sample_data.dart';
import '../core/services/firebase_service.dart';
import '../models/lesson_model.dart';
import '../models/grammar_model.dart';

class LessonRepository {
  List<LessonModel> _lessons = List.from(SampleData.initialLessons);
  List<GrammarModel> _grammarLessons = List.from(SampleData.initialGrammar);

  Future<List<LessonModel>> getLessons({String languageId = 'spanish'}) async {
    final firestore = FirebaseService.firestore;
    if (firestore != null) {
      try {
        final snapshot = await firestore
            .collection('lessons')
            .where('languageId', isEqualTo: languageId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          _lessons = snapshot.docs
              .map((doc) => LessonModel.fromJson(doc.data()))
              .toList();
          _lessons.sort((a, b) => a.order.compareTo(b.order));
          return _lessons;
        }
      } catch (e) {
        debugPrint('Firestore fetch lessons error: $e');
      }
    }
    return _lessons.where((l) => l.languageId == languageId).toList();
  }

  Future<LessonModel?> getLessonById(String id) async {
    try {
      return _lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> markLessonCompleted(String id) async {
    final index = _lessons.indexWhere((l) => l.id == id);
    if (index != -1) {
      _lessons[index] = _lessons[index].copyWith(isCompleted: true);
    }
  }

  Future<List<GrammarModel>> getGrammarLessons({String languageId = 'spanish'}) async {
    final firestore = FirebaseService.firestore;
    if (firestore != null) {
      try {
        final snapshot = await firestore
            .collection('grammar')
            .where('languageId', isEqualTo: languageId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          _grammarLessons = snapshot.docs
              .map((doc) => GrammarModel.fromJson(doc.data()))
              .toList();
          return _grammarLessons;
        }
      } catch (e) {
        debugPrint('Firestore fetch grammar error: $e');
      }
    }
    return _grammarLessons.where((g) => g.languageId == languageId).toList();
  }

  Future<GrammarModel?> getGrammarLessonById(String id) async {
    try {
      return _grammarLessons.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> markGrammarCompleted(String id) async {
    final index = _grammarLessons.indexWhere((g) => g.id == id);
    if (index != -1) {
      _grammarLessons[index] = _grammarLessons[index].copyWith(isCompleted: true);
    }
  }
}


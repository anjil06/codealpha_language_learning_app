import 'package:flutter/foundation.dart';
import '../core/constants/sample_data.dart';
import '../core/services/firebase_service.dart';
import '../models/vocabulary_model.dart';

class VocabularyRepository {
  List<VocabularyModel> _vocabList = List.from(SampleData.initialVocabulary);

  Future<List<VocabularyModel>> getVocabulary({
    String languageId = 'spanish',
    String? category,
  }) async {
    final firestore = FirebaseService.firestore;
    if (firestore != null) {
      try {
        var query = firestore.collection('vocabulary').where('languageId', isEqualTo: languageId);
        if (category != null && category.isNotEmpty && category != 'All') {
          query = query.where('category', isEqualTo: category);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => VocabularyModel.fromJson(doc.data()))
              .toList();
        }
      } catch (e) {
        debugPrint('Firestore fetch vocabulary error: $e');
      }
    }

    var list = _vocabList.where((v) => v.languageId == languageId).toList();
    if (category != null && category.isNotEmpty && category != 'All') {
      list = list.where((v) => v.category.toLowerCase() == category.toLowerCase()).toList();
    }
    return list;
  }

  Future<void> toggleMastered(String vocabId) async {
    final index = _vocabList.indexWhere((v) => v.id == vocabId);
    if (index != -1) {
      final current = _vocabList[index];
      _vocabList[index] = current.copyWith(isMastered: !current.isMastered);
    }
  }

  List<VocabularyModel> getFlashcardDeck({String languageId = 'spanish', int limit = 10}) {
    final items = _vocabList.where((v) => v.languageId == languageId).toList();
    items.shuffle();
    return items.take(limit).toList();
  }
}

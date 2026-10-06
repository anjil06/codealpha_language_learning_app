class VocabularyModel {
  final String id;
  final String languageId;
  final String category;
  final String word;
  final String translation;
  final String pronunciation;
  final String exampleSentence;
  final String exampleTranslation;
  final String? audioUrl;
  final bool isMastered;

  const VocabularyModel({
    required this.id,
    required this.languageId,
    required this.category,
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.exampleSentence,
    this.exampleTranslation = '',
    this.audioUrl,
    this.isMastered = false,
  });

  VocabularyModel copyWith({
    String? id,
    String? languageId,
    String? category,
    String? word,
    String? translation,
    String? pronunciation,
    String? exampleSentence,
    String? exampleTranslation,
    String? audioUrl,
    bool? isMastered,
  }) {
    return VocabularyModel(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      category: category ?? this.category,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      pronunciation: pronunciation ?? this.pronunciation,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      audioUrl: audioUrl ?? this.audioUrl,
      isMastered: isMastered ?? this.isMastered,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageId': languageId,
      'category': category,
      'word': word,
      'translation': translation,
      'pronunciation': pronunciation,
      'exampleSentence': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'audioUrl': audioUrl,
      'isMastered': isMastered,
    };
  }

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id'] as String? ?? '',
      languageId: json['languageId'] as String? ?? 'spanish',
      category: json['category'] as String? ?? 'General',
      word: json['word'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      exampleSentence: json['exampleSentence'] as String? ?? '',
      exampleTranslation: json['exampleTranslation'] as String? ?? '',
      audioUrl: json['audioUrl'] as String?,
      isMastered: json['isMastered'] as bool? ?? false,
    );
  }
}

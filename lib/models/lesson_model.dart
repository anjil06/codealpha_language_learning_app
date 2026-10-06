class MiniPracticeQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const MiniPracticeQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
  };

  factory MiniPracticeQuestion.fromJson(Map<String, dynamic> json) => MiniPracticeQuestion(
    question: json['question'] as String? ?? '',
    options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
    explanation: json['explanation'] as String? ?? '',
  );
}

class LessonModel {
  final String id;
  final String languageId;
  final String title;
  final String category;
  final String description;
  final String difficulty; // Beginner, Intermediate, Advanced
  final int order;
  final int estimatedMinutes;
  final String introduction;
  final List<String> vocabularyWords; // target words introduced
  final List<String> vocabularyMeanings; // English meanings
  final String pronunciationGuide;
  final List<Map<String, String>> exampleSentences; // {'target': '...', 'english': '...'}
  final List<MiniPracticeQuestion> miniPractice;
  final String? quizId; // Associated quiz
  final bool isCompleted;

  const LessonModel({
    required this.id,
    required this.languageId,
    required this.title,
    required this.category,
    required this.description,
    this.difficulty = 'Beginner',
    this.order = 1,
    this.estimatedMinutes = 5,
    required this.introduction,
    required this.vocabularyWords,
    required this.vocabularyMeanings,
    required this.pronunciationGuide,
    required this.exampleSentences,
    required this.miniPractice,
    this.quizId,
    this.isCompleted = false,
  });

  LessonModel copyWith({
    String? id,
    String? languageId,
    String? title,
    String? category,
    String? description,
    String? difficulty,
    int? order,
    int? estimatedMinutes,
    String? introduction,
    List<String>? vocabularyWords,
    List<String>? vocabularyMeanings,
    String? pronunciationGuide,
    List<Map<String, String>>? exampleSentences,
    List<MiniPracticeQuestion>? miniPractice,
    String? quizId,
    bool? isCompleted,
  }) {
    return LessonModel(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      order: order ?? this.order,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      introduction: introduction ?? this.introduction,
      vocabularyWords: vocabularyWords ?? this.vocabularyWords,
      vocabularyMeanings: vocabularyMeanings ?? this.vocabularyMeanings,
      pronunciationGuide: pronunciationGuide ?? this.pronunciationGuide,
      exampleSentences: exampleSentences ?? this.exampleSentences,
      miniPractice: miniPractice ?? this.miniPractice,
      quizId: quizId ?? this.quizId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageId': languageId,
      'title': title,
      'category': category,
      'description': description,
      'difficulty': difficulty,
      'order': order,
      'estimatedMinutes': estimatedMinutes,
      'introduction': introduction,
      'vocabularyWords': vocabularyWords,
      'vocabularyMeanings': vocabularyMeanings,
      'pronunciationGuide': pronunciationGuide,
      'exampleSentences': exampleSentences,
      'miniPractice': miniPractice.map((p) => p.toJson()).toList(),
      'quizId': quizId,
      'isCompleted': isCompleted,
    };
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String? ?? '',
      languageId: json['languageId'] as String? ?? 'spanish',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      order: (json['order'] as num?)?.toInt() ?? 1,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 5,
      introduction: json['introduction'] as String? ?? '',
      vocabularyWords: (json['vocabularyWords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      vocabularyMeanings: (json['vocabularyMeanings'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      pronunciationGuide: json['pronunciationGuide'] as String? ?? '',
      exampleSentences: (json['exampleSentences'] as List<dynamic>?)?.map((e) => Map<String, String>.from(e as Map)).toList() ?? [],
      miniPractice: (json['miniPractice'] as List<dynamic>?)?.map((e) => MiniPracticeQuestion.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      quizId: json['quizId'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

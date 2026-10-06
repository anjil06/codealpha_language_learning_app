class GrammarExample {
  final String target;
  final String translation;
  final String? note;

  const GrammarExample({
    required this.target,
    required this.translation,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'target': target,
    'translation': translation,
    'note': note,
  };

  factory GrammarExample.fromJson(Map<String, dynamic> json) => GrammarExample(
    target: json['target'] as String? ?? '',
    translation: json['translation'] as String? ?? '',
    note: json['note'] as String?,
  );
}

class GrammarQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const GrammarQuestion({
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

  factory GrammarQuestion.fromJson(Map<String, dynamic> json) => GrammarQuestion(
    question: json['question'] as String? ?? '',
    options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
    explanation: json['explanation'] as String? ?? '',
  );
}

class GrammarModel {
  final String id;
  final String languageId;
  final String title;
  final String category;
  final String explanation;
  final List<String> keyRules;
  final List<GrammarExample> examples;
  final List<GrammarQuestion> practiceQuestions;
  final bool isCompleted;

  const GrammarModel({
    required this.id,
    required this.languageId,
    required this.title,
    required this.category,
    required this.explanation,
    required this.keyRules,
    required this.examples,
    required this.practiceQuestions,
    this.isCompleted = false,
  });

  GrammarModel copyWith({
    String? id,
    String? languageId,
    String? title,
    String? category,
    String? explanation,
    List<String>? keyRules,
    List<GrammarExample>? examples,
    List<GrammarQuestion>? practiceQuestions,
    bool? isCompleted,
  }) {
    return GrammarModel(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      title: title ?? this.title,
      category: category ?? this.category,
      explanation: explanation ?? this.explanation,
      keyRules: keyRules ?? this.keyRules,
      examples: examples ?? this.examples,
      practiceQuestions: practiceQuestions ?? this.practiceQuestions,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageId': languageId,
      'title': title,
      'category': category,
      'explanation': explanation,
      'keyRules': keyRules,
      'examples': examples.map((e) => e.toJson()).toList(),
      'practiceQuestions': practiceQuestions.map((q) => q.toJson()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory GrammarModel.fromJson(Map<String, dynamic> json) {
    return GrammarModel(
      id: json['id'] as String? ?? '',
      languageId: json['languageId'] as String? ?? 'spanish',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Grammar',
      explanation: json['explanation'] as String? ?? '',
      keyRules: (json['keyRules'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      examples: (json['examples'] as List<dynamic>?)?.map((e) => GrammarExample.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      practiceQuestions: (json['practiceQuestions'] as List<dynamic>?)?.map((e) => GrammarQuestion.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

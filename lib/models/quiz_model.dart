enum QuizType {
  multipleChoice,
  translation,
  wordMatching,
  fillInBlank,
  listening,
}

class QuizQuestionModel {
  final String id;
  final QuizType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final Map<String, String>? matchingPairs; // For wordMatching: {'Hola': 'Hello', 'Adiós': 'Goodbye'}
  final String? audioPrompt; // Word to be pronounced for listening type
  final String explanation;

  const QuizQuestionModel({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.matchingPairs,
    this.audioPrompt,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'question': question,
    'options': options,
    'correctAnswer': correctAnswer,
    'matchingPairs': matchingPairs,
    'audioPrompt': audioPrompt,
    'explanation': explanation,
  };

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    QuizType parsedType;
    try {
      parsedType = QuizType.values.byName(json['type'] as String? ?? 'multipleChoice');
    } catch (_) {
      parsedType = QuizType.multipleChoice;
    }

    return QuizQuestionModel(
      id: json['id'] as String? ?? '',
      type: parsedType,
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctAnswer: json['correctAnswer'] as String? ?? '',
      matchingPairs: json['matchingPairs'] != null
          ? Map<String, String>.from(json['matchingPairs'] as Map)
          : null,
      audioPrompt: json['audioPrompt'] as String?,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class QuizModel {
  final String id;
  final String languageId;
  final String? lessonId;
  final String title;
  final String description;
  final String difficulty;
  final List<QuizQuestionModel> questions;

  const QuizModel({
    required this.id,
    required this.languageId,
    this.lessonId,
    required this.title,
    required this.description,
    this.difficulty = 'Beginner',
    required this.questions,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'languageId': languageId,
    'lessonId': lessonId,
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
    id: json['id'] as String? ?? '',
    languageId: json['languageId'] as String? ?? 'spanish',
    lessonId: json['lessonId'] as String?,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    difficulty: json['difficulty'] as String? ?? 'Beginner',
    questions: (json['questions'] as List<dynamic>?)
            ?.map((q) => QuizQuestionModel.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

class QuizResultModel {
  final String quizId;
  final String quizTitle;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int xpEarned;
  final int wordsLearned;
  final int currentStreak;
  final String recommendedLesson;
  final DateTime completedAt;

  const QuizResultModel({
    required this.quizId,
    required this.quizTitle,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.xpEarned,
    required this.wordsLearned,
    required this.currentStreak,
    required this.recommendedLesson,
    required this.completedAt,
  });

  double get accuracy => totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0.0;
  bool get isPassed => accuracy >= 70.0;
}

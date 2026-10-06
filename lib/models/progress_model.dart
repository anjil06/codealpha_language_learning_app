class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    icon: json['icon'] as String? ?? '🏆',
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    unlockedAt: json['unlockedAt'] != null
        ? DateTime.tryParse(json['unlockedAt'] as String)
        : null,
  );
}

class ProgressModel {
  final String userId;
  final List<String> completedLessons;
  final List<String> learnedWords;
  final List<String> completedGrammar;
  final Map<String, int> quizScores; // quizId -> score (0-100)
  final int streak;
  final DateTime lastActiveDate;
  final Map<String, int> weeklyActivity; // e.g. {'Mon': 25, 'Tue': 40, ...} in minutes
  final List<AchievementModel> achievements;

  const ProgressModel({
    required this.userId,
    this.completedLessons = const [],
    this.learnedWords = const [],
    this.completedGrammar = const [],
    this.quizScores = const {},
    this.streak = 5,
    required this.lastActiveDate,
    this.weeklyActivity = const {
      'Mon': 25,
      'Tue': 35,
      'Wed': 15,
      'Thu': 30,
      'Fri': 45,
      'Sat': 20,
      'Sun': 10,
    },
    this.achievements = const [],
  });

  ProgressModel copyWith({
    String? userId,
    List<String>? completedLessons,
    List<String>? learnedWords,
    List<String>? completedGrammar,
    Map<String, int>? quizScores,
    int? streak,
    DateTime? lastActiveDate,
    Map<String, int>? weeklyActivity,
    List<AchievementModel>? achievements,
  }) {
    return ProgressModel(
      userId: userId ?? this.userId,
      completedLessons: completedLessons ?? this.completedLessons,
      learnedWords: learnedWords ?? this.learnedWords,
      completedGrammar: completedGrammar ?? this.completedGrammar,
      quizScores: quizScores ?? this.quizScores,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      achievements: achievements ?? this.achievements,
    );
  }

  double get averageQuizAccuracy {
    if (quizScores.isEmpty) return 82.0;
    final total = quizScores.values.fold(0, (sum, score) => sum + score);
    return total / quizScores.length;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'completedLessons': completedLessons,
    'learnedWords': learnedWords,
    'completedGrammar': completedGrammar,
    'quizScores': quizScores,
    'streak': streak,
    'lastActiveDate': lastActiveDate.toIso8601String(),
    'weeklyActivity': weeklyActivity,
    'achievements': achievements.map((a) => a.toJson()).toList(),
  };

  factory ProgressModel.fromJson(Map<String, dynamic> json) => ProgressModel(
    userId: json['userId'] as String? ?? '',
    completedLessons: (json['completedLessons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    learnedWords: (json['learnedWords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    completedGrammar: (json['completedGrammar'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    quizScores: json['quizScores'] != null
        ? Map<String, int>.from(json['quizScores'] as Map)
        : {},
    streak: (json['streak'] as num?)?.toInt() ?? 5,
    lastActiveDate: json['lastActiveDate'] != null
        ? DateTime.tryParse(json['lastActiveDate'] as String) ?? DateTime.now()
        : DateTime.now(),
    weeklyActivity: json['weeklyActivity'] != null
        ? Map<String, int>.from(json['weeklyActivity'] as Map)
        : {
            'Mon': 25,
            'Tue': 35,
            'Wed': 15,
            'Thu': 30,
            'Fri': 45,
            'Sat': 20,
            'Sun': 10,
          },
    achievements: (json['achievements'] as List<dynamic>?)
            ?.map((a) => AchievementModel.fromJson(a as Map<String, dynamic>))
            .toList() ??
        ProgressModel.defaultAchievements,
  );

  static List<AchievementModel> get defaultAchievements => const [
    AchievementModel(
      id: 'first_lesson',
      title: 'First Lesson',
      description: 'Completed your very first lesson',
      icon: '🏆',
      isUnlocked: true,
    ),
    AchievementModel(
      id: 'streak_7',
      title: '7 Day Streak',
      description: 'Maintained a 7-day learning streak',
      icon: '🔥',
      isUnlocked: true,
    ),
    AchievementModel(
      id: 'words_100',
      title: '100 Words',
      description: 'Mastered 100 new vocabulary words',
      icon: '📚',
      isUnlocked: false,
    ),
    AchievementModel(
      id: 'quiz_90',
      title: '90% Quiz Score',
      description: 'Scored 90% or higher in any quiz',
      icon: '🎯',
      isUnlocked: true,
    ),
    AchievementModel(
      id: 'flashcard_master',
      title: 'Flashcard Ace',
      description: 'Completed 5 flashcard sessions',
      icon: '⚡',
      isUnlocked: false,
    ),
  ];
}


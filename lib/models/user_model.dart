class UserModel {
  final String id;
  final String name;
  final String email;
  final String learningLanguage;
  final int xp;
  final int level;
  final int streak;
  final int dailyGoal;
  final int lessonsCompleted;
  final int wordsLearned;
  final DateTime createdAt;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.learningLanguage,
    this.xp = 0,
    this.level = 1,
    this.streak = 1,
    this.dailyGoal = 10,
    this.lessonsCompleted = 0,
    this.wordsLearned = 0,
    required this.createdAt,
    this.avatarUrl,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? learningLanguage,
    int? xp,
    int? level,
    int? streak,
    int? dailyGoal,
    int? lessonsCompleted,
    int? wordsLearned,
    DateTime? createdAt,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'learningLanguage': learningLanguage,
      'xp': xp,
      'level': level,
      'streak': streak,
      'dailyGoal': dailyGoal,
      'lessonsCompleted': lessonsCompleted,
      'wordsLearned': wordsLearned,
      'createdAt': createdAt.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Learner',
      email: json['email'] as String? ?? '',
      learningLanguage: json['learningLanguage'] as String? ?? 'Spanish',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      streak: (json['streak'] as num?)?.toInt() ?? 1,
      dailyGoal: (json['dailyGoal'] as num?)?.toInt() ?? 10,
      lessonsCompleted: (json['lessonsCompleted'] as num?)?.toInt() ?? 0,
      wordsLearned: (json['wordsLearned'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  factory UserModel.initial({
    required String id,
    required String name,
    required String email,
    String learningLanguage = 'Spanish',
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      learningLanguage: learningLanguage,
      xp: 45,
      level: 1,
      streak: 5,
      dailyGoal: 10,
      lessonsCompleted: 7,
      wordsLearned: 24,
      createdAt: DateTime.now(),
    );
  }
}


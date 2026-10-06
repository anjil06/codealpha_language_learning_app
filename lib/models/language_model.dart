class LanguageModel {
  final String id;
  final String name;
  final String code; // e.g. 'es', 'fr', 'de', 'ja', 'ko', 'hi', 'te'
  final String flag; // Emoji flag or emblem
  final int totalLessons;
  final double progressPercentage;
  final String greeting;
  final String ttsLocale;

  const LanguageModel({
    required this.id,
    required this.name,
    required this.code,
    required this.flag,
    this.totalLessons = 30,
    this.progressPercentage = 0.0,
    this.greeting = 'Hello',
    this.ttsLocale = 'en-US',
  });

  LanguageModel copyWith({
    String? id,
    String? name,
    String? code,
    String? flag,
    int? totalLessons,
    double? progressPercentage,
    String? greeting,
    String? ttsLocale,
  }) {
    return LanguageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      flag: flag ?? this.flag,
      totalLessons: totalLessons ?? this.totalLessons,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      greeting: greeting ?? this.greeting,
      ttsLocale: ttsLocale ?? this.ttsLocale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'flag': flag,
      'totalLessons': totalLessons,
      'progressPercentage': progressPercentage,
      'greeting': greeting,
      'ttsLocale': ttsLocale,
    };
  }

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      flag: json['flag'] as String? ?? '🌐',
      totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 30,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      greeting: json['greeting'] as String? ?? 'Hello',
      ttsLocale: json['ttsLocale'] as String? ?? 'en-US',
    );
  }

  static List<LanguageModel> get supportedLanguages => const [
    LanguageModel(
      id: 'spanish',
      name: 'Spanish',
      code: 'es',
      flag: '🇪🇸',
      totalLessons: 45,
      progressPercentage: 35.0,
      greeting: '¡Hola!',
      ttsLocale: 'es-ES',
    ),
    LanguageModel(
      id: 'french',
      name: 'French',
      code: 'fr',
      flag: '🇫🇷',
      totalLessons: 40,
      progressPercentage: 20.0,
      greeting: 'Bonjour!',
      ttsLocale: 'fr-FR',
    ),
    LanguageModel(
      id: 'german',
      name: 'German',
      code: 'de',
      flag: '🇩🇪',
      totalLessons: 38,
      progressPercentage: 10.0,
      greeting: 'Hallo!',
      ttsLocale: 'de-DE',
    ),
    LanguageModel(
      id: 'japanese',
      name: 'Japanese',
      code: 'ja',
      flag: '🇯🇵',
      totalLessons: 50,
      progressPercentage: 15.0,
      greeting: 'こんにちは!',
      ttsLocale: 'ja-JP',
    ),
    LanguageModel(
      id: 'korean',
      name: 'Korean',
      code: 'ko',
      flag: '🇰🇷',
      totalLessons: 42,
      progressPercentage: 8.0,
      greeting: '안녕하세요!',
      ttsLocale: 'ko-KR',
    ),
    LanguageModel(
      id: 'hindi',
      name: 'Hindi',
      code: 'hi',
      flag: '🇮🇳',
      totalLessons: 35,
      progressPercentage: 25.0,
      greeting: 'नमस्ते!',
      ttsLocale: 'hi-IN',
    ),
    LanguageModel(
      id: 'telugu',
      name: 'Telugu',
      code: 'te',
      flag: '🇮🇳',
      totalLessons: 30,
      progressPercentage: 12.0,
      greeting: 'నమస్కారం!',
      ttsLocale: 'te-IN',
    ),
  ];
}


class AppConstants {
  static const String appName = 'LinguaLearn';
  static const String appTagline = 'Master languages through daily interactive practice';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keySoundEffectsEnabled = 'sound_effects_enabled';
  static const String keyTtsAudioEnabled = 'tts_audio_enabled';
  static const String keyDailyGoal = 'daily_goal';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyUserCache = 'cached_user_profile';
  static const String keyProgressCache = 'cached_user_progress';
  static const String keyOfflineVocabulary = 'offline_vocabulary';
  static const String keyOfflineLessons = 'offline_lessons';
  static const String keyOfflineQuizzes = 'offline_quizzes';

  // Gamification XP Rewards
  static const int xpPerLesson = 20;
  static const int xpPerQuiz = 30;
  static const int xpPerVocabularyWord = 5;
  static const int xpPerDailyLogin = 10;
  static const int xpPerGrammarLesson = 15;

  // Levels
  static const Map<int, String> levelTitles = {
    1: 'Beginner',
    2: 'Explorer',
    3: 'Learner',
    4: 'Speaker',
    5: 'Fluent Starter',
  };

  static String getLevelTitle(int level) {
    return levelTitles[level] ?? 'Master';
  }

  static int calculateLevel(int xp) {
    if (xp < 100) return 1;
    if (xp < 250) return 2;
    if (xp < 500) return 3;
    if (xp < 900) return 4;
    return 5;
  }

  static double getLevelProgress(int xp) {
    if (xp < 100) return xp / 100.0;
    if (xp < 250) return (xp - 100) / 150.0;
    if (xp < 500) return (xp - 250) / 250.0;
    if (xp < 900) return (xp - 500) / 400.0;
    return 1.0;
  }
}


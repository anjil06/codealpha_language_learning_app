import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/progress_model.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Onboarding
  bool get isOnboardingCompleted =>
      _prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;

  Future<bool> setOnboardingCompleted(bool value) =>
      _prefs.setBool(AppConstants.keyOnboardingComplete, value);

  // Selected Language
  String get selectedLanguage =>
      _prefs.getString(AppConstants.keySelectedLanguage) ?? 'spanish';

  Future<bool> setSelectedLanguage(String languageId) =>
      _prefs.setString(AppConstants.keySelectedLanguage, languageId);

  // Dark Mode
  bool get isDarkMode =>
      _prefs.getBool(AppConstants.keyIsDarkMode) ?? false;

  Future<bool> setDarkMode(bool value) =>
      _prefs.setBool(AppConstants.keyIsDarkMode, value);

  // Sound Effects
  bool get soundEffectsEnabled =>
      _prefs.getBool(AppConstants.keySoundEffectsEnabled) ?? true;

  Future<bool> setSoundEffectsEnabled(bool value) =>
      _prefs.setBool(AppConstants.keySoundEffectsEnabled, value);

  // TTS Audio
  bool get ttsAudioEnabled =>
      _prefs.getBool(AppConstants.keyTtsAudioEnabled) ?? true;

  Future<bool> setTtsAudioEnabled(bool value) =>
      _prefs.setBool(AppConstants.keyTtsAudioEnabled, value);

  // Daily Goal
  int get dailyGoal =>
      _prefs.getInt(AppConstants.keyDailyGoal) ?? 10;

  Future<bool> setDailyGoal(int goal) =>
      _prefs.setInt(AppConstants.keyDailyGoal, goal);

  // User Profile Cache
  UserModel? getCachedUser() {
    final raw = _prefs.getString(AppConstants.keyUserCache);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveUserCache(UserModel user) {
    return _prefs.setString(AppConstants.keyUserCache, jsonEncode(user.toJson()));
  }

  Future<bool> clearUserCache() {
    return _prefs.remove(AppConstants.keyUserCache);
  }

  // User Progress Cache
  ProgressModel? getCachedProgress(String userId) {
    final raw = _prefs.getString('${AppConstants.keyProgressCache}_$userId');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ProgressModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveProgressCache(ProgressModel progress) {
    return _prefs.setString(
      '${AppConstants.keyProgressCache}_${progress.userId}',
      jsonEncode(progress.toJson()),
    );
  }
}


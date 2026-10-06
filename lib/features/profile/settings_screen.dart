import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _soundEffects;
  late bool _ttsAudio;
  late bool _notifications;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _soundEffects = storage.soundEffectsEnabled;
    _ttsAudio = storage.ttsAudioEnabled;
    _notifications = true;
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('About LinguaLearn'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LinguaLearn v${AppConstants.appVersion}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'A modern, interactive language learning mobile app designed to help users master new languages through daily lessons, vocabulary, flashcards, pronunciation practice, grammar, quizzes, and progress tracking.',
              style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.lightTextSecondary),
            ),
            SizedBox(height: 12),
            Text(
              'Developed with Flutter, Riverpod, Material 3, and Firebase.',
              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            body,
            style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.lightTextSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(currentLanguageModelProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final storage = ref.read(storageServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section: Learning Preferences
          _buildSectionHeader('Learning Preferences'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                  title: const Text('Learning Language'),
                  subtitle: Text('${currentLang.flag} ${currentLang.name}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/language-select'),
                ),
                _buildDivider(isDark),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: AppColors.warning),
                  title: const Text('Daily Learning Goal'),
                  subtitle: Text('${storage.dailyGoal} lessons/day'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/language-select'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Audio & App Preferences
          _buildSectionHeader('Audio & Display'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.accent),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch between light and dark themes'),
                  value: isDark,
                  onChanged: (_) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
                _buildDivider(isDark),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined, color: AppColors.secondary),
                  title: const Text('Pronunciation Audio'),
                  subtitle: const Text('Auto-play and native text-to-speech'),
                  value: _ttsAudio,
                  onChanged: (val) {
                    setState(() => _ttsAudio = val);
                    storage.setTtsAudioEnabled(val);
                  },
                ),
                _buildDivider(isDark),
                SwitchListTile(
                  secondary: const Icon(Icons.music_note_outlined, color: AppColors.xpGold),
                  title: const Text('Sound Effects'),
                  subtitle: const Text('Feedback chimes on correct quiz answers'),
                  value: _soundEffects,
                  onChanged: (val) {
                    setState(() => _soundEffects = val);
                    storage.setSoundEffectsEnabled(val);
                  },
                ),
                _buildDivider(isDark),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_none_rounded, color: AppColors.streakFire),
                  title: const Text('Daily Reminders'),
                  subtitle: const Text('Notifications to preserve learning streak'),
                  value: _notifications,
                  onChanged: (val) {
                    setState(() => _notifications = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Legal & About
          _buildSectionHeader('About & Legal'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.info),
                  title: const Text('About LinguaLearn'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showAboutDialog(context),
                ),
                _buildDivider(isDark),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.success),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showInfoDialog(
                    context,
                    'Privacy Policy',
                    'LinguaLearn respects your privacy. All user progress, vocabulary reviews, and streak records are securely kept and never sold. Offline cache data resides securely on your device, and optional Cloud Firestore synchronization uses encrypted connections.',
                  ),
                ),
                _buildDivider(isDark),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Colors.blueGrey),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showInfoDialog(
                    context,
                    'Terms of Service',
                    'By using LinguaLearn, you agree to engage in educational language study in accordance with educational terms. Learning materials and audio pronunciation assets are provided for educational and demonstrative purposes.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Account Actions
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              onTap: () async {
                await ref.read(authRepositoryProvider).logout();
                ref.read(userStateProvider.notifier).setUser(null);
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}


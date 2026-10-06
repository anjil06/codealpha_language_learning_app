import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';
import '../../core/widgets/stat_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider);
    final currentLanguage = ref.watch(currentLanguageModelProvider);
    final lessonsAsync = ref.watch(lessonsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = user?.name ?? 'Anjil';
    final streakDays = user?.streak ?? 5;
    final userXp = user?.xp ?? 45;
    final userLevel = user?.level ?? 1;

    // Daily Goal progress
    final dailyGoalTarget = user?.dailyGoal ?? 10;
    final dailyLessonsDone = user?.lessonsCompleted ?? 7;
    final goalProgress = (dailyLessonsDone / dailyGoalTarget).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(progressProvider);
            ref.invalidate(lessonsProvider);
            await ref.read(userStateProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Greeting, Language Pill, and Profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $userName 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready to practice ${currentLanguage.name}?',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => context.push('/language-select'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(currentLanguage.flag, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              currentLanguage.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Streak & XP Badges Row
                Row(
                  children: [
                    StatBadge.streak(streakDays),
                    const SizedBox(width: 8),
                    StatBadge.xp(userXp),
                    const SizedBox(width: 8),
                    StatBadge.level(userLevel),
                  ],
                ),
                const SizedBox(height: 20),

                // Daily Goal Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(60),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.flag_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Daily Goal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$dailyLessonsDone / $dailyGoalTarget completed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: goalProgress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withAlpha(60),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpGold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        goalProgress >= 1.0
                            ? '🎉 Great job! You hit your daily learning goal!'
                            : '${(dailyGoalTarget - dailyLessonsDone).clamp(0, dailyGoalTarget)} more lessons to hit today\'s goal!',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Actions: 4 Buttons (Vocabulary, Grammar, Flashcards, Quiz)
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickActionItem(
                      context,
                      title: 'Vocabulary',
                      icon: Icons.translate_rounded,
                      color: const Color(0xFF3B82F6),
                      onTap: () => context.push('/vocabulary'),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                      context,
                      title: 'Grammar',
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => context.push('/grammar'),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                      context,
                      title: 'Flashcards',
                      icon: Icons.flip_to_back_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () => context.push('/flashcards'),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                      context,
                      title: 'Quiz',
                      icon: Icons.quiz_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () => context.push('/quiz/q1'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Today's Lesson Card
                const Text(
                  "Today's Lesson",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.record_voice_over_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Vocabulary – Greetings',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '10 new words • 6 mins practice',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '+20 XP',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(140, 44),
                              ),
                              onPressed: () => context.push('/lessons/l1'),
                              icon: const Icon(Icons.play_arrow_rounded, size: 20),
                              label: const Text('Start Lesson'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Continue Learning
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Continue Learning',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/lessons'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                lessonsAsync.when(
                  data: (lessons) {
                    final nextLesson = lessons.firstWhere(
                      (l) => !l.isCompleted,
                      orElse: () => lessons.first,
                    );

                    return Card(
                      child: InkWell(
                        onTap: () => context.push('/lessons/${nextLesson.id}'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withAlpha(25),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${nextLesson.order}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nextLesson.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${nextLesson.category} • ${nextLesson.estimatedMinutes} mins',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: AppColors.lightTextMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, _) => const SizedBox(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


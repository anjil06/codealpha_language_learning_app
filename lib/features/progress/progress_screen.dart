import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/app_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider);
    final progressAsync = ref.watch(progressProvider);
    final currentLang = ref.watch(currentLanguageModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userXp = user?.xp ?? 45;
    final userLevel = user?.level ?? 1;
    final levelTitle = AppConstants.getLevelTitle(userLevel);
    final levelProgress = AppConstants.getLevelProgress(userXp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Progress'),
      ),
      body: progressAsync.when(
        data: (progress) {
          final totalWordsLearned = progress.learnedWords.length + (user?.wordsLearned ?? 24);
          final accuracy = progress.averageQuizAccuracy.toInt();
          final streakDays = user?.streak ?? progress.streak;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level & XP Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.military_tech_rounded, color: AppColors.xpGold, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Level $userLevel – $levelTitle',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$userXp XP Total',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(200),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.xpGold,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: levelProgress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withAlpha(60),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpGold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${((1 - levelProgress) * 100).toInt()}% progress to Level ${userLevel + 1}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Core Metrics Grid
                const Text(
                  'Overview Metrics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Overall Progress',
                        value: '65%',
                        icon: Icons.pie_chart_rounded,
                        color: AppColors.primary,
                        subtitle: '${currentLang.name} Course',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Current Streak',
                        value: '$streakDays Days',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.streakFire,
                        subtitle: 'Keep it going!',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Vocabulary',
                        value: '$totalWordsLearned / 500',
                        icon: Icons.translate_rounded,
                        color: AppColors.secondary,
                        subtitle: 'Words mastered',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Grammar',
                        value: '15 / 30',
                        icon: Icons.auto_stories_rounded,
                        color: AppColors.accent,
                        subtitle: 'Lessons cleared',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Quizzes Taken',
                        value: '${progress.quizScores.length + 19}',
                        icon: Icons.quiz_rounded,
                        color: AppColors.warning,
                        subtitle: 'Assessments done',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Quiz Accuracy',
                        value: '$accuracy%',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                        subtitle: 'High proficiency',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Weekly Learning Activity Chart
                const Text(
                  'Weekly Learning Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Minutes Learned Per Day',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Total: 180 mins',
                              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildWeeklyBarChart(progress.weeklyActivity, isDark),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Gamification Achievements
                const Text(
                  'Achievements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: progress.achievements.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    itemBuilder: (context, index) {
                      final ach = progress.achievements[index];

                      return ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: ach.isUnlocked
                                ? AppColors.xpGold.withAlpha(25)
                                : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            ach.icon,
                            style: TextStyle(
                              fontSize: 22,
                              color: ach.isUnlocked ? null : Colors.grey,
                            ),
                          ),
                        ),
                        title: Text(
                          ach.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: ach.isUnlocked
                                ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                : AppColors.lightTextMuted,
                          ),
                        ),
                        subtitle: Text(
                          ach.description,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: ach.isUnlocked
                                ? AppColors.lightTextSecondary
                                : AppColors.lightTextMuted,
                          ),
                        ),
                        trailing: ach.isUnlocked
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'UNLOCKED',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.lightTextMuted),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart(Map<String, int> weeklyData, bool isDark) {
    const maxMinutes = 50.0;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: days.map((day) {
        final minutes = weeklyData[day] ?? 10;
        final barHeight = ((minutes / maxMinutes) * 100.0).clamp(16.0, 100.0);
        final isToday = day == 'Fri';

        return Column(
          children: [
            Text(
              '${minutes}m',
              style: TextStyle(
                fontSize: 10,
                color: isToday ? AppColors.primary : AppColors.lightTextMuted,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 22,
              height: barHeight,
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary : AppColors.primary.withAlpha(60),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: isToday ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}


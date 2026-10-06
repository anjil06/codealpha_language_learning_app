import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/quiz_model.dart';

class QuizResultScreen extends ConsumerWidget {
  final QuizResultModel result;

  const QuizResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accuracyInt = result.accuracy.toInt();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: result.isPassed
                      ? AppColors.success.withAlpha(25)
                      : AppColors.warning.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    result.isPassed ? '🎉' : '💪',
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Quiz Completed 🎉',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                result.quizTitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Score & Accuracy Cards
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        child: Column(
                          children: [
                            const Text('Score', style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text(
                              '${result.correctCount} / ${result.totalQuestions}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        child: Column(
                          children: [
                            const Text('Accuracy', style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text(
                              '$accuracyInt%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: result.isPassed ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Correct & Wrong Answers Row
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Correct: ${result.correctCount}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(height: 24, width: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      Row(
                        children: [
                          const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Wrong: ${result.wrongCount}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gamification rewards row
              Card(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.xpGold.withAlpha(80),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRewardPill('XP Earned', '+${result.xpEarned} XP', Icons.stars_rounded, AppColors.xpGold),
                      _buildRewardPill('Words Learned', '+${result.wordsLearned}', Icons.menu_book_rounded, AppColors.secondary),
                      _buildRewardPill('Current Streak', '${result.currentStreak} Days', Icons.local_fire_department_rounded, AppColors.streakFire),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Recommended Next Lesson Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lightbulb_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recommended Next Step',
                              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              result.recommendedLesson,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Buttons
              CustomButton(
                label: 'Continue Learning',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Try Again',
                type: ButtonType.outline,
                icon: Icons.replay_rounded,
                onPressed: () => context.pushReplacement('/quiz/${result.quizId}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardPill(String title, String val, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
        ),
      ],
    );
  }
}

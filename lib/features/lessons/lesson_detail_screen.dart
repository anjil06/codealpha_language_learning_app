import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/lesson_model.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  final Map<int, int?> _selectedAnswers = {};

  void _speak(String text) {
    final tts = ref.read(ttsServiceProvider);
    final lang = ref.read(currentLanguageModelProvider);
    tts.speak(text, languageCode: lang.ttsLocale);
  }

  Future<void> _completeLesson(LessonModel lesson) async {
    final progressRepo = ref.read(progressRepositoryProvider);
    await progressRepo.recordLessonCompleted(lesson.id);
    ref.invalidate(progressProvider);
    ref.invalidate(lessonsProvider);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎉', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 18),
              const Text(
                'Lesson Completed!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You earned +20 XP and improved your streak!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: lesson.quizId != null ? 'Take Quiz Now' : 'Back to Lessons',
                icon: lesson.quizId != null ? Icons.quiz_rounded : Icons.check_circle_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  if (lesson.quizId != null) {
                    context.push('/quiz/${lesson.quizId}');
                  } else {
                    context.pop();
                  }
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('Done for now'),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonsAsync = ref.watch(lessonsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return lessonsAsync.when(
      data: (lessons) {
        final lesson = lessons.firstWhere(
          (l) => l.id == widget.lessonId,
          orElse: () => lessons.first,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(lesson.title),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lesson.difficulty,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Introduction Card
                _buildSectionHeader(
                  icon: Icons.info_outline_rounded,
                  title: '1. Introduction',
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      lesson.introduction,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Vocabulary
                _buildSectionHeader(
                  icon: Icons.translate_rounded,
                  title: '2. New Vocabulary',
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lesson.vocabularyWords.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    itemBuilder: (context, index) {
                      final word = lesson.vocabularyWords[index];
                      final meaning = index < lesson.vocabularyMeanings.length
                          ? lesson.vocabularyMeanings[index]
                          : '';

                      return ListTile(
                        title: Text(
                          word,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(meaning),
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                          onPressed: () => _speak(word),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Pronunciation Guide
                _buildSectionHeader(
                  icon: Icons.record_voice_over_rounded,
                  title: '3. Pronunciation Guide',
                  color: AppColors.accent,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.tips_and_updates_rounded, color: AppColors.xpGold),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lesson.pronunciationGuide,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Example Sentences
                _buildSectionHeader(
                  icon: Icons.format_quote_rounded,
                  title: '4. Example Sentences',
                  color: AppColors.success,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lesson.exampleSentences.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    itemBuilder: (context, index) {
                      final ex = lesson.exampleSentences[index];
                      final target = ex['target'] ?? '';
                      final english = ex['english'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                              onPressed: () => _speak(target),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    target,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    english,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Mini Practice
                _buildSectionHeader(
                  icon: Icons.checklist_rounded,
                  title: '5. Mini Practice',
                  color: AppColors.warning,
                ),
                const SizedBox(height: 8),
                ...List.generate(lesson.miniPractice.length, (pIndex) {
                  final practice = lesson.miniPractice[pIndex];
                  final selected = _selectedAnswers[pIndex];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${pIndex + 1}: ${practice.question}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(practice.options.length, (optIndex) {
                            final isChosen = selected == optIndex;
                            final isCorrect = optIndex == practice.correctIndex;

                            Color? tileColor;
                            if (selected != null) {
                              if (isChosen && isCorrect) {
                                tileColor = AppColors.success.withAlpha(30);
                              } else if (isChosen && !isCorrect) {
                                tileColor = AppColors.error.withAlpha(30);
                              } else if (isCorrect) {
                                tileColor = AppColors.success.withAlpha(20);
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: tileColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isChosen
                                      ? (isCorrect ? AppColors.success : AppColors.error)
                                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                title: Text(practice.options[optIndex]),
                                trailing: selected != null
                                    ? (isCorrect
                                        ? const Icon(Icons.check_circle, color: AppColors.success)
                                        : (isChosen
                                            ? const Icon(Icons.cancel, color: AppColors.error)
                                            : null))
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedAnswers[pIndex] = optIndex;
                                  });
                                },
                              ),
                            );
                          }),
                          if (selected != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              practice.explanation,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.lightTextSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // 6. Action Button
                CustomButton(
                  label: 'Complete Lesson (+20 XP)',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () => _completeLesson(lesson),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


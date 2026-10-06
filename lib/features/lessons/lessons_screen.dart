import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';
import '../../core/widgets/error_view.dart';

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsProvider);
    final currentLang = ref.watch(currentLanguageModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentLang.name} Lessons'),
      ),
      body: lessonsAsync.when(
        data: (lessons) {
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: lessons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final isCompleted = lesson.isCompleted;

              Color diffColor;
              switch (lesson.difficulty.toLowerCase()) {
                case 'beginner':
                  diffColor = AppColors.difficultyBeginner;
                  break;
                case 'intermediate':
                  diffColor = AppColors.difficultyIntermediate;
                  break;
                default:
                  diffColor = AppColors.difficultyAdvanced;
              }

              return Card(
                child: InkWell(
                  onTap: () => context.push('/lessons/${lesson.id}'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        // Order badge / check icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.success.withAlpha(25)
                                : AppColors.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check_rounded, color: AppColors.success, size: 24)
                                : Text(
                                    '${lesson.order}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      lesson.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: diffColor.withAlpha(25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      lesson.difficulty,
                                      style: TextStyle(
                                        color: diffColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lesson.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.lightTextMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${lesson.estimatedMinutes} mins',
                                    style: const TextStyle(fontSize: 12, color: AppColors.lightTextMuted),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.menu_book_rounded, size: 14, color: AppColors.lightTextMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${lesson.vocabularyWords.length} words',
                                    style: const TextStyle(fontSize: 12, color: AppColors.lightTextMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.lightTextMuted),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: 'Unable to load lessons. Please check your internet connection.',
          onRetry: () => ref.invalidate(lessonsProvider),
        ),
      ),
    );
  }
}


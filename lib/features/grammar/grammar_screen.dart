import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';
import '../../core/widgets/error_view.dart';

class GrammarScreen extends ConsumerWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammarAsync = ref.watch(grammarProvider);
    final currentLang = ref.watch(currentLanguageModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentLang.name} Grammar'),
      ),
      body: grammarAsync.when(
        data: (topics) {
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: topics.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final topic = topics[index];

              return Card(
                child: InkWell(
                  onTap: () => context.push('/grammar/${topic.id}'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: AppColors.accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                topic.explanation,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '${topic.examples.length} examples • ${topic.practiceQuestions.length} practice questions',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
          message: 'Unable to load grammar lessons: $err',
          onRetry: () => ref.invalidate(grammarProvider),
        ),
      ),
    );
  }
}

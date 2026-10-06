import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/grammar_model.dart';

class GrammarDetailScreen extends ConsumerStatefulWidget {
  final String grammarId;

  const GrammarDetailScreen({
    super.key,
    required this.grammarId,
  });

  @override
  ConsumerState<GrammarDetailScreen> createState() => _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends ConsumerState<GrammarDetailScreen> {
  final Map<int, int?> _answers = {};

  void _speak(String text) {
    final tts = ref.read(ttsServiceProvider);
    final currentLang = ref.read(currentLanguageModelProvider);
    tts.speak(text, languageCode: currentLang.ttsLocale);
  }

  Future<void> _completeGrammar(GrammarModel grammar) async {
    final progressRepo = ref.read(progressRepositoryProvider);
    await progressRepo.recordGrammarCompleted(grammar.id);
    ref.invalidate(progressProvider);
    ref.invalidate(grammarProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Grammar lesson completed! +15 XP earned.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final grammarAsync = ref.watch(grammarProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return grammarAsync.when(
      data: (grammarLessons) {
        final item = grammarLessons.firstWhere(
          (g) => g.id == widget.grammarId,
          orElse: () => grammarLessons.first,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(item.title),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Explanation
                const Text(
                  'Explanation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      item.explanation,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Key Rules
                const Text(
                  'Key Rules',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: item.keyRules.map((rule) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  rule,
                                  style: const TextStyle(fontSize: 14, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Examples
                const Text(
                  'Examples',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.examples.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    itemBuilder: (context, index) {
                      final ex = item.examples[index];
                      return ListTile(
                        leading: IconButton(
                          icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                          onPressed: () => _speak(ex.target),
                        ),
                        title: Text(
                          ex.target,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ex.translation),
                            if (ex.note != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Note: ${ex.note!}',
                                style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Practice Questions
                const Text(
                  'Check Your Understanding',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...List.generate(item.practiceQuestions.length, (qIndex) {
                  final q = item.practiceQuestions[qIndex];
                  final selected = _answers[qIndex];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${qIndex + 1}: ${q.question}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(q.options.length, (optIndex) {
                            final isChosen = selected == optIndex;
                            final isCorrect = optIndex == q.correctIndex;

                            Color? optBg;
                            if (selected != null) {
                              if (isChosen && isCorrect) {
                                optBg = AppColors.success.withAlpha(25);
                              } else if (isChosen && !isCorrect) {
                                optBg = AppColors.error.withAlpha(25);
                              } else if (isCorrect) {
                                optBg = AppColors.success.withAlpha(20);
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: optBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isChosen
                                      ? (isCorrect ? AppColors.success : AppColors.error)
                                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                title: Text(q.options[optIndex]),
                                trailing: selected != null
                                    ? (isCorrect
                                        ? const Icon(Icons.check_circle, color: AppColors.success)
                                        : (isChosen
                                            ? const Icon(Icons.cancel, color: AppColors.error)
                                            : null))
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _answers[qIndex] = optIndex;
                                  });
                                },
                              ),
                            );
                          }),
                          if (selected != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              q.explanation,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.lightTextSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                CustomButton(
                  label: 'Mark Grammar Completed (+15 XP)',
                  icon: Icons.check_circle_rounded,
                  onPressed: () => _completeGrammar(item),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

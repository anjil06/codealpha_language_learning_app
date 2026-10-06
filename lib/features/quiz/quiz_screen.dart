import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/app_providers.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/quiz_model.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizScreen({
    super.key,
    required this.quizId,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _questionIndex = 0;
  String? _selectedOption;
  bool _isAnswerChecked = false;
  bool _isCurrentCorrect = false;

  int _correctCount = 0;
  int _wrongCount = 0;

  // Matching type state
  String? _selectedLeftWord;
  String? _selectedRightWord;
  final Map<String, String> _userMatchedPairs = {};

  void _speak(String text) {
    final tts = ref.read(ttsServiceProvider);
    final currentLang = ref.read(currentLanguageModelProvider);
    tts.speak(text, languageCode: currentLang.ttsLocale);
  }

  void _checkAnswer(QuizQuestionModel question) {
    if (_isAnswerChecked) return;

    bool isCorrect = false;

    if (question.type == QuizType.wordMatching) {
      final pairs = question.matchingPairs ?? {};
      isCorrect = true;
      for (final entry in pairs.entries) {
        if (_userMatchedPairs[entry.key] != entry.value) {
          isCorrect = false;
          break;
        }
      }
    } else {
      if (_selectedOption == null) return;
      isCorrect = _selectedOption!.trim().toLowerCase() ==
          question.correctAnswer.trim().toLowerCase();
    }

    setState(() {
      _isAnswerChecked = true;
      _isCurrentCorrect = isCorrect;
      if (isCorrect) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });
  }

  Future<void> _nextQuestion(QuizModel quiz) async {
    if (_questionIndex < quiz.questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
        _isAnswerChecked = false;
        _isCurrentCorrect = false;
        _selectedLeftWord = null;
        _selectedRightWord = null;
        _userMatchedPairs.clear();
      });

      // Automatically play listening audio if the next question is listening
      final nextQ = quiz.questions[_questionIndex];
      if (nextQ.type == QuizType.listening && nextQ.audioPrompt != null) {
        _speak(nextQ.audioPrompt!);
      }
    } else {
      // Finished all questions
      await _finishQuiz(quiz);
    }
  }

  Future<void> _finishQuiz(QuizModel quiz) async {
    final total = quiz.questions.length;
    final accuracyPercent = total > 0 ? ((_correctCount / total) * 100).toInt() : 0;

    final progressRepo = ref.read(progressRepositoryProvider);
    await progressRepo.recordQuizCompleted(
      quizId: quiz.id,
      scorePercent: accuracyPercent,
      wordsCount: 5,
    );
    ref.invalidate(progressProvider);

    final user = ref.read(userStateProvider);
    final streak = user?.streak ?? 5;

    final result = QuizResultModel(
      quizId: quiz.id,
      quizTitle: quiz.title,
      totalQuestions: total,
      correctCount: _correctCount,
      wrongCount: _wrongCount,
      xpEarned: AppConstants.xpPerQuiz,
      wordsLearned: 5,
      currentStreak: streak,
      recommendedLesson: 'Lesson 2 – Polite Expressions & Courtesies',
      completedAt: DateTime.now(),
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(quizzesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return quizzesAsync.when(
      data: (quizzes) {
        final quiz = quizzes.firstWhere(
          (q) => q.id == widget.quizId,
          orElse: () => quizzes.first,
        );

        final question = quiz.questions[_questionIndex];
        final totalQuestions = quiz.questions.length;
        final progress = (_questionIndex + 1) / totalQuestions;

        return Scaffold(
          appBar: AppBar(
            title: Text(quiz.title),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${_questionIndex + 1} / $totalQuestions',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Progress Bar
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),

                // Question Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question Type Badge
                        _buildTypeBadge(question.type),
                        const SizedBox(height: 14),

                        // Question Prompt
                        Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Interactive Question Interface by Type
                        if (question.type == QuizType.listening) ...[
                          _buildListeningWidget(question),
                          const SizedBox(height: 20),
                        ],

                        if (question.type == QuizType.wordMatching)
                          _buildWordMatchingWidget(question, isDark)
                        else
                          _buildOptionsList(question, isDark),
                      ],
                    ),
                  ),
                ),

                // Bottom Check / Continue Banner
                _buildBottomBanner(question, quiz, isDark),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error loading quiz: $e'))),
    );
  }

  Widget _buildTypeBadge(QuizType type) {
    String label;
    IconData icon;
    Color color;

    switch (type) {
      case QuizType.multipleChoice:
        label = 'Multiple Choice';
        icon = Icons.radio_button_checked_rounded;
        color = AppColors.primary;
        break;
      case QuizType.translation:
        label = 'Translation';
        icon = Icons.translate_rounded;
        color = AppColors.secondary;
        break;
      case QuizType.wordMatching:
        label = 'Word Matching';
        icon = Icons.link_rounded;
        color = AppColors.accent;
        break;
      case QuizType.fillInBlank:
        label = 'Fill in the Blank';
        icon = Icons.edit_note_rounded;
        color = AppColors.warning;
        break;
      case QuizType.listening:
        label = 'Listening';
        icon = Icons.headphones_rounded;
        color = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningWidget(QuizQuestionModel question) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: 'Tap to listen again',
              icon: const Icon(Icons.volume_up_rounded, size: 40, color: AppColors.primary),
              onPressed: () {
                if (question.audioPrompt != null) {
                  _speak(question.audioPrompt!);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap icon to listen again',
            style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(QuizQuestionModel question, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = _selectedOption == option;
        final isCorrect = option.trim().toLowerCase() ==
            question.correctAnswer.trim().toLowerCase();

        Color cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        Color? cardBg;

        if (_isAnswerChecked) {
          if (isSelected && isCorrect) {
            cardBg = AppColors.success.withAlpha(25);
            cardBorder = AppColors.success;
          } else if (isSelected && !isCorrect) {
            cardBg = AppColors.error.withAlpha(25);
            cardBorder = AppColors.error;
          } else if (isCorrect) {
            cardBg = AppColors.success.withAlpha(15);
            cardBorder = AppColors.success;
          }
        } else if (isSelected) {
          cardBg = AppColors.primary.withAlpha(20);
          cardBorder = AppColors.primary;
        }

        return InkWell(
          onTap: _isAnswerChecked
              ? null
              : () {
                  setState(() => _selectedOption = option);
                },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: cardBg ?? Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder, width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (_isAnswerChecked) ...[
                  if (isSelected && isCorrect)
                    const Icon(Icons.check_circle_rounded, color: AppColors.success)
                  else if (isSelected && !isCorrect)
                    const Icon(Icons.cancel_rounded, color: AppColors.error)
                  else if (isCorrect)
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                ] else if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWordMatchingWidget(QuizQuestionModel question, bool isDark) {
    final pairs = question.matchingPairs ?? {};
    final leftWords = pairs.keys.toList();
    final rightWords = pairs.values.toList()..shuffle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a word on the left, then select its English translation on the right:',
          style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left list (target words)
            Expanded(
              child: Column(
                children: leftWords.map((word) {
                  final isMatched = _userMatchedPairs.containsKey(word);
                  final isSelected = _selectedLeftWord == word;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: _isAnswerChecked || isMatched
                          ? null
                          : () {
                              setState(() {
                                _selectedLeftWord = word;
                                _tryMatch(pairs);
                              });
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isMatched
                              ? AppColors.success.withAlpha(25)
                              : isSelected
                                  ? AppColors.primary.withAlpha(25)
                                  : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMatched
                                ? AppColors.success
                                : isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                word,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            if (isMatched)
                              const Icon(Icons.check, size: 16, color: AppColors.success),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 12),
            // Right list (english translations)
            Expanded(
              child: Column(
                children: rightWords.map((word) {
                  final isMatched = _userMatchedPairs.containsValue(word);
                  final isSelected = _selectedRightWord == word;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: _isAnswerChecked || isMatched
                          ? null
                          : () {
                              setState(() {
                                _selectedRightWord = word;
                                _tryMatch(pairs);
                              });
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isMatched
                              ? AppColors.success.withAlpha(25)
                              : isSelected
                                  ? AppColors.accent.withAlpha(25)
                                  : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMatched
                                ? AppColors.success
                                : isSelected
                                    ? AppColors.accent
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                word,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                            if (isMatched)
                              const Icon(Icons.check, size: 16, color: AppColors.success),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _tryMatch(Map<String, String> pairs) {
    if (_selectedLeftWord != null && _selectedRightWord != null) {
      if (pairs[_selectedLeftWord!] == _selectedRightWord!) {
        _userMatchedPairs[_selectedLeftWord!] = _selectedRightWord!;
      }
      _selectedLeftWord = null;
      _selectedRightWord = null;
    }
  }

  Widget _buildBottomBanner(QuizQuestionModel question, QuizModel quiz, bool isDark) {
    final canCheck = question.type == QuizType.wordMatching
        ? _userMatchedPairs.isNotEmpty
        : _selectedOption != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isAnswerChecked
            ? (_isCurrentCorrect
                ? AppColors.success.withAlpha(30)
                : AppColors.error.withAlpha(30))
            : (isDark ? AppColors.darkSurface : Colors.white),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAnswerChecked) ...[
            Row(
              children: [
                Icon(
                  _isCurrentCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: _isCurrentCorrect ? AppColors.success : AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _isCurrentCorrect ? 'Correct! Excellent work.' : 'Incorrect.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isCurrentCorrect ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              question.explanation,
              style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 14),
          ],
          CustomButton(
            label: _isAnswerChecked
                ? (_questionIndex < quiz.questions.length - 1 ? 'Next Question' : 'View Results')
                : 'Check Answer',
            icon: _isAnswerChecked ? Icons.arrow_forward_rounded : Icons.check_rounded,
            backgroundColor: _isAnswerChecked
                ? (_isCurrentCorrect ? AppColors.success : AppColors.error)
                : AppColors.primary,
            onPressed: _isAnswerChecked
                ? () => _nextQuestion(quiz)
                : (canCheck ? () => _checkAnswer(question) : null),
          ),
        ],
      ),
    );
  }
}

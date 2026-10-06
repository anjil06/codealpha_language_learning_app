import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/vocabulary_model.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  List<VocabularyModel> _deck = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  final Set<String> _knownIds = {};
  final Set<String> _unknownIds = {};
  bool _isSessionFinished = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDeck();
    });
  }

  void _initDeck() {
    final vocabRepo = ref.read(vocabularyRepositoryProvider);
    final lang = ref.read(selectedLanguageProvider);
    final deck = vocabRepo.getFlashcardDeck(languageId: lang, limit: 10);
    setState(() {
      _deck = deck;
      _currentIndex = 0;
      _isFlipped = false;
      _knownIds.clear();
      _unknownIds.clear();
      _isSessionFinished = false;
    });
    _flipController.reset();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _markCard(bool known) {
    if (_deck.isEmpty) return;
    final current = _deck[_currentIndex];

    if (known) {
      _knownIds.add(current.id);
      _unknownIds.remove(current.id);
    } else {
      _unknownIds.add(current.id);
      _knownIds.remove(current.id);
    }

    if (_currentIndex < _deck.length - 1) {
      _nextCard();
    } else {
      _finishSession();
    }
  }

  void _nextCard() {
    if (_currentIndex < _deck.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _flipController.reset();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
      _flipController.reset();
    }
  }

  Future<void> _finishSession() async {
    setState(() {
      _isSessionFinished = true;
    });

    final progressRepo = ref.read(progressRepositoryProvider);
    await progressRepo.addXpAndSync(15, wordsDelta: _knownIds.length);
    ref.invalidate(progressProvider);
  }

  void _reviewDifficult() {
    final difficultItems = _deck.where((item) => _unknownIds.contains(item.id)).toList();
    if (difficultItems.isEmpty) return;

    setState(() {
      _deck = difficultItems;
      _currentIndex = 0;
      _isFlipped = false;
      _knownIds.clear();
      _unknownIds.clear();
      _isSessionFinished = false;
    });
    _flipController.reset();
  }

  void _speak(String text) {
    final tts = ref.read(ttsServiceProvider);
    final currentLang = ref.read(currentLanguageModelProvider);
    tts.speak(text, languageCode: currentLang.ttsLocale);
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(currentLanguageModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isSessionFinished) {
      return _buildFinishedView();
    }

    if (_deck.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentWord = _deck[_currentIndex];
    final total = _deck.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentLang.name} Flashcards'),
        actions: [
          IconButton(
            tooltip: 'Restart Deck',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _initDeck,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Card ${_currentIndex + 1} of $total',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    '${_knownIds.length} Known • ${_unknownIds.length} Review',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),

              // 3D Flip Flashcard
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value * pi;
                      final isFront = angle < (pi / 2);

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // perspective
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: isFront
                            ? _buildCardFront(currentWord, isDark)
                            : Transform(
                                transform: Matrix4.identity()..rotateY(pi),
                                alignment: Alignment.center,
                                child: _buildCardBack(currentWord, isDark),
                              ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tap hint
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 16,
                    color: AppColors.lightTextMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isFlipped ? 'Tap to see target word' : 'Tap to flip and reveal translation',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons: Known vs Don't Know
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withAlpha(30),
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error, width: 1.5),
                        minimumSize: const Size(0, 52),
                      ),
                      onPressed: () => _markCard(false),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text("Don't Know ✕"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                      ),
                      onPressed: () => _markCard(true),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Known ✓'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Navigation Controls: Previous / Next
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentIndex > 0 ? _previousCard : null,
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                    label: const Text('Previous'),
                  ),
                  TextButton.icon(
                    onPressed: _currentIndex < total - 1 ? _nextCard : null,
                    label: const Text('Next'),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(VocabularyModel word, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              word.category,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            word.word,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '/${word.pronunciation}/',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 28),
          IconButton.filledTonal(
            tooltip: 'Listen',
            icon: const Icon(Icons.volume_up_rounded, size: 28),
            onPressed: () => _speak(word.word),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(VocabularyModel word, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withAlpha(70),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'English Translation',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            word.translation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (word.exampleSentence.isNotEmpty) ...[
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    '"${word.exampleSentence}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                  if (word.exampleTranslation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      word.exampleTranslation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.lightTextSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinishedView() {
    final total = _deck.length;
    final knownCount = _knownIds.length;
    final accuracy = total > 0 ? ((knownCount / total) * 100).toInt() : 0;
    final hasDifficult = _unknownIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Session Finished')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎉', style: TextStyle(fontSize: 54)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Flashcards Completed',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                '$knownCount / $total Words Mastered',
                style: const TextStyle(fontSize: 18, color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 24),

              // Accuracy Stat Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Accuracy', style: TextStyle(color: AppColors.lightTextSecondary)),
                          const SizedBox(height: 6),
                          Text(
                            '$accuracy%',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: accuracy >= 70 ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 40, width: 1, color: AppColors.lightBorder),
                      const Column(
                        children: [
                          Text('Reward', style: TextStyle(color: AppColors.lightTextSecondary)),
                          SizedBox(height: 6),
                          Text(
                            '+15 XP',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.xpGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (hasDifficult) ...[
                CustomButton(
                  label: 'Review Difficult Words (${_unknownIds.length})',
                  icon: Icons.replay_rounded,
                  backgroundColor: AppColors.warning,
                  onPressed: _reviewDifficult,
                ),
                const SizedBox(height: 12),
              ],
              CustomButton(
                label: 'Practice New Deck',
                icon: Icons.shuffle_rounded,
                onPressed: _initDeck,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Practice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


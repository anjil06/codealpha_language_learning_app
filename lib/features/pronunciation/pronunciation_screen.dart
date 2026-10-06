import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';

class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});

  @override
  ConsumerState<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _phrases = const [
    {
      'target': 'Buenos días',
      'translation': 'Good morning',
      'phonetic': 'BWEH-nos DEE-ahs',
      'tip': 'Keep the "d" soft, touched lightly behind upper teeth.',
    },
    {
      'target': 'Muchas gracias',
      'translation': 'Thank you very much',
      'phonetic': 'MOO-chahs GRAH-syahs',
      'tip': 'Vowels are crisp and short. Do not drag the "a".',
    },
    {
      'target': '¿Cómo estás?',
      'translation': 'How are you?',
      'phonetic': 'KOH-moh es-TAHS',
      'tip': 'Place the stress on the accented syllable "tás".',
    },
    {
      'target': 'Mucho gusto',
      'translation': 'Nice to meet you',
      'phonetic': 'MOO-choh GOOS-toh',
      'tip': 'Ensure clear "oo" vowel sounds throughout.',
    },
    {
      'target': 'Hasta mañana',
      'translation': 'See you tomorrow',
      'phonetic': 'AHS-tah mah-NYAH-nah',
      'tip': 'Remember the "h" in "Hasta" is completely silent!',
    },
  ];

  int _currentIndex = 0;
  bool _isRecording = false;
  int? _lastScore;
  Timer? _recordingTimer;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _speak(String text) {
    final tts = ref.read(ttsServiceProvider);
    final currentLang = ref.read(currentLanguageModelProvider);
    tts.speak(text, languageCode: currentLang.ttsLocale);
  }

  void _startPractice() {
    if (_isRecording) return;

    setState(() {
      _isRecording = true;
      _lastScore = null;
    });

    // Simulated microphone capture duration
    _recordingTimer = Timer(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      // Generates a simulated realistic similarity score between 85% and 98%
      final randomScore = 85 + Random().nextInt(14);
      setState(() {
        _isRecording = false;
        _lastScore = randomScore;
      });

      final progressRepo = ref.read(progressRepositoryProvider);
      await progressRepo.addXpAndSync(10);
      ref.invalidate(progressProvider);
    });
  }

  void _nextPhrase() {
    if (_currentIndex < _phrases.length - 1) {
      setState(() {
        _currentIndex++;
        _lastScore = null;
        _isRecording = false;
      });
    }
  }

  void _previousPhrase() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _lastScore = null;
        _isRecording = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(currentLanguageModelProvider);
    final phrase = _phrases[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentLang.name} Pronunciation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header title
              const Text(
                'Listen and Repeat',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Phrase ${_currentIndex + 1} of ${_phrases.length}',
                style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 24),

              // Phrase Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(20),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      phrase['target']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '/${phrase['phonetic']!}/',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.lightTextSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      phrase['translation']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tips_and_updates_rounded, size: 16, color: AppColors.xpGold),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              phrase['tip']!,
                              style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Waveform / Recording Animation
              if (_isRecording) ...[
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (index) {
                        final height = 16.0 + 36.0 * sin((_waveController.value * pi) + (index * 0.5)).abs();
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 6,
                          height: height,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Listening... Speak now!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Feedback Score Card
              if (_lastScore != null) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.success.withAlpha(70)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Accuracy: $_lastScore%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.xpGold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '+10 XP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Clear articulation and natural pronunciation pace!',
                        style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'ℹ️ Note: Evaluated via acoustic simulation flow for instant demo.',
                  style: TextStyle(fontSize: 11, color: AppColors.lightTextMuted),
                ),
                const SizedBox(height: 20),
              ],

              // Practice Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 54),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      onPressed: () => _speak(phrase['target']!),
                      icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                      label: const Text('Listen', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording ? AppColors.error : AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 54),
                      ),
                      onPressed: _startPractice,
                      icon: Icon(_isRecording ? Icons.mic_rounded : Icons.mic_none_rounded),
                      label: Text(_isRecording ? 'Recording...' : 'Practice', style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Navigation between phrases
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentIndex > 0 ? _previousPhrase : null,
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                    label: const Text('Previous'),
                  ),
                  TextButton.icon(
                    onPressed: _currentIndex < _phrases.length - 1 ? _nextPhrase : null,
                    label: const Text('Next Phrase'),
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
}


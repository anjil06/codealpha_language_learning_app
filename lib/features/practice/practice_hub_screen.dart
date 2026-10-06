import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';

class PracticeHubScreen extends ConsumerWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(currentLanguageModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(currentLang.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('Practice ${currentLang.name}'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Interactive Drills',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Strengthen retention, speak naturally, and challenge yourself with interactive quizzes.',
            style: TextStyle(fontSize: 14, color: AppColors.lightTextSecondary),
          ),
          const SizedBox(height: 20),

          // 1. Flashcards Card
          _buildPracticeCard(
            context,
            title: 'Interactive Flashcards',
            description: 'Flip through active vocabulary cards, test memory recall, and review difficult words.',
            icon: Icons.flip_to_back_rounded,
            iconColor: AppColors.secondary,
            badge: '10 Cards / Deck',
            onTap: () => context.push('/flashcards'),
          ),
          const SizedBox(height: 16),

          // 2. Pronunciation Card
          _buildPracticeCard(
            context,
            title: 'Pronunciation Lab',
            description: 'Listen to native audio pronunciations and practice speaking into the microphone with instant feedback.',
            icon: Icons.record_voice_over_rounded,
            iconColor: AppColors.primary,
            badge: 'Listen & Repeat',
            onTap: () => context.push('/pronunciation'),
          ),
          const SizedBox(height: 16),

          // 3. Quiz Challenge Card
          _buildPracticeCard(
            context,
            title: 'Mastery Quizzes',
            description: 'Multiple choice, translation, word matching, fill-in-the-blank, and listening comprehension challenges.',
            icon: Icons.quiz_rounded,
            iconColor: AppColors.xpGold,
            badge: '10 Questions Each',
            onTap: () => context.push('/quiz/q1'),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.lightTextMuted),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


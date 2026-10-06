import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/sample_data.dart';
import '../../core/services/app_providers.dart';
import '../../core/widgets/empty_view.dart';
import '../../models/vocabulary_model.dart';

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _speak(String word) {
    final tts = ref.read(ttsServiceProvider);
    final currentLang = ref.read(currentLanguageModelProvider);
    tts.speak(word, languageCode: currentLang.ttsLocale);
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(currentLanguageModelProvider);
    final categoryFilter = _selectedCategory == 'All' ? null : _selectedCategory;
    final vocabAsync = ref.watch(vocabularyProvider(categoryFilter));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allCategories = ['All', ...SampleData.vocabularyCategories];

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentLang.name} Vocabulary'),
        actions: [
          IconButton(
            tooltip: 'Practice Flashcards',
            icon: const Icon(Icons.flip_to_back_rounded, color: AppColors.primary),
            onPressed: () => context.push('/flashcards'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search words, meanings...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim().toLowerCase());
              },
            ),
          ),

          // Horizontal Category Pills
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: allCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = allCategories[index];
                final isSelected = cat == _selectedCategory;

                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // Vocabulary List
          Expanded(
            child: vocabAsync.when(
              data: (items) {
                final filtered = items.where((item) {
                  if (_searchQuery.isEmpty) return true;
                  return item.word.toLowerCase().contains(_searchQuery) ||
                      item.translation.toLowerCase().contains(_searchQuery) ||
                      item.pronunciation.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyView(
                    title: 'No Words Found',
                    message: 'Try selecting another category or clear your search keyword.',
                    icon: Icons.search_off_rounded,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildVocabCard(item, isDark);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Unable to load vocabulary: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabCard(VocabularyModel item, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.word,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '/${item.pronunciation}/',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.translation,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Speaker Audio Button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: 'Listen to pronunciation',
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                    onPressed: () => _speak(item.word),
                  ),
                ),
              ],
            ),
            if (item.exampleSentence.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface.withAlpha(150) : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_outlined, size: 14, color: AppColors.lightTextMuted),
                        const SizedBox(width: 6),
                        const Text(
                          'Example',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightTextMuted,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => _speak(item.exampleSentence),
                          child: const Icon(Icons.volume_down_rounded, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${item.exampleSentence}"',
                      style: const TextStyle(fontSize: 13.5, fontStyle: FontStyle.italic),
                    ),
                    if (item.exampleTranslation.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.exampleTranslation,
                        style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';
import '../lessons/lessons_screen.dart';
import '../vocabulary/vocabulary_screen.dart';
import '../grammar/grammar_screen.dart';

class LearnHubScreen extends ConsumerStatefulWidget {
  const LearnHubScreen({super.key});

  @override
  ConsumerState<LearnHubScreen> createState() => _LearnHubScreenState();
}

class _LearnHubScreenState extends ConsumerState<LearnHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(currentLanguageModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(currentLang.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('Learn ${currentLang.name}'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.lightTextSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Lessons', icon: Icon(Icons.school_rounded, size: 20)),
            Tab(text: 'Vocabulary', icon: Icon(Icons.translate_rounded, size: 20)),
            Tab(text: 'Grammar', icon: Icon(Icons.menu_book_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LessonsScreen(),
          VocabularyScreen(),
          GrammarScreen(),
        ],
      ),
    );
  }
}


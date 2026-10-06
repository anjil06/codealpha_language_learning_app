import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';
import '../../models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final nameController = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final updated = user.copyWith(name: nameController.text.trim());
                ref.read(authRepositoryProvider).updateUser(updated);
                ref.read(userStateProvider.notifier).setUser(updated);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog(BuildContext context, WidgetRef ref, UserModel user) {
    int selected = user.dailyGoal;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Set Daily Learning Goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [5, 10, 15, 20].map((goal) {
                final isSelected = selected == goal;
                return ListTile(
                  dense: true,
                  title: Text('$goal lessons / day'),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: isSelected ? AppColors.primary : AppColors.lightTextMuted,
                  ),
                  onTap: () {
                    setState(() => selected = goal);
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(storageServiceProvider).setDailyGoal(selected);
                  final updated = user.copyWith(dailyGoal: selected);
                  await ref.read(authRepositoryProvider).updateUser(updated);
                  ref.read(userStateProvider.notifier).setUser(updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save Goal'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider);
    final currentLang = ref.watch(currentLanguageModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = user?.name ?? 'Anjil Reddy';
    final userEmail = user?.email ?? 'anjil@example.com';
    final userXp = user?.xp ?? 45;
    final userLevel = user?.level ?? 1;
    final userStreak = user?.streak ?? 5;
    final lessonsDone = user?.lessonsCompleted ?? 7;
    final wordsLearned = user?.wordsLearned ?? 24;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Avatar & Info
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(50),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.xpGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded, size: 18, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 10),

            // Language Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Learning: ${currentLang.flag} ${currentLang.name}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards Row 1: XP, Level, Streak
            Row(
              children: [
                Expanded(
                  child: _buildProfileStatCard(
                    title: 'Total XP',
                    value: '$userXp',
                    icon: Icons.stars_rounded,
                    color: AppColors.xpGold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildProfileStatCard(
                    title: 'Level',
                    value: '$userLevel',
                    icon: Icons.military_tech_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildProfileStatCard(
                    title: 'Streak',
                    value: '$userStreak d',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.streakFire,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats Cards Row 2: Lessons Completed, Words Learned
            Row(
              children: [
                Expanded(
                  child: _buildProfileStatCard(
                    title: 'Lessons Completed',
                    value: '$lessonsDone',
                    icon: Icons.school_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProfileStatCard(
                    title: 'Words Learned',
                    value: '$wordsLearned',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Profile Actions List
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      if (user != null) {
                        _showEditProfileDialog(context, ref, user);
                      }
                    },
                  ),
                  _buildDivider(isDark),
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.secondary),
                    title: const Text('Change Language'),
                    subtitle: Text('${currentLang.flag} ${currentLang.name}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/language-select'),
                  ),
                  _buildDivider(isDark),
                  ListTile(
                    leading: const Icon(Icons.flag_outlined, color: AppColors.warning),
                    title: const Text('Daily Learning Goal'),
                    subtitle: Text('${user?.dailyGoal ?? 10} lessons/day'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      if (user != null) {
                        _showGoalDialog(context, ref, user);
                      }
                    },
                  ),
                  _buildDivider(isDark),
                  ListTile(
                    leading: const Icon(Icons.notifications_none_rounded, color: AppColors.accent),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/settings'),
                  ),
                  _buildDivider(isDark),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: Colors.blueGrey),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/settings'),
                  ),
                  _buildDivider(isDark),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                    title: const Text('Logout', style: TextStyle(color: AppColors.error)),
                    onTap: () async {
                      await ref.read(authRepositoryProvider).logout();
                      ref.read(userStateProvider.notifier).setUser(null);
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}


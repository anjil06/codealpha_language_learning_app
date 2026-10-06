import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  factory StatBadge.streak(int streak, {VoidCallback? onTap}) {
    return StatBadge(
      icon: Icons.local_fire_department_rounded,
      label: '$streak Days',
      iconColor: AppColors.streakFire,
      backgroundColor: AppColors.streakFire.withAlpha(25),
      onTap: onTap,
    );
  }

  factory StatBadge.xp(int xp, {VoidCallback? onTap}) {
    return StatBadge(
      icon: Icons.stars_rounded,
      label: '$xp XP',
      iconColor: AppColors.xpGold,
      backgroundColor: AppColors.xpGold.withAlpha(25),
      onTap: onTap,
    );
  }

  factory StatBadge.level(int level, {VoidCallback? onTap}) {
    return StatBadge(
      icon: Icons.military_tech_rounded,
      label: 'Lvl $level',
      iconColor: AppColors.primary,
      backgroundColor: AppColors.primary.withAlpha(25),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.lightBackground),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: iconColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: child,
      );
    }

    return child;
  }
}


import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark || isDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(70),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Speech bubble outline & book overlay icon
              Icon(
                Icons.chat_bubble_rounded,
                size: size * 0.58,
                color: Colors.white.withAlpha(220),
              ),
              Positioned(
                child: Icon(
                  Icons.translate_rounded,
                  size: size * 0.34,
                  color: AppColors.primaryDark,
                ),
              ),
              Positioned(
                bottom: size * 0.14,
                right: size * 0.14,
                child: Container(
                  padding: EdgeInsets.all(size * 0.04),
                  decoration: const BoxDecoration(
                    color: AppColors.xpGold,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: size * 0.18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'LinguaLearn',
            style: TextStyle(
              fontSize: size * 0.36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Learn & Speak Naturally',
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w500,
              color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}


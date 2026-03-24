// 🤖 Copilot: Generate AppTextStyles class using Inter font family.
// Include heading, body, caption, label styles. All use AppColors.
// Follow Flutter TextStyle best practices, static const throughout.

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Inter';

  // Display
  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily, fontSize: 28,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily, fontSize: 24,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily, fontSize: 20,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily, fontSize: 16,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily, fontSize: 14,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 16,
    fontWeight: FontWeight.w400, color: AppColors.textPrimary,
    height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 14,
    fontWeight: FontWeight.w400, color: AppColors.textPrimary,
    height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily, fontSize: 12,
    fontWeight: FontWeight.w400, color: AppColors.textSecondary,
    height: 1.4,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 14,
    fontWeight: FontWeight.w500, color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 12,
    fontWeight: FontWeight.w500, color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily, fontSize: 11,
    fontWeight: FontWeight.w500, color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily, fontSize: 11,
    fontWeight: FontWeight.w400, color: AppColors.textTertiary,
    height: 1.4,
  );

  // Button
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 16,
    fontWeight: FontWeight.w600, color: AppColors.textOnPrimary,
    letterSpacing: 0.3,
  );
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 14,
    fontWeight: FontWeight.w600, letterSpacing: 0.2,
  );

  // Special
  static const TextStyle metric = TextStyle(
    fontFamily: _fontFamily, fontSize: 22,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle tabLabel = TextStyle(
    fontFamily: _fontFamily, fontSize: 11,
    fontWeight: FontWeight.w500, letterSpacing: 0.2,
  );
  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily, fontSize: 10,
    fontWeight: FontWeight.w500, letterSpacing: 0.3,
  );
  static const TextStyle chip = TextStyle(
    fontFamily: _fontFamily, fontSize: 11,
    fontWeight: FontWeight.w500, letterSpacing: 0.2,
  );
  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily, fontSize: 10,
    fontWeight: FontWeight.w600, letterSpacing: 1.2,
  );
}
// 🤖 Copilot: Generate AppColors class with all color constants
// for a Flutter EdTech app. Include brand colors, role colors,
// subject colors, attendance status colors, semantic colors.
// Use static const Color throughout.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4A3AFF);
  static const Color primaryLight = Color(0xFF7B6EFF);
  static const Color primaryDark = Color(0xFF2D1FDB);
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF9A6C);

  // Role Accents
  static const Color studentBlue = Color(0xFF185FA5);
  static const Color teacherPurple = Color(0xFF534AB7);
  static const Color parentTeal = Color(0xFF0F6E56);

  // Semantic
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFFA502);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF1E90FF);

  // Attendance Status
  static const Color present = Color(0xFF00C48C);
  static const Color absent = Color(0xFFFF4757);
  static const Color late = Color(0xFFFFA502);
  static const Color onLeave = Color(0xFF747D8C);
  static const Color holiday = Color(0xFFDFE4EA);

  // Subject Colors
  static const Color mathColor = Color(0xFF185FA5);
  static const Color sciColor = Color(0xFF3B6D11);
  static const Color engColor = Color(0xFFFF6B35);
  static const Color hindiColor = Color(0xFFBA7517);
  static const Color sstColor = Color(0xFF534AB7);
  static const Color itColor = Color(0xFF0F6E56);
  static const Color defaultSubjectColor = Color(0xFF888780);

  // Backgrounds
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF5F5F7);
  static const Color bgTertiary = Color(0xFFEEEEF2);
  static const Color bgCard = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);

  // Misc
  static const Color divider = Color(0xFFF3F4F6);
  static const Color shimmerBase = Color(0xFFE8E8E8);
  static const Color shimmerHigh = Color(0xFFF5F5F5);

  // Fee status
  static const Color feePaid = Color(0xFF00C48C);
  static const Color feePending = Color(0xFFFFA502);
  static const Color feeOverdue = Color(0xFFFF4757);

  // Helper: get subject color by subject ID
  static Color subjectColor(String subjectId) {
    switch (subjectId) {
      case 'SUB_MATH':
        return mathColor;
      case 'SUB_SCI':
        return sciColor;
      case 'SUB_ENG':
        return engColor;
      case 'SUB_HIN':
        return hindiColor;
      case 'SUB_SST':
        return sstColor;
      case 'SUB_IT':
        return itColor;
      default:
        return defaultSubjectColor;
    }
  }

  // Helper: get attendance color by status
  static Color attendanceColor(String status) {
    switch (status) {
      case 'P':
        return present;
      case 'A':
        return absent;
      case 'Late':
        return late;
      case 'L':
        return onLeave;
      default:
        return holiday;
    }
  }

  // Helper: get fee status color by status
  static Color feeStatusColor(String status) {
    switch (status) {
      case 'paid':
        return feePaid;
      case 'pending':
        return feePending;
      case 'overdue':
        return feeOverdue;
      default:
        return feePending;
    }
  }
}

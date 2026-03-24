import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Teacher Home'),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_rounded,
              size: 64,
              color: AppColors.teacherPurple,
            ),
            SizedBox(height: 12),
            Text(
              'Teacher Home',
              style: AppTextStyles.h2,
            ),
            SizedBox(height: 8),
            Text(
              'Mr. R.K. Sharma · Mathematics',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

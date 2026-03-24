import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ParentAcademicsScreen extends StatelessWidget {
  const ParentAcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Academics'),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 64,
              color: AppColors.parentTeal,
            ),
            SizedBox(height: 12),
            Text(
              'Academics',
              style: AppTextStyles.h2,
            ),
          ],
        ),
      ),
    );
  }
}

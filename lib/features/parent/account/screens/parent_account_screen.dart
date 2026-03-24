import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ParentAccountScreen extends StatelessWidget {
  const ParentAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_rounded,
              size: 64,
              color: AppColors.parentTeal,
            ),
            SizedBox(height: 12),
            Text(
              'My Account',
              style: AppTextStyles.h2,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class TeacherClassroomScreen extends StatelessWidget {
  const TeacherClassroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('My Class'),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.class_rounded,
              size: 64,
              color: AppColors.teacherPurple,
            ),
            SizedBox(height: 12),
            Text(
              'My Class',
              style: AppTextStyles.h2,
            ),
          ],
        ),
      ),
    );
  }
}

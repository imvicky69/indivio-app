import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class StudentDetailsCard extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailsCard({super.key, required this.student});

  String _safe(Map m, List<String> path, [String fallback = '-']) {
    try {
      dynamic cur = m;
      for (final p in path) {
        cur = cur[p];
      }
      return cur?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _safe(student, ['personal', 'fullName']);
    final admission = _safe(student, ['academic', 'admissionNumber']);
    final className = _safe(student, ['academic', 'className']);
    final section = _safe(student, ['academic', 'section']);
    final roll = _safe(student, ['academic', 'rollNumber']);
    final phone = _safe(student, ['contact', 'phone'], '-');
    final email = _safe(student, ['contact', 'email'], '-');
    final father = _safe(student, ['personal', 'fatherName'], '-');
    final photo = _safe(student, ['personal', 'photoUrl'], '');

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.bgTertiary,
              backgroundImage:
                  photo.isNotEmpty ? AssetImage(photo) as ImageProvider : null,
              child: photo.isEmpty
                  ? Text(
                      fullName.isNotEmpty ? fullName[0] : 'S',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.textOnPrimary),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName, style: AppTextStyles.h2),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                          label: 'Class',
                          value:
                              '$className ${section.isNotEmpty ? '- $section' : ''}'),
                      _InfoChip(label: 'Roll', value: roll),
                      _InfoChip(label: 'Adm. No.', value: admission),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Parent: $father', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Phone: $phone', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text('Email: $email', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: AppTextStyles.labelSmall),
          Text(value, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

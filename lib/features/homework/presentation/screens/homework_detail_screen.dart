import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/fade_in_slide.dart';
import '../../../student/home/providers/student_home_provider.dart';

class HomeworkDetailScreen extends ConsumerWidget {
  final String homeworkId;

  const HomeworkDetailScreen({super.key, required this.homeworkId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(homeworkDetailProvider(homeworkId));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Homework Detail'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: homeworkAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (homework) {
          if (homework == null) {
            return const Center(child: Text('Homework not found'));
          }

          final subjectColor = AppColors.subjectColor(homework.subjectId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInSlide(
                  delay: const Duration(milliseconds: 0),
                  child: _SubjectHeader(
                    subjectName: homework.subjectName,
                    color: subjectColor,
                    dueDate: homework.dueDate,
                  ),
                ),
                const SizedBox(height: AppDimensions.gapLG),
                FadeInSlide(
                  delay: const Duration(milliseconds: 100),
                  child: Text(homework.title, style: AppTextStyles.h2),
                ),
                const SizedBox(height: AppDimensions.gapMD),
                FadeInSlide(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    homework.description,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: AppDimensions.gapSection),
                if (homework.attachments.isNotEmpty) ...[
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: const Text('Attachments', style: AppTextStyles.h4),
                  ),
                  const SizedBox(height: AppDimensions.gapMD),
                  ...homework.attachments.asMap().entries.map((entry) {
                    return FadeInSlide(
                      delay: Duration(milliseconds: 300 + (entry.key * 50)),
                      child: _AttachmentTile(attachment: entry.value),
                    );
                  }),
                ],
                const SizedBox(height: 40),
                FadeInSlide(
                  delay: const Duration(milliseconds: 500),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Homework submission feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Submit My Work'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.studentBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SubjectHeader extends StatelessWidget {
  final String subjectName;
  final Color color;
  final String dueDate;

  const _SubjectHeader({
    required this.subjectName,
    required this.color,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = dueDate;
    try {
      formattedDate = DateFormat('EEEE, MMM d').format(DateTime.parse(dueDate));
    } catch (_) {}

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Text(
            subjectName,
            style: AppTextStyles.labelLarge
                .copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('DUE DATE', style: AppTextStyles.caption),
            Text(formattedDate,
                style: AppTextStyles.labelSmall
                    .copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final Map<String, dynamic> attachment;

  const _AttachmentTile({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final fileName = attachment['name'] as String? ?? 'file';
    // final url = attachment['url'] as String? ?? '';
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapSM),
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isPdf ? Colors.red : AppColors.studentBlue)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
              color: isPdf ? Colors.red : AppColors.studentBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.gapMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text('Tap to view file', style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Open URL
            },
            icon: const Icon(Icons.open_in_new,
                size: 20, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

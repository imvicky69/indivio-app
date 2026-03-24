import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/classroom_provider.dart';

class SyllabusTrackerWidget extends ConsumerWidget {
  const SyllabusTrackerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syllabusAsync = ref.watch(syllabusProvider);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        side: const BorderSide(color: AppColors.borderLight, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Syllabus Progress', style: AppTextStyles.h3),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(color: AppColors.studentBlue)),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.gapSM),
            syllabusAsync.when(
              loading: () => Column(
                children: [
                  const ShimmerBox(height: 52, width: double.infinity),
                  const SizedBox(height: AppDimensions.gapSM),
                  const ShimmerBox(height: 52, width: double.infinity),
                ],
              ),
              error: (e, s) => const EmptyStateWidget(icon: Icons.menu_book_outlined, title: 'Error loading syllabus'),
              data: (trackerList) {
                if (trackerList.isEmpty) {
                  return const EmptyStateWidget(icon: Icons.menu_book_outlined, title: 'No syllabus data');
                }

                return Column(
                  children: trackerList.map((tracker) => _SyllabusSubjectRow(tracker: tracker)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SyllabusSubjectRow extends StatelessWidget {
  final Map<String, dynamic> tracker;

  const _SyllabusSubjectRow({required this.tracker});

  @override
  Widget build(BuildContext context) {
    final subjectId = tracker['subjectId'] as String? ?? '';
    final subjectName = tracker['subjectName'] as String? ?? 'Subject';
    final totalChapters = tracker['totalChapters'] as int? ?? 1;
    final completedChapters = tracker['completedChapters'] as int? ?? 0;
    final completionPercent = (completedChapters / totalChapters * 100).toInt();
    final subjectColor = AppColors.subjectColor(subjectId);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: subjectColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppDimensions.gapSM),
              Expanded(
                child: Text(subjectName, style: AppTextStyles.labelLarge),
              ),
              Text('$completedChapters/$totalChapters chapters', style: AppTextStyles.caption),
              const SizedBox(width: AppDimensions.gapSM),
              Text(
                '$completionPercent%',
                style: AppTextStyles.labelMedium.copyWith(color: _getProgressColor(completionPercent)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: completionPercent / 100,
              minHeight: 8,
              backgroundColor: AppColors.bgTertiary,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(completionPercent)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${totalChapters - completedChapters} chapters remaining',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int percent) {
    if (percent >= 75) return AppColors.success;
    if (percent >= 50) return AppColors.warning;
    return AppColors.error;
  }
}

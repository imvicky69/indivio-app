// lib/features/student/home/widgets/homework_today_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../homework/data/homework_model.dart';
import '../providers/student_home_provider.dart';

class HomeworkTodayWidget extends ConsumerWidget {
  const HomeworkTodayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHw = ref.watch(homeworkTodayProvider);

    return asyncHw.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(count: 0, context: context),
          const SizedBox(height: AppDimensions.gapSM),
          const ShimmerBox(
              height: 70,
              width: double.infinity,
              borderRadius: AppDimensions.radiusMD),
          const SizedBox(height: AppDimensions.gapSM),
          const ShimmerBox(
              height: 70,
              width: double.infinity,
              borderRadius: AppDimensions.radiusMD),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (hwList) {
        debugPrint(
            'HomeworkTodayWidget data: ${hwList.map((h) => h.title).toList()}');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(count: hwList.length, context: context),
            const SizedBox(height: AppDimensions.gapSM),
            if (hwList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.success, size: AppDimensions.iconXL),
                    SizedBox(height: AppDimensions.gapSM),
                    Text('No homework due today',
                        style: AppTextStyles.bodyMedium),
                    SizedBox(height: 2),
                    Text('Enjoy your free time!', style: AppTextStyles.caption),
                  ],
                ),
              )
            else
              ...hwList.map((hw) => _HomeworkItem(hw: hw)),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.context});
  final int count;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Today's Homework", style: AppTextStyles.h4),
        if (count > 0) ...[
          const SizedBox(width: AppDimensions.gapSM),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
        const Spacer(),
        TextButton(
          onPressed: () => context.go('/student/classroom'),
          child: const Text('See All', style: AppTextStyles.labelSmall),
        ),
      ],
    );
  }
}

class _HomeworkItem extends StatelessWidget {
  const _HomeworkItem({required this.hw});
  final HomeworkModel hw;

  @override
  Widget build(BuildContext context) {
    final subjectId = hw.subjectId;
    final subjectName = hw.subjectName;
    final title = hw.title;
    final dueTime = hw.dueTime;
    final isUrgent = hw.isUrgent;
    final attachments = hw.attachments;
    final subjectColor = AppColors.subjectColor(subjectId);

    return InkWell(
      onTap: () => context.push('/student/homework/${hw.homeworkId.trim()}'),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.gapSM),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Row(
          children: [
            // colored left stripe
            Container(
              width: 4,
              height: 88,
              decoration: BoxDecoration(
                color: subjectColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusMD),
                  bottomLeft: Radius.circular(AppDimensions.radiusMD),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subjectName,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: subjectColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded,
                                  size: AppDimensions.iconXS,
                                  color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text('Due: $dueTime',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.textTertiary)),
                              if (attachments.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                const Icon(Icons.attach_file_rounded,
                                    size: AppDimensions.iconXS,
                                    color: AppColors.textTertiary),
                                Text('${attachments.length} file',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textTertiary)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(
                          'Urgent',
                          style: AppTextStyles.chip
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

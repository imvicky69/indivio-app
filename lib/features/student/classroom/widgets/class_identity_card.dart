import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/classroom_provider.dart';

class ClassIdentityCard extends ConsumerWidget {
  final String classId;
  final String studentId;
  final String rollNumber;

  const ClassIdentityCard({
    super.key,
    required this.classId,
    required this.studentId,
    required this.rollNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classInfoAsync = ref.watch(classInfoProvider(classId));

    return classInfoAsync.when(
      loading: () => const ShimmerBox(height: 110, width: double.infinity),
      error: (err, stack) => const EmptyStateWidget(
        icon: Icons.class_outlined,
        title: 'Class info unavailable',
      ),
      data: (classInfo) {
        if (classInfo == null) {
          return const EmptyStateWidget(
            icon: Icons.class_outlined,
            title: 'Class data not found',
          );
        }

        final teacherId = classInfo['classTeacherId'] as String;
        final teacherAsync = ref.watch(classTeacherProvider(teacherId));

        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            side: const BorderSide(color: AppColors.borderLight, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classInfo['name'] ?? 'Class',
                            style: AppTextStyles.h2
                                .copyWith(color: AppColors.studentBlue),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${classInfo['section']} · Academic Year ${classInfo['academicYear']}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.studentBlue.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            'Roll No. $rollNumber',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.studentBlue),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.bgTertiary,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            classInfo['board'] ?? 'CBSE',
                            style: AppTextStyles.chip,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.gapMD),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: AppDimensions.gapMD),
                teacherAsync.when(
                  loading: () =>
                      const ShimmerBox(height: 40, width: double.infinity),
                  error: (e, s) => const Text('Teacher info unavailable'),
                  data: (teacher) {
                    if (teacher == null) return const SizedBox.shrink();

                    final fullName = teacher['personal']['fullName'] as String;
                    final names = fullName.split(' ');
                    final initials = names.length > 1
                        ? '${names.first[0]}${names.last[0]}'
                        : names.first[0];

                    return InkWell(
                      onTap: () {}, // InkWell as requested
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                AppColors.teacherPurple.withValues(alpha: 0.15),
                            child: Text(
                              initials,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.teacherPurple),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.gapSM),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fullName, style: AppTextStyles.labelLarge),
                              const Text('Class Teacher',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textTertiary,
                              size: AppDimensions.iconMD),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

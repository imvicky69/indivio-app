// lib/features/student/home/widgets/leave_status_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/student_home_provider.dart';

class LeaveStatusWidget extends ConsumerWidget {
  const LeaveStatusWidget({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLeave = ref.watch(activeLeaveProvider(studentId));

    return asyncLeave.when(
      loading: () => const ShimmerBox(
          height: 60,
          width: double.infinity,
          borderRadius: AppDimensions.radiusMD),
      error: (_, __) => const SizedBox.shrink(),
      data: (leave) {
        if (leave == null) return const SizedBox.shrink();

        final isPending = leave['status'] == 'pending';
        final fromDate = leave['fromDate'] as String? ?? '';
        final toDate = leave['toDate'] as String? ?? '';
        final totalDays = leave['totalDays'] as int? ?? 1;
        final reason = leave['reason'] as String? ?? '';
        final alertColor = isPending ? AppColors.warning : AppColors.success;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
            vertical: AppDimensions.paddingMD,
          ),
          decoration: BoxDecoration(
            color: alertColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: alertColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(
                isPending
                    ? Icons.hourglass_empty_rounded
                    : Icons.event_available_rounded,
                color: alertColor,
                size: AppDimensions.iconLG,
              ),
              const SizedBox(width: AppDimensions.gapMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPending ? 'Leave Pending Approval' : 'Leave Approved',
                      style: AppTextStyles.labelLarge,
                    ),
                    Text(
                      '$fromDate → $toDate · $totalDays day(s)',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      reason,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.gapSM),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: alertColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  isPending ? 'Pending' : 'Approved',
                  style: AppTextStyles.chip.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// lib/features/student/home/widgets/quick_stats_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/dev_config.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/student_home_provider.dart';

class QuickStatsRow extends ConsumerWidget {
  const QuickStatsRow({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSummary = ref.watch(attendanceSummaryProvider(AttendanceParams(
      studentId: studentId,
      month: DevConfig.effectiveMonth(),
      year: DevConfig.effectiveYear(),
    )));
    final asyncAssignments = ref.watch(pendingAssignmentsProvider(studentId));
    final asyncFee = ref.watch(pendingFeeProvider(studentId));

    return Row(
      children: [
        // Card 1 — Attendance %
        Expanded(
          child: asyncSummary.when(
            loading: () => const ShimmerBox(
                height: 72,
                width: double.infinity,
                borderRadius: AppDimensions.radiusMD),
            error: (_, __) => const _StatCard(
                value: '--',
                label: 'This Month',
                valueColor: AppColors.textTertiary),
            data: (summary) {
              final pct =
                  (summary?['attendancePercent'] as num?)?.toDouble() ?? 0;
              final color = pct >= 85
                  ? AppColors.success
                  : pct >= 75
                      ? AppColors.warning
                      : AppColors.error;
              return _StatCard(
                value: '${pct.toStringAsFixed(0)}%',
                label: 'This Month',
                valueColor: color,
              );
            },
          ),
        ),
        const SizedBox(width: AppDimensions.gapSM),

        // Card 2 — Pending Assignments
        Expanded(
          child: asyncAssignments.when(
            loading: () => const ShimmerBox(
                height: 72,
                width: double.infinity,
                borderRadius: AppDimensions.radiusMD),
            error: (_, __) => const _StatCard(
                value: '--',
                label: 'Pending',
                valueColor: AppColors.textTertiary),
            data: (count) {
              final color = count == 0
                  ? AppColors.success
                  : count <= 2
                      ? AppColors.warning
                      : AppColors.error;
              return _StatCard(
                value: '$count',
                label: 'Pending',
                valueColor: color,
              );
            },
          ),
        ),
        const SizedBox(width: AppDimensions.gapSM),

        // Card 3 — Next Fee
        Expanded(
          child: asyncFee.when(
            loading: () => const ShimmerBox(
                height: 72,
                width: double.infinity,
                borderRadius: AppDimensions.radiusMD),
            error: (_, __) => const _StatCard(
                value: '--',
                label: 'All Fees',
                valueColor: AppColors.textTertiary),
            data: (fee) {
              if (fee == null) {
                return const _StatCard(
                  value: '✓ Clear',
                  label: 'All Fees',
                  valueColor: AppColors.success,
                );
              }
              final isOverdue = fee.isOverdue;
              final dueDateStr = fee.dueDate;
              String displayVal = dueDateStr;
              try {
                final dt = DateTime.parse(dueDateStr);
                displayVal = DateFormat('MMM d').format(dt);
              } catch (_) {}
              final color = isOverdue ? AppColors.error : AppColors.warning;
              return _StatCard(
                value: displayVal,
                label: 'Fee Due',
                valueColor: color,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.metric.copyWith(color: valueColor)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

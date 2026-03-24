// lib/features/student/home/widgets/fee_alert_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/student_home_provider.dart';

class FeeAlertCard extends ConsumerWidget {
  const FeeAlertCard({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFee = ref.watch(pendingFeeProvider(studentId));

    return asyncFee.when(
      loading: () => const ShimmerBox(
          height: 88,
          width: double.infinity,
          borderRadius: AppDimensions.radiusLG),
      error: (_, __) => const SizedBox.shrink(),
      data: (fee) {
        if (fee == null) return const SizedBox.shrink();

        final isOverdue = fee.isOverdue;
        final netPayable = fee.netPayable;
        final lateFine = fee.lateFine.toInt();
        final dueDateStr = fee.dueDate;
        String formattedDate = dueDateStr;
        try {
          formattedDate =
              DateFormat('d MMMM yyyy').format(DateTime.parse(dueDateStr));
        } catch (_) {}

        final alertColor = isOverdue ? AppColors.error : AppColors.warning;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          decoration: BoxDecoration(
            color: alertColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: alertColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                isOverdue
                    ? Icons.error_outline_rounded
                    : Icons.payment_outlined,
                color: alertColor,
                size: AppDimensions.iconXL,
              ),
              const SizedBox(width: AppDimensions.gapMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOverdue ? 'Fee Overdue!' : 'Fee Due Soon',
                      style: AppTextStyles.h4.copyWith(color: alertColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOverdue
                          ? '₹$netPayable overdue since $formattedDate'
                          : '₹$netPayable due by $formattedDate',
                      style: AppTextStyles.bodySmall,
                    ),
                    if (lateFine > 0)
                      Text(
                        'Late fine: ₹$lateFine added',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.error),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.gapMD),
              ElevatedButton(
                onPressed: () => context.push('/student/fees'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: alertColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                ),
                child: const Text('Pay Now', style: AppTextStyles.buttonMedium),
              ),
            ],
          ),
        );
      },
    );
  }
}

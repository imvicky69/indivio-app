// lib/features/student/home/widgets/today_status_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/student_home_provider.dart';

class TodayStatusBanner extends ConsumerWidget {
  const TodayStatusBanner({super.key, required this.studentId});

  final String studentId;

  Color _statusColor(String s) {
    switch (s) {
      case 'P':
        return AppColors.present;
      case 'A':
        return AppColors.absent;
      case 'Late':
        return AppColors.warning;
      case 'L':
        return AppColors.onLeave;
      default:
        return AppColors.holiday;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'P':
        return Icons.check_circle_rounded;
      case 'A':
        return Icons.cancel_rounded;
      case 'Late':
        return Icons.schedule_rounded;
      case 'L':
        return Icons.event_busy_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'P':
        return 'Present Today';
      case 'A':
        return 'Absent Today';
      case 'Late':
        return 'Marked Late';
      case 'L':
        return 'On Leave';
      default:
        return 'Status Unknown';
    }
  }

  String _statusSubtitle(String s) {
    switch (s) {
      case 'P':
        return 'School attendance marked';
      case 'A':
        return 'Contact class teacher';
      case 'Late':
        return 'Arrived late today';
      case 'L':
        return 'Leave approved';
      default:
        return 'No record found';
    }
  }

  String _statusBadge(String s) {
    switch (s) {
      case 'Late':
        return 'Late';
      case 'L':
        return 'Leave';
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStatus = ref.watch(todayAttendanceProvider(studentId));

    return asyncStatus.when(
      loading: () => const ShimmerBox(
        height: 80,
        width: double.infinity,
        borderRadius: AppDimensions.radiusLG,
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (status) {
        final color = _statusColor(status);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(
                  _statusIcon(status),
                  color: Colors.white,
                  size: AppDimensions.iconLG,
                ),
              ),
              const SizedBox(width: AppDimensions.gapMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_statusLabel(status), style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(_statusSubtitle(status),
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  _statusBadge(status),
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

// lib/features/student/home/widgets/schedule_strip.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/utils/dev_config.dart';
import '../providers/student_home_provider.dart';

class ScheduleStrip extends ConsumerWidget {
  const ScheduleStrip({super.key});

  // For dev: period index 3 (period 4, 10:30–11:00) is "current" on Wed Nov 20
  bool _isCurrent(int index) => index == 3;

  void _showPeriodDetail(BuildContext context, Map<String, dynamic> period) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      builder: (_) => _PeriodDetailSheet(period: period),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSchedule = ref.watch(todayScheduleProvider);

    return asyncSchedule.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          const SizedBox(height: AppDimensions.gapSM),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppDimensions.gapSM),
              itemBuilder: (_, __) => const ShimmerBox(
                width: 140,
                height: 108,
                borderRadius: AppDimensions.radiusLG,
              ),
            ),
          ),
        ],
      ),
      error: (_, __) => const Text(
        'Could not load schedule',
        style: AppTextStyles.bodySmall,
      ),
      data: (periods) {
        if (periods.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              const SizedBox(height: AppDimensions.gapSM),
              Text(
                'No classes today',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            const SizedBox(height: AppDimensions.gapSM),
            SizedBox(
              height: 130, // Increased height for safe layout
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: periods.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppDimensions.gapSM),
                itemBuilder: (_, i) {
                  final period = periods[i] as Map<String, dynamic>;
                  return _PeriodCard(
                    period: period,
                    isCurrent: _isCurrent(i),
                    onTap: () => _showPeriodDetail(context, period),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Today's Classes", style: AppTextStyles.h4),
        Text(DevConfig.formatDisplayDate(), style: AppTextStyles.caption),
      ],
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.period,
    required this.isCurrent,
    required this.onTap,
  });

  final Map<String, dynamic> period;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subjectId = period['subjectId'] as String? ?? '';
    final subjectName = period['subjectName'] as String? ?? 'Subject';
    final teacherName = period['teacherName'] as String? ?? '';
    final startTime = period['startTime'] as String? ?? '';
    final endTime = period['endTime'] as String? ?? '';
    final periodNum = period['period'] as int? ?? 0;
    final subjectColor = AppColors.subjectColor(subjectId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: isCurrent ? AppColors.primary : AppColors.borderLight,
            width: 1.0, // Use uniform width to be safe
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.bgTertiary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                  ),
                  child: Center(
                    child: Text(
                      '$periodNum',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.gapSM),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: subjectColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.gapSM),
            Text(
              subjectName,
              style: AppTextStyles.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              teacherName,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimensions.gapSM),
            Text(
              '$startTime–$endTime',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodDetailSheet extends StatelessWidget {
  final Map<String, dynamic> period;
  const _PeriodDetailSheet({required this.period});

  @override
  Widget build(BuildContext context) {
    final subjectId = period['subjectId'] as String? ?? '';
    final subjectName = period['subjectName'] as String? ?? 'Subject';
    final teacherName = period['teacherName'] as String? ?? 'Teacher Name';
    final startTime = period['startTime'] as String? ?? '';
    final endTime = period['endTime'] as String? ?? '';
    final periodNum = period['period'] as int? ?? 0;
    final room = period['room'] as String? ?? '402, Block B';
    final subjectColor = AppColors.subjectColor(subjectId);

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.gapLG),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Text(
                  'Period $periodNum',
                  style: AppTextStyles.labelLarge.copyWith(
                      color: subjectColor, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              _StatusText(
                  isCurrent:
                      true), // For now statically true if tapped in "Today's Classes"
            ],
          ),
          const SizedBox(height: AppDimensions.gapLG),
          Text(subjectName, style: AppTextStyles.h2),
          const SizedBox(height: AppDimensions.gapSM),
          _DetailRow(
              icon: Icons.schedule_rounded, text: '$startTime - $endTime'),
          _DetailRow(icon: Icons.person_outline_rounded, text: teacherName),
          _DetailRow(icon: Icons.room_outlined, text: room),
          const SizedBox(height: AppDimensions.gapSection),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgSecondary,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
              ),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(height: AppDimensions.gapMD),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.gapMD),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: AppDimensions.gapMD),
          Text(text, style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  final bool isCurrent;
  const _StatusText({required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    if (!isCurrent) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: const Text(
        'LIVE NOW',
        style: TextStyle(
            color: AppColors.success,
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

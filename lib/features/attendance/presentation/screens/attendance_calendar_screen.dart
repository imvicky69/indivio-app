import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/fade_in_slide.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../student/home/providers/student_home_provider.dart';

class AttendanceCalendarScreen extends ConsumerWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentStudentProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (profile) {
        if (profile == null)
          return const Scaffold(body: Center(child: Text('Profile not found')));

        final studentId = profile.studentId;
        final focusedDay = ref.watch(attendanceCalendarFocusProvider);

        final params = AttendanceParams(
          studentId: studentId,
          month: focusedDay.month,
          year: focusedDay.year,
        );

        final asyncSummary = ref.watch(attendanceSummaryProvider(params));
        final asyncRecords = ref.watch(attendanceRecordsProvider(params));

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          appBar: AppBar(
            title: const Text('Attendance History'),
            backgroundColor: AppColors.bgPrimary,
            elevation: 0,
            foregroundColor: AppColors.textPrimary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Stats
                FadeInSlide(
                  delay: const Duration(milliseconds: 0),
                  child: asyncSummary.when(
                    loading: () =>
                        const ShimmerBox(height: 100, width: double.infinity),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (summary) {
                      final present =
                          (summary?['present'] as num?)?.toInt() ?? 0;
                      final absent = (summary?['absent'] as num?)?.toInt() ?? 0;
                      final leave = (summary?['leave'] as num?)?.toInt() ?? 0;
                      final percentage =
                          (summary?['attendancePercent'] as num?)?.toDouble() ??
                              0;

                      return _AttendanceSummaryStats(
                        present: present,
                        absent: absent,
                        leave: leave,
                        percentage: percentage,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.gapSection),

                // Calendar Card
                FadeInSlide(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppDimensions.paddingLG),
                    child: asyncRecords.when(
                      loading: () => const SizedBox(
                          height: 300, child: LoadingIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (records) {
                        Map<String, String> dayStatus = {};
                        for (final r in records) {
                          dayStatus[r['date'] as String] =
                              r['status'] as String;
                        }

                        return TableCalendar(
                          firstDay: DateTime(2023, 1, 1),
                          lastDay: DateTime(2026, 12, 31),
                          focusedDay: focusedDay,
                          calendarFormat: CalendarFormat.month,
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: AppTextStyles.h4,
                            leftChevronIcon: Icon(Icons.chevron_left_rounded),
                            rightChevronIcon: Icon(Icons.chevron_right_rounded),
                          ),
                          onPageChanged: (newFocus) {
                            ref
                                .read(attendanceCalendarFocusProvider.notifier)
                                .state = newFocus;
                          },
                          calendarStyle: const CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: AppColors.studentBlue,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, day, events) {
                              final key = DateFormat('yyyy-MM-dd').format(day);
                              final status = dayStatus[key];
                              if (status == null) return null;

                              Color color = AppColors.attendanceColor(status);
                              return Positioned(
                                bottom: 1,
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                      color: color, shape: BoxShape.circle),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.gapSection),

                // Legend
                const FadeInSlide(
                  delay: Duration(milliseconds: 200),
                  child: _AttendanceLegend(),
                ),
                const SizedBox(height: AppDimensions.gapSection),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceSummaryStats extends StatelessWidget {
  final int present;
  final int absent;
  final int leave;
  final double percentage;

  const _AttendanceSummaryStats({
    required this.present,
    required this.absent,
    required this.leave,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _StatCard(
            label: 'Attendance',
            value: '${percentage.toStringAsFixed(0)}%',
            subtitle: 'This Month',
            color: AppColors.studentBlue,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _MiniStat(
                  label: 'Present',
                  value: '$present',
                  color: AppColors.present),
              const SizedBox(height: 8),
              _MiniStat(
                  label: 'Absent', value: '$absent', color: AppColors.absent),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.labelSmall.copyWith(color: color)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.h1.copyWith(color: color)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: color.withValues(alpha: 0.7))),
              ],
            ),
          ),
          Icon(icon, color: color.withValues(alpha: 0.5), size: 40),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: color, fontWeight: FontWeight.bold)),
          Text(value, style: AppTextStyles.h4.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _AttendanceLegend extends StatelessWidget {
  const _AttendanceLegend();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Legend', style: AppTextStyles.labelLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _LegendItem(label: 'Present', color: AppColors.present),
            _LegendItem(label: 'Absent', color: AppColors.absent),
            _LegendItem(label: 'Late', color: AppColors.warning),
            _LegendItem(label: 'Leave', color: AppColors.onLeave),
            _LegendItem(label: 'Holiday', color: AppColors.borderMedium),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  const ShimmerBox({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
    );
  }
}

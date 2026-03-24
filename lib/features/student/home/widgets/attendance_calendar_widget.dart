// lib/features/student/home/widgets/attendance_calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/student_home_provider.dart';

class AttendanceCalendarWidget extends ConsumerWidget {
  const AttendanceCalendarWidget({super.key, required this.studentId});

  final String studentId;

  Color _pctColor(double pct) {
    if (pct >= 85) return AppColors.success;
    if (pct >= 75) return AppColors.warning;
    return AppColors.error;
  }

  void _showDayDetail(
      BuildContext context, DateTime date, String? status, String? remarks) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      builder: (_) =>
          _DayDetailSheet(date: date, status: status, remarks: remarks),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedDay = ref.watch(attendanceCalendarFocusProvider);

    final params = AttendanceParams(
      studentId: studentId,
      month: focusedDay.month,
      year: focusedDay.year,
    );

    final asyncSummary = ref.watch(attendanceSummaryProvider(params));
    final asyncRecords = ref.watch(attendanceRecordsProvider(params));

    return asyncSummary.when(
      loading: () => const ShimmerBox(
          height: 320,
          width: double.infinity,
          borderRadius: AppDimensions.radiusLG),
      error: (_, __) => const SizedBox.shrink(),
      data: (summary) {
        final present = (summary?['present'] as num?)?.toInt() ?? 0;
        final absent = (summary?['absent'] as num?)?.toInt() ?? 0;
        final late = (summary?['late'] as num?)?.toInt() ?? 0;
        final leave = (summary?['leave'] as num?)?.toInt() ?? 0;
        final pct = (summary?['attendancePercent'] as num?)?.toDouble() ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: AppColors.borderLight, width: 0.5),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Attendance', style: AppTextStyles.h4),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/student/attendance'),
                    child:
                        const Text('View All', style: AppTextStyles.labelSmall),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.gapSM),

              asyncRecords.when(
                loading: () =>
                    const SizedBox(height: 150, child: LoadingIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (records) {
                  Map<String, Map<String, dynamic>> dayData = {};
                  for (final r in records) {
                    final date = r['date'] as String? ?? '';
                    dayData[date] = r;
                  }

                  return TableCalendar(
                    firstDay: DateTime(2023, 1, 1),
                    lastDay: DateTime(2026, 12, 31),
                    focusedDay: focusedDay,
                    calendarFormat: CalendarFormat.month,
                    headerVisible: true,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: AppTextStyles.labelLarge,
                      leftChevronIcon: Icon(Icons.chevron_left, size: 20),
                      rightChevronIcon: Icon(Icons.chevron_right, size: 20),
                      headerPadding: EdgeInsets.zero,
                    ),
                    onPageChanged: (newFocusedDay) {
                      ref.read(attendanceCalendarFocusProvider.notifier).state =
                          newFocusedDay;
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      final key =
                          '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}';
                      final data = dayData[key];
                      _showDayDetail(
                          context,
                          selectedDay,
                          data?['status'] as String?,
                          data?['remarks'] as String?);
                    },
                    rowHeight: 36,
                    daysOfWeekHeight: 20,
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: AppTextStyles.bodySmall,
                      weekendTextStyle: AppTextStyles.bodySmall,
                      cellMargin: EdgeInsets.all(2),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (ctx, day, focused) {
                        final key =
                            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                        final status = dayData[key]?['status'];
                        Color? dotColor;
                        if (status == 'P') dotColor = AppColors.present;
                        if (status == 'A') dotColor = AppColors.absent;
                        if (status == 'L' || status == 'Late') {
                          dotColor = AppColors.warning;
                        }
                        if (status == 'OL' || status == 'Leave') {
                          dotColor = AppColors.onLeave;
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: dotColor ?? Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.gapMD),

              // Summary row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DotStat(
                      label: 'Present',
                      count: present,
                      color: AppColors.present),
                  _DotStat(
                      label: 'Absent', count: absent, color: AppColors.absent),
                  _DotStat(
                      label: 'Late', count: late, color: AppColors.warning),
                  _DotStat(
                      label: 'Leave', count: leave, color: AppColors.onLeave),
                ],
              ),

              const SizedBox(height: AppDimensions.gapSM),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  backgroundColor: AppColors.bgTertiary,
                  color: _pctColor(pct),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${pct.toStringAsFixed(0)}% attendance this month',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  final DateTime date;
  final String? status;
  final String? remarks;

  const _DayDetailSheet({
    required this.date,
    this.status,
    this.remarks,
  });

  String _statusLabel(String? status) {
    switch (status) {
      case 'P':
        return 'Present';
      case 'A':
        return 'Absent';
      case 'L':
      case 'Late':
        return 'Late';
      case 'OL':
      case 'Leave':
        return 'On Leave';
      default:
        return 'No Record';
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'P':
        return Icons.check_circle_rounded;
      case 'A':
        return Icons.cancel_rounded;
      case 'L':
      case 'Late':
        return Icons.schedule_rounded;
      case 'OL':
      case 'Leave':
        return Icons.event_busy_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.attendanceColor(status ?? 'none');

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(date),
                style: AppTextStyles.h3,
              ),
              const Spacer(),
              _StatusPill(status: status),
            ],
          ),
          const SizedBox(height: AppDimensions.gapLG),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              border: Border.all(color: statusColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  _statusIcon(status),
                  color: statusColor,
                  size: 48,
                ),
                const SizedBox(height: AppDimensions.gapMD),
                Text(_statusLabel(status),
                    style: AppTextStyles.h3.copyWith(color: statusColor)),
                if (remarks != null && remarks!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(remarks!,
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center),
                  ),
                if (status == null)
                  const Text('No attendance record for this day',
                      style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.gapSection),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String? status;
  const _StatusPill({this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.attendanceColor(status ?? 'none');
    String label = 'none';
    if (status != null) {
      if (status == 'P') {
        label = 'Present';
      } else if (status == 'A') {
        label = 'Absent';
      } else if (status == 'L' || status == 'Late') {
        label = 'Late';
      } else if (status == 'OL' || status == 'Leave') {
        label = 'Leave';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.chip
            .copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DotStat extends StatelessWidget {
  const _DotStat(
      {required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$count $label', style: AppTextStyles.caption),
      ],
    );
  }
}

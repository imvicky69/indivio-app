// lib/features/student/home/screens/student_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/dev_config.dart';
import '../../../../core/widgets/indivio_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/fade_in_slide.dart';
import '../widgets/today_status_banner.dart';
import '../widgets/schedule_strip.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/attendance_calendar_widget.dart';
import '../widgets/homework_today_widget.dart';
import '../widgets/fee_alert_card.dart';
import '../widgets/announcements_feed.dart';
import '../widgets/leave_status_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  String _todayLabel() {
    final now = DateTime.now();
    return DateFormat('EEEE, d MMMM yyyy').format(now);
  }

  String _getGreeting(String firstName) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, $firstName 👋';
    if (hour < 17) return 'Good Afternoon, $firstName 👋';
    return 'Good Evening, $firstName 👋';
  }

  Widget _buildHomeContent(String studentId, String firstName) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlide(
            delay: const Duration(milliseconds: 0),
            child: LeaveStatusWidget(studentId: studentId),
          ),
          const SizedBox(height: AppDimensions.gapMD),
          FadeInSlide(
            delay: const Duration(milliseconds: 100),
            child: TodayStatusBanner(studentId: studentId),
          ),
          const SizedBox(height: AppDimensions.gapMD),
          const FadeInSlide(
            delay: Duration(milliseconds: 200),
            child: ScheduleStrip(),
          ),
          const SizedBox(height: AppDimensions.gapMD),
          FadeInSlide(
            delay: const Duration(milliseconds: 300),
            child: QuickStatsRow(studentId: studentId),
          ),
          const SizedBox(height: AppDimensions.gapMD),
          FadeInSlide(
            delay: const Duration(milliseconds: 400),
            child: AttendanceCalendarWidget(studentId: studentId),
          ),
          const SizedBox(height: AppDimensions.gapMD),
          const FadeInSlide(
            delay: Duration(milliseconds: 500),
            child: HomeworkTodayWidget(),
          ),
          const SizedBox(height: AppDimensions.gapMD),
          FadeInSlide(
            delay: const Duration(milliseconds: 600),
            child: FeeAlertCard(studentId: studentId),
          ),
          const SizedBox(height: AppDimensions.gapMD),
          const FadeInSlide(
            delay: Duration(milliseconds: 700),
            child: AnnouncementsFeed(),
          ),
          const SizedBox(height: AppDimensions.gapSection),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentProfile = ref.watch(currentStudentProfileProvider);

    return studentProfile.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.bgSecondary,
        appBar: IndivioAppBar(
          title: 'Loading...',
          subtitle: _todayLabel(),
          showNotificationBell: true,
          notificationCount: 2,
          roleColor: AppColors.studentBlue,
        ),
        body: const LoadingIndicator(),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bgSecondary,
        body: Center(
          child: Text('Failed to load profile: $e'),
        ),
      ),
      data: (profile) {
        if (profile == null) {
          // Auth has fully resolved with no user — redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            backgroundColor: AppColors.bgSecondary,
            body: LoadingIndicator(),
          );
        }

        // Update appbar with real name
        final firstName = profile.fullName.split(' ').first;

        return Scaffold(
          backgroundColor: AppColors.bgSecondary,
          appBar: IndivioAppBar(
            title: _getGreeting(firstName),
            subtitle: DevConfig.fullDateLabel(),
            showNotificationBell: true,
            notificationCount: 2,
            roleColor: AppColors.studentBlue,
          ),
          body: _buildHomeContent(profile.studentId, firstName),
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/indivio_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../widgets/class_identity_card.dart';
import '../widgets/homework_section.dart';
import '../widgets/assignments_section.dart';
import '../widgets/test_performance_widget.dart';
import '../widgets/study_materials_widget.dart';
import '../widgets/syllabus_tracker_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/fade_in_slide.dart';

class StudentClassroomScreen extends ConsumerWidget {
  const StudentClassroomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentProfile = ref.watch(currentStudentProfileProvider);

    return studentProfile.when(
      loading: () => const Scaffold(
        body: LoadingIndicator(),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('No student profile found.')),
          );
        }

        final classId = profile.classId;
        final studentId = profile.studentId;
        final rollNumber = profile.rollNumber;

        return Scaffold(
          appBar: IndivioAppBar(
            title: 'Classroom',
            roleColor: AppColors.studentBlue,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined, size: AppDimensions.iconMD),
                color: AppColors.textSecondary,
                onPressed: () {
                  // TODO: implement GoRouter navigation to timetable
                },
                tooltip: 'Timetable',
              )
            ],
          ),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingPage),
              child: Column(
                children: [
                  FadeInSlide(
                    delay: const Duration(milliseconds: 0),
                    child: ClassIdentityCard(
                      classId: classId,
                      studentId: studentId,
                      rollNumber: rollNumber,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.gapMD),

                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child: HomeworkSection(studentId: studentId),
                  ),
                  const SizedBox(height: AppDimensions.gapMD),

                  FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: AssignmentsSection(studentId: studentId),
                  ),
                  const SizedBox(height: AppDimensions.gapMD),

                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: TestPerformanceWidget(studentId: studentId),
                  ),
                  const SizedBox(height: AppDimensions.gapMD),

                  const FadeInSlide(
                    delay: Duration(milliseconds: 400),
                    child: StudyMaterialsWidget(),
                  ),
                  const SizedBox(height: AppDimensions.gapMD),

                  const FadeInSlide(
                    delay: Duration(milliseconds: 500),
                    child: SyllabusTrackerWidget(),
                  ),
                  const SizedBox(height: AppDimensions.gapSection),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

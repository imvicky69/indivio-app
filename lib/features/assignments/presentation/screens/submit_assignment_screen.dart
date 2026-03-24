import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/fade_in_slide.dart';
import '../../../student/classroom/providers/classroom_provider.dart';

class AssignmentSubmitScreen extends ConsumerStatefulWidget {
  final String assignmentId;

  const AssignmentSubmitScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<AssignmentSubmitScreen> createState() =>
      _AssignmentSubmitScreenState();
}

class _AssignmentSubmitScreenState
    extends ConsumerState<AssignmentSubmitScreen> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final List<String> _attachedFiles = [];

  void _pickFiles() async {
    // Simulate file picking
    setState(() {
      _attachedFiles.add('solution_v1.pdf');
    });
  }

  void _submit() async {
    if (_attachedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach at least one file')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // Simulate upload progress
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _uploadProgress = i / 10;
        });
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignmentAsync =
        ref.watch(assignmentDetailProvider(widget.assignmentId));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Submit Assignment'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: assignmentAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (assignment) {
          if (assignment == null)
            return const Center(child: Text('Assignment not found'));

          final subjectColor =
              AppColors.subjectColor(assignment['subjectId'] ?? '');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInSlide(
                  delay: const Duration(milliseconds: 0),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingLG),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLG),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                  color: subjectColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(assignment['subjectName'] ?? '',
                                style: AppTextStyles.labelLarge),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(assignment['title'] ?? '',
                            style: AppTextStyles.h2),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 16, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              'Due ${DateFormat('MMM d').format(DateTime.parse(assignment['dueDate']))}',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.gapSection),
                FadeInSlide(
                  delay: const Duration(milliseconds: 100),
                  child: const Text('Instructions', style: AppTextStyles.h4),
                ),
                const SizedBox(height: AppDimensions.gapSM),
                FadeInSlide(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    assignment['description'] ??
                        'Solve all problems and upload the solution in PDF format.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(height: 1.5, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: AppDimensions.gapSection),
                FadeInSlide(
                  delay: const Duration(milliseconds: 200),
                  child: const Text('Attachments', style: AppTextStyles.h4),
                ),
                const SizedBox(height: AppDimensions.gapMD),
                ..._attachedFiles.map((file) => _FileTile(
                    name: file,
                    onRemove: () =>
                        setState(() => _attachedFiles.remove(file)))),
                FadeInSlide(
                  delay: const Duration(milliseconds: 250),
                  child: _UploadArea(onTap: _isUploading ? null : _pickFiles),
                ),
                const SizedBox(height: AppDimensions.gapSection * 2),
                if (_isUploading)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: AppColors.bgTertiary,
                        color: AppColors.studentBlue,
                        minHeight: 8,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading... ${(_uploadProgress * 100).toInt()}%',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.studentBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLG)),
                      ),
                      child: const Text('SUBMIT ASSIGNMENT',
                          style: AppTextStyles.labelLarge),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;

  const _FileTile({required this.name, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: AppTextStyles.bodyMedium)),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close,
                size: 20, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _UploadArea extends StatelessWidget {
  final VoidCallback? onTap;

  const _UploadArea({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: AppColors.studentBlue.withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined,
                color: AppColors.studentBlue.withValues(alpha: 0.6), size: 48),
            const SizedBox(height: 12),
            const Text('Tap to upload files', style: AppTextStyles.labelLarge),
            const SizedBox(height: 4),
            Text('PDF, PNG or JPG (Max 5MB)', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

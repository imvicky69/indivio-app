import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/classroom_provider.dart';

class AssignmentsSection extends ConsumerStatefulWidget {
  final String studentId;

  const AssignmentsSection({super.key, required this.studentId});

  @override
  ConsumerState<AssignmentsSection> createState() => _AssignmentsSectionState();
}

class _AssignmentsSectionState extends ConsumerState<AssignmentsSection> {
  int _selectedTab = 0; // 0 = Pending, 1 = Submitted, 2 = Graded

  @override
  Widget build(BuildContext context) {
    final statusAsync =
        ref.watch(assignmentsByStatusProvider(widget.studentId));

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        side: const BorderSide(color: AppColors.borderLight, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Assignments', style: AppTextStyles.h3),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('All assignments — coming soon')),
                    );
                  },
                  child: const Text('See All',
                      style: TextStyle(color: AppColors.studentBlue)),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.gapSM),
            statusAsync.when(
              loading: () =>
                  const ShimmerBox(height: 40, width: double.infinity),
              error: (e, s) => const SizedBox.shrink(),
              data: (data) {
                final pending = data['pending'] ?? [];
                final submitted = data['submitted'] ?? [];
                final graded = data['graded'] ?? [];

                return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _AssignmentTab(
                            label: 'Pending',
                            count: pending.length,
                            selected: _selectedTab == 0,
                            onTap: () => setState(() => _selectedTab = 0),
                          ),
                          const SizedBox(width: AppDimensions.gapSM),
                          _AssignmentTab(
                            label: 'Submitted',
                            count: submitted.length,
                            selected: _selectedTab == 1,
                            onTap: () => setState(() => _selectedTab = 1),
                          ),
                          const SizedBox(width: AppDimensions.gapSM),
                          _AssignmentTab(
                            label: 'Graded',
                            count: graded.length,
                            selected: _selectedTab == 2,
                            onTap: () => setState(() => _selectedTab = 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.gapMD),
                    _buildTabContent(pending, submitted, graded),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
      List<dynamic> pending, List<dynamic> submitted, List<dynamic> graded) {
    final list = _selectedTab == 0
        ? pending
        : _selectedTab == 1
            ? submitted
            : graded;

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(
              _selectedTab == 0
                  ? Icons.check_circle_outline
                  : Icons.assignment_outlined,
              color: _selectedTab == 0
                  ? AppColors.success
                  : AppColors.textTertiary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 0
                  ? 'No pending assignments'
                  : _selectedTab == 1
                      ? 'No submitted assignments'
                      : 'No graded assignments',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      );
    }

    return Column(
      children: list
          .map((item) => _AssignmentCard(
                assignment: item as Map<String, dynamic>,
                studentId: widget.studentId,
                tabIndex: _selectedTab,
              ))
          .toList(),
    );
  }
}

class _AssignmentTab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _AssignmentTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.studentBlue : AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(
              label,
              style: AppTextStyles.chip.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
          if (count > 0 && !selected)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final String studentId;
  final int tabIndex;

  const _AssignmentCard({
    required this.assignment,
    required this.studentId,
    required this.tabIndex,
  });

  void _showGradeDetail(BuildContext context, Map<String, dynamic> assignment) {
    final submissionRaw = assignment['submission'];
    final submission = Map<String, dynamic>.from(submissionRaw as Map);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      builder: (context) => Padding(
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
            Text(assignment['title'] ?? 'Assignment Detail',
                style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.gapMD),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              decoration: BoxDecoration(
                color: AppColors.studentBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ScoreItem(
                      label: 'Score',
                      value:
                          '${submission['marks']}/${assignment['totalMarks']}'),
                  _ScoreItem(label: 'Grade', value: submission['grade'] ?? 'A'),
                  _ScoreItem(
                      label: 'Rank',
                      value: submission['rank']?.toString() ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.gapLG),
            const Text('Teacher\'s Feedback', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Text(
              submission['feedback'] ?? 'Great work on this assignment!',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.gapSection),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: AppDimensions.gapMD),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submissionRaw = assignment['submission'];
    final Map<String, dynamic>? submission = submissionRaw != null
        ? Map<String, dynamic>.from(submissionRaw as Map)
        : null;
    final subjectColor = AppColors.subjectColor(assignment['subjectId'] ?? '');

    return InkWell(
      onTap: () {
        if (tabIndex == 2) _showGradeDetail(context, assignment);
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        margin: const EdgeInsets.only(bottom: AppDimensions.gapSM),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: subjectColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppDimensions.gapSM),
                Expanded(
                  child: Text(
                    assignment['title'] ?? '',
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.school_outlined,
                    size: AppDimensions.iconXS, color: AppColors.textTertiary),
                const SizedBox(width: 3),
                Text(assignment['subjectName'] ?? '',
                    style: AppTextStyles.caption),
                const SizedBox(width: 12),
                const Icon(Icons.assignment_outlined,
                    size: AppDimensions.iconXS, color: AppColors.textTertiary),
                const SizedBox(width: 3),
                Text('${assignment['totalMarks']} marks',
                    style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 8),
            if (tabIndex == 0) ...[
              Row(
                children: [
                  const Icon(Icons.schedule,
                      size: AppDimensions.iconXS, color: AppColors.warning),
                  const SizedBox(width: 3),
                  Text(
                    'Due: ${_formatDate(assignment['dueDate'])}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.warning),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => context.push(
                          '/student/assignment/${(assignment['assignmentId'] as String).trim()}/submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.studentBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusSM)),
                      ),
                      child: Text('Submit',
                          style:
                              AppTextStyles.chip.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ] else if (tabIndex == 1) ...[
              Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: AppDimensions.iconXS, color: AppColors.success),
                  const SizedBox(width: 3),
                  Text(
                    'Submitted · Awaiting grade',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ] else if (tabIndex == 2 && submission != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${submission['marks']}/${assignment['totalMarks']}',
                        style: AppTextStyles.h4
                            .copyWith(color: AppColors.studentBlue),
                      ),
                      const SizedBox(width: AppDimensions.gapSM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(
                          submission['grade'] ?? 'A',
                          style: AppTextStyles.chip
                              .copyWith(color: AppColors.success),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rank ${submission['rank'] ?? '-'}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (submission['feedback'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '"${submission['feedback']}"',
                      style: AppTextStyles.caption
                          .copyWith(fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final String value;
  const _ScoreItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.h4.copyWith(color: AppColors.studentBlue)),
      ],
    );
  }
}

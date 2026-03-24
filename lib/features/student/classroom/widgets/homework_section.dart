import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/classroom_provider.dart';

class HomeworkSection extends ConsumerStatefulWidget {
  final String studentId;

  const HomeworkSection({super.key, required this.studentId});

  @override
  ConsumerState<HomeworkSection> createState() => _HomeworkSectionState();
}

class _HomeworkSectionState extends ConsumerState<HomeworkSection> {
  int _selectedTab = 0; // 0 = Today, 1 = Upcoming

  @override
  Widget build(BuildContext context) {
    final homeworkAsync = ref
        .watch(homeworkByTabProvider(_selectedTab == 0 ? 'today' : 'upcoming'));

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
                const Text('Homework', style: AppTextStyles.h3),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('All homework — coming soon')),
                    );
                  },
                  child: const Text('See All',
                      style: TextStyle(color: AppColors.studentBlue)),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.gapSM),
            Row(
              children: [
                _TabChip(
                  label: 'Today',
                  selected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                const SizedBox(width: AppDimensions.gapSM),
                _TabChip(
                  label: 'Upcoming',
                  selected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.gapMD),
            homeworkAsync.when(
              loading: () => Column(
                children: [
                  const ShimmerBox(height: 68, width: double.infinity),
                  const SizedBox(height: AppDimensions.gapSM),
                  const ShimmerBox(height: 68, width: double.infinity),
                ],
              ),
              error: (err, stack) =>
                  const Center(child: Text('Error loading homework')),
              data: (homeworkList) {
                if (homeworkList.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLG),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppColors.success, size: 32),
                        const SizedBox(height: 6),
                        Text(
                          'No homework ${_selectedTab == 0 ? "due today" : "upcoming"}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: homeworkList
                      .map((h) => _HomeworkTile(homework: h))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }
}

class _HomeworkTile extends StatelessWidget {
  final Map<String, dynamic> homework;

  const _HomeworkTile({required this.homework});

  @override
  Widget build(BuildContext context) {
    final subjectId = homework['subjectId'] as String;
    final subjectColor = AppColors.subjectColor(subjectId);
    final attachments = homework['attachments'] as List<dynamic>? ?? [];

    return InkWell(
      onTap: () => context.push(
          '/student/homework/${(homework['homeworkId'] as String).trim()}'),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.gapSM),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border(
            left: BorderSide(color: subjectColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homework['subjectName'] ?? 'Subject',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: subjectColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      homework['title'] ?? '',
                      style: AppTextStyles.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: AppDimensions.iconXS,
                            color: AppColors.textTertiary),
                        const SizedBox(width: 3),
                        Text(
                          'Due: ${_formatDueDate(homework['dueDate'])}',
                          style: AppTextStyles.caption,
                        ),
                        if (attachments.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_file,
                                    size: AppDimensions.iconXS,
                                    color: AppColors.textTertiary),
                                const SizedBox(width: 2),
                                Text('${attachments.length} file',
                                    style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (homework['isUrgent'] == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    'Urgent',
                    style: AppTextStyles.chip.copyWith(color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDueDate(String dateStr) {
    try {
      final dueDate = DateTime.parse(dateStr);
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

      if (dueDay == tomorrow) return 'Tomorrow';
      return DateFormat('MMM d').format(dueDate);
    } catch (e) {
      return dateStr;
    }
  }
}

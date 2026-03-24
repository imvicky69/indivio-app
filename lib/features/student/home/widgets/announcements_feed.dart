// lib/features/student/home/widgets/announcements_feed.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../notices/data/notice_model.dart';
import '../providers/student_home_provider.dart';

class AnnouncementsFeed extends ConsumerWidget {
  const AnnouncementsFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAnnouncements = ref.watch(announcementsProvider);

    return asyncAnnouncements.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(context: context),
          const SizedBox(height: AppDimensions.gapSM),
          const ShimmerBox(
              height: 72,
              width: double.infinity,
              borderRadius: AppDimensions.radiusMD),
          const SizedBox(height: AppDimensions.gapSM),
          const ShimmerBox(
              height: 72,
              width: double.infinity,
              borderRadius: AppDimensions.radiusMD),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(context: context),
            const SizedBox(height: AppDimensions.gapSM),
            if (items.isEmpty)
              const EmptyStateWidget(
                icon: Icons.notifications_none_outlined,
                title: 'No announcements',
                subtitle: 'School notices will appear here',
              )
            else
              ...items.map(
                (item) => _AnnouncementTile(announcement: item),
              ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Notices', style: AppTextStyles.h4),
        const Spacer(),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All notices — coming soon')),
            );
          },
          child: const Text('See All', style: AppTextStyles.labelSmall),
        ),
      ],
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.announcement});
  final NoticeModel announcement;

  String _timeAgo(DateTime createdAt) {
    try {
      final ref = DateTime(2024, 11, 20);
      final diff = ref.difference(createdAt);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      if (diff.inDays < 14) return '1 week ago';
      return '${(diff.inDays / 7).round()} weeks ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = announcement.title;
    final category = announcement.category;
    final createdAt = announcement.createdAt;
    final createdBy = announcement.createdByName;
    final isPinned = announcement.isPinned;

    return InkWell(
      onTap: () =>
          context.push('/student/notice/${announcement.announcementId.trim()}'),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.gapSM),
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 5, right: AppDimensions.gapSM),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryChip(category: category),
                      const Spacer(),
                      Text(_timeAgo(createdAt), style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: AppTextStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(createdBy, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (isPinned) ...[
              const SizedBox(width: AppDimensions.gapSM),
              const Icon(Icons.push_pin_rounded,
                  size: AppDimensions.iconSM, color: AppColors.textTertiary),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});
  final String category;

  Color _chipColor(String cat) {
    switch (cat) {
      case 'event':
        return AppColors.primary;
      case 'exam':
        return AppColors.error;
      case 'fee':
        return AppColors.warning;
      case 'holiday':
        return AppColors.success;
      case 'academic':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _chipColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        category,
        style: AppTextStyles.chip.copyWith(color: color),
      ),
    );
  }
}

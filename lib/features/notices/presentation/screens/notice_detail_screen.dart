import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/fade_in_slide.dart';
import '../../../student/home/providers/student_home_provider.dart';

class NoticeDetailScreen extends ConsumerWidget {
  final String noticeId;

  const NoticeDetailScreen({super.key, required this.noticeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticeAsync = ref.watch(noticeDetailProvider(noticeId));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Announcement'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: noticeAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (notice) {
          if (notice == null) {
            return const Center(child: Text('Notice not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInSlide(
                  delay: const Duration(milliseconds: 0),
                  child: Row(
                    children: [
                      if (notice.isPinned)
                        _Tag(
                          text: 'PINNED',
                          color: AppColors.studentBlue,
                          icon: Icons.push_pin,
                        ),
                      if (notice.category.isNotEmpty) ...[
                        if (notice.isPinned) const SizedBox(width: 8),
                        _Tag(
                          text: notice.category.toUpperCase(),
                          color: notice.category.toLowerCase() == 'urgent'
                              ? Colors.red
                              : AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.gapMD),
                FadeInSlide(
                  delay: const Duration(milliseconds: 100),
                  child: Text(notice.title, style: AppTextStyles.h2),
                ),
                const SizedBox(height: AppDimensions.gapSM),
                FadeInSlide(
                  delay: const Duration(milliseconds: 150),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(notice.createdByName, style: AppTextStyles.caption),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy • hh:mm a')
                            .format(notice.createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 48),
                FadeInSlide(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    notice.body,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                  ),
                ),
                if (notice.attachmentUrl != null) ...[
                  const SizedBox(height: AppDimensions.gapSection),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: const Text('Attachment', style: AppTextStyles.h4),
                  ),
                  const SizedBox(height: AppDimensions.gapMD),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 350),
                    child: _AttachmentCard(url: notice.attachmentUrl!),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _Tag({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final String url;

  const _AttachmentCard({required this.url});

  @override
  Widget build(BuildContext context) {
    final fileName = url.split('/').last.split('?').first;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.studentBlue,
            radius: 18,
            child: Icon(Icons.file_present, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppDimensions.gapMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: AppTextStyles.labelLarge),
                const Text('Tap to download', style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded,
                color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

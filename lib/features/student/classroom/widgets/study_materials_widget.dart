import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/classroom_provider.dart';

class StudyMaterialsWidget extends ConsumerWidget {
  const StudyMaterialsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(studyMaterialsProvider);

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
                const Text('Study Materials', style: AppTextStyles.h3),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All',
                      style: TextStyle(color: AppColors.studentBlue)),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.gapSM),
            materialsAsync.when(
              loading: () => Column(
                children: [
                  const ShimmerBox(height: 52, width: double.infinity),
                  const SizedBox(height: AppDimensions.gapSM),
                  const ShimmerBox(height: 52, width: double.infinity),
                ],
              ),
              error: (e, s) => const EmptyStateWidget(
                  icon: Icons.folder_outlined,
                  title: 'Error loading materials'),
              data: (groupedMaterials) {
                if (groupedMaterials.isEmpty) {
                  return const EmptyStateWidget(
                      icon: Icons.folder_outlined,
                      title: 'No materials uploaded yet');
                }

                // Map of subject names for display (can be fetched from a provider in real app)
                final Map<String, String> subjectNames = {
                  'SUB_MATH': 'Mathematics',
                  'SUB_SCI': 'Science',
                  'SUB_ENG': 'English',
                  'SUB_IT': 'IT',
                };

                return Column(
                  children: groupedMaterials.entries.map((entry) {
                    final subjectId = entry.key;
                    final materials = entry.value;
                    return _SubjectFolderTile(
                      subjectId: subjectId,
                      subjectName: subjectNames[subjectId] ?? subjectId,
                      materials: materials,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectFolderTile extends StatelessWidget {
  final String subjectId;
  final String subjectName;
  final List<dynamic> materials;

  const _SubjectFolderTile({
    required this.subjectId,
    required this.subjectName,
    required this.materials,
  });

  @override
  Widget build(BuildContext context) {
    final subjectColor = AppColors.subjectColor(subjectId);
    final fileCount = materials.length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapSM),
      child: InkWell(
        onTap: () => _showMaterials(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.borderLight, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Icon(
                  _getSubjectIcon(subjectId),
                  color: subjectColor,
                  size: AppDimensions.iconMD,
                ),
              ),
              const SizedBox(width: AppDimensions.gapMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subjectName, style: AppTextStyles.labelLarge),
                    Text('$fileCount file${fileCount > 1 ? "s" : ""}',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary, size: AppDimensions.iconMD),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String id) {
    switch (id) {
      case 'SUB_MATH':
        return Icons.calculate_outlined;
      case 'SUB_SCI':
        return Icons.science_outlined;
      case 'SUB_ENG':
        return Icons.menu_book_outlined;
      case 'SUB_IT':
        return Icons.computer_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  void _showMaterials(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      builder: (_) => _MaterialsBottomSheet(
        subjectName: subjectName,
        materials: materials,
      ),
    );
  }
}

class _MaterialsBottomSheet extends StatelessWidget {
  final String subjectName;
  final List<dynamic> materials;

  const _MaterialsBottomSheet(
      {required this.subjectName, required this.materials});

  @override
  Widget build(BuildContext context) {
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
          Text(subjectName, style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.gapMD),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return _MaterialFileTile(material: material);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialFileTile extends StatelessWidget {
  final Map<String, dynamic> material;

  const _MaterialFileTile({required this.material});

  @override
  Widget build(BuildContext context) {
    final type = material['type'] as String? ?? 'pdf';
    final sizeKB = material['sizeKB'] as int? ?? 0;
    final teacherName = material['uploadedBy']?['name'] ?? 'Teacher';

    Color iconBgColor;
    IconData fileIcon;
    Color iconColor;

    switch (type.toLowerCase()) {
      case 'pdf':
        iconBgColor = AppColors.error.withValues(alpha: 0.1);
        fileIcon = Icons.picture_as_pdf;
        iconColor = AppColors.error;
        break;
      case 'video':
        iconBgColor = AppColors.info.withValues(alpha: 0.1);
        fileIcon = Icons.play_circle;
        iconColor = AppColors.info;
        break;
      default:
        iconBgColor = AppColors.warning.withValues(alpha: 0.1);
        fileIcon = Icons.description;
        iconColor = AppColors.warning;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
        child: Icon(fileIcon, color: iconColor, size: AppDimensions.iconMD),
      ),
      title: Text(material['title'] ?? '',
          style: AppTextStyles.labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${sizeKB ~/ 1024 > 0 ? "${sizeKB ~/ 1024} MB" : "${sizeKB} KB"} · $teacherName',
        style: AppTextStyles.caption,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.download_outlined,
            size: AppDimensions.iconMD, color: AppColors.textSecondary),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download coming soon')));
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/classroom_provider.dart';

class TestPerformanceWidget extends ConsumerWidget {
  final String studentId;

  const TestPerformanceWidget({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(testResultsProvider(studentId));

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
                const Text('Test Performance', style: AppTextStyles.h3),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All',
                      style: TextStyle(color: AppColors.studentBlue)),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.gapMD),
            resultsAsync.when(
              loading: () =>
                  const ShimmerBox(height: 200, width: double.infinity),
              error: (e, s) => const EmptyStateWidget(
                icon: Icons.bar_chart,
                title: 'No test results yet',
              ),
              data: (results) {
                if (results.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.bar_chart,
                    title: 'No test results yet',
                  );
                }

                // Calculate best rank and labels
                int bestRank = results.fold(
                    100,
                    (prev, element) => (element['rank'] as int) < prev
                        ? element['rank'] as int
                        : prev);
                const int classSize =
                    40; // Hardcoded class size per mock context
                final latestTest = results.last;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events,
                              color: AppColors.warning,
                              size: AppDimensions.iconLG),
                          const SizedBox(width: AppDimensions.gapSM),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Class Rank',
                                  style: AppTextStyles.caption),
                              Text(
                                'Rank $bestRank of $classSize',
                                style: AppTextStyles.h4
                                    .copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            latestTest['title'] ?? '',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.gapMD),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          minY: 0,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) =>
                                  AppColors.textPrimary.withValues(alpha: 0.8),
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                final test = results[groupIndex];
                                return BarTooltipItem(
                                  '${test['subjectName']}\n${test['marks']}/${test['totalMarks']}',
                                  AppTextStyles.caption
                                      .copyWith(color: Colors.white),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= results.length)
                                    return const SizedBox.shrink();
                                  final subjectName = results[value.toInt()]
                                      ['subjectName'] as String;
                                  final label = subjectName.length > 4
                                      ? subjectName.substring(0, 3)
                                      : subjectName;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(label,
                                        style: AppTextStyles.caption),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (_) => const FlLine(
                              color: AppColors.borderLight,
                              strokeWidth: 0.5,
                            ),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(results.length, (i) {
                            final test = results[i];
                            final percent =
                                (test['percentage'] as num? ?? 0).toDouble();
                            final classAvgPercent =
                                (test['classAverage'] as num? ?? 0) /
                                    (test['totalMarks'] as num? ?? 1) *
                                    100;
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: percent,
                                  color:
                                      AppColors.subjectColor(test['subjectId']),
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top:
                                        Radius.circular(AppDimensions.radiusXS),
                                  ),
                                ),
                                BarChartRodData(
                                  toY: classAvgPercent,
                                  color: AppColors.borderMedium,
                                  width: 12,
                                  borderRadius: const BorderRadius.vertical(
                                    top:
                                        Radius.circular(AppDimensions.radiusXS),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.gapSM),
                    Row(
                      children: [
                        _LegendDot(
                            color: AppColors.studentBlue, label: 'Your score'),
                        const SizedBox(width: AppDimensions.gapLG),
                        _LegendDot(
                            color: AppColors.borderMedium,
                            label: 'Class average'),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

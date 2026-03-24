import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/fade_in_slide.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../student/home/providers/student_home_provider.dart';

class FeeDashboardScreen extends ConsumerWidget {
  const FeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentStudentProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (profile) {
        if (profile == null)
          return const Scaffold(body: Center(child: Text('Profile not found')));

        final feeHistoryAsync =
            ref.watch(feeHistoryProvider(profile.studentId));

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          appBar: AppBar(
            title: const Text('Fee Dashboard'),
            backgroundColor: AppColors.bgPrimary,
            elevation: 0,
            foregroundColor: AppColors.textPrimary,
          ),
          body: feeHistoryAsync.when(
            loading: () => const LoadingIndicator(),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (fees) {
              final pendingFees =
                  fees.where((f) => f.status != 'paid').toList();
              final totalOutstanding =
                  pendingFees.fold<double>(0, (sum, f) => sum + f.netPayable);

              return ListView(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                children: [
                  FadeInSlide(
                    delay: const Duration(milliseconds: 0),
                    child: _OutstandingBalanceCard(amount: totalOutstanding),
                  ),
                  const SizedBox(height: AppDimensions.gapSection),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child:
                        const Text('Fee Installments', style: AppTextStyles.h4),
                  ),
                  const SizedBox(height: AppDimensions.gapMD),
                  ...fees.asMap().entries.map((entry) {
                    final index = entry.key;
                    return FadeInSlide(
                      delay: Duration(milliseconds: 200 + (index * 50)),
                      child: _FeeInstallmentTile(fee: entry.value),
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _OutstandingBalanceCard extends StatelessWidget {
  final double amount;

  const _OutstandingBalanceCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.studentBlue,
            AppColors.studentBlue.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.studentBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL OUTSTANDING',
            style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8), letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##,###').format(amount)}',
            style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 32),
          ),
          const SizedBox(height: 20),
          if (amount > 0)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.studentBlue,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child:
                  const Text('PAY TOTAL DUO', style: AppTextStyles.labelLarge),
            )
          else
            const Text(
              'All fees paid. Great job!',
              style: AppTextStyles.labelLarge,
            ),
        ],
      ),
    );
  }
}

class _FeeInstallmentTile extends StatelessWidget {
  final dynamic fee;

  const _FeeInstallmentTile({required this.fee});

  @override
  Widget build(BuildContext context) {
    bool isPaid = fee.status == 'paid';
    bool isOverdue = fee.status == 'overdue';

    Color statusColor = isPaid
        ? AppColors.success
        : (isOverdue ? AppColors.error : AppColors.warning);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapMD),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(
                  isPaid ? Icons.check_circle_outline : Icons.pending_actions,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.gapMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${fee.quarter} Installment',
                        style: AppTextStyles.labelLarge),
                    Text(
                      isPaid
                          ? 'Paid on ${DateFormat('MMM d, yyyy').format(fee.paidAt!)}'
                          : 'Due by ${DateFormat('MMM d, yyyy').format(DateTime.parse(fee.dueDate))}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text(
                '₹${NumberFormat('#,##,###').format(fee.netPayable)}',
                style: AppTextStyles.labelLarge
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (!isPaid) ...[
            const Divider(height: 24),
            Row(
              children: [
                if (isOverdue)
                  Text(
                    'LATE FINE: ₹${fee.lateFine}',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('PAY NOW'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

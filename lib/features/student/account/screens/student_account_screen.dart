import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../home/providers/student_home_provider.dart';
import '../widgets/student_details_card.dart';
import '../widgets/fee_status_card.dart';
import 'student_profile_screen.dart';
import '../../../../core/widgets/fade_in_slide.dart';

class StudentAccountScreen extends ConsumerWidget {
  const StudentAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentStudentProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bgSecondary,
        body: LoadingIndicator(),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bgSecondary,
        body: Center(child: Text('Error: $e')),
      ),
      data: (profile) {
        if (profile == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            backgroundColor: AppColors.bgSecondary,
            body: LoadingIndicator(),
          );
        }

        // Fetch fee data dynamically
        final pendingFeeAsync = ref.watch(pendingFeeProvider(profile.studentId));

        return Scaffold(
          backgroundColor: AppColors.bgSecondary,
          appBar: AppBar(
            title: const Text('My Account'),
            backgroundColor: AppColors.bgPrimary,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              FadeInSlide(
                delay: const Duration(milliseconds: 0),
                child: StudentDetailsCard(student: profile.toMap()),
              ),
              
              // Compact Actions
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const StudentProfileScreen(),
                            ));
                          },
                          icon: const Icon(Icons.person_outline, size: 18),
                          label: const Text('View Full Profile'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement Edit Details
                          },
                          icon: const Icon(Icons.edit_note, size: 18),
                          label: const Text('Edit Details'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fees Section
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: pendingFeeAsync.when(
                  data: (fee) {
                    if (fee == null || fee.netPayable <= 0) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Current Dues', style: AppTextStyles.h4),
                        ),
                        FeeStatusCard(fee: fee.toMap()),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 24),

              // Logout / Settings
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text('Are you sure you want to log out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await ref.read(authRepositoryProvider).signOut();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          }
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Log Out', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

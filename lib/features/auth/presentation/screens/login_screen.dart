// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    ref.read(loginProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // Listen for successful login to navigate
    ref.listen(loginProvider, (_, next) {
      if (next is LoginSuccess) {
        // Role-based navigation
        if (next.user.isStudent) {
          context.go('/student/home');
        } else if (next.user.isTeacher) {
          context.go('/teacher/home');
        } else if (next.user.isParent) {
          context.go('/parent/home');
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingXXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo + Title
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  ),
                  child: const Center(
                    child: Text(
                      'In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Indivio', style: AppTextStyles.display),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Smart School Management',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Form Title
              const Text('Login to your account', style: AppTextStyles.h3),
              const SizedBox(height: AppDimensions.gapMD),

              // Email Field
              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'yourname@school.edu',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                enabled: loginState is! LoginLoading,
              ),
              const SizedBox(height: AppDimensions.gapMD),

              // Password Field
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                enabled: loginState is! LoginLoading,
              ),
              const SizedBox(height: AppDimensions.gapLG),

              // Login Button & Error State
              Column(
                children: [
                  CustomButton(
                    label: loginState is LoginLoading ? '' : 'Login',
                    isLoading: loginState is LoginLoading,
                    onTap: loginState is LoginLoading ? null : _attemptLogin,
                  ),
                  if (loginState is LoginError) ...[
                    const SizedBox(height: AppDimensions.gapMD),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingMD),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: AppDimensions.iconMD,
                          ),
                          const SizedBox(width: AppDimensions.gapSM),
                          Expanded(
                            child: Text(
                              (loginState).message,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // Footer
              const Center(
                child: Text(
                  'Indivio Edtech · v1.0.0',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/core/widgets/app_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

// ============================================================================
// StudentShell
// ============================================================================

class StudentShell extends StatelessWidget {
  const StudentShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _IndivioBottomNav(
        roleColor: AppColors.studentBlue,
        items: const [
          _NavItem(icon: Icons.home_rounded, label: 'Home'),
          _NavItem(icon: Icons.menu_book_rounded, label: 'Classroom'),
          _NavItem(icon: Icons.person_rounded, label: 'Account'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/student/home');
            case 1:
              context.go('/student/classroom');
            case 2:
              context.go('/student/account');
          }
        },
        currentIndex: _getSelectedIndex(context),
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    try {
      final location = GoRouterState.of(context).uri.path;
      if (location.startsWith('/student/classroom')) return 1;
      if (location.startsWith('/student/account')) return 2;
    } catch (_) {}
    return 0;
  }
}

// ============================================================================
// TeacherShell
// ============================================================================

class TeacherShell extends StatelessWidget {
  const TeacherShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _IndivioBottomNav(
        roleColor: AppColors.teacherPurple,
        items: const [
          _NavItem(icon: Icons.home_rounded, label: 'Home'),
          _NavItem(icon: Icons.class_rounded, label: 'My Class'),
          _NavItem(icon: Icons.person_rounded, label: 'Account'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/teacher/home');
            case 1:
              context.go('/teacher/classroom');
            case 2:
              context.go('/teacher/account');
          }
        },
        currentIndex: _getSelectedIndex(context),
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    try {
      final location = GoRouterState.of(context).uri.path;
      if (location.startsWith('/teacher/classroom')) return 1;
      if (location.startsWith('/teacher/account')) return 2;
    } catch (_) {}
    return 0;
  }
}

// ============================================================================
// ParentShell
// ============================================================================

class ParentShell extends StatelessWidget {
  const ParentShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _IndivioBottomNav(
        roleColor: AppColors.parentTeal,
        items: const [
          _NavItem(icon: Icons.home_rounded, label: 'Overview'),
          _NavItem(icon: Icons.school_rounded, label: 'Academics'),
          _NavItem(icon: Icons.person_rounded, label: 'Account'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/parent/home');
            case 1:
              context.go('/parent/academics');
            case 2:
              context.go('/parent/account');
          }
        },
        currentIndex: _getSelectedIndex(context),
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    try {
      final location = GoRouterState.of(context).uri.path;
      if (location.startsWith('/parent/academics')) return 1;
      if (location.startsWith('/parent/account')) return 2;
    } catch (_) {}
    return 0;
  }
}

// ============================================================================
// _IndivioBottomNav (Private)
// ============================================================================

class _IndivioBottomNav extends StatelessWidget {
  const _IndivioBottomNav({
    required this.roleColor,
    required this.items,
    required this.onTap,
    required this.currentIndex,
  });

  final Color roleColor;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppDimensions.bottomNavHeight,
          child: Row(
            children: List.generate(
              items.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? roleColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSM,
                      vertical: AppDimensions.paddingXS,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[index].icon,
                          size: AppDimensions.bottomNavIconSize,
                          color: currentIndex == index
                              ? roleColor
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index].label,
                          style: AppTextStyles.navLabel.copyWith(
                            color: currentIndex == index
                                ? roleColor
                                : AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// _NavItem (Private)
// ============================================================================

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

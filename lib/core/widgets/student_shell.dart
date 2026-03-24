import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class StudentShell extends StatelessWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/student/classroom')) return 1;
    if (location.startsWith('/student/account')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _IndivioBottomNav(
        currentIndex: _selectedIndex(context),
        roleColor: AppColors.studentBlue,
        items: const [
          _NavItem(icon: Icons.home_rounded, label: 'Home'),
          _NavItem(icon: Icons.menu_book_rounded, label: 'Classroom'),
          _NavItem(icon: Icons.person_rounded, label: 'Account'),
        ],
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/student/home');
              break;
            case 1:
              context.go('/student/classroom');
              break;
            case 2:
              context.go('/student/account');
              break;
          }
        },
      ),
    );
  }
}

class TeacherShell extends StatelessWidget {
  final Widget child;
  const TeacherShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/teacher/classroom')) return 1;
    if (location.startsWith('/teacher/account')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _IndivioBottomNav(
        currentIndex: _selectedIndex(context),
        roleColor: AppColors.teacherPurple,
        items: const [
          _NavItem(icon: Icons.home_rounded, label: 'Home'),
          _NavItem(icon: Icons.class_rounded, label: 'My Class'),
          _NavItem(icon: Icons.person_rounded, label: 'Account'),
        ],
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/teacher/home');
              break;
            case 1:
              context.go('/teacher/classroom');
              break;
            case 2:
              context.go('/teacher/account');
              break;
          }
        },
      ),
    );
  }
}

class ParentShell extends StatelessWidget {
  final Widget child;
  const ParentShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/parent/academics')) return 1;
    if (location.startsWith('/parent/account')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _IndivioBottomNav(
        currentIndex: _selectedIndex(context),
        roleColor: AppColors.parentTeal,
        items: const [
          _NavItem(icon: Icons.home_rounded, label: 'Overview'),
          _NavItem(icon: Icons.school_rounded, label: 'Academics'),
          _NavItem(icon: Icons.person_rounded, label: 'Account'),
        ],
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/parent/home');
              break;
            case 1:
              context.go('/parent/academics');
              break;
            case 2:
              context.go('/parent/account');
              break;
          }
        },
      ),
    );
  }
}

// Shared bottom nav component
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _IndivioBottomNav extends StatelessWidget {
  final int currentIndex;
  final Color roleColor;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _IndivioBottomNav({
    required this.currentIndex,
    required this.roleColor,
    required this.items,
    required this.onTap,
  });

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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLG,
                    vertical: AppDimensions.paddingSM,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? roleColor.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: Icon(
                          items[i].icon,
                          size: AppDimensions.bottomNavIconSize,
                          color:
                              isSelected ? roleColor : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected ? roleColor : AppColors.textTertiary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

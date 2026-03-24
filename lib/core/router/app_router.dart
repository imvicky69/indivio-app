// 🤖 Copilot: Generate GoRouter config for Flutter app with 3 user roles.
// Routes: /splash, /login, /student (shell with 3 tabs),
// /teacher (shell with 3 tabs), /parent (shell with 3 tabs).
// Use ShellRoute for bottom nav. Add redirect logic for auth guard.

import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/student/home/screens/student_home_screen.dart';
import '../../features/student/classroom/screens/student_classroom_screen.dart';
import '../../features/student/account/screens/student_account_screen.dart';
import '../../features/teacher/home/screens/teacher_home_screen.dart';
import '../../features/teacher/classroom/screens/teacher_classroom_screen.dart';
import '../../features/teacher/account/screens/teacher_account_screen.dart';
import '../../features/parent/home/screens/parent_home_screen.dart';
import '../../features/parent/academics/screens/parent_academics_screen.dart';
import '../../features/parent/account/screens/parent_account_screen.dart';
import '../widgets/app_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),

      // Student Shell
      ShellRoute(
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(
            path: '/student/home',
            name: 'student-home',
            builder: (_, __) => const StudentHomeScreen(),
          ),
          GoRoute(
            path: '/student/classroom',
            name: 'student-classroom',
            builder: (_, __) => const StudentClassroomScreen(),
          ),
          GoRoute(
            path: '/student/account',
            name: 'student-account',
            builder: (_, __) => const StudentAccountScreen(),
          ),
        ],
      ),

      // Teacher Shell
      ShellRoute(
        builder: (context, state, child) => TeacherShell(child: child),
        routes: [
          GoRoute(
            path: '/teacher/home',
            name: 'teacher-home',
            builder: (_, __) => const TeacherHomeScreen(),
          ),
          GoRoute(
            path: '/teacher/classroom',
            name: 'teacher-classroom',
            builder: (_, __) => const TeacherClassroomScreen(),
          ),
          GoRoute(
            path: '/teacher/account',
            name: 'teacher-account',
            builder: (_, __) => const TeacherAccountScreen(),
          ),
        ],
      ),

      // Parent Shell
      ShellRoute(
        builder: (context, state, child) => ParentShell(child: child),
        routes: [
          GoRoute(
            path: '/parent/home',
            name: 'parent-home',
            builder: (_, __) => const ParentHomeScreen(),
          ),
          GoRoute(
            path: '/parent/academics',
            name: 'parent-academics',
            builder: (_, __) => const ParentAcademicsScreen(),
          ),
          GoRoute(
            path: '/parent/account',
            name: 'parent-account',
            builder: (_, __) => const ParentAccountScreen(),
          ),
        ],
      ),
    ],
  );
}

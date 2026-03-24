// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../data/student_repository.dart';
import '../../domain/user_model.dart';
import '../../domain/student_profile_model.dart';

// ============================================================================
// Repositories
// ============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository();
});

// ============================================================================
// Auth State Streams
// ============================================================================

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateStream;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  // Watch auth state changes so this provider rebuilds naturally on login/logout
  final authUser = await ref.watch(authStateProvider.future);
  if (authUser == null) return null;
  
  return ref.watch(authRepositoryProvider).getCurrentUser();
});

final currentStudentProfileProvider = FutureProvider<StudentProfileModel?>(
  (ref) async {
    final user = await ref.watch(currentUserProvider.future);

    if (user == null || !user.isStudent || user.studentId == null) {
      return null;
    }

    try {
      final student = await ref
          .watch(studentRepositoryProvider)
          .getStudentById(user.studentId!);
      return student;
    } catch (_) {
      return null;
    }
  },
);

// ============================================================================
// Login State & Notifier
// ============================================================================

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final UserModel user;
  const LoginSuccess(this.user);
}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _authRepo;

  LoginNotifier(this._authRepo) : super(const LoginInitial());

  Future<void> login(String email, String password) async {
    state = const LoginLoading();
    try {
      final user = await _authRepo.signInWithEmail(email, password);
      if (user != null) {
        state = LoginSuccess(user);
      } else {
        state = const LoginError('Login failed. Please try again.');
      }
    } on Exception catch (e, stack) {
      print('LOGIN_NOTIFIER: Exception: $e\n$stack');
      final message = e.toString().replaceAll('Exception: ', '').trim();
      state = LoginError(message);
    } catch (e, stack) {
      print('LOGIN_NOTIFIER: Unexpected Error: $e\n$stack');
      state = const LoginError('An unexpected error occurred. Please try again.');
    }
  }

  void reset() {
    state = const LoginInitial();
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return LoginNotifier(authRepo);
});

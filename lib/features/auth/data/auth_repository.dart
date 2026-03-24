// lib/features/auth/data/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Sign in with email and password
  /// Returns UserModel on success
  /// Throws Exception with descriptive message on failure
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      print('AUTH: Start sign in');
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('AUTH: User object null? ${result.user == null}');
      if (result.user == null) return null;

      final uid = result.user?.uid ?? '';
      print('AUTH: User UID is $uid');

      final query = await _db
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      print('AUTH: Doc exists? ${query.docs.isNotEmpty}');
      if (query.docs.isEmpty) return null;

      final userData = query.docs.first.data();

      print('AUTH: Parsing Map');
      try {
        final model = UserModel.fromMap(userData, uid);
        print('AUTH: Parse success');
        return model;
      } catch (e, stack) {
        print('AUTH: Parse failed: $e, $stack');
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later';
          break;
        default:
          message = 'Login failed: ${e.message ?? "Unknown error"}';
      }
      throw Exception(message);
    } on Exception catch (e) {
      throw Exception('Login error: ${e.toString()}');
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Get current logged-in user
  /// Returns UserModel if user exists in Firestore, null otherwise
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final query = await _db
          .collection('users')
          .where('uid', isEqualTo: currentUser.uid)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;

      return UserModel.fromMap(
        query.docs.first.data(),
        currentUser.uid,
      );
    } on Exception catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Watch auth state changes
  Stream<User?> get authStateStream => _auth.authStateChanges();

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Update FCM token for push notifications
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _db.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    } on Exception catch (e) {
      throw Exception('Failed to update FCM token: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }
}

// lib/features/auth/data/student_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/student_profile_model.dart';

class StudentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get student profile by studentId
  Future<StudentProfileModel?> getStudentById(String studentId) async {
    try {
      final doc = await _db.collection('students').doc(studentId).get();

      if (!doc.exists) return null;

      return StudentProfileModel.fromMap(
        doc.data() as Map<String, dynamic>,
      );
    } on Exception catch (e) {
      throw Exception('Failed to fetch student: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch student: $e');
    }
  }

  /// Get student profile by userId (Firebase Auth uid)
  /// Requires schoolId to filter properly
  Future<StudentProfileModel?> getStudentByUserId(
    String userId,
    String schoolId,
  ) async {
    try {
      final query = await _db
          .collection('students')
          .where('schoolId', isEqualTo: schoolId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return StudentProfileModel.fromMap(
        query.docs.first.data(),
      );
    } on Exception catch (e) {
      throw Exception('Failed to fetch student by userId: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch student by userId: $e');
    }
  }

  /// Watch student profile changes in real-time
  Stream<StudentProfileModel?> watchStudent(String studentId) {
    return _db.collection('students').doc(studentId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return StudentProfileModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassroomRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch class info by ID
  Future<Map<String, dynamic>?> getClassById(String schoolId, String classId) async {
    try {
      final doc = await _db.collection('schools').doc(schoolId).collection('classes').doc(classId).get();
      if (!doc.exists) return null;
      return {
        ...doc.data()!, 
        'classId': doc.id,
        'id': doc.id,
      };
    } catch (e) {
      return null;
    }
  }

  /// Fetch teacher info by ID
  Future<Map<String, dynamic>?> getTeacherById(String schoolId, String teacherId) async {
    try {
      final doc = await _db.collection('schools').doc(schoolId).collection('teachers').doc(teacherId).get();
      if (!doc.exists) return null;
      return {
        ...doc.data()!, 
        'teacherId': doc.id,
        'id': doc.id,
      };
    } catch (e) {
      return null;
    }
  }

  /// Fetch assignments for a class
  Future<List<Map<String, dynamic>>> getAssignments(String schoolId, String classId) async {
    try {
      final snapshot = await _db
          .collection('assignments')
          .where('schoolId', isEqualTo: schoolId)
          .where('classId', isEqualTo: classId)
          .orderBy('dueDate', descending: false)
          .get();
      
      return snapshot.docs.map((doc) => {
        ...doc.data(), 
        'assignmentId': doc.id,
        'id': doc.id,
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch test results for a student
  Future<List<Map<String, dynamic>>> getTestResults(String schoolId, String classId) async {
    try {
      final snapshot = await _db
          .collection('testResults')
          .where('schoolId', isEqualTo: schoolId)
          .where('classId', isEqualTo: classId)
          .orderBy('publishedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => {
        ...doc.data(), 
        'testId': doc.id,
        'id': doc.id,
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch study materials for a class
  Future<List<Map<String, dynamic>>> getStudyMaterials(String schoolId, String classId) async {
    try {
      final snapshot = await _db
          .collection('materials')
          .where('schoolId', isEqualTo: schoolId)
          .where('classId', isEqualTo: classId)
          .get();
      
      return snapshot.docs.map((doc) => {
        ...doc.data(), 
        'materialId': doc.id,
        'id': doc.id,
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch syllabus tracker for a class
  Future<List<Map<String, dynamic>>> getSyllabusTracker(String schoolId, String classId) async {
    try {
      final snapshot = await _db
          .collection('syllabus')
          .where('schoolId', isEqualTo: schoolId)
          .where('classId', isEqualTo: classId)
          .get();
      
      return snapshot.docs.map((doc) => {
        ...doc.data(), 
        'syllabusId': doc.id,
        'id': doc.id,
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch assignment by ID
  Future<Map<String, dynamic>?> getAssignmentById(String schoolId, String assignmentId) async {
    try {
      final doc = await _db.collection('assignments').doc(assignmentId).get();
      if (!doc.exists) return null;
      return {
        ...doc.data()!,
        'assignmentId': doc.id,
        'id': doc.id,
      };
    } catch (e) {
      return null;
    }
  }
}

final classroomRepositoryProvider = Provider((ref) => ClassroomRepository());

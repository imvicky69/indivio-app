// lib/features/homework/data/homework_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'homework_model.dart';

class HomeworkRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get homework for a class with optional date filter
  Future<List<HomeworkModel>> getHomeworkForClass({
    required String schoolId,
    required String classId,
    String? dueDateFilter, // 'YYYY-MM-DD' or null for all
  }) async {
    try {
      var query = _db
          .collection('homework')
          .where('schoolId', isEqualTo: schoolId)
          .where('classId', isEqualTo: classId)
          .orderBy('dueDate', descending: false);

      if (dueDateFilter != null) {
        query = query.where('dueDate', isEqualTo: dueDateFilter);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => HomeworkModel.fromMap(doc.data(), doc.id))
          .toList();
    } on Exception catch (e) {
      throw Exception('Failed to fetch homework: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch homework: $e');
    }
  }

  /// Get today's homework for a class
  Future<List<HomeworkModel>> getTodayHomework({
    required String schoolId,
    required String classId,
  }) async {
    try {
      final now = DateTime.now();
      final todayDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      return getHomeworkForClass(
        schoolId: schoolId,
        classId: classId,
        dueDateFilter: todayDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch today\'s homework: $e');
    }
  }

  /// Get homework by ID
  Future<HomeworkModel?> getHomeworkById(String homeworkId) async {
    try {
      final doc = await _db.collection('homework').doc(homeworkId).get();
      if (!doc.exists) return null;
      return HomeworkModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch homework detail: $e');
    }
  }
}

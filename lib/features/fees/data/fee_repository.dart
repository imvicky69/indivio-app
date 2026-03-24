// lib/features/fees/data/fee_repository.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fee_model.dart';

class FeeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all fees for a student
  Future<List<FeeModel>> getFeesByStudent({
    required String schoolId,
    required String studentId,
  }) async {
    try {
      final snapshot = await _db
          .collection('fees')
          .where('schoolId', isEqualTo: schoolId)
          .where('studentId', isEqualTo: studentId)
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => FeeModel.fromMap(doc.data(), doc.id))
          .toList();
    } on Exception catch (e) {
      throw Exception('Failed to fetch fees: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch fees: $e');
    }
  }

  /// Get latest pending or overdue fee for a student
  /// Returns overdue first, then pending, then null
  Future<FeeModel?> getLatestPendingFee({
    required String schoolId,
    required String studentId,
  }) async {
    try {
      // NOTE: This query needs the composite index:
      // fees: schoolId ASC + studentId ASC + status ASC
      // Deploy firestore.indexes.json if this returns null unexpectedly.
      final snap = await _db
          .collection('fees')
          .where('schoolId', isEqualTo: schoolId)
          .where('studentId', isEqualTo: studentId)
          .where('status', whereIn: ['pending', 'overdue']).get();

      debugPrint('FeeRepository: found ${snap.docs.length} pending/overdue fees');

      if (snap.docs.isEmpty) return null;

      // Sort: overdue first, then pending
      final docs = snap.docs.toList()
        ..sort((a, b) {
          final aStatus = a.data()['status'] as String;
          final bStatus = b.data()['status'] as String;
          if (aStatus == 'overdue') return -1;
          if (bStatus == 'overdue') return 1;
          return 0;
        });

      return FeeModel.fromMap(docs.first.data(), docs.first.id);
    } catch (e) {
      debugPrint('FeeRepository.getLatestPendingFee error: $e');
      throw Exception('FeeRepository.getLatestPendingFee failed: $e');
    }
  }
}

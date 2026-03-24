// lib/features/notices/data/notice_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'notice_model.dart';

class NoticeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get announcements for school or specific class
  /// Pass classId = null to get only school-wide announcements
  Future<List<NoticeModel>> getAnnouncements({
    required String schoolId,
    String? classId,
    int limit = 10,
  }) async {
    try {
      var query = _db
          .collection('announcements')
          .where('schoolId', isEqualTo: schoolId)
          .orderBy('isPinned', descending: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch announcements: $e');
    }
  }

  /// Get specific notice by ID
  Future<NoticeModel?> getNoticeById(String noticeId) async {
    try {
      final doc = await _db.collection('announcements').doc(noticeId).get();
      if (!doc.exists) return null;
      return NoticeModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch notice detail: $e');
    }
  }
}

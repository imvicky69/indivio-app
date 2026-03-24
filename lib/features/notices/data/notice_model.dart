// lib/features/notices/data/notice_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String announcementId;
  final String schoolId;
  final List<String> classIds;
  final bool isSchoolWide;
  final String targetRole;
  final String title;
  final String body;
  final String category;
  final bool isPinned;
  final String? attachmentUrl;
  final String createdByName;
  final DateTime createdAt;

  const NoticeModel({
    required this.announcementId,
    required this.schoolId,
    required this.classIds,
    required this.isSchoolWide,
    required this.targetRole,
    required this.title,
    required this.body,
    required this.category,
    required this.isPinned,
    this.attachmentUrl,
    required this.createdByName,
    required this.createdAt,
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime createdAt = DateTime.now();
    final createdAtField = map['createdAt'];

    if (createdAtField is Timestamp) {
      createdAt = createdAtField.toDate();
    } else if (createdAtField is String) {
      try {
        createdAt = DateTime.parse(createdAtField);
      } catch (_) {
        // Use default
      }
    }

    return NoticeModel(
      announcementId: id,
      schoolId: (map['schoolId'] as String?) ?? '',
      classIds: (map['classIds'] as List<dynamic>?)?.cast<String>() ?? [],
      isSchoolWide: (map['isSchoolWide'] as bool?) ?? true,
      targetRole: (map['targetRole'] as String?) ?? 'all',
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
      isPinned: (map['isPinned'] as bool?) ?? false,
      attachmentUrl: map['attachmentUrl'] as String?,
      createdByName: (map['createdByName'] as String?) ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'classIds': classIds,
      'isSchoolWide': isSchoolWide,
      'targetRole': targetRole,
      'title': title,
      'body': body,
      'category': category,
      'isPinned': isPinned,
      'attachmentUrl': attachmentUrl,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  String toString() =>
      'NoticeModel(id: $announcementId, title: $title, category: $category)';
}

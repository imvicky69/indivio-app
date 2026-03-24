// lib/features/auth/domain/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'student' | 'teacher' | 'parent'
  final String schoolId;
  final String photoUrl;
  final String fcmToken;
  final String? studentId;
  final String? teacherId;
  final String? classId;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.schoolId,
    required this.photoUrl,
    required this.fcmToken,
    this.studentId,
    this.teacherId,
    this.classId,
    required this.createdAt,
  });

  /// Parse a Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
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

    return UserModel(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      role: (map['role'] as String?) ?? 'student',
      schoolId: (map['schoolId'] as String?) ?? '',
      photoUrl: (map['photoUrl'] as String?) ?? '',
      fcmToken: (map['fcmToken'] as String?) ?? '',
      studentId: map['studentId'] as String?,
      teacherId: map['teacherId'] as String?,
      classId: map['classId'] as String?,
      createdAt: createdAt,
    );
  }

  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'schoolId': schoolId,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'studentId': studentId,
      'teacherId': teacherId,
      'classId': classId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with some fields replaced
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? schoolId,
    String? photoUrl,
    String? fcmToken,
    String? studentId,
    String? teacherId,
    String? classId,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      classId: classId ?? this.classId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isStudent => role == 'student';
  bool get isTeacher => role == 'teacher';
  bool get isParent => role == 'parent';

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, role: $role)';
}

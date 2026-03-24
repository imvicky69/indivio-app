// 🤖 Copilot: Generate MockDataService class that loads all JSON files
// from Flutter assets using rootBundle. Each method returns parsed data.
// Include getSchool, getStudentById, getStudentByUid, getTimetable,
// getAttendance, getAcademics, getFeesAndLeaves, getMaterials.
// Handle errors gracefully with try/catch.

import 'dart:convert';
import 'package:flutter/services.dart';

class MockDataService {
  MockDataService._();

  static const String _basePath = 'assets/mock_db';

  static Future<Map<String, dynamic>> _loadJson(String file) async {
    final String data = await rootBundle.loadString('$_basePath/$file');
    return Map<String, dynamic>.from(json.decode(data));
  }

  static Future<List<Map<String, dynamic>>> _loadJsonList(String file) async {
    final String data = await rootBundle.loadString('$_basePath/$file');
    final List<dynamic> list = json.decode(data) as List<dynamic>;
    return list.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // School
  static Future<Map<String, dynamic>> getSchool() async {
    return _loadJson('school.json');
  }

  // Classes
  static Future<List<Map<String, dynamic>>> getClasses() async {
    return _loadJsonList('classes.json');
  }

  static Future<Map<String, dynamic>?> getClassById(String classId) async {
    final classes = await getClasses();
    try {
      return Map<String, dynamic>.from(classes.firstWhere(
        (c) => c['classId'] == classId,
      ));
    } catch (_) {
      return null;
    }
  }

  // Subjects
  static Future<List<Map<String, dynamic>>> getSubjects() async {
    return _loadJsonList('subjects.json');
  }

  // Students
  static Future<List<Map<String, dynamic>>> getStudents() async {
    return _loadJsonList('students.json');
  }

  static Future<Map<String, dynamic>?> getStudentById(String studentId) async {
    final students = await getStudents();
    try {
      return Map<String, dynamic>.from(students.firstWhere(
        (s) => s['studentId'] == studentId,
      ));
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getStudentByUid(String uid) async {
    final students = await getStudents();
    try {
      return Map<String, dynamic>.from(students.firstWhere(
        (s) => s['_queryKeys']['uid'] == uid,
      ));
    } catch (_) {
      return null;
    }
  }

  // Teachers
  static Future<List<Map<String, dynamic>>> getTeachers() async {
    return _loadJsonList('teachers.json');
  }

  static Future<Map<String, dynamic>?> getTeacherById(String teacherId) async {
    final teachers = await getTeachers();
    try {
      return teachers.firstWhere(
        (t) => t['teacherId'] == teacherId,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getTeacherByUid(String uid) async {
    final teachers = await getTeachers();
    try {
      return teachers.firstWhere(
        (t) => t['_queryKeys']['uid'] == uid,
      );
    } catch (_) {
      return null;
    }
  }

  // Timetable
  static Future<Map<String, dynamic>> getTimetable() async {
    return _loadJson('timetable.json');
  }

  static Future<List<dynamic>> getTodaySchedule(String dayName) async {
    final timetable = await getTimetable();
    final schedule = timetable['schedule'] as Map<String, dynamic>;
    return schedule[dayName.toLowerCase()] as List<dynamic>? ?? [];
  }

  // Attendance
  static Future<Map<String, dynamic>> getAttendance() async {
    return _loadJson('attendance.json');
  }

  static Future<Map<String, dynamic>?> getStudentAttendanceSummary(
      String studentId) async {
    final attendance = await getAttendance();
    final summaries = attendance['studentMonthlySummary'] as List<dynamic>;
    try {
      return summaries.firstWhere(
        (s) => s['studentId'] == studentId,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String> getTodayStatus(String studentId) async {
    final attendance = await getAttendance();
    final records = attendance['dailyRecords'] as List<dynamic>;

    // For dev: use Nov 20 as "today" since mock data is for Nov 2024
    const devToday = '2024-11-20';

    try {
      final dayRecord = Map<String, dynamic>.from(records.firstWhere(
        (r) => r['date'] == devToday,
      ));
      final students = dayRecord['students'] as List<dynamic>;
      final student = Map<String, dynamic>.from(students.firstWhere(
        (s) => s['studentId'] == studentId,
      ));
      return student['status'] as String;
    } catch (_) {
      return 'A';
    }
  }

  // Academics (Homework, Assignments, Tests)
  static Future<Map<String, dynamic>> getAcademics() async {
    return _loadJson('academics.json');
  }

  static Future<List<dynamic>> getHomework() async {
    final academics = await getAcademics();
    return (academics['homework'] as List<dynamic>)
        .map((h) => Map<String, dynamic>.from(h))
        .toList();
  }

  static Future<List<dynamic>> getAssignments() async {
    final academics = await getAcademics();
    return (academics['assignments'] as List<dynamic>)
        .map((a) => Map<String, dynamic>.from(a))
        .toList();
  }

  static Future<List<dynamic>> getTestResults() async {
    final academics = await getAcademics();
    return (academics['testResults'] as List<dynamic>)
        .map((t) => Map<String, dynamic>.from(t))
        .toList();
  }

  // Fees, Leaves, Announcements, Notifications
  static Future<Map<String, dynamic>> getFeesAndLeaves() async {
    return _loadJson('fees_leaves_announcements.json');
  }

  static Future<List<dynamic>> getFeesByStudentId(String studentId) async {
    final data = await getFeesAndLeaves();
    final fees = data['fees'] as List<dynamic>;
    return fees.where((f) => f['studentId'] == studentId).toList();
  }

  static Future<List<dynamic>> getAnnouncements() async {
    final data = await getFeesAndLeaves();
    return data['announcements'] as List<dynamic>;
  }

  static Future<List<dynamic>> getNotificationsByUid(String uid) async {
    final data = await getFeesAndLeaves();
    final notifs = data['notifications'] as List<dynamic>;
    return notifs.where((n) => n['targetUid'] == uid).toList();
  }

  static Future<List<dynamic>> getLeavesByStudentId(String studentId) async {
    final data = await getFeesAndLeaves();
    final leaves = data['leaves'] as List<dynamic>;
    return leaves.where((l) => l['studentId'] == studentId).toList();
  }

  // Materials & Syllabus
  static Future<Map<String, dynamic>> getMaterials() async {
    return _loadJson('materials_syllabus.json');
  }

  static Future<List<dynamic>> getStudyMaterials() async {
    final data = await getMaterials();
    return (data['studyMaterials'] as List<dynamic>)
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  static Future<List<dynamic>> getSyllabusTracker() async {
    final data = await getMaterials();
    return (data['syllabusTracker'] as List<dynamic>)
        .map((s) => Map<String, dynamic>.from(s))
        .toList();
  }
}

// lib/features/attendance/data/attendance_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get today's attendance status for a student
  /// Returns status string ('P', 'A', 'L', 'OL') or 'A' if not found
  Future<String> getTodayStatus({
    required String schoolId,
    required String classId,
    required String studentId,
    required String date, // 'YYYY-MM-DD'
  }) async {
    try {
      final doc = await _db
          .collection('attendance')
          .doc(schoolId)
          .collection(date)
          .doc(classId)
          .collection('students')
          .doc(studentId)
          .get();

      if (!doc.exists) return 'A'; // Absent by default

      return (doc.data()?['status'] as String?) ?? 'A';
    } on Exception catch (e) {
      throw Exception('Failed to fetch attendance: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch attendance: $e');
    }
  }

  /// Get monthly attendance summary for a student
  /// Returns map with records list and summary stats
  Future<Map<String, dynamic>> getMonthlyAttendance({
    required String schoolId,
    required String classId,
    required String studentId,
    required int month,
    required int year,
  }) async {
    try {
      // Build all dates in the month
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final dates = List.generate(daysInMonth, (i) {
        final day = i + 1;
        return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      });

      // Fetch all dates in parallel — catch individual failures
      final futures = dates.map((date) async {
        try {
          final doc = await _db
              .collection('attendance')
              .doc(schoolId)
              .collection(date)
              .doc(classId)
              .collection('students')
              .doc(studentId)
              .get();
          if (!doc.exists) return null;
          return {'date': date, 'status': doc.data()?['status'] ?? 'A'};
        } catch (_) {
          return null; // date has no record — skip silently
        }
      });

      final results = await Future.wait(futures);
      final records = results.whereType<Map<String, dynamic>>().toList();

      // Calculate summary
      int present = 0, absent = 0, late = 0, leave = 0;
      for (final r in records) {
        switch (r['status']) {
          case 'P':
            present++;
            break;
          case 'A':
            absent++;
            break;
          case 'Late':
          case 'L': // Handle both 'Late' and 'L'
            late++;
            break;
          case 'OL':
          case 'Leave': // Handle both 'OL' and 'Leave'
            leave++;
            break;
        }
      }
      final total = present + absent + late + leave;
      final percent = total > 0
          ? double.parse(((present + late) / total * 100).toStringAsFixed(1))
          : 0.0;

      return {
        'records': records,
        'summary': {
          'present': present,
          'absent': absent,
          'late': late,
          'leave': leave,
          'totalWorkingDays': total,
          'attendancePercent': percent,
        },
      };
    } catch (e) {
      throw Exception('AttendanceRepository.getMonthlyAttendance failed: $e');
    }
  }

  /// Get attendance for entire class on a specific date
  Future<List<Map<String, dynamic>>> getClassAttendance({
    required String schoolId,
    required String classId,
    required String date,
  }) async {
    try {
      final snapshot = await _db
          .collection('attendance')
          .doc(schoolId)
          .collection(date)
          .doc(classId)
          .collection('students')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'studentId': doc.id,
          'status': (doc.data()['status'] as String?) ?? 'A',
          'remarks': (doc.data()['remarks'] as String?) ?? '',
        };
      }).toList();
    } on Exception catch (e) {
      throw Exception('Failed to fetch class attendance: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch class attendance: $e');
    }
  }
}

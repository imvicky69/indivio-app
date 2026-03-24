// lib/features/student/home/providers/student_home_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/dev_config.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../attendance/data/attendance_repository.dart';
import '../../../homework/data/homework_repository.dart';
import '../../../homework/data/homework_model.dart';
import '../../../fees/data/fee_repository.dart';
import '../../../fees/data/fee_model.dart';
import '../../../notices/data/notice_repository.dart';
import '../../../notices/data/notice_model.dart';
import '../../../auth/data/student_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ── Models for Families ──────────────────────────────────

class AttendanceParams {
  final String studentId;
  final int month;
  final int year;

  const AttendanceParams({
    required this.studentId,
    required this.month,
    required this.year,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceParams &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => studentId.hashCode ^ month.hashCode ^ year.hashCode;
}

final attendanceCalendarFocusProvider = StateProvider<DateTime>((ref) {
  return DevConfig.DEV_MODE ? DateTime(2024, 11, 20) : DateTime.now();
});

// Helper to get active session IDs
Future<Map<String, String>> _getSession(Ref ref) async {
  if (DevConfig.USE_FIRESTORE) {
    final profile = await ref.watch(currentStudentProfileProvider.future);
    if (profile != null) {
      return {
        'schoolId': profile.schoolId,
        'classId': profile.classId,
        'studentId': profile.studentId,
      };
    }
  }
  return {
    'schoolId': 'SCH001',
    'classId': 'CLS_10A',
    'studentId': 'STU001',
  };
}

// ── Repository providers ──────────────────────────────────

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepository(),
);
final homeworkRepositoryProvider = Provider<HomeworkRepository>(
  (ref) => HomeworkRepository(),
);
final feeRepositoryProvider = Provider<FeeRepository>(
  (ref) => FeeRepository(),
);
final noticeRepositoryProvider = Provider<NoticeRepository>(
  (ref) => NoticeRepository(),
);
final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepository(),
);

// ── Student data ──────────────────────────────────────────

final studentDataProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, studentId) async {
    try {
      if (DevConfig.USE_FIRESTORE) {
        // use passed studentId if it looks like a real ID, else fall back to session
        final profile = await ref.read(studentRepositoryProvider).getStudentById(studentId);
        return profile?.toMap();
      } else {
        return await MockDataService.getStudentByUid('UID_$studentId');
      }
    } catch (e) {
      debugPrint('studentDataProvider error: $e');
      return null;
    }
  },
);

// ── Today's schedule ──────────────────────────────────────

final todayScheduleProvider = FutureProvider<List<dynamic>>(
  (ref) async {
    try {
      final dayName = DevConfig.effectiveDayName();
      return await MockDataService.getTodaySchedule(dayName);
    } catch (e) {
      debugPrint('todayScheduleProvider error: $e');
      return [];
    }
  },
);

// ── Today's attendance status ─────────────────────────────

final todayAttendanceProvider = FutureProvider.family<String, String>(
  (ref, studentId) async {
    try {
      if (DevConfig.USE_FIRESTORE) {
        final session = await _getSession(ref);
        final repo = ref.read(attendanceRepositoryProvider);
        return await repo.getTodayStatus(
          schoolId: session['schoolId']!,
          classId: session['classId']!,
          studentId: studentId,
          date: DevConfig.effectiveDate(),
        );
      } else {
        return await MockDataService.getTodayStatus(studentId);
      }
    } catch (e) {
      debugPrint('todayAttendanceProvider error: $e');
      return 'A';
    }
  },
);

// ── Monthly attendance summary ────────────────────────────

final attendanceSummaryProvider =
    FutureProvider.family<Map<String, dynamic>?, AttendanceParams>(
  (ref, params) async {
    try {
      if (DevConfig.USE_FIRESTORE) {
        final session = await _getSession(ref);
        final repo = ref.read(attendanceRepositoryProvider);
        final result = await repo.getMonthlyAttendance(
          schoolId: session['schoolId']!,
          classId: session['classId']!,
          studentId: params.studentId,
          month: params.month,
          year: params.year,
        );
        return result['summary'] as Map<String, dynamic>?;
      } else {
        return await MockDataService.getStudentAttendanceSummary(params.studentId);
      }
    } catch (e) {
      debugPrint('attendanceSummaryProvider error: $e');
      return null;
    }
  },
);

// ── Monthly attendance records (for calendar dots) ────────

final attendanceRecordsProvider =
    FutureProvider.family<List<dynamic>, AttendanceParams>(
  (ref, params) async {
    try {
      if (DevConfig.USE_FIRESTORE) {
        final session = await _getSession(ref);
        final repo = ref.read(attendanceRepositoryProvider);
        final result = await repo.getMonthlyAttendance(
          schoolId: session['schoolId']!,
          classId: session['classId']!,
          studentId: params.studentId,
          month: params.month,
          year: params.year,
        );
        return result['records'] as List<dynamic>? ?? [];
      } else {
        // Mock only supports Nov 2024
        if (params.month == 11 && params.year == 2024) {
          final attendance = await MockDataService.getAttendance();
          final dailyRecords = attendance['dailyRecords'] as List<dynamic>;
          final records = <Map<String, dynamic>>[];
          for (final day in dailyRecords) {
            if (day['isHoliday'] == true) {
              records.add({'date': day['date'], 'status': 'H'});
              continue;
            }
            final students = day['students'] as List<dynamic>? ?? [];
            final studentRecordArray = students.where(
              (s) => s['studentId'] == params.studentId,
            );
            if (studentRecordArray.isNotEmpty) {
              records.add({
                'date': day['date'],
                'status': studentRecordArray.first['status'],
              });
            }
          }
          return records;
        }
        return [];
      }
    } catch (e) {
      debugPrint('attendanceRecordsProvider error: $e');
      return [];
    }
  },
);

// ── Today's homework ──────────────────────────────────────

final homeworkTodayProvider = FutureProvider<List<HomeworkModel>>(
  (ref) async {
    try {
      final dueDate = DevConfig.effectiveDate();
      
      if (DevConfig.USE_FIRESTORE) {
        final session = await _getSession(ref);
        final repo = ref.read(homeworkRepositoryProvider);
        return await repo.getHomeworkForClass(
          schoolId: session['schoolId']!,
          classId: session['classId']!,
          dueDateFilter: dueDate,
        );
      } else {
        final mockData = await MockDataService.getHomework();
        return mockData
            .where((m) => (m['dueDate'] as String?) == dueDate)
            .map((m) => HomeworkModel.fromMap(m, (m['homeworkId'] as String?) ?? 'mock'))
            .toList();
      }
    } catch (e) {
      debugPrint('homeworkTodayProvider error: $e');
      return [];
    }
  },
);

// ── Pending assignments count ─────────────────────────────

final pendingAssignmentsProvider = FutureProvider.family<int, String>(
  (ref, studentId) async {
    try {
      // Currently assignments are mock only OR handled by classroom_provider
      final academics = await MockDataService.getAcademics();
      final assignments = academics['assignments'] as List<dynamic>;
      int count = 0;
      for (final assignment in assignments) {
        final submissions = assignment['submissions'] as List<dynamic>? ?? [];
        final hasSubmission = submissions.any((s) => s['studentId'] == studentId);
        if (!hasSubmission) count++;
      }
      return count;
    } catch (e) {
      debugPrint('pendingAssignmentsProvider error: $e');
      return 0;
    }
  },
);

// ── Pending fee ───────────────────────────────────────────

final pendingFeeProvider = FutureProvider.family<FeeModel?, String>(
  (ref, studentId) async {
    try {
      if (DevConfig.USE_FIRESTORE) {
        final session = await _getSession(ref);
        final repo = ref.read(feeRepositoryProvider);
        return await repo.getLatestPendingFee(
          schoolId: session['schoolId']!,
          studentId: studentId,
        );
      } else {
        final fees = await MockDataService.getFeesByStudentId(studentId);
        final pending = fees.where((f) => f['status'] == 'pending' || f['status'] == 'overdue').toList();
        if (pending.isEmpty) return null;
        pending.sort((a, b) {
          if (a['status'] == 'overdue') return -1;
          if (b['status'] == 'overdue') return 1;
          return 0;
        });
        return FeeModel.fromMap(pending.first as Map<String, dynamic>, 'mock');
      }
    } catch (e) {
      debugPrint('pendingFeeProvider error: $e');
      return null;
    }
  },
);

// ── Announcements ─────────────────────────────────────────

final announcementsProvider = FutureProvider<List<NoticeModel>>(
  (ref) async {
    try {
      if (DevConfig.USE_FIRESTORE) {
        final session = await _getSession(ref);
        final repo = ref.read(noticeRepositoryProvider);
        return await repo.getAnnouncements(schoolId: session['schoolId']!, limit: 3);
      } else {
        final all = await MockDataService.getAnnouncements();
        return all.take(3).map((m) => NoticeModel.fromMap(m, 'mock')).toList();
      }
    } catch (e) {
      debugPrint('announcementsProvider error: $e');
      return [];
    }
  },
);

// ── Active leave ──────────────────────────────────────────

final activeLeaveProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, studentId) async {
    try {
      final leaves = await MockDataService.getLeavesByStudentId(studentId);
      final active = leaves.where((l) => l['status'] == 'pending' || l['status'] == 'approved').toList();
      if (active.isEmpty) return null;
      return active.first as Map<String, dynamic>;
    } catch (e) {
      debugPrint('activeLeaveProvider error: $e');
      return null;
    }
  },
);
final homeworkDetailProvider = FutureProvider.family<HomeworkModel?, String>(
  (ref, homeworkId) async {
    try {
      if (DevConfig.USE_FIRESTORE) {
        return await ref.read(homeworkRepositoryProvider).getHomeworkById(homeworkId);
      } else {
        final mockData = await MockDataService.getHomework();
        final match = mockData.firstWhere(
          (m) => (m['homeworkId'] as String?) == homeworkId,
          orElse: () => mockData.first,
        );
        return HomeworkModel.fromMap(match, (match['homeworkId'] as String?) ?? 'mock');
      }
    } catch (e) {
      debugPrint('homeworkDetailProvider error: $e');
      return null;
    }
  },
);

final noticeDetailProvider = FutureProvider.family<NoticeModel?, String>(
  (ref, noticeId) async {
    try {
      if (DevConfig.USE_FIRESTORE) {
        return await ref.read(noticeRepositoryProvider).getNoticeById(noticeId);
      } else {
        final mockData = await MockDataService.getAnnouncements();
        final match = mockData.firstWhere(
          (m) => (m['noticeId'] as String?) == noticeId,
          orElse: () => mockData.first,
        );
        return NoticeModel.fromMap(match, (match['noticeId'] as String?) ?? 'mock');
      }
    } catch (e) {
      debugPrint('noticeDetailProvider error: $e');
      return null;
    }
  },
);

final feeHistoryProvider = FutureProvider.family<List<FeeModel>, String>(
  (ref, studentId) async {
    try {
      if (DevConfig.USE_FIRESTORE) {
        final session = await _getSession(ref);
        return await ref.read(feeRepositoryProvider).getFeesByStudent(
          schoolId: session['schoolId']!,
          studentId: studentId,
        );
      } else {
        final fees = await MockDataService.getFeesByStudentId(studentId);
        return fees.map((m) => FeeModel.fromMap(m as Map<String, dynamic>, 'mock')).toList();
      }
    } catch (e) {
      debugPrint('feeHistoryProvider error: $e');
      return [];
    }
  },
);

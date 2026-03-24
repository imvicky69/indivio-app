import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/utils/dev_config.dart';
import '../data/classroom_repository.dart';
import '../../../homework/data/homework_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Repository Providers
final homeworkRepoProvider = Provider((ref) => HomeworkRepository());

// Helper to get active session IDs
Future<Map<String, String>> _getSession(WidgetRef? ref, Ref? providerRef) async {
  final r = ref ?? (providerRef as dynamic);
  
  if (DevConfig.USE_FIRESTORE) {
    final profile = await r.watch(currentStudentProfileProvider.future);
    if (profile != null) {
      return {
        'schoolId': profile.schoolId,
        'classId': profile.classId,
        'studentId': profile.studentId,
      };
    }
  }
  
  // Default/Mock Fallback
  return {
    'schoolId': 'SCH001',
    'classId': 'CLS_10A',
    'studentId': 'STU001',
  };
}

// 1. Class Info Provider
final classInfoProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, classId) async {
  try {
    if (DevConfig.USE_FIRESTORE) {
      final session = await _getSession(null, ref);
      return await ref.read(classroomRepositoryProvider).getClassById(session['schoolId']!, classId);
    } else {
      return await MockDataService.getClassById(classId);
    }
  } catch (e) {
    debugPrint('Error fetching class info: $e');
    return null;
  }
});

// 2. Class Teacher Provider
final classTeacherProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, teacherId) async {
  try {
    if (DevConfig.USE_FIRESTORE) {
      final session = await _getSession(null, ref);
      return await ref.read(classroomRepositoryProvider).getTeacherById(session['schoolId']!, teacherId);
    } else {
      return await MockDataService.getTeacherById(teacherId);
    }
  } catch (e) {
    debugPrint('Error fetching teacher info: $e');
    return null;
  }
});

// 3. All Homework Provider
final allHomeworkProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final session = await _getSession(null, ref);
    List<dynamic> homework;
    if (DevConfig.USE_FIRESTORE) {
      final models = await ref.read(homeworkRepoProvider).getHomeworkForClass(
        schoolId: session['schoolId']!,
        classId: session['classId']!,
      );
      homework = models.map((m) => m.toMap()).toList();
    } else {
      homework = await MockDataService.getHomework();
    }
    
    final results = homework.map((h) => Map<String, dynamic>.from(h)).toList();
    results.sort((a, b) => (a['dueDate'] as String).compareTo(b['dueDate'] as String));
    return results;
  } catch (e) {
    debugPrint('Error fetching all homework: $e');
    return [];
  }
});

// 4. Homework By Tab Provider
final homeworkByTabProvider = FutureProvider.family<List<dynamic>, String>((ref, tab) async {
  try {
    final homeworkResult = await ref.watch(allHomeworkProvider.future);
    final typedHomework = homeworkResult.map((h) => Map<String, dynamic>.from(h)).toList();
    
    final effectiveDate = DevConfig.effectiveDate();
    
    if (tab == 'today') {
      return typedHomework.where((h) => h['dueDate'] == effectiveDate).toList();
    } else {
      return typedHomework.where((h) => (h['dueDate'] as String).compareTo(effectiveDate) > 0).toList();
    }
  } catch (e) {
    debugPrint('Error fetching homework by tab: $e');
    return [];
  }
});

// 5. All Assignments Provider
final assignmentsProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final session = await _getSession(null, ref);
    if (DevConfig.USE_FIRESTORE) {
      final list = await ref.read(classroomRepositoryProvider).getAssignments(session['schoolId']!, session['classId']!);
      return list.map((a) => Map<String, dynamic>.from(a)).toList();
    } else {
      final assignments = await MockDataService.getAssignments();
      return assignments.map((a) => Map<String, dynamic>.from(a)).toList();
    }
  } catch (e) {
    debugPrint('Error fetching assignments: $e');
    return [];
  }
});

// 6. Assignments By Status Provider
final assignmentsByStatusProvider = FutureProvider.family<Map<String, List<dynamic>>, String>((ref, studentId) async {
  try {
    final assignments = await ref.watch(assignmentsProvider.future);
    
    final List<dynamic> pending = [];
    final List<dynamic> submitted = [];
    final List<dynamic> graded = [];

    for (var assignment in assignments) {
      final submissions = assignment['submissions'] as List<dynamic>? ?? [];
      final studentSubmission = submissions.firstWhere(
        (s) => s['studentId'] == studentId,
        orElse: () => null,
      );

      final typedAssignment = Map<String, dynamic>.from(assignment);

      if (studentSubmission == null) {
        pending.add(typedAssignment);
      } else {
        final typedSubmission = Map<String, dynamic>.from(studentSubmission);
        final combined = {
          ...typedAssignment,
          'submission': typedSubmission,
        };
        
        if (typedSubmission['status'] == 'submitted') {
          submitted.add(combined);
        } else if (typedSubmission['status'] == 'graded') {
          graded.add(combined);
        }
      }
    }

    return {
      'pending': pending,
      'submitted': submitted,
      'graded': graded,
    };
  } catch (e) {
    debugPrint('Error fetching assignments by status: $e');
    return {'pending': [], 'submitted': [], 'graded': []};
  }
});

// 7. Test Results Provider
final testResultsProvider = FutureProvider.family<List<dynamic>, String>((ref, studentId) async {
  try {
    final session = await _getSession(null, ref);
    List<dynamic> testResults;
    if (DevConfig.USE_FIRESTORE) {
      testResults = await ref.read(classroomRepositoryProvider).getTestResults(session['schoolId']!, session['classId']!);
    } else {
      testResults = await MockDataService.getTestResults();
    }
    
    final List<dynamic> results = [];

    for (var test in testResults) {
      final testMetadata = test['results'] as List<dynamic>? ?? [];
      final studentResult = testMetadata.firstWhere(
        (r) => r['studentId'] == studentId,
        orElse: () => null,
      );

      if (studentResult != null) {
        results.add({
          'testId': test['testId'] ?? test['id'],
          'title': test['title'],
          'subjectId': test['subjectId'],
          'subjectName': test['subjectName'],
          'type': test['type'],
          'totalMarks': test['totalMarks'],
          'classAverage': test['classAverage'],
          ...Map<String, dynamic>.from(studentResult),
        });
      }
    }
    return results;
  } catch (e) {
    debugPrint('Error fetching test results: $e');
    return [];
  }
});

// 8. Study Materials Provider
final studyMaterialsProvider = FutureProvider<Map<String, List<dynamic>>>((ref) async {
  try {
    final session = await _getSession(null, ref);
    List<dynamic> materials;
    if (DevConfig.USE_FIRESTORE) {
      materials = await ref.read(classroomRepositoryProvider).getStudyMaterials(session['schoolId']!, session['classId']!);
    } else {
      materials = await MockDataService.getStudyMaterials();
    }
    
    final Map<String, List<dynamic>> grouped = {};

    for (var material in materials) {
      final typedMaterial = Map<String, dynamic>.from(material);
      final subjectId = typedMaterial['subjectId'] as String;
      grouped.putIfAbsent(subjectId, () => []).add(typedMaterial);
    }
    return grouped;
  } catch (e) {
    debugPrint('Error fetching study materials: $e');
    return {};
  }
});

// 9. Syllabus Provider
final syllabusProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final session = await _getSession(null, ref);
    List<dynamic> syllabus;
    if (DevConfig.USE_FIRESTORE) {
      syllabus = await ref.read(classroomRepositoryProvider).getSyllabusTracker(session['schoolId']!, session['classId']!);
    } else {
      syllabus = await MockDataService.getSyllabusTracker();
    }
    return syllabus.map((s) => Map<String, dynamic>.from(s)).toList();
  } catch (e) {
    debugPrint('Error fetching syllabus: $e');
    return [];
  }
});

// 10. Assignment Detail Provider
final assignmentDetailProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, assignmentId) async {
  try {
    if (DevConfig.USE_FIRESTORE) {
      final session = await _getSession(null, ref);
      return await ref.read(classroomRepositoryProvider).getAssignmentById(session['schoolId']!, assignmentId);
    } else {
      final assignments = await MockDataService.getAssignments();
      final match = assignments.firstWhere(
        (a) => a['assignmentId'] == assignmentId,
        orElse: () => assignments.first,
      );
      return Map<String, dynamic>.from(match);
    }
  } catch (e) {
    debugPrint('Error fetching assignment detail: $e');
    return null;
  }
});

// lib/features/homework/data/homework_model.dart

class HomeworkModel {
  final String homeworkId;
  final String schoolId;
  final String classId;
  final String subjectId;
  final String subjectName;
  final String subjectColor;
  final String teacherName;
  final String title;
  final String description;
  final String dueDate;
  final String dueTime;
  final bool isUrgent;
  final List<Map<String, dynamic>> attachments;

  const HomeworkModel({
    required this.homeworkId,
    required this.schoolId,
    required this.classId,
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.teacherName,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.isUrgent,
    required this.attachments,
  });

  factory HomeworkModel.fromMap(Map<String, dynamic> map, String id) {
    return HomeworkModel(
      homeworkId: id,
      schoolId: (map['schoolId'] as String?) ?? '',
      classId: (map['classId'] as String?) ?? '',
      subjectId: (map['subjectId'] as String?) ?? '',
      subjectName: (map['subjectName'] as String?) ?? '',
      subjectColor: (map['subjectColor'] as String?) ?? '#888780',
      teacherName: (map['teacherName'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      dueDate: (map['dueDate'] as String?) ?? '',
      dueTime: (map['dueTime'] as String?) ?? '',
      isUrgent: (map['isUrgent'] as bool?) ?? false,
      attachments: (map['attachments'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'classId': classId,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'subjectColor': subjectColor,
      'teacherName': teacherName,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'isUrgent': isUrgent,
      'attachments': attachments,
    };
  }

  @override
  String toString() =>
      'HomeworkModel(id: $homeworkId, title: $title, subject: $subjectName)';
}

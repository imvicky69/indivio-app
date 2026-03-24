// lib/features/auth/domain/student_profile_model.dart

class StudentProfileModel {
  final String studentId;
  final String schoolId;
  final String userId; // Firebase Auth uid
  final String classId;
  final String rollNumber;
  final String admissionNumber;
  final String section;
  final String academicYear;
  final String board;

  // Personal
  final String fullName;
  final String firstName;
  final String? dob;
  final String gender;
  final String bloodGroup;
  final String category; // General/OBC/SC/ST
  final String photoUrl;
  final String fatherName;
  final String motherName;

  // Academic
  final String className;
  final String houseGroup;

  // Contact
  final String phone;
  final String? email;
  final Map<String, dynamic> address;

  // Fees
  final String feeCategory;
  final bool concession;

  const StudentProfileModel({
    required this.studentId,
    required this.schoolId,
    required this.userId,
    required this.classId,
    required this.rollNumber,
    required this.admissionNumber,
    required this.section,
    required this.academicYear,
    required this.board,
    required this.fullName,
    required this.firstName,
    this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.category,
    required this.photoUrl,
    required this.fatherName,
    required this.motherName,
    required this.className,
    required this.houseGroup,
    required this.phone,
    this.email,
    required this.address,
    required this.feeCategory,
    required this.concession,
  });

  factory StudentProfileModel.fromMap(Map<String, dynamic> map) {
    final personal = map['personal'] as Map<String, dynamic>? ?? {};
    final academic = map['academic'] as Map<String, dynamic>? ?? {};
    final contact = map['contact'] as Map<String, dynamic>? ?? {};
    final fees = map['fees'] as Map<String, dynamic>? ?? {};
    final queryKeys = map['_queryKeys'] as Map<String, dynamic>? ?? {};

    return StudentProfileModel(
      studentId: (map['studentId'] as String?) ?? '',
      schoolId: (map['schoolId'] as String?) ?? '',
      userId: (queryKeys['uid'] as String?) ?? (map['userId'] as String?) ?? '',
      classId: (academic['classId'] as String?) ?? (map['classId'] as String?) ?? '',
      rollNumber: (academic['rollNumber'] as String?) ?? (map['rollNumber'] as String?) ?? '',
      admissionNumber: (academic['admissionNumber'] as String?) ?? (map['admissionNumber'] as String?) ?? '',
      section: (academic['section'] as String?) ?? (map['section'] as String?) ?? '',
      academicYear: (academic['academicYear'] as String?) ?? (map['academicYear'] as String?) ?? '',
      board: (academic['board'] as String?) ?? (map['board'] as String?) ?? '',
      fullName: (personal['fullName'] as String?) ?? '',
      firstName: (personal['firstName'] as String?) ?? '',
      dob: personal['dob'] as String?,
      gender: (personal['gender'] as String?) ?? '',
      bloodGroup: (personal['bloodGroup'] as String?) ?? '',
      category: (personal['category'] as String?) ?? 'General',
      photoUrl: (personal['photoUrl'] as String?) ?? '',
      fatherName: (personal['fatherName'] as String?) ?? '',
      motherName: (personal['motherName'] as String?) ?? '',
      className: (academic['className'] as String?) ?? '',
      houseGroup: (academic['houseGroup'] as String?) ?? '',
      phone: (contact['phone'] as String?) ?? '',
      email: contact['email'] as String?,
      address: (contact['address'] as Map<String, dynamic>?) ?? {},
      feeCategory: (fees['category'] as String?) ?? '',
      concession: (fees['concession'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'schoolId': schoolId,
      'userId': userId,
      'personal': {
        'fullName': fullName,
        'firstName': firstName,
        'dob': dob,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'category': category,
        'photoUrl': photoUrl,
        'fatherName': fatherName,
        'motherName': motherName,
      },
      'academic': {
        'classId': classId,
        'className': className,
        'section': section,
        'rollNumber': rollNumber,
        'admissionNumber': admissionNumber,
        'academicYear': academicYear,
        'board': board,
        'houseGroup': houseGroup,
      },
      'contact': {
        'phone': phone,
        'email': email,
        'address': address,
      },
      'fees': {
        'category': feeCategory,
        'concession': concession,
      },
    };
  }

  String get displayName => fullName.isNotEmpty ? fullName : 'Student';

  String get classDisplay => '$className-$section';

  String get rollDisplay => 'Roll No. $rollNumber';

  @override
  String toString() =>
      'StudentProfileModel(studentId: $studentId, fullName: $fullName)';
}

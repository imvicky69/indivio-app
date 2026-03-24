import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/mock_data_service.dart';
import '../widgets/student_info_section.dart';
import '../widgets/student_info_tile.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Student Profile'),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: MockDataService.getStudentByUid('UID_STU001'),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Student data not available'));
          }

          final student = snapshot.data!;
          final personal = student['personal'] ?? {};

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.bgTertiary,
                      backgroundImage: personal['photoUrl'] != null && personal['photoUrl'].isNotEmpty
                          ? AssetImage(personal['photoUrl']) as ImageProvider
                          : null,
                      child: personal['photoUrl'] == null || personal['photoUrl'].isEmpty
                          ? Text(
                              personal['fullName'] != null ? personal['fullName'][0] : 'S',
                              style: AppTextStyles.h1.copyWith(color: AppColors.textOnPrimary),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(personal['fullName'] ?? '-', style: AppTextStyles.h2),
                    Text(
                      '${student['academic']?['className']} - ${student['academic']?['section']}',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Academic Details
              StudentInfoSection(
                title: 'Academic Details',
                icon: Icons.school_outlined,
                children: [
                  StudentInfoTile(
                    label: 'Admission No.',
                    value: _safe(student, ['academic', 'admissionNumber']),
                  ),
                  StudentInfoTile(
                    label: 'Roll Number',
                    value: _safe(student, ['academic', 'rollNumber']),
                  ),
                  StudentInfoTile(
                    label: 'Admission Date',
                    value: _safe(student, ['academic', 'admissionDate']),
                  ),
                  StudentInfoTile(
                    label: 'SR Number',
                    value: _safe(student, ['academic', 'srNumber']),
                  ),
                  StudentInfoTile(
                    label: 'Board',
                    value: _safe(student, ['academic', 'board']),
                  ),
                  StudentInfoTile(
                    label: 'Academic Year',
                    value: _safe(student, ['academic', 'academicYear']),
                  ),
                ],
              ),

              // Parent Details
              if (student['parents'] != null && (student['parents'] as List).isNotEmpty)
                ... (student['parents'] as List).map((parent) => StudentInfoSection(
                  title: '${parent['relation']} Information',
                  icon: Icons.family_restroom_outlined,
                  children: [
                    StudentInfoTile(label: 'Name', value: parent['name'] ?? '-'),
                    StudentInfoTile(label: 'Phone', value: parent['phone'] ?? '-'),
                    StudentInfoTile(label: 'Email', value: parent['email'] ?? '-'),
                    StudentInfoTile(label: 'Occupation', value: parent['occupation'] ?? '-'),
                    StudentInfoTile(label: 'Qualification', value: parent['qualification'] ?? '-'),
                  ],
                )),

              // Contact & Address
              StudentInfoSection(
                title: 'Contact & Address',
                icon: Icons.location_on_outlined,
                children: [
                  StudentInfoTile(
                    label: 'Emergency Contact',
                    value: '${_safe(student, ['contact', 'emergencyContact', 'name'])} (${_safe(student, ['contact', 'emergencyContact', 'relation'])})',
                  ),
                  StudentInfoTile(
                    label: 'Emergency Phone',
                    value: _safe(student, ['contact', 'emergencyContact', 'phone']),
                  ),
                  const Divider(height: 20),
                  StudentInfoTile(
                    label: 'Address',
                    value: _formatAddress(student),
                  ),
                ],
              ),

              // Health & Transport
              StudentInfoSection(
                title: 'Other Details',
                icon: Icons.info_outline,
                children: [
                  StudentInfoTile(
                    label: 'Blood Group',
                    value: _safe(student, ['personal', 'bloodGroup']),
                  ),
                  StudentInfoTile(
                    label: 'Height / Weight',
                    value: '${_safe(student, ['health', 'height_cm'])} cm / ${_safe(student, ['health', 'weight_kg'])} kg',
                  ),
                  StudentInfoTile(
                    label: 'Allergies',
                    value: (student['health']?['allergies'] as List?)?.join(', ') ?? 'None',
                  ),
                  StudentInfoTile(
                    label: 'Transport',
                    value: student['transport']?['usesTransport'] == true
                        ? 'Bus Route ${student['transport']?['busRouteNumber']}'
                        : 'Self Transport',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _safe(Map m, List<String> path, [String fallback = '-']) {
    try {
      dynamic cur = m;
      for (final p in path) {
        if (cur == null || cur[p] == null) return fallback;
        cur = cur[p];
      }
      return cur?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  String _formatAddress(Map student) {
    try {
      final addr = student['contact']?['address'];
      if (addr == null) return '-';
      final parts = [
        addr['line1'],
        addr['line2'],
        addr['city'],
        addr['pincode'],
        addr['state'],
      ];
      return parts.where((p) => p != null && p.toString().isNotEmpty).join(', ');
    } catch (_) {
      return '-';
    }
  }
}

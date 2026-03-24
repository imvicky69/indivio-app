import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/services/mock_data_service.dart';
import '../widgets/student_details_card.dart';

class StudentAllDetailsScreen extends StatelessWidget {
  const StudentAllDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('All Students'),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: MockDataService.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: LoadingIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('No students available'));
          }

          final students = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final s = students[index] as Map<String, dynamic>;
              return Column(
                children: [
                  StudentDetailsCard(student: s),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shaheen_namaz/admin/widgets/student_data_table.dart';

class StudentDataMobile extends StatelessWidget {
  const StudentDataMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const StudentDataTable(),
    );
  }
}

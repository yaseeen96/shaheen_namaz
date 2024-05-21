import 'package:flutter/material.dart';
import 'package:shaheen_namaz/admin/widgets/student_data_table.dart';

class StudentDataMobile extends StatefulWidget {
  const StudentDataMobile({super.key});

  @override
  State<StudentDataMobile> createState() => _StudentDataMobileState();
}

class _StudentDataMobileState extends State<StudentDataMobile> {
  int dataCount = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Text("$dataCount"),
          )
        ],
      ),
      body: StudentDataTable(
        onDataFetched: (value) {
          setState(() {
            dataCount = value;
          });
        },
      ),
    );
  }
}

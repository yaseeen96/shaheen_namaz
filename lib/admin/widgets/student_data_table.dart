import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shaheen_namaz/admin/models/student_data.dart';

class StudentDataTable extends StatefulWidget {
  const StudentDataTable({super.key});

  @override
  State<StudentDataTable> createState() => _StudentDataTableState();
}

class _StudentDataTableState extends State<StudentDataTable> {
  List<StudentData> _students = [];

  Future<void> _fetchStudents() async {
    var snapshot =
        await FirebaseFirestore.instance.collection('students').get();

    List<Future<StudentData>> studentFutures = snapshot.docs.map((doc) async {
      var data = doc.data() as Map<String, dynamic>;
      String masjidName = '';

      // Fetch masjid document reference
      if (data['masjid'] is DocumentReference) {
        DocumentSnapshot masjidSnapshot =
            await (data['masjid'] as DocumentReference).get();
        // Assuming the masjid document has a 'name' field
        var masjidData = masjidSnapshot.data() as Map<String, dynamic>?;
        // Use the casted map to access fields
        masjidName = masjidData?['name'] ?? 'Unknown';
      }

      return StudentData(
        uid: doc.id,
        name: data['name'] ?? '',
        streak: data['streak'] ?? 0,
        guardianNumber: data['guardianNumber'].toString(),
        masjid: masjidName,
      );
    }).toList();

    // Wait for all futures to complete
    var students = await Future.wait(studentFutures);

    setState(() {
      _students = students;
    });
  }

  @override
  void initState() {
    _fetchStudents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 40,
            columns: const [
              DataColumn(
                  label: Text(
                'Student Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )),
              DataColumn(
                  label: Text(
                    'Streak',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  numeric: true),
              DataColumn(
                  label: Text(
                    'Guardian Number',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  numeric: true),
              DataColumn(
                  label: Text(
                'Masjid',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
            rows: _students.map((StudentData student) {
              return DataRow(cells: [
                DataCell(Text(student.name)),
                DataCell(Text(student.streak.toString())),
                DataCell(Text(student.guardianNumber)),
                DataCell(Text(student.masjid)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

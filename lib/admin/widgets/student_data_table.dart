import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shaheen_namaz/admin/models/student_data.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class StudentDataTable extends StatefulWidget {
  const StudentDataTable(
      {super.key, required this.onDataFetched, this.isAdmin = false});
  final bool isAdmin;

  final ValueChanged<int> onDataFetched;
  @override
  State<StudentDataTable> createState() => _StudentDataTableState();
}

class _StudentDataTableState extends State<StudentDataTable> {
  bool isLoading = false;
  List<StudentData> _students = [];
  List<StudentData> _filteredStudents = [];
  Future<void> _fetchStudents() async {
    setState(() {
      isLoading = true;
    });
    var snapshot =
        await FirebaseFirestore.instance.collection('students').get();

    List<Future<StudentData>> studentFutures = snapshot.docs.map((doc) async {
      logger.i("doc data ${doc.data()}");

      final studentData = StudentData.getStudentDataFromFirestore(doc);
      logger.i(studentData);

      return studentData;
    }).toList();

    // Wait for all futures to complete
    var students = await Future.wait(studentFutures);
    // get current user id
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final user =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (widget.isAdmin) {
      setState(() {
        _students = students;
        _filteredStudents = _students;
        isLoading = false;
      });
      widget.onDataFetched(_students.length);
      logger.i("Students: $_students");
      return;
    } else {
// get user's masjid reference

      setState(() {
        _students = students.where((student) {
          logger.i("masjid name: ${student.name == "abdullah"}");
          return student.masjid == user['masjid_allocated'];
        }).toList();
        _filteredStudents = _students;
        widget.onDataFetched(_students.length);
        isLoading = false;
      });
      logger.i("Students: $_students");
    }
  }

  @override
  void initState() {
    _fetchStudents();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.95,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by name',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filteredStudents = _students
                          .where((student) =>
                              student.name.toLowerCase().contains(value))
                          .toList();
                    });
                  },
                ),
              ),
              DataTable(
                dataRowMinHeight: 30,
                dataRowMaxHeight: 100,
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
                    'Class',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  DataColumn(
                      label: Text(
                    'Age',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  DataColumn(
                    label: Text(
                      'Guardian name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                      'Student Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                      label: Text(
                    'Masjid',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  DataColumn(
                      label: Text(
                    'Cluster No:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  DataColumn(
                      label: Text(
                    'Last Prayed',
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
                ],
                rows: _filteredStudents.map((StudentData student) {
                  return DataRow(cells: [
                    DataCell(Text(student.name)),
                    DataCell(Text(student.studentClass)),
                    DataCell(Text(student.age)),
                    DataCell(Text(student.guardianName)),
                    DataCell(
                      Text(student.guardianNumber),
                    ),
                    DataCell(Text(student.address)),
                    DataCell(Text(student.masjid)),
                    DataCell(Text(student.clusterNumber.toString())),
                    DataCell(Text(student.streakLastModified)),
                    DataCell(Text(student.streak.toString())),
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shaheen_namaz/admin/models/attendance_data_model.dart';
import 'package:shaheen_namaz/common/widgets/loading_indicator.dart';
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
  List<AttendanceDataModel> _attendance = [];
  List<AttendanceDataModel> _filteredAttendance = [];

  Future<void> _fetchStudents() async {
    setState(() {
      isLoading = true;
    });

    // Fetch today's attendance
    List<AttendanceDataModel> todaysAttendance = await getTodayAttendance();

    // Get current user id
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final user =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (widget.isAdmin) {
      setState(() {
        _attendance = todaysAttendance;
        _filteredAttendance = _attendance;
        isLoading = false;
      });
      widget.onDataFetched(_attendance.length);
      return;
    } else {
      // Get user's masjid references and handle both cases
      var userMasjidDetails = user.data()?["masjid_details"];
      List<String> userMasjidIds;

      if (userMasjidDetails is List) {
        userMasjidIds = userMasjidDetails
            .map((masjid) => masjid["masjidId"] as String)
            .toList();
      } else if (userMasjidDetails is Map) {
        userMasjidIds = [(userMasjidDetails["masjidId"] as String)];
      } else {
        userMasjidIds = [];
      }

      setState(() {
        _attendance = todaysAttendance.where((singleAttendance) {
          return userId == singleAttendance.trackedByUserId;
        }).toList();
        _filteredAttendance = _attendance;
        widget.onDataFetched(_attendance.length);
        isLoading = false;
      });
      logger.i("Attendance: $_attendance");
    }
  }

  @override
  void initState() {
    _fetchStudents();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return CustomLoadingIndicator();
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
                      _filteredAttendance = _attendance
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
                    'Masjid Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  DataColumn(
                      label: Text(
                    'Masjid Id',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  DataColumn(
                    label: Text(
                      'Cluster Number',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                      label: Text(
                        'Attendance Time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      numeric: true),
                  DataColumn(
                    label: Text(
                      'Tracked By',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                      label: Text(
                    'User Id',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ],
                rows: _filteredAttendance
                    .map((AttendanceDataModel attendance) {
                      return DataRow(cells: [
                        DataCell(Text(attendance.name)),
                        DataCell(Text(attendance.masjidName)),
                        DataCell(Text(attendance.masjidId)),
                        DataCell(Text(attendance.clusterNumber.toString())),
                        DataCell(
                          Text(attendance.attendanceTime.toString()),
                        ),
                        DataCell(Text(attendance.trackedByName)),
                        DataCell(Text(attendance.trackedByUserId)),
                      ]);
                    })
                    .toList()
                    .cast<DataRow>(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

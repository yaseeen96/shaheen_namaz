import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/admin/widgets/masjid_dropdown.dart';
import 'package:shaheen_namaz/common/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

class AttendancePopup extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> data;

  const AttendancePopup({
    super.key,
    required this.studentId,
    required this.data,
  });

  @override
  _AttendancePopupState createState() => _AttendancePopupState();
}

class _AttendancePopupState extends State<AttendancePopup> {
  late Map<String, dynamic> selectedMasjid;
  late DateTime selectedDate;
  final TextEditingController _dateController = TextEditingController();
  bool increaseStreak = false;

  @override
  void initState() {
    super.initState();
    selectedMasjid = widget.data['masjid_details'];
    selectedDate = DateTime.now();
    _dateController.text =
        DateFormat('yyyy-MM-dd – kk:mm').format(selectedDate);
  }

  Future<List<Map<String, dynamic>>> getAttendanceDetails() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('Attendance')
        .doc(widget.studentId)
        .get();

    if (docSnapshot.exists) {
      List<dynamic> attendanceDetails = docSnapshot.get('attendance_details');
      attendanceDetails
          .sort((a, b) => b['attendance_time'].compareTo(a['attendance_time']));
      return List<Map<String, dynamic>>.from(attendanceDetails);
    } else {
      return [];
    }
  }

  void addAttendance() async {
    try {
      final newAttendance = {
        "id": DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        "attendance_time": Timestamp.fromDate(selectedDate),
        "masjid": FirebaseFirestore.instance
            .collection('Masjid')
            .doc(selectedMasjid['masjidId']),
        "masjid_details": selectedMasjid,
        "name": widget.data['name'],
        "tracked_by": {
          "name": FirebaseAuth.instance.currentUser?.displayName ?? "admin",
          "userId": FirebaseAuth.instance.currentUser?.uid ?? "uid12a"
        },
      };

      await FirebaseFirestore.instance
          .collection('Attendance')
          .doc(widget.studentId)
          .update({
        'attendance_details': FieldValue.arrayUnion([newAttendance])
      });

      if (increaseStreak) {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(widget.studentId)
            .update({
          'streak': FieldValue.increment(1),
          'streak_last_modified': Timestamp.now(),
        });
      }

      setState(() {});
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance added successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add attendance: $error')),
      );
    }
  }

  void deleteAttendance(Map<String, dynamic> attendance,
      {bool decreaseStreak = false}) async {
    final shouldDelete = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content:
            const Text('Do you really want to delete this attendance record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(0),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(1),
            child: const Text('Yes'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
            onPressed: () => Navigator.of(context).pop(2),
            child: const Text('Yes & Decrease Streak'),
          ),
        ],
      ),
    );

    if (shouldDelete == 1 || shouldDelete == 2) {
      try {
        await FirebaseFirestore.instance
            .collection('Attendance')
            .doc(widget.studentId)
            .update({
          'attendance_details': FieldValue.arrayRemove([attendance])
        });

        if (shouldDelete == 2) {
          DocumentSnapshot studentDoc = await FirebaseFirestore.instance
              .collection('students')
              .doc(widget.studentId)
              .get();

          int currentStreak = studentDoc.get('streak') ?? 0;
          if (currentStreak > 0) {
            await FirebaseFirestore.instance
                .collection('students')
                .doc(widget.studentId)
                .update({
              'streak': FieldValue.increment(-1),
              'streak_last_modified': Timestamp.now(),
            });
          }
        }

        setState(() {});
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance deleted successfully')),
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete attendance: $error')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateController.text =
              DateFormat('yyyy-MM-dd – kk:mm').format(selectedDate);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            AppBar(
              title: Text('Attendance Details for ${widget.data["name"]}'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getAttendanceDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomLoadingIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No attendance records found');
                  } else {
                    List<Map<String, dynamic>> attendanceDetails =
                        snapshot.data!;
                    return ListView.builder(
                      itemCount: attendanceDetails.length,
                      itemBuilder: (context, index) {
                        final data = attendanceDetails[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 10),
                          child: ListTile(
                            key: ValueKey(index),
                            leading: const Icon(Icons.verified_user),
                            title: Text(
                                "Attendance Time: ${data["attendance_time"].toDate().toString()}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Masjid: ${data["masjid_details"]["masjidName"] ?? 'N/A'}"),
                                Text(
                                    "Cluster Number: ${data["masjid_details"]["clusterNumber"]?.toString() ?? 'N/A'}"),
                                Text(
                                    "Tracked By: ${data["tracked_by"]["name"] ?? 'N/A'}"),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteAttendance(data),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MasjidDropdownWidget(
                    initialValue: selectedMasjid,
                    onSelected: (masjid) {
                      setState(() {
                        selectedMasjid = masjid;
                      });
                    },
                  ),
                  const Gap(10),
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Select Date and Time',
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Increase streak:'),
                      Switch(
                        value: increaseStreak,
                        onChanged: (value) {
                          setState(() {
                            increaseStreak = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const Gap(10),
                  ElevatedButton(
                    onPressed: addAttendance,
                    child: const Text('Add Attendance'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showAttendancePopup(
    BuildContext context, String studentId, Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (context) => AttendancePopup(studentId: studentId, data: data),
  );
}

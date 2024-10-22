import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/admin/widgets/masjid_dropdown.dart';
import 'package:shaheen_namaz/common/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final logger = Logger();
  bool _isLoading = false;
  String? _message;
  List<DateTime> missingDates = [];
  List<DateTime> certificateDates = [];

  @override
  void initState() {
    super.initState();
    selectedMasjid = widget.data['masjid_details'];
    selectedDate = DateTime.now();
    _dateController.text =
        DateFormat('yyyy-MM-dd – kk:mm').format(selectedDate);
    calculateMissingDates();
    fetchCertificateDates();
  }

  Stream<List<Map<String, dynamic>>> getAttendanceDetails() async* {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('Attendance')
        .doc(widget.studentId)
        .get();

    if (docSnapshot.exists) {
      List<dynamic> attendanceDetails = docSnapshot.get('attendance_details');

      // Create indexed list before sorting
      List<Map<String, dynamic>> indexedAttendanceDetails = attendanceDetails
          .asMap()
          .entries
          .map((entry) =>
              {'index': entry.key, ...entry.value as Map<String, dynamic>})
          .toList();

      // Sort the indexed list by attendance_time
      indexedAttendanceDetails
          .sort((a, b) => b['attendance_time'].compareTo(a['attendance_time']));

      yield indexedAttendanceDetails;
    } else {
      yield [];
    }
  }

  void addAttendance() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Log start of attendance addition
      logger.i("Adding attendance...");

      // Prepare the data for the cloud function
      final HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('add_attendance_update_streak');
      final result = await callable.call(<String, dynamic>{
        'studentId': widget.studentId,
        'attendance_datetime': selectedDate.toUtc().toIso8601String(),
        'userId': FirebaseAuth.instance.currentUser?.uid ?? "uid12a",
        'displayName':
            FirebaseAuth.instance.currentUser?.displayName ?? "admin",
        'masjidId': selectedMasjid['masjidId'],
        'masjidName': selectedMasjid['masjidName'],
        'clusterNumber': selectedMasjid['clusterNumber'],
        "studentName": widget.data["name"]
      });

      logger.i("Cloud function result: ${result.data}");

      if (result.data['error'] != null) {
        setState(() {
          _message = 'Failed to add attendance: ${result.data['error']}';
        });
      } else {
        setState(() {
          _message = 'Attendance added successfully';
        });
      }
    } catch (error) {
      logger.e("Error: $error");
      setState(() {
        _message = 'Failed to add attendance: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void logAttendanceDetails() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('Attendance')
        .doc(widget.studentId)
        .get();

    if (docSnapshot.exists) {
      List<dynamic> attendanceDetails = docSnapshot.get('attendance_details');
      logger.i("Current attendance details in Firestore: $attendanceDetails");
    } else {
      logger
          .i("No attendance details found for student ID ${widget.studentId}");
    }
  }

  // Function to calculate missing attendance dates from the oldest date to today
  void calculateMissingDates() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('Attendance')
        .doc(widget.studentId)
        .get();

    if (docSnapshot.exists) {
      List<dynamic> attendanceDetails = docSnapshot.get('attendance_details');

      if (attendanceDetails.isNotEmpty) {
        List<DateTime> recordedDates = attendanceDetails
            .map((e) => (e['attendance_time'] as Timestamp).toDate())
            .toList();

        // Sort dates
        recordedDates.sort();

        DateTime firstDate = recordedDates.first;
        DateTime lastDate = DateTime.now();

        Set<DateTime> allDatesSet = {};
        DateTime currentDate = firstDate;

        // Generate all dates between first and today
        while (!currentDate.isAfter(lastDate)) {
          allDatesSet.add(
              DateTime(currentDate.year, currentDate.month, currentDate.day));
          currentDate = currentDate.add(Duration(days: 1));
        }

        // Convert recordedDates to a set of unique DateTime (ignoring time)
        Set<DateTime> recordedDatesSet = recordedDates
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet();

        // Find missing dates
        setState(() {
          missingDates = allDatesSet.difference(recordedDatesSet).toList()
            ..sort();
        });
      }
    }
  }

  // Function to fetch certificate dates and add them to the list
  void fetchCertificateDates() async {
    QuerySnapshot certificateSnapshot = await FirebaseFirestore.instance
        .collection('certificates')
        .where('studentId', isEqualTo: widget.studentId)
        .get();

    List<DateTime> tempCertificateDates = [];
    for (var doc in certificateSnapshot.docs) {
      Timestamp time = doc['time'];
      tempCertificateDates.add(time.toDate());
    }

    setState(() {
      certificateDates = tempCertificateDates;
    });
  }

  void deleteAttendance(int indexToDelete,
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
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('Attendance')
            .doc(widget.studentId)
            .get();

        if (docSnapshot.exists) {
          List<dynamic> attendanceDetails =
              List.from(docSnapshot.get('attendance_details'));

          if (indexToDelete >= 0 && indexToDelete < attendanceDetails.length) {
            final attendanceToRemove = attendanceDetails[indexToDelete];
            logger.i("Attendance to remove: $attendanceToRemove");

            attendanceDetails.removeAt(indexToDelete);
            logger.i("Attendance after removed: $attendanceDetails");

            await FirebaseFirestore.instance
                .collection('Attendance')
                .doc(widget.studentId)
                .update({
              'attendance_details': attendanceDetails,
            });

            // Fetch the updated document to verify the deletion
            DocumentSnapshot updatedDocSnapshot = await FirebaseFirestore
                .instance
                .collection('Attendance')
                .doc(widget.studentId)
                .get();

            List<dynamic> updatedAttendanceDetails =
                List.from(updatedDocSnapshot.get('attendance_details'));
            logger.i(
                "Updated attendance details in Firestore: $updatedAttendanceDetails");

            // Verify if the record still exists after deletion
            bool stillExists =
                updatedAttendanceDetails.contains(attendanceToRemove);
            if (stillExists) {
              logger.e(
                  "The record still exists after deletion: $attendanceToRemove");
            } else {
              logger.i("The record was successfully deleted.");
            }

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
                });
              }
            }

            setState(() {
              _message = 'Attendance deleted successfully';
            });
          } else {
            setState(() {
              _message = 'Invalid index for deletion';
            });
          }
        } else {
          setState(() {
            _message = 'No attendance records found';
          });
        }
      } catch (error) {
        logger.e("error: $error");
        setState(() {
          _message = 'Failed to delete attendance: $error';
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
        height: MediaQuery.of(context).size.height * 0.9, // Use relative height
        child: SingleChildScrollView(
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
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _message!,
                    style: TextStyle(
                        color: _message!.contains('successfully')
                            ? Colors.green
                            : Colors.red),
                  ),
                ),
              // Missing Dates Section with Accordion
              if (missingDates.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ExpansionTile(
                    title: const Text(
                      'Missing Attendance Dates:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    children: [
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: missingDates.map((date) {
                          return Chip(
                            label: Text(
                              DateFormat('MMMM dd, yyyy').format(date),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            backgroundColor: Colors.red[50],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              // Attendance Records Section
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: getAttendanceDetails(),
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
                        shrinkWrap: true,
                        itemCount: attendanceDetails.length,
                        itemBuilder: (context, index) {
                          final data = attendanceDetails[index];
                          DateTime attendanceDate =
                              (data['attendance_time'] as Timestamp).toDate();
                          bool isCertificateDate = certificateDates.any(
                              (certDate) =>
                                  certDate.year == attendanceDate.year &&
                                  certDate.month == attendanceDate.month &&
                                  certDate.day == attendanceDate.day);

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            child: ListTile(
                              key: ValueKey(data['index']),
                              leading: const Icon(Icons.verified_user),
                              title: Text(
                                "Attendance Time: ${DateFormat('MMMM dd, yyyy – hh:mm a').format(attendanceDate)}",
                                style: TextStyle(
                                  color: isCertificateDate
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Masjid: ${data['masjid_details']['masjidName'] ?? 'N/A'}"),
                                  Text(
                                      "Cluster Number: ${data['masjid_details']['clusterNumber']?.toString() ?? 'N/A'}"),
                                  Text(
                                      "Tracked By: ${data['tracked_by']['name'] ?? 'N/A'}"),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    deleteAttendance(data['index']),
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await launchUrl(
                                Uri.parse(
                                  "https://get-student-attendance-report-ytvfas5sda-uc.a.run.app/?studentId=${widget.studentId}",
                                ),
                                webOnlyWindowName: "_blank");
                          },
                          label: const Text("download report"),
                          icon: const Icon(Icons.download),
                        ),
                        const Gap(20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : addAttendance,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Add Attendance'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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

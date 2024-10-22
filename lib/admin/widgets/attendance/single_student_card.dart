import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shaheen_namaz/admin/widgets/attendance/attendance_popup.dart';
import 'package:shaheen_namaz/admin/widgets/attendance/edit_student_dialog.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Import the cloud functions package

class SingleStudentCard extends StatefulWidget {
  const SingleStudentCard({
    super.key,
    required this.data,
    required this.studentId,
  });

  final Map<String, dynamic> data;
  final String studentId;

  @override
  State<SingleStudentCard> createState() => _SingleStudentCardState();
}

class _SingleStudentCardState extends State<SingleStudentCard> {
  bool _isLoading = false;

  void handleEditStudent() {
    showDialog(
      context: context,
      builder: (context) => EditStudentDialog(
        data: widget.data,
        studentId: widget.studentId,
      ),
    );
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure? This cannot be undone. '
            'Please confirm to delete the student.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                handleDeleteStudent();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> handleDeleteStudent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('delete_student');
      final result = await callable.call(<String, dynamic>{
        'face_id': widget.studentId,
      });

      if (result.data['error'] != null) {
        // Handle error
        logger.e("Error deleting student: ${result.data['error']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting student: ${result.data['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        logger.i("Student ${widget.data["name"]} has been deleted.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student ${widget.data["name"]} has been deleted.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      logger.e("Error deleting student: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        badges.Badge(
          badgeContent: Text(
              "Cluster ${widget.data["masjid_details"]["clusterNumber"].toString()}"),
          position: badges.BadgePosition.topStart(),
          badgeAnimation: const badges.BadgeAnimation.slide(
            animationDuration: Duration(seconds: 1),
            loopAnimation: false,
            curve: Curves.fastOutSlowIn,
            colorChangeAnimationCurve: Curves.easeInCubic,
          ),
          badgeStyle: badges.BadgeStyle(
            shape: badges.BadgeShape.square,
            badgeColor: Constants.primaryColor,
            padding: const EdgeInsets.all(5),
            borderRadius: BorderRadius.circular(10),
            elevation: 0,
          ),
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              width: MediaQuery.of(context).size.width * 0.6,
              constraints: const BoxConstraints(maxHeight: 1500),
              child: Card(
                surfaceTintColor: Constants.secondaryColor,
                color: Constants.secondaryColor,
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 50,
                    ),
                    Text(
                      widget.data["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.data["guardianNumber"].toString()),
                    Text(widget.data["masjid_details"]["masjidName"]),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: 'Check Attendance',
                          child: IconButton(
                            icon: const Icon(Icons.check_circle),
                            onPressed: () => showAttendancePopup(
                                context, widget.studentId, widget.data),
                          ),
                        ),
                        Tooltip(
                          message: 'Show More Details',
                          child: IconButton(
                            icon: const Icon(Icons.info),
                            onPressed: handleEditStudent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        // Streak at the top right
        Positioned(
            top: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(5),
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Constants.bgColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.data["streak"].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
        // Certificate Count at the bottom left
        Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(5),
              width: 100,
              height: 30,
              decoration: const BoxDecoration(
                color: Constants.bgColor,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                '${widget.data["certificate_count"]}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
        // Delete button at the bottom right
        Positioned(
            bottom: 5,
            right: 5,
            child: IconButton(
              onPressed: showDeleteConfirmationDialog,
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            )),
      ],
    );
  }
}

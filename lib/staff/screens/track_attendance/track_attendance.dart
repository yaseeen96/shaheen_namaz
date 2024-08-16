import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shaheen_namaz/common/widgets/loading_indicator.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';

class TrackAttendanceScreen extends StatefulWidget {
  const TrackAttendanceScreen({super.key});

  @override
  _TrackAttendanceScreenState createState() => _TrackAttendanceScreenState();
}

class _TrackAttendanceScreenState extends State<TrackAttendanceScreen> {
  late User currentUser;
  late Timestamp startOfDay;
  late Timestamp endOfDay;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() {
    currentUser = FirebaseAuth.instance.currentUser!;
    final now = DateTime.now();
    startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    endOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    logger.i('Current User ID: ${currentUser.uid}');
    logger.i('Start of Day: ${startOfDay.toDate()}');
    logger.i('End of Day: ${endOfDay.toDate()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tracked Attendances"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("AttendanceTrack")
            .where("userId", isEqualTo: currentUser.uid)
            .where("datetime", isGreaterThanOrEqualTo: startOfDay)
            // .where("datetime", isLessThanOrEqualTo: endOfDay) // Remove this line
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.e("Error fetching data: ${snapshot.error}");
            return Center(
              child: Text("An error occurred: ${snapshot.error}"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomLoadingIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Attendance tracked for today"),
            );
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['datetime'] as Timestamp;
            return timestamp.compareTo(startOfDay) >= 0 &&
                timestamp.compareTo(endOfDay) <= 0;
          }).toList();

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final studentName = data['studentName'] ?? 'No Name';
              final timestamp = data['datetime'] as Timestamp;
              final dateTime =
                  DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Constants.primaryColor,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "$dateTime\n${data["masjid_details"]["masjidName"]}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceDataModel {
  final DateTime? attendanceTime;
  final DocumentReference? masjid;
  final String masjidName;
  final String masjidId;
  final int clusterNumber;
  final String name;
  final String trackedByName;
  final String trackedByUserId;

  AttendanceDataModel({
    required this.attendanceTime,
    required this.masjid,
    required this.masjidName,
    required this.masjidId,
    required this.clusterNumber,
    required this.name,
    required this.trackedByName,
    required this.trackedByUserId,
  });

  // Converts a map to an AttendanceDataModel instance
  static AttendanceDataModel fromMap(Map<String, dynamic> data) {
    return AttendanceDataModel(
      attendanceTime: data['attendance_time'] != null
          ? (data['attendance_time'] as Timestamp).toDate()
          : null,
      masjid: data['masjid'],
      masjidName: data['masjid_details']?['masjidName'] ?? '',
      masjidId: data['masjid_details']?['masjidId'] ?? '',
      clusterNumber: (data['masjid_details']?['clusterNumber'] is String)
          ? int.parse(data['masjid_details']?['clusterNumber'])
          : data['masjid_details']?['clusterNumber'] ?? 0,
      name: data['name'] ?? '',
      trackedByName: data['tracked_by']?['name'] ?? '',
      trackedByUserId: data['tracked_by']?['userId'] ?? '',
    );
  }

  // Method to check if the attendance time is today
  bool isAttendanceToday() {
    if (attendanceTime == null) {
      return false;
    }
    DateTime now = DateTime.now();
    return attendanceTime!.year == now.year &&
        attendanceTime!.month == now.month &&
        attendanceTime!.day == now.day;
  }

  @override
  String toString() {
    return 'AttendanceDataModel(attendanceTime: $attendanceTime, masjid: $masjid, masjidName: $masjidName, masjidId: $masjidId, clusterNumber: $clusterNumber, name: $name, trackedByName: $trackedByName, trackedByUserId: $trackedByUserId)';
  }

  // Equality based on unique fields
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceDataModel &&
          runtimeType == other.runtimeType &&
          attendanceTime == other.attendanceTime &&
          masjidId == other.masjidId &&
          name == other.name &&
          trackedByUserId == other.trackedByUserId;

  @override
  int get hashCode =>
      attendanceTime.hashCode ^
      masjidId.hashCode ^
      name.hashCode ^
      trackedByUserId.hashCode;
}

// Processes a Firestore document to extract today's attendance details
Future<List<AttendanceDataModel>> getTodayAttendanceListFromFirestore(
    DocumentSnapshot doc) async {
  List<dynamic> attendanceDetails = doc['attendance_details'];
  List<AttendanceDataModel> attendanceList = attendanceDetails.map((detail) {
    return AttendanceDataModel.fromMap(detail);
  }).toList();

  return attendanceList
      .where((attendance) => attendance.isAttendanceToday())
      .toList();
}

// Fetches today's attendance for all documents in the Attendance collection
Future<List<AttendanceDataModel>> getTodayAttendance() async {
  DateTime now = DateTime.now();
  DateTime startOfDay = DateTime(now.year, now.month, now.day);
  DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Attendance')
      .get(); // Retrieve all documents

  List<Future<List<AttendanceDataModel>>> attendanceFutures =
      querySnapshot.docs.map((doc) {
    return getTodayAttendanceListFromFirestore(doc);
  }).toList();

  List<List<AttendanceDataModel>> allAttendanceLists =
      await Future.wait(attendanceFutures);

  // Flatten the list of lists and remove duplicates
  List<AttendanceDataModel> allTodayAttendance =
      allAttendanceLists.expand((list) => list).toList();

  // Remove duplicates
  allTodayAttendance = allTodayAttendance.toSet().toList();

  print('All today\'s attendance: $allTodayAttendance');
  return allTodayAttendance;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardNotifier extends StateNotifier<void> {
  DashboardNotifier() : super(null);

  int totalStudents = 0;
  int totalMasjids = 0;
  int totalVolunteers = 0;

  Future<int> getTodayAttendance() async {
    final attendanceSnapshot =
        await FirebaseFirestore.instance.collection('Attendance').get();
    final attendanceDocs = attendanceSnapshot.docs;

    // Get current date in local time zone
    DateTime now = DateTime.now();
    // Format current date to only consider the date part (ignoring time)
    String todayDateStr = DateFormat('yyyy-MM-dd').format(now);

    // Initialize a counter for today's attendance
    int todayAttendanceCount = 0;

    // Loop through each attendance document
    for (var doc in attendanceDocs) {
      // Check if attendance_details is not null or empty
      if (doc.data()['attendance_details'] != null &&
          doc.data()['attendance_details'].isNotEmpty) {
        for (var detail in doc.data()['attendance_details']) {
          // Convert the attendance_time to a DateTime object
          Timestamp attendanceTimestamp = detail['attendance_time'];
          DateTime attendanceTime = attendanceTimestamp.toDate();

          // Format attendance time to only consider the date part
          String attendanceDateStr =
              DateFormat('yyyy-MM-dd').format(attendanceTime);

          // Compare attendance date with today's date
          if (attendanceDateStr == todayDateStr) {
            todayAttendanceCount++;
          }
        }
      }
    }

    // Return the total count of today's attendance
    return todayAttendanceCount;
  }

  Future<int> getTotalStudents() async {
    final students =
        await FirebaseFirestore.instance.collection('students').get();

    totalStudents = students.docs.length;
    return totalStudents;
  }

  Future<List<QueryDocumentSnapshot>> getStudentDocs() async {
    final students =
        await FirebaseFirestore.instance.collection('students').get();
    final studentDocs = students.docs;
    return studentDocs;
  }

  Future<int> getTotalMasjids() async {
    final masjids = await FirebaseFirestore.instance.collection('Masjid').get();
    totalMasjids = masjids.docs.length;
    return totalMasjids;
  }

  Future<int> getTotalVolunteers() async {
    final volunteers =
        await FirebaseFirestore.instance.collection('Users').get();
    totalVolunteers = volunteers.docs.length;
    return totalVolunteers;
  }

  Future<int> getAbsentData() async {
    final studentDocs = await getStudentDocs();
    final totalStudents = studentDocs.length;
    final todayAttendance = await getTodayAttendance();
    final absentData = totalStudents - todayAttendance;
    return absentData;
  }

  int getClusterData(
      List<QueryDocumentSnapshot> studentDocs, dynamic clusterNumber) {
    final clusterData = studentDocs.where((student) {
      var masjidDetails = student["masjid_details"];

      if (masjidDetails is List) {
        for (var detail in masjidDetails) {
          if (detail['clusterNumber'].toString() == clusterNumber.toString()) {
            return true;
          }
        }
        return false;
      } else if (masjidDetails is Map) {
        return masjidDetails['clusterNumber'].toString() ==
            clusterNumber.toString();
      }
      return false;
    }).length;
    return clusterData;
  }
}

final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, void>((ref) {
  return DashboardNotifier();
});

final totalStudentsProvider = FutureProvider.autoDispose<int>((ref) async {
  final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
  return dashboardNotifier.getTotalStudents();
});

final totalMasjidsProvider = FutureProvider.autoDispose<int>((ref) async {
  final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
  return dashboardNotifier.getTotalMasjids();
});

final totalVolunteersProvider = FutureProvider.autoDispose<int>((ref) async {
  final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
  return dashboardNotifier.getTotalVolunteers();
});

final attendanceProvider = FutureProvider.autoDispose<int>((ref) async {
  final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
  return dashboardNotifier.getTodayAttendance();
});

final absentProvider = FutureProvider.autoDispose<int>((ref) async {
  final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
  return dashboardNotifier.getAbsentData();
});

final studentDocsProvider =
    FutureProvider.autoDispose<List<QueryDocumentSnapshot>>((ref) async {
  final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
  return dashboardNotifier.getStudentDocs();
});

final clusterDataProvider =
    FutureProvider.family.autoDispose<int, int>((ref, clusterNumber) async {
  final studentDocs = await ref.read(studentDocsProvider.future);
  final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);

  return dashboardNotifier.getClusterData(studentDocs, clusterNumber);
});

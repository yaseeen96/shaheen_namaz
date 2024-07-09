import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/providers/dashboard_provider.dart';
import 'package:shaheen_namaz/admin/widgets/dashboard/attendance_chart.dart';
import 'package:shaheen_namaz/admin/widgets/dashboard/cluster_card.dart';
import 'package:shaheen_namaz/admin/widgets/dashboard/today_attendance_chart.dart';
import 'package:shaheen_namaz/admin/widgets/dashboard/total_students_chart.dart';
import 'package:shaheen_namaz/common/widgets/loading_indicator.dart';

class ShaheenDashboard extends ConsumerStatefulWidget {
  const ShaheenDashboard({super.key});

  @override
  ShaheenDashboardState createState() => ShaheenDashboardState();
}

class ShaheenDashboardState extends ConsumerState<ShaheenDashboard> {
  int touchedIndex = -1; // Initialize with -1 to indicate no section is touched

  @override
  Widget build(BuildContext context) {
    final combinedDashboardAsyncValue = ref.watch(dashboardDataProvider);

    return combinedDashboardAsyncValue.when(
      data: (data) {
        return ListView(
          children: [
            ClusterCard(data: data),
            TodayAttendanceChart(data: data),
            AttendanceChart(data: data),
            TotalStudentsChart(data: data),
          ],
        );
      },
      loading: () => const CustomLoadingIndicator(),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}


// {
//   'totalStudents': 1000,
//   'totalMasjids': 50,
//   'totalVolunteers': 200,
//   'todayAttendance': 800,
//   'absentData': 200,
//   'clusterData': [
//     {
//       'clusterNumber': 0,
//       'totalStudentsByCluster': 100,
//       'todayAttendance': 80,
//       'totalStudents': 100
//     },
//     {
//       'clusterNumber': 1,
//       'totalStudentsByCluster': 90,
//       'todayAttendance': 70,
//       'totalStudents': 90
//     },
//     {
//       'clusterNumber': 2,
//       'totalStudentsByCluster': 110,
//       'todayAttendance': 90,
//       'totalStudents': 110
//     },
//     {
//       'clusterNumber': 3,
//       'totalStudentsByCluster': 95,
//       'todayAttendance': 75,
//       'totalStudents': 95
//     },
//     {
//       'clusterNumber': 4,
//       'totalStudentsByCluster': 105,
//       'todayAttendance': 85,
//       'totalStudents': 105
//     },
//     {
//       'clusterNumber': 5,
//       'totalStudentsByCluster': 85,
//       'todayAttendance': 65,
//       'totalStudents': 85
//     },
//     {
//       'clusterNumber': 6,
//       'totalStudentsByCluster': 115,
//       'todayAttendance': 95,
//       'totalStudents': 115
//     },
//     {
//       'clusterNumber': 7,
//       'totalStudentsByCluster': 90,
//       'todayAttendance': 70,
//       'totalStudents': 90
//     },
//     {
//       'clusterNumber': 8,
//       'totalStudentsByCluster': 120,
//       'todayAttendance': 100,
//       'totalStudents': 120
//     },
//     {
//       'clusterNumber': 9,
//       'totalStudentsByCluster': 80,
//       'todayAttendance': 60,
//       'totalStudents': 80
//     },
//     {
//       'clusterNumber': 10,
//       'totalStudentsByCluster': 105,
//       'todayAttendance': 85,
//       'totalStudents': 105
//     },
//     {
//       'clusterNumber': 11,
//       'totalStudentsByCluster': 95,
//       'todayAttendance': 75,
//       'totalStudents': 95
//     },
//     {
//       'clusterNumber': 12,
//       'totalStudentsByCluster': 85,
//       'todayAttendance': 65,
//       'totalStudents': 85
//     }
//   ]
// }
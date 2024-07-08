import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class DashboardNotifier extends StateNotifier<void> {
  DashboardNotifier() : super(null);

  Future<int> getTotalStudents() async {
    try {
      final functions = FirebaseFunctions.instance;
      final result = await functions.httpsCallable('get_total_students').call();
      if (result.data['error'] != null) {
        throw Exception(result.data['error']);
      }
      return result.data['totalStudents'];
    } catch (e) {
      throw Exception('Failed to get total students: $e');
    }
  }

  Future<int> getTotalMasjids() async {
    try {
      final functions = FirebaseFunctions.instance;
      final result = await functions.httpsCallable('get_total_masjids').call();
      logger.e("result: ${result.data}");
      if (result.data['error'] != null) {
        logger.e("error from masjid provider: ${result.data['error']}");
        throw Exception(result.data['error']);
      }
      return result.data['totalMasjids'];
    } catch (e) {
      throw Exception('Failed to get total masjids: $e');
    }
  }

  Future<int> getTotalVolunteers() async {
    try {
      final functions = FirebaseFunctions.instance;
      final result =
          await functions.httpsCallable('get_total_volunteers').call();
      if (result.data['error'] != null) {
        throw Exception(result.data['error']);
      }
      return result.data['totalVolunteers'];
    } catch (e) {
      throw Exception('Failed to get total volunteers: $e');
    }
  }

  Future<int> getTodayAttendance({int? clusterNumber}) async {
    try {
      final functions = FirebaseFunctions.instance;
      final result =
          await functions.httpsCallable('get_today_attendance').call({
        'clusterNumber': clusterNumber,
      });
      if (result.data['error'] != null) {
        throw Exception(result.data['error']);
      }
      return result.data['todayAttendance'];
    } catch (e) {
      logger.e("error in query: ${e}");
      throw Exception('Failed to get today\'s attendance: $e');
    }
  }

  Future<int> getAbsentData({int? clusterNumber}) async {
    try {
      final functions = FirebaseFunctions.instance;
      final result =
          await functions.httpsCallable('get_today_absent_data').call({
        'clusterNumber': clusterNumber,
      });
      if (result.data['error'] != null) {
        throw Exception(result.data['error']);
      }
      return result.data['todayAbsent'];
    } catch (e) {
      throw Exception('Failed to get today\'s absent data: $e');
    }
  }

  Future<int> getTotalStudentsByCluster(int clusterNumber) async {
    try {
      final functions = FirebaseFunctions.instance;
      final result =
          await functions.httpsCallable('get_total_students_by_cluster').call({
        'clusterNumber': clusterNumber,
      });
      if (result.data['error'] != null) {
        throw Exception(result.data['error']);
      }
      return result.data['totalStudentsInCluster'];
    } catch (e) {
      throw Exception('Failed to get total students by cluster: $e');
    }
  }

  Future<Map<String, int>> getTodayAttendanceByCluster(
      int clusterNumber) async {
    try {
      final functions = FirebaseFunctions.instance;
      final result = await functions
          .httpsCallable('get_today_attendance_by_cluster')
          .call({
        'clusterNumber': clusterNumber,
      });
      if (result.data['error'] != null) {
        throw Exception(result.data['error']);
      }
      return {
        'todayAttendance': result.data['todayAttendance'],
        'totalStudents': result.data['totalStudents']
      };
    } catch (e) {
      logger.e("error in query: ${e}");
      throw Exception('Failed to get today\'s attendance by cluster: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('get_dashboard_data');
      final result = await callable.call();

      if (result.data['error'] != null) {
        throw Exception(result.data['error']);
      }

      return result.data;
    } catch (e) {
      throw Exception('Failed to get dashboard data: $e');
    }
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

final clusterDataProvider =
    FutureProvider.family.autoDispose<int, int>((ref, clusterNumber) async {
  final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
  return dashboardNotifier.getTotalStudentsByCluster(clusterNumber);
});

final todayAttendanceByClusterProvider = FutureProvider.family
    .autoDispose<Map<String, int>, int>((ref, clusterNumber) async {
  final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
  return dashboardNotifier.getTodayAttendanceByCluster(clusterNumber);
});

final dashboardDataProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
  return dashboardNotifier.getDashboardData();
});




// for getting data from server

// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shaheen_namaz/utils/config/logger.dart';

// final dashboardNotifierProvider =
//     StateNotifierProvider<DashboardNotifier, void>((ref) {
//   return DashboardNotifier();
// });

// class DashboardNotifier extends StateNotifier<void> {
//   DashboardNotifier() : super(null);

//   Future<int> getTotalStudents() async {
//     final functions = FirebaseFunctions.instance;
//     final result = await functions.httpsCallable('get_total_students').call();
//     if (result.data['error'] != null) {
//       throw Exception(result.data['error']);
//     }
//     return result.data['totalStudents'];
//   }

//   Future<int> getTotalMasjids() async {
//     final functions = FirebaseFunctions.instance;
//     final result = await functions.httpsCallable('get_total_masjids').call();
//     if (result.data['error'] != null) {
//       logger.e("masjid error ${result.data['error']}");
//       throw Exception(result.data['error']);
//     }
//     return result.data['totalMasjids'];
//   }

//   Future<int> getTotalVolunteers() async {
//     final functions = FirebaseFunctions.instance;
//     final result = await functions.httpsCallable('get_total_volunteers').call();
//     if (result.data['error'] != null) {
//       throw Exception(result.data['error']);
//     }
//     return result.data['totalVolunteers'];
//   }

//   Future<int> getTodayAttendance({int? clusterNumber}) async {
//     final functions = FirebaseFunctions.instance;
//     final result = await functions
//         .httpsCallable('get_today_attendance')
//         .call({'clusterNumber': clusterNumber});
//     if (result.data['error'] != null) {
//       logger.e("Error from gettodayAttendance: ${result.data['error']}");
//       throw Exception(result.data['error']);
//     }
//     return result.data['todayAttendance'];
//   }

//   Future<int> getTodayAbsent({int? clusterNumber}) async {
//     final functions = FirebaseFunctions.instance;
//     final result = await functions
//         .httpsCallable('get_today_absent_data')
//         .call({'clusterNumber': clusterNumber});
//     if (result.data['error'] != null) {
//       throw Exception(result.data['error']);
//     }
//     return result.data['todayAbsent'];
//   }

//   Future<int> getTotalStudentsByCluster(int clusterNumber) async {
//     final functions = FirebaseFunctions.instance;
//     final result = await functions
//         .httpsCallable('get_total_students_by_cluster')
//         .call({'clusterNumber': clusterNumber});
//     if (result.data['error'] != null) {
//       logger.e("total student by cluster error ${result.data['error']}");
//       throw Exception(result.data['error']);
//     }
//     return result.data['totalStudentsInCluster'];
//   }

//   Future<int> getTodayAttendanceByCluster(int clusterNumber) async {
//     final functions = FirebaseFunctions.instance;
//     final result = await functions
//         .httpsCallable('get_today_attendance')
//         .call({'clusterNumber': clusterNumber});
//     if (result.data['error'] != null) {
//       logger.e("today attendance by cluster error ${result.data['error']}");
//       throw Exception(result.data['error']);
//     }
//     return result.data['todayAttendanceInCluster'];
//   }
// }

// final totalStudentsProvider = FutureProvider.autoDispose<int>((ref) async {
//   final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
//   return dashboardNotifier.getTotalStudents();
// });

// final totalMasjidsProvider = FutureProvider.autoDispose<int>((ref) async {
//   final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
//   return dashboardNotifier.getTotalMasjids();
// });

// final totalVolunteersProvider = FutureProvider.autoDispose<int>((ref) async {
//   final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
//   return dashboardNotifier.getTotalVolunteers();
// });

// final attendanceProvider = FutureProvider.autoDispose<int>((ref) async {
//   final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
//   return dashboardNotifier.getTodayAttendance();
// });

// final absentProvider = FutureProvider.autoDispose<int>((ref) async {
//   final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
//   return dashboardNotifier.getTodayAbsent();
// });

// final totalStudentsByClusterProvider =
//     FutureProvider.family.autoDispose<int, int>((ref, clusterNumber) async {
//   final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
//   return dashboardNotifier.getTotalStudentsByCluster(clusterNumber);
// });

// final todayAttendanceByClusterProvider =
//     FutureProvider.family.autoDispose<int, int>((ref, clusterNumber) async {
//   final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
//   return dashboardNotifier.getTodayAttendanceByCluster(clusterNumber);
// });

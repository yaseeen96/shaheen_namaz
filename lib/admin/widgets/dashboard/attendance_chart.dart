import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';

class AttendanceChart extends StatefulWidget {
  const AttendanceChart({
    super.key,
    required this.data,
  });
  final Map<String, dynamic> data;

  @override
  State<AttendanceChart> createState() => _AttendanceChartState();
}

class _AttendanceChartState extends State<AttendanceChart> {
  int touchedIndex = -1;

  List<PieChartSectionData> showingSections(
      List<Map<String, dynamic>> clusters, int todayAttendance) {
    return List.generate(clusters.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 180.0 : 170.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final cluster = clusters[i];
      final int clusterNumber = cluster['clusterNumber'];

      final int todayAttendanceCluster = cluster['todayAttendance'];

      // Calculate percentage of today's attendance in this cluster
      final double attendancePercentage =
          (todayAttendanceCluster / todayAttendance) * 100;

      return PieChartSectionData(
        color: getColorForCluster(clusterNumber),
        value: attendancePercentage,
        title: "$todayAttendanceCluster",
        //  '${attendancePercentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
        badgeWidget: Container(
          width: widgetSize,
          height: widgetSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$clusterNumber',
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }

  Color getColorForCluster(int clusterNumber) {
    switch (clusterNumber) {
      case 0:
        return const Color(0xFF8B4513); // Saddle Brown
      case 1:
        return const Color(0xFFA0522D); // Sienna
      case 2:
        return const Color(0xFFCD853F); // Peru
      case 3:
        return const Color(0xFFD2691E); // Chocolate
      case 4:
        return const Color(0xFFF4A460); // Sandy Brown
      case 5:
        return const Color(0xFFDEB887); // Burlywood
      case 6:
        return const Color(0xFFD2B48C); // Tan
      case 7:
        return const Color(0xFFBC8F8F); // Rosy Brown
      case 8:
        return const Color(0xFFA52A2A); // Brown
      case 9:
        return const Color(0xFFB22222); // Fire Brick
      case 10:
        return const Color(0xFFDC143C); // Crimson
      case 11:
        return const Color(0xFFFF4500); // Orange Red
      case 12:
        return const Color(0xFFFF6347); // Tomato
      default:
        return const Color(0xFF8B0000); // Dark Red
    }
  }

  Widget buildLegend(List<Map<String, dynamic>> clusters) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Constants.bgColor,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: clusters.map((cluster) {
          final int clusterNumber = cluster['clusterNumber'];
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                color: getColorForCluster(clusterNumber),
              ),
              const SizedBox(width: 8),
              Text(
                'Cluster $clusterNumber',
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clusters =
        List<Map<String, dynamic>>.from(widget.data['clusterData']);

    final int todayAttendance = widget.data['todayAttendance'];
    return Container(
      decoration: BoxDecoration(
          color: Constants.secondaryColor,
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 5, spreadRadius: 5)
          ],
          borderRadius: BorderRadius.circular(12)),
      width: double.infinity,
      height: 500,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      child: Stack(
        children: [
          const Text(
            "Today's Attendance By Cluster",
            style: TextStyle(fontSize: 24),
          ),
          AspectRatio(
            aspectRatio: 2.4,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: showingSections(clusters, todayAttendance),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: buildLegend(clusters),
          ),
        ],
      ),
    );
  }
}

// class _Badge extends StatelessWidget {
//   const _Badge({
//     required this.clusterNumber,
//     required this.size,
//     required this.borderColor,
//   });

//   final int clusterNumber;
//   final double size;
//   final Color borderColor;

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: PieChart.defaultDuration,
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: borderColor,
//           width: 2,
//         ),
//         boxShadow: <BoxShadow>[
//           BoxShadow(
//             color: Colors.black.withOpacity(.5),
//             offset: const Offset(3, 3),
//             blurRadius: 3,
//           ),
//         ],
//       ),
//       padding: EdgeInsets.all(size * .15),
//       child: Center(
//         child: Text(
//           clusterNumber.toString(),
//           style: const TextStyle(
//             fontSize: 16.0, // Adjust the font size as needed
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }

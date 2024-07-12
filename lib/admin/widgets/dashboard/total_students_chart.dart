import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';

class TotalStudentsChart extends StatefulWidget {
  const TotalStudentsChart({
    super.key,
    required this.data,
  });
  final Map<String, dynamic> data;

  @override
  State<TotalStudentsChart> createState() => _TotalStudentsChartState();
}

class _TotalStudentsChartState extends State<TotalStudentsChart> {
  int touchedIndex = -1;

  List<PieChartSectionData> showingSections(
      List<Map<String, dynamic>> clusters, int totalStudents) {
    return List.generate(clusters.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 180.0 : 170.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final cluster = clusters[i];
      final int clusterNumber = cluster['clusterNumber'];
      final int clusterTotalStudents = cluster['totalStudents'];

      // Calculate percentage of total students in this cluster
      final double studentPercentage =
          (clusterTotalStudents / totalStudents) * 100;

      return PieChartSectionData(
        color: getColorForCluster(clusterNumber),
        value: studentPercentage,
        title: "$clusterTotalStudents",
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
        return const Color(0xFF2E8B57); // Sea Green
      case 1:
        return const Color(0xFF3CB371); // Medium Sea Green
      case 2:
        return const Color(0xFF66CDAA); // Medium Aquamarine
      case 3:
        return const Color(0xFF8FBC8F); // Dark Sea Green
      case 4:
        return const Color(0xFF20B2AA); // Light Sea Green
      case 5:
        return const Color(0xFF00FA9A); // Medium Spring Green
      case 6:
        return const Color(0xFF98FB98); // Pale Green
      case 7:
        return const Color(0xFF4682B4); // Steel Blue
      case 8:
        return const Color(0xFF5F9EA0); // Cadet Blue
      case 9:
        return const Color(0xFF7FFFD4); // Aquamarine
      case 10:
        return const Color(0xFF40E0D0); // Turquoise
      case 11:
        return const Color(0xFF00CED1); // Dark Turquoise
      case 12:
        return const Color(0xFF1E90FF); // Dodger Blue
      default:
        return const Color(0xFF556B2F); // Dark Olive Green
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

    // Calculate total number of students across all clusters
    final int totalStudents = clusters.fold<int>(
      0,
      (sum, cluster) => sum + (cluster['totalStudents'] as int),
    );

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
            "Total Registered Students By Cluster",
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
                sections: showingSections(clusters, totalStudents),
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

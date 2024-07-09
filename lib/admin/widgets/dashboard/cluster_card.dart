import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ClusterCard extends StatefulWidget {
  const ClusterCard({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  State<ClusterCard> createState() => _ClusterCardState();
}

class _ClusterCardState extends State<ClusterCard> {
  // Function to get progress color based on percentage
  Color getProgressColor(double percentage) {
    if (percentage >= 0.9) {
      return Colors.blue;
    } else if (percentage >= 0.75) {
      return Colors.green;
    } else if (percentage >= 0.6) {
      return Colors.lightGreen;
    } else if (percentage >= 0.45) {
      return Colors.yellow;
    } else if (percentage >= 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clusters =
        List<Map<String, dynamic>>.from(widget.data['clusterData']);

    return Container(
      decoration: BoxDecoration(
        color: Constants.secondaryColor,
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 5, spreadRadius: 5)
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.85,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Text("Cluster Based Attendance for today",
              style: TextStyle(fontSize: 24)),
          const Gap(10),
          GridView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: clusters.length,
            itemBuilder: (context, index) {
              final cluster = clusters[index];
              final int clusterNumber = cluster['clusterNumber'];
              final int todayAttendance = cluster['todayAttendance'];
              final int totalStudents = cluster['totalStudents'];

              // Calculate the attendance percentage
              final double attendancePercentage =
                  totalStudents == 0 ? 0 : (todayAttendance / totalStudents);

              return Card(
                color: Constants.bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 80.0,
                        lineWidth: 10.0,
                        animation: true,
                        animationDuration: 1000,
                        percent: attendancePercentage,
                        center: Text(
                          "${(attendancePercentage * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        footer: Text(
                          "Cluster $clusterNumber",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: getProgressColor(attendancePercentage),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';

class TodayAttendanceChart extends StatefulWidget {
  const TodayAttendanceChart({
    super.key,
    required this.data,
  });
  final Map<String, dynamic> data;

  @override
  State<TodayAttendanceChart> createState() => _TodayAttendanceChartState();
}

class _TodayAttendanceChartState extends State<TodayAttendanceChart> {
  int touchedIndex = -1;

  List<PieChartSectionData> showingSections(int totalPresent, int totalAbsent) {
    final double presentPercentage =
        (totalPresent / (totalPresent + totalAbsent)) * 100;
    final double absentPercentage =
        (totalAbsent / (totalPresent + totalAbsent)) * 100;

    return [
      PieChartSectionData(
        color: Color(0xFF00FF00), // Green for present
        value: presentPercentage,
        title: '${presentPercentage.toStringAsFixed(1)}%',
        radius: touchedIndex == 0 ? 180.0 : 170.0,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 0 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        badgeWidget: Container(
          width: touchedIndex == 0 ? 55.0 : 40.0,
          height: touchedIndex == 0 ? 55.0 : 40.0,
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
              'P',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ),
        badgePositionPercentageOffset: .98,
      ),
      PieChartSectionData(
        color: Color(0xFFFF0000), // Red for absent
        value: absentPercentage,
        title: '${absentPercentage.toStringAsFixed(1)}%',
        radius: touchedIndex == 1 ? 180.0 : 170.0,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 1 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        badgeWidget: Container(
          width: touchedIndex == 1 ? 55.0 : 40.0,
          height: touchedIndex == 1 ? 55.0 : 40.0,
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
              'A',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ),
        badgePositionPercentageOffset: .98,
      ),
    ];
  }

  Widget buildLegend() {
    return Container(
      width: 200,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Constants.bgColor,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                color: Color(0xFF00FF00),
              ),
              SizedBox(width: 8),
              Text('Present'),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                color: Color(0xFFFF0000),
              ),
              SizedBox(width: 8),
              Text('Absent'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalPresent = widget.data['todayAttendance'];
    final int totalAbsent =
        widget.data['totalStudents'] - widget.data['todayAttendance'];

    return Container(
      decoration: BoxDecoration(
          color: Constants.secondaryColor,
          boxShadow: [
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
            "Today's Attendance",
            style: TextStyle(fontSize: 24),
          ),
          AspectRatio(
            aspectRatio: 3,
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
                sections: showingSections(totalPresent, totalAbsent),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: buildLegend(),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.size,
    required this.borderColor,
  });

  final String label;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.0, // Adjust the font size as needed
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

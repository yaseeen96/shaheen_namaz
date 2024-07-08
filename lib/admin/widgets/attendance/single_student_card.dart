import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/admin/widgets/attendance/edit_student_dialog.dart';

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
  void handleEditStudent() {
    showDialog(
      context: context,
      builder: (context) => EditStudentDialog(
        data: widget.data,
        studentId: widget.studentId,
      ),
    );
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
            badgeColor: Colors.blue,
            padding: const EdgeInsets.all(5),
            borderRadius: BorderRadius.circular(10),
            elevation: 0,
          ),
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              width: MediaQuery.of(context).size.width * 0.6,
              constraints: const BoxConstraints(maxHeight: 1500),
              child: Card(
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle, size: 50),
                    Text(
                      widget.data["name"],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.data["guardianNumber"].toString()),
                    Text(widget.data["masjid_details"]["masjidName"]),
                    const Spacer(),
                    ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.present_to_all),
                        label: Text("Check Attendance")),
                    const Gap(10),
                    ElevatedButton.icon(
                        onPressed: handleEditStudent,
                        icon: Icon(Icons.details),
                        label: Text("Show More Details")),
                    const Gap(10),
                  ],
                ),
              )),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(5),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.data["streak"].toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ))
      ],
    );
  }
}

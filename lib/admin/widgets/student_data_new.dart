import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentDataNew extends ConsumerStatefulWidget {
  const StudentDataNew({super.key});

  @override
  ConsumerState<StudentDataNew> createState() => _StudentDataNewState();
}

class _StudentDataNewState extends ConsumerState<StudentDataNew> {
  void getStudentsByMasjid() {
    FirebaseFirestore.instance
        .collection("students")
        .where("masjid", isEqualTo: "Masjid")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        print(element.data());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Reporting Under Progress"));
    // return Container(

    //   child: GridView(
    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: 3,
    //       crossAxisSpacing: 10,
    //       mainAxisSpacing: 10,
    //       childAspectRatio: 2,
    //     ),
    //     children: [
    //       ElevatedButton.icon(
    //           onPressed: () {},
    //           icon: Icon(Icons.mosque),
    //           label: Text("Get Students By Masjid")),
    //       ElevatedButton.icon(
    //           onPressed: () {},
    //           icon: Icon(Icons.numbers),
    //           label: Text("Get Students By Cluster Number")),
    //       ElevatedButton.icon(
    //           onPressed: () {},
    //           icon: Icon(Icons.all_inclusive),
    //           label: Text("Get All Students")),
    //     ],
    //   ),
    // );
  }
}

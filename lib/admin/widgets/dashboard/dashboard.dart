import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/widgets/dashboard/number_card.dart';

class ShaheenDashboard extends ConsumerStatefulWidget {
  const ShaheenDashboard({super.key});

  @override
  ConsumerState<ShaheenDashboard> createState() => _ShaheenDashboardState();
}

class _ShaheenDashboardState extends ConsumerState<ShaheenDashboard> {
  int totalStudents = 0;
  int totalMasjids = 0;
  int totalVolunteers = 0;
  int cluster1 = 0;
  int cluster2 = 0;
  int cluster3 = 0;
  int cluster4 = 0;
  int cluster5 = 0;
  int cluster6 = 0;
  int cluster7 = 0;
  int cluster8 = 0;
  int cluster9 = 0;
  int cluster10 = 0;
  int cluster11 = 0;
  int cluster12 = 0;

  Future<void> _fetchData() async {
    var students =
        await FirebaseFirestore.instance.collection('students').get();
    var masjids = await FirebaseFirestore.instance.collection('Masjid').get();
    var volunteers = await FirebaseFirestore.instance.collection('Users').get();

    setState(() {
      totalStudents = students.docs.length;
      totalMasjids = masjids.docs.length;
      totalVolunteers = volunteers.docs.length;
      cluster1 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 1;
      }).length;
      cluster2 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 2;
      }).length;
      cluster3 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 3;
      }).length;
      cluster4 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 4;
      }).length;
      cluster5 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 5;
      }).length;
      cluster6 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 6;
      }).length;
      cluster7 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 7;
      }).length;
      cluster8 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 8;
      }).length;
      cluster9 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 9;
      }).length;
      cluster10 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 10;
      }).length;
      cluster11 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 11;
      }).length;
      cluster12 = students.docs.where((student) {
        return student['masjid_details']['clusterNumber'] == 12;
      }).length;
    });
  }

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(30), children: [
      GridView(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        children: [
          NumberCard(title: "Total Students", number: totalStudents),
          NumberCard(title: "Total Masjids", number: totalMasjids),
          NumberCard(title: "Total volunteers", number: totalVolunteers),
        ],
      ),
      const Gap(20),
      Text(
        "Cluster Wise Data",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const Gap(30),
      GridView(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        children: [
          NumberCard(title: "Cluster 1", number: cluster1),
          NumberCard(title: "Cluster 2", number: cluster2),
          NumberCard(title: "Cluster 3", number: cluster3),
          NumberCard(title: "Cluster 4", number: cluster4),
          NumberCard(title: "Cluster 5", number: cluster5),
          NumberCard(title: "Cluster 6", number: cluster6),
          NumberCard(title: "Cluster 7", number: cluster7),
          NumberCard(title: "Cluster 8", number: cluster8),
          NumberCard(title: "Cluster 9", number: cluster9),
          NumberCard(title: "Cluster 10", number: cluster10),
          NumberCard(title: "Cluster 11", number: cluster11),
          NumberCard(title: "Cluster 12", number: cluster12),
          InkWell(
            onTap: () {
              context.go("/admin/volunteer");
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue[400],
              ),
              child: Center(
                child: Text(
                  "Volunteers Data",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              context.go("/admin/masjid");
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue[400],
              ),
              child: Center(
                child: Text(
                  "Masjid Data",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
  }
}

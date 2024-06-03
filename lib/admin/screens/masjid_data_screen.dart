import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MasjidDataScreen extends ConsumerStatefulWidget {
  const MasjidDataScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MasjidDataScreenState();
}

class _MasjidDataScreenState extends ConsumerState<MasjidDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<List<QueryDocumentSnapshot>> fetchMasjidsData() async {
    final masjids = await FirebaseFirestore.instance.collection('Masjid').get();
    return masjids.docs;
  }

  Future<List<QueryDocumentSnapshot>> fetchStudentsData() async {
    final students =
        await FirebaseFirestore.instance.collection('students').get();
    return students.docs;
  }

  int getRegistrationCount({
    required List<QueryDocumentSnapshot> students,
    required QueryDocumentSnapshot masjid,
  }) {
    final registrationCount = students.where((student) {
      try {
        return student["masjid_details"]["masjidId"] == masjid.id;
      } catch (e) {
        return false;
      }
    }).length;
    return registrationCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Text(
              "Number of Students Registered in Masjids",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Masjids',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            Expanded(
              child: FutureBuilder(
                future: Future.wait([
                  fetchMasjidsData(),
                  fetchStudentsData(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error fetching data"));
                  }
                  if (snapshot.data == null) {
                    return const Center(child: Text("No data found"));
                  }
                  final masjids = snapshot.data![0];
                  final students = snapshot.data![1];

                  // Calculate the registration count for each masjid
                  final List<Map<String, dynamic>> masjidsWithCount =
                      masjids.map((masjid) {
                    final count = getRegistrationCount(
                        students: students, masjid: masjid);
                    return {'masjid': masjid, 'count': count};
                  }).toList();

                  // Sort the masjids list based on registration count in descending order
                  masjidsWithCount
                      .sort((a, b) => b['count'].compareTo(a['count']));

                  // Filter the list based on the search query
                  final filteredMasjidsWithCount =
                      masjidsWithCount.where((masjidData) {
                    final masjid =
                        masjidData['masjid'] as QueryDocumentSnapshot;
                    final masjidName = masjid['name'].toString().toLowerCase();
                    return masjidName.contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredMasjidsWithCount.length,
                    itemBuilder: (ctx, index) {
                      final masjidData = filteredMasjidsWithCount[index];
                      final masjid =
                          masjidData['masjid'] as QueryDocumentSnapshot;
                      final count = masjidData['count'] as int;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          key: ValueKey(masjid.id),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: Colors.black12,
                          title: Text(
                            masjid["name"],
                            style: const TextStyle(color: Colors.black),
                          ),
                          trailing: Container(
                            alignment: Alignment.center,
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[900],
                            ),
                            child: Text(count.toString()),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

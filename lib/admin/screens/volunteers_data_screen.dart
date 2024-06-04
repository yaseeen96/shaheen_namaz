import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VolunteersDataScreen extends ConsumerStatefulWidget {
  const VolunteersDataScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VolunteersDataScreenState();
}

class _VolunteersDataScreenState extends ConsumerState<VolunteersDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<List<QueryDocumentSnapshot>> fetchVolunteersData() async {
    final volunteers =
        await FirebaseFirestore.instance.collection('Users').get();
    return volunteers.docs;
  }

  Future<List<QueryDocumentSnapshot>> fetchStudentsData() async {
    final students =
        await FirebaseFirestore.instance.collection('students').get();
    return students.docs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int getRegistrationCount({
    required List<QueryDocumentSnapshot> students,
    required QueryDocumentSnapshot volunteer,
  }) {
    final registrationCount = students.where((student) {
      try {
        return student["volunteer"]["volunteerId"] == volunteer.id;
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
              "Number of Students Registered by Volunteers",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Volunteers',
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
                  fetchVolunteersData(),
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
                  final volunteers = snapshot.data![0];
                  final students = snapshot.data![1];

                  // Calculate the registration count for each volunteer
                  final List<Map<String, dynamic>> volunteersWithCount =
                      volunteers.map((volunteer) {
                    final count = getRegistrationCount(
                        students: students, volunteer: volunteer);
                    return {'volunteer': volunteer, 'count': count};
                  }).toList();

                  // Sort the volunteers list based on registration count in descending order
                  volunteersWithCount
                      .sort((a, b) => b['count'].compareTo(a['count']));

                  // Filter the list based on the search query
                  final filteredVolunteersWithCount =
                      volunteersWithCount.where((volunteerData) {
                    final volunteer =
                        volunteerData['volunteer'] as QueryDocumentSnapshot;
                    final volunteerName =
                        volunteer['name'].toString().toLowerCase();
                    return volunteerName.contains(_searchQuery);
                  }).toList();

                  // Build the ListView using the filtered and sorted list
                  return ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredVolunteersWithCount.length,
                    itemBuilder: (ctx, index) {
                      final volunteerData = filteredVolunteersWithCount[index];
                      final volunteer =
                          volunteerData['volunteer'] as QueryDocumentSnapshot;
                      final count = volunteerData['count'] as int;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          key: ValueKey(volunteer.id),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: Colors.black12,
                          title: Text(
                            volunteer["name"],
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

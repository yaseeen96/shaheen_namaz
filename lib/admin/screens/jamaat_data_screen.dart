import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';

class JamaatDataScreen extends ConsumerStatefulWidget {
  const JamaatDataScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _JamaatDataScreenState();
}

class _JamaatDataScreenState extends ConsumerState<JamaatDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<List<QueryDocumentSnapshot>> fetchVolunteersData() async {
    final volunteers =
        await FirebaseFirestore.instance.collection('Users').get();
    return volunteers.docs;
  }

  Map<String, int> getUsersCountByJamaat(List<QueryDocumentSnapshot> users) {
    Map<String, int> jamaatCounts = {};
    for (var jamaat in Constants.jamaatList) {
      jamaatCounts[jamaat] = 0;
    }

    for (var user in users) {
      try {
        String jamaat = user['jamaat_name'];
        if (jamaatCounts.containsKey(jamaat)) {
          jamaatCounts[jamaat] = jamaatCounts[jamaat]! + 1;
        }
      } catch (e) {
        // Handle error if needed
      }
    }

    return jamaatCounts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Text(
              "Number of Users in Jamaat",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Jamaat',
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
                future: fetchVolunteersData(),
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
                  final users = snapshot.data!;

                  // Get user count by Jamaat
                  final jamaatCounts = getUsersCountByJamaat(users);

                  // Convert the jamaatCounts map to a list for filtering and sorting
                  final jamaatCountsList = jamaatCounts.entries
                      .where((entry) =>
                          entry.key.toLowerCase().contains(_searchQuery))
                      .toList();

                  // Build the ListView using the jamaatCounts list
                  return ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: jamaatCountsList.length,
                    itemBuilder: (ctx, index) {
                      final jamaatData = jamaatCountsList[index];
                      final jamaatName = jamaatData.key;
                      final count = jamaatData.value;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          key: ValueKey(jamaatName),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: Colors.black12,
                          title: Text(
                            jamaatName,
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

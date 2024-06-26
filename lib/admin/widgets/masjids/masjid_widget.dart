import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/widgets/masjids/masjid_popup.dart';

class MasjidWidget extends ConsumerStatefulWidget {
  const MasjidWidget({super.key});

  @override
  ConsumerState<MasjidWidget> createState() => _MasjidWidgetState();
}

class _MasjidWidgetState extends ConsumerState<MasjidWidget> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> masjidList = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredMasjidList = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  int activeCluster = 0;

  @override
  void initState() {
    super.initState();
    fetchMasjids();
  }

  void fetchMasjids() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('Masjid').get();
    setState(() {
      masjidList = snapshot.docs;
      filteredMasjidList = masjidList;
      isLoading = false;
    });
  }

  void addMasjid(String name, int clusterNumber) {
    if (name.trim().length < 2 || name.length < 3 || name.isEmpty) {
      return;
    } else {
      FirebaseFirestore.instance.collection("Masjid").add({
        "name": name, // Store the name as is
        "cluster_number":
            clusterNumber.toString(), // Store cluster_number as a string
      });
      context.pop();
      fetchMasjids();
    }
  }

  Future<void> showPopup() async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return MasjidPopup(
              onPressed: (masjidName, clusterNumber) {
                addMasjid(masjidName, clusterNumber);
              },
              actionText: "Add Masjid");
        });
  }

  void deleteMasjid(String docID) async {
    // delete masjid from Masjid Collection
    DocumentReference masjidReference =
        FirebaseFirestore.instance.collection("Masjid").doc(docID);
    await masjidReference.delete();
    fetchMasjids();
  }

  void onSearchChanged() {
    String query = searchController.text.trim().toLowerCase();
    setState(() {
      filteredMasjidList = masjidList.where((doc) {
        Map<String, dynamic> data = doc.data();
        String name = data['name'].toString().toLowerCase();
        String clusterNumber = data['cluster_number'].toString().toLowerCase();
        bool matchesSearchQuery =
            name.contains(query) || clusterNumber.contains(query);
        bool matchesCluster =
            activeCluster == 0 || clusterNumber == activeCluster.toString();
        return matchesSearchQuery && matchesCluster;
      }).toList();
    });
  }

  void onClusterChanged(int cluster) {
    setState(() {
      activeCluster = cluster;
      onSearchChanged();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Masjids",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showPopup();
              },
              icon: const Icon(Icons.add))
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Masjids...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    onSearchChanged();
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(12, (index) {
                    int cluster = index + 1;
                    bool isActive = cluster == activeCluster;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(cluster.toString()),
                        selected: isActive,
                        onSelected: (selected) {
                          onClusterChanged(selected ? cluster : 0);
                        },
                        selectedColor: Colors.black,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isActive ? Colors.white : Colors.black,
                        ),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredMasjidList.length,
              itemBuilder: (context, index) {
                final doc = filteredMasjidList[index];
                final masjidData = doc.data();
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => MasjidPopup(
                            masjidName: masjidData["name"],
                            clusterName:
                                masjidData["cluster_number"].toString(),
                            onPressed: (masjidName, clusterNumber) async {
                              FirebaseFirestore.instance
                                  .collection("Masjid")
                                  .doc(doc.id)
                                  .update({
                                "name": masjidName, // Update the name
                                "cluster_number": clusterNumber
                                    .toString(), // Update the cluster number
                              });
                              fetchMasjids();
                            },
                            actionText: "Update Masjid"),
                      );
                    },
                    leading: const Icon(
                      Icons.mosque,
                      color: Colors.white,
                    ),
                    title: Text(
                      masjidData["name"],
                    ),
                    subtitle: Text(
                      "Cluster no: ${masjidData["cluster_number"]}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        deleteMasjid(doc.id);
                      },
                    ),
                    tileColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

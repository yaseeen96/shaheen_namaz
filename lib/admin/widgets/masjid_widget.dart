import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/providers/get_masjids_provider.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class MasjidWidget extends ConsumerStatefulWidget {
  const MasjidWidget({super.key});

  @override
  ConsumerState<MasjidWidget> createState() => _MasjidWidgetState();
}

class _MasjidWidgetState extends ConsumerState<MasjidWidget> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredMasjidList = [];
  final masjidNameController = TextEditingController();
  final clusterNameController = TextEditingController();

  void addMasjid(String name, clusterNumber) {
    if (name.trim().length < 2 || name.length < 3 || name.isEmpty) {
      return;
    } else {
      FirebaseFirestore.instance.collection("Masjid").add({
        "name": name,
        "cluster_number": int.parse(clusterNumber),
      });
      masjidNameController.clear();
      clusterNameController.clear();
      context.pop();
    }
  }

  Future<void> showPopup() async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Please Enter the Name of Masjid'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: masjidNameController,
                    decoration: const InputDecoration(
                      label: Text("Name of Masjid"),
                    ),
                  ),
                  const Gap(10),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: clusterNameController,
                    decoration: const InputDecoration(
                      label: Text("Cluster Number"),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    addMasjid(
                        masjidNameController.text, clusterNameController.text);
                  },
                  child: const Text("Add"))
            ],
          );
        });
  }

  void deleteMasjid(String docID) async {
    // delete masjid from Masjid Collection
    DocumentReference masjidReference =
        FirebaseFirestore.instance.collection("Masjid").doc(docID);
    await masjidReference.delete();
  }

  @override
  void dispose() {
    masjidNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final masjids = ref.watch(getMasjidProvider);
    return masjids.when(
      data: (data) {
        final masjidList = data.docs;
        if (filteredMasjidList.isEmpty) {
          filteredMasjidList = masjidList;
        }
        if (filteredMasjidList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "All Masjids",
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.w900),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await showPopup();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Masjid"),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text("No Masjids Added. Please Add some"),
                  const Spacer(),
                ],
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Masjids",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                ),
                ElevatedButton.icon(
                  onPressed: showPopup,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Masjid"),
                ),
              ],
            ),
            const Gap(10),
            TextField(
              decoration: const InputDecoration(
                hintText: "Search Masjid",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  filteredMasjidList = masjidList
                      .where((masjid) =>
                          masjid
                              .data()["name"]
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          masjid
                              .data()["cluster_number"]
                              .toString()
                              .contains(value))
                      .toList();
                  logger.i(
                      "filtered masjid list: ${filteredMasjidList[0].data()["name"]}");
                });
              },
            ),
            const Gap(10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: filteredMasjidList.length,
              itemBuilder: (ctx, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: const Icon(
                      Icons.mosque,
                      color: Colors.white,
                    ),
                    title: Text(
                      filteredMasjidList[index].data()["name"],
                    ),
                    subtitle: Text(
                      "Cluster no: ${filteredMasjidList[index].data()["cluster_number"]}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        deleteMasjid(filteredMasjidList[index].id);
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
          ],
        );
      },
      error: (err, stk) {
        return Center(
          child: Text("An Error Occurred. $err"),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

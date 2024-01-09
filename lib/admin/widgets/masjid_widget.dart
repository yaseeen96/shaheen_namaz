import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/providers/get_masjids_provider.dart';

class MasjidWidget extends ConsumerStatefulWidget {
  const MasjidWidget({super.key});

  @override
  ConsumerState<MasjidWidget> createState() => _MasjidWidgetState();
}

class _MasjidWidgetState extends ConsumerState<MasjidWidget> {
  final masjidNameController = TextEditingController();

  void addMasjid(String name) {
    if (name.trim().length < 2 || name.length < 3 || name.isEmpty) {
      return;
    } else {
      FirebaseFirestore.instance.collection("Masjid").add({
        "name": name,
      });
      masjidNameController.clear();
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
                    onSubmitted: (value) {
                      addMasjid(value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    addMasjid(masjidNameController.text);
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
        if (masjidList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "All Masjids",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
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
            ListView.builder(
              shrinkWrap: true,
              itemCount: masjidList.length,
              itemBuilder: (ctx, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(
                      masjidList[index].data()["name"],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        deleteMasjid(masjidList[index].id);
                      },
                    ),
                    tileColor: Theme.of(context).primaryColor,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/staff/providers/providers.dart';

// updates the new value in the provider

class MasjidSearchWidget extends ConsumerStatefulWidget {
  const MasjidSearchWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MasjidSearchWidgetState();
}

class _MasjidSearchWidgetState extends ConsumerState<MasjidSearchWidget> {
  late QuerySnapshot<Map<String, dynamic>>? masjids;
  late List<QueryDocumentSnapshot<Map<String, dynamic>>>? filteredMasjids;

  void getMasjids() async {
    final masjidsDB =
        await FirebaseFirestore.instance.collection("Masjid").get();
    setState(() {
      masjids = masjidsDB;
      filteredMasjids = masjidsDB.docs;
    });
  }

  @override
  void initState() {
    getMasjids();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMasjid = ref.watch(selectedMasjidProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add a search field
        TextField(
          decoration: const InputDecoration(
            labelText: "Search by name",
          ),
          onChanged: (value) {
            setState(() {
              filteredMasjids = masjids!.docs.where((masjidRef) {
                final name = masjidRef.get("name");
                return name
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase());
              }).toList();
            });
          },
        ),
        if (masjids != null && masjids!.docs.isNotEmpty)
          ...filteredMasjids!.map((masjidRef) {
            return RadioListTile<String>(
                value: masjidRef.id,
                groupValue: selectedMasjid,
                onChanged: (newValue) {
                  // Update the selectedMasjid state
                  ref.read(selectedMasjidProvider.notifier).state = newValue;
                },
                title: Text(
                  masjidRef.get("name") as String,
                ),
                subtitle: Text(
                  masjidRef.get("cluster_number").toString(),
                ));
          })
      ],
    );
  }
}

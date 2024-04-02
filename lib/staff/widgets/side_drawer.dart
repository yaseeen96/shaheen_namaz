import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/staff/providers/providers.dart';

class SideDrawer extends ConsumerStatefulWidget {
  const SideDrawer({
    super.key,
  });

  @override
  ConsumerState<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends ConsumerState<SideDrawer> {
  @override
  Widget build(BuildContext context) {
    DocumentReference collection = FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid);

    return StreamBuilder(
      stream: collection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Something went Wrong"),
          );
        }
        var userDoc = snapshot.data!;
        var masjids = userDoc["masjid_allocated"] as List<dynamic>;
        // Automatically select the first masjid if none is selected yet
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (masjids.isNotEmpty) {
            final currentSelected = ref.read(selectedMasjidProvider);
            if (currentSelected == null) {
              ref.read(selectedMasjidProvider.notifier).state = masjids.first;
            }
          }
        });
        return Drawer(
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_circle_rounded,
                      size: 100,
                    ),
                    Text(
                      "Welcome ${FirebaseAuth.instance.currentUser!.displayName!}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Masjids",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              ...masjids.map((masjidRef) {
                return Consumer(
                  builder: (context, ref, _) {
                    var selectedMasjid = ref.watch(selectedMasjidProvider);
                    return RadioListTile<DocumentReference>(
                      value: masjidRef,
                      groupValue: selectedMasjid,
                      onChanged: (newValue) {
                        // Update the selectedMasjid state
                        ref.read(selectedMasjidProvider.notifier).state =
                            newValue;
                      },
                      title: MasjidNameText(masjidRef: masjidRef),
                    );
                  },
                );
              }).toList(),
              // RadioListTile<bool>(
              //   value: true,
              //   groupValue: false,
              //   onChanged: (currentVal) {},
              //   title: Text("Masjid 1"),
              // ),
              const Spacer(),
              ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"))
            ],
          ),
        );
      },
    );
  }
}

class MasjidNameText extends StatelessWidget {
  const MasjidNameText({
    super.key,
    required this.masjidRef,
  });
  final DocumentReference masjidRef;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: masjidRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        return Text(
          snapshot.data!["name"],
          style: const TextStyle(
            color: Colors.black,
          ),
        );
      },
    );
  }
}

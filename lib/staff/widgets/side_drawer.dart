import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              ...snapshot.data!["masjid_allocated"]
                  .map(
                    (e) => RadioListTile<bool>(
                      value: true,
                      groupValue: false,
                      onChanged: (currentVal) {},
                      title: MasjidNameText(
                        masjidRef: e,
                      ),
                    ),
                  )
                  .toList(),
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
                  icon: Icon(Icons.logout),
                  label: Text("Logout"))
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
          style: TextStyle(
            color: Colors.black,
          ),
        );
      },
    );
  }
}

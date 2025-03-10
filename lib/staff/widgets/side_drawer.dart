import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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

        return Drawer(
          child: Column(
            children: [
              Expanded(
                flex: 10,
                child: DrawerHeader(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.account_circle_rounded,
                        size: 100,
                      ),
                      Text(
                        "Welcome ${FirebaseAuth.instance.currentUser!.displayName ?? "User"}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(20),
                      Text(
                        "My Masjid: ${(snapshot.data?["imam_details"] != null) ? (snapshot.data?["imam_details"]["masjidName"]) : (snapshot.data?["masjid_details"] is List) ? (snapshot.data?["masjid_details"] as List)[0]["masjidName"] ?? "not sure what your masjid is" : snapshot.data?["masjid_details"]["masjidName"]}",
                      ),
                      const Gap(20),
                      ListTile(
                        title: const Text(
                          "Edit Student Data",
                          textAlign: TextAlign.center,
                        ),
                        onTap: () async {
                          final cameras = await availableCameras();

                          final firstCamera = cameras.first;
                          if (!context.mounted) return;
                          context.pushNamed(
                            "camera_preview",
                            pathParameters: {
                              "isAttendenceTracking": "false",
                              "isEdit": "true",
                              "isManual": "false"
                            },
                            extra: firstCamera,
                          );
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "School Attendance",
                          textAlign: TextAlign.center,
                        ),
                        onTap: () async {
                          if (!context.mounted) return;
                          context.pushNamed(
                            "school_attendance",
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout")),
              )
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
        );
      },
    );
  }
}

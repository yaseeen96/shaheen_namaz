import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/widgets/home_widget.dart';
import 'package:shaheen_namaz/admin/widgets/signin_widget.dart';
import 'package:shaheen_namaz/providers/auth_provider.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userAuthProvider);
    return Scaffold(
      body: user.when(data: (user) {
        // user not signed in
        if (user == null) {
          return const SignInWIdget();
        }
        // user is signed in
        else {
          final DocumentReference userRef =
              FirebaseFirestore.instance.collection("Users").doc(user.uid);
          return StreamBuilder(
              stream: userRef.snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                logger.e("User isAdmin: ${data["isAdmin"]}");
                if (data["isAdmin"] == true) {
                  return const AdminHomeWidget();
                } else {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.error(
                          message: "You Are not an Admin"),
                    );
                  });
                  FirebaseAuth.instance.signOut();
                  return const SignInWIdget();
                }
              });
        }
      }, error: (err, stk) {
        return Center(
          child: Text(err.toString()),
        );
      }, loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }
}

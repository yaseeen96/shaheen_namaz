import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/staff/widgets/side_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 120,
        title: Image.asset(
          "assets/logo.png",
          width: 150,
          height: 150,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Text("Logout")),
      ),
      drawer: const SideDrawer(),
    );
  }
}

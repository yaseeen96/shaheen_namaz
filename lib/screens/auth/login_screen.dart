import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onButtonPress() async {
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: "admin@shaheen.org", password: "123QweAsdZxc098");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }

    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        logger.e('User is currently signed out!');
      } else {
        logger.i('User is signed in!');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login "),
      ),
      body: Center(
        child: ElevatedButton(onPressed: onButtonPress, child: Text("Loogin")),
      ),
    );
  }
}

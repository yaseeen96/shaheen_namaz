import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import "package:firebase_ui_auth/firebase_ui_auth.dart" as UiAuth;

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        logger.e('User is currently signed out!');
      } else {
        logger.i('User is signed in!');
      }
    });

    return SignInScreen(
      subtitleBuilder: (context, action) {
        return const Text(
            "Your credentials will be provided by the admin of this application. If you don't have any credentials, please contact the Admin");
      },
      showAuthActionSwitch: false,
      auth: FirebaseAuth.instance,
      providers: [
        UiAuth.EmailAuthProvider(),
      ],
      headerBuilder: (context, constraints, shrinkOffset) {
        return Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            "assets/logo.png",
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class SignInWIdget extends StatelessWidget {
  const SignInWIdget({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      sideBuilder: (ctx, constraints) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.black),
          child: Image.asset("assets/logo.png"),
        );
      },
      styles: const {
        EmailFormStyle(
          signInButtonVariant: ButtonVariant.filled,
        ),
      },
      showAuthActionSwitch: false,
      showPasswordVisibilityToggle: true,
      providers: [
        EmailAuthProvider(),
      ],
    );
  }
}

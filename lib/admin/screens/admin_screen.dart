import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/widgets/home_widget.dart';
import 'package:shaheen_namaz/admin/widgets/signin_widget.dart';
import 'package:shaheen_namaz/providers/auth_provider.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

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
          return const AdminHomeWidget();
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/common/widgets/loading_indicator.dart';
import 'package:shaheen_namaz/providers/auth_provider.dart';
import 'package:shaheen_namaz/staff/screens/home_screen.dart';
import 'package:shaheen_namaz/staff/screens/login_screen.dart';

class ParentScreen extends ConsumerWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userAuthProvider);
    return user.when(
        data: (user) {
          if (user == null) {
            return const LoginScreen();
          } else {
            return const HomeScreen();
          }
        },
        error: (error, stackTrace) => Scaffold(
              body: Center(
                child: Text("An Error Occurred $error"),
              ),
            ),
        loading: () => const Scaffold(body: CustomLoadingIndicator()));
  }
}

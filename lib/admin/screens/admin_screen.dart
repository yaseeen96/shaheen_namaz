import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shaheen_namaz/admin/providers/admin_check_provider.dart';
import 'package:shaheen_namaz/admin/widgets/home_widget.dart';
import 'package:shaheen_namaz/admin/widgets/signin_widget.dart';
import 'package:shaheen_namaz/common/widgets/loading_indicator.dart';
import 'package:shaheen_namaz/providers/auth_provider.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.i('AdminScreen build method called');

    final userAsyncValue = ref.watch(userAuthProvider);

    return Scaffold(
      body: userAsyncValue.when(
        data: (user) => _buildContent(context, ref, user),
        error: (err, stk) => _buildError(err),
        loading: () => _buildLoading(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, User? user) {
    if (user == null) {
      return const SignInWIdget();
    } else {
      final adminCheckNotifier = ref.read(adminCheckProvider.notifier);
      final adminCheckState = ref.watch(adminCheckProvider);

      if (adminCheckState is AsyncLoading) {
        adminCheckNotifier.checkAdminStatus(user.uid);
      }

      return adminCheckState.when(
        data: (isAdmin) {
          if (isAdmin) {
            return const AdminHomeWidget();
          } else {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.error(message: "You Are not an Admin"),
              );
              FirebaseAuth.instance.signOut();
            });
            return const SignInWIdget();
          }
        },
        error: (err, stk) => _buildError(err),
        loading: () => CustomLoadingIndicator(),
      );
    }
  }

  Widget _buildError(Object err) {
    logger.e('Error: $err');
    return Center(child: Text(err.toString()));
  }

  Widget _buildLoading() {
    logger.i('Loading');
    return CustomLoadingIndicator();
  }
}

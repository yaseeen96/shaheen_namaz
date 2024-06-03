import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key});

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController _newPasswordController = TextEditingController();
  String? oldPassword;
  String? newPassword;
  String? confirmPassword;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void updatePasswordHandler() async {
    if (!validateAndSave()) {
      return;
    }
    final user = FirebaseAuth.instance.currentUser;

    try {
      setState(() {
        isLoading = true;
      });
      final credential = EmailAuthProvider.credential(
          email: user!.email!, password: oldPassword!);
      final updatedCredential = await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credential);
      if (updatedCredential.user != null) {
        logger.i("User re-authenticated.");
        FirebaseAuth.instance.currentUser!.updatePassword(newPassword!);
        if (mounted) {
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(message: "Password Updated"),
          );
          context.pop();
        }
      }
    } catch (e) {
      logger.e("Error while updating password: $e");
      if (mounted) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(message: "Invalid Password"),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Change Password"),
      content: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(50),
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Old Password",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter old password";
                    }
                    return null;
                  },
                  onSaved: (newValue) => oldPassword = newValue,
                ),
                const Gap(20),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: "New Password",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter new password";
                    }
                    return null;
                  },
                  onSaved: (newValue) => newPassword = newValue,
                ),
                const Gap(20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter confirm password";
                    }
                    if (value != _newPasswordController.text) {
                      return "Password does not match";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    confirmPassword = newValue;
                  },
                ),
                const Gap(20),
                ElevatedButton(
                  onPressed: isLoading ? null : updatePasswordHandler,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Change Password"),
                )
              ],
            ),
          )),
      actions: [
        ElevatedButton(
            onPressed: () {
              context.pop();
            },
            child: const Text("Cancel"))
      ],
    );
  }
}

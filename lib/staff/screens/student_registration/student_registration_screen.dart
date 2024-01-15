import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/staff/widgets/app_bar.dart';
import 'package:shaheen_namaz/staff/widgets/image_preview.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class StudentRegistrationScreen extends ConsumerStatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  ConsumerState<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState
    extends ConsumerState<StudentRegistrationScreen> {
  final formkey = GlobalKey<FormState>();
  String? name;
  String? guardianNumber;

  void onRegister() {
    final currentState = formkey.currentState;
    if (currentState == null) return;
    if (currentState.validate()) {
      currentState.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppbar(),
        body: Form(
          key: formkey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Gap(MediaQuery.of(context).size.height * 0.05),
                Align(
                  alignment: Alignment.center,
                  child: ImagePreview(
                    onTap: () {
                      logger.i("Preview pressed");
                    },
                  ),
                ),
                Gap(MediaQuery.of(context).size.height * 0.05),
                TextFormField(
                  decoration: formDecoration(label: "Name"),
                  validator: (value) {
                    if (value == null ||
                        value.length < 5 ||
                        value.trim().isEmpty) {
                      return "Please enter a valid name";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (currentVal) {
                    name = currentVal;
                  },
                ),
                const Gap(10),
                TextFormField(
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  decoration: formDecoration(label: "Guardian Number"),
                  validator: (value) {
                    if (value == null ||
                        value.length < 10 ||
                        value.trim().isEmpty) {
                      return "Please enter a valid number";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (currentVal) {
                    guardianNumber = currentVal;
                  },
                ),
                const Gap(30),
                ElevatedButton(
                  style: buttonStyle(),
                  onPressed: onRegister,
                  child: const Text("Register"),
                ),
              ],
            ),
          ),
        ));
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  InputDecoration formDecoration({required String label}) {
    return InputDecoration(
      label: Text(label),
      border: const OutlineInputBorder(),
    );
  }
}

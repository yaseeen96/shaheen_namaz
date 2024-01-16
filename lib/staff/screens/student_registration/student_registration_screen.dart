import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/staff/widgets/app_bar.dart';
import 'package:shaheen_namaz/staff/widgets/image_preview.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class StudentRegistrationScreen extends ConsumerStatefulWidget {
  const StudentRegistrationScreen({super.key, this.image});
  final XFile? image;

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
    if (currentState.validate() && widget.image != null) {
      currentState.save();
      // todo - get face id via aws sdk

      // todo - create a doc of faceId with collection "Students" in firestore
      //
      // fields - name and guardian number
    }
  }

  void onAddImage() async {
    final cameras = await availableCameras();

    final firstCamera = cameras.first;
    if (!context.mounted) return;
    context.push("/camera_preview", extra: firstCamera);
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
                    onTap: onAddImage,
                    image: widget.image,
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

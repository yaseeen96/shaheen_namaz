import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/staff/providers/providers.dart';
import 'package:shaheen_namaz/staff/widgets/app_bar.dart';
import 'package:shaheen_namaz/staff/widgets/image_preview.dart';
import 'package:shaheen_namaz/staff/widgets/side_drawer.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class StudentRegistrationScreen extends ConsumerStatefulWidget {
  const StudentRegistrationScreen(
      {super.key, this.image, this.name, this.guardianNumber});
  final XFile? image;
  final String? name;
  final String? guardianNumber;

  @override
  ConsumerState<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState
    extends ConsumerState<StudentRegistrationScreen> {
  final formkey = GlobalKey<FormState>();
  String? name;
  String? guardianNumber;
  bool isLoading = false;

  void onRegister() async {
    setState(() {
      isLoading = true;
    });
    try {
      final currentState = formkey.currentState;
      if (currentState == null) return;
      if (currentState.validate()) {
        currentState.save();

        if (widget.image == null) {
          if (!context.mounted) return;
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
                message: "Please select an image before registering."),
          );
          return;
        }

        final bytes = await widget.image!.readAsBytes();
        final base64Image = base64Encode(bytes);
        // Read the selected masjid from the provider
        final DocumentReference? selectedMasjidRef =
            ref.read(selectedMasjidProvider);
        if (selectedMasjidRef == null) {
          // Handle the case where no masjid is selected, if necessary
          if (!context.mounted) return;
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
                message: "Please select a masjid before registering."),
          );
          return;
        }
        final response = await FirebaseFunctions.instance
            .httpsCallable('register_student')
            .call({
          "image_data": base64Image,
          "name": name,
          "guardianNumber": guardianNumber,
          "masjidId": selectedMasjidRef.id,
        });

        final jsonResponse = response.data;
        if (jsonResponse["faceId"] != null) {
          logger.i("Success");
          if (!context.mounted) return;
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
                message: "Yayyy!! Successfully Registered"),
          );
          context.pop();
        } else {
          if (!context.mounted) return;
          showTopSnackBar(
              Overlay.of(context),
              CustomSnackBar.error(
                  message:
                      "An Error Occurred: ${jsonResponse["error"] ?? ''}"));
        }

        logger.i("Response: ${jsonResponse}");
      }
    } catch (err) {
      if (!context.mounted) return;
      showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
              message: "Server Error. Please Come Back Later."));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onAddImage() async {
    final cameras = await availableCameras();

    final firstCamera = cameras.first;
    if (!context.mounted) return;
    context.pushNamed("camera_preview", extra: firstCamera, pathParameters: {
      "isAttendanceTracking": "false",
      "name": name ?? "a",
      "guardianNumber": guardianNumber ?? "a",
    });
  }

  @override
  void initState() {
    name = widget.name;
    guardianNumber = widget.guardianNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference collection = FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    return Scaffold(
        appBar: const CustomAppbar(),
        body: StreamBuilder(
            stream: collection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text("Something went Wrong"),
                );
              }
              var userDoc = snapshot.data!;
              var masjids = userDoc["masjid_allocated"] as List<dynamic>;
              return Form(
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
                              value.length < 2 ||
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
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Masjids",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      ...masjids.map((masjidRef) {
                        return Consumer(
                          builder: (context, ref, _) {
                            var selectedMasjid =
                                ref.watch(selectedMasjidProvider);
                            return RadioListTile<DocumentReference>(
                              value: masjidRef,
                              groupValue: selectedMasjid,
                              onChanged: (newValue) {
                                // Update the selectedMasjid state
                                ref
                                    .read(selectedMasjidProvider.notifier)
                                    .state = newValue;
                              },
                              title: MasjidNameText(masjidRef: masjidRef),
                            );
                          },
                        );
                      }).toList(),
                      const Gap(30),
                      ElevatedButton(
                        style: buttonStyle(),
                        onPressed: isLoading ? null : onRegister,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text("Register"),
                      ),
                    ],
                  ),
                ),
              );
            }));
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

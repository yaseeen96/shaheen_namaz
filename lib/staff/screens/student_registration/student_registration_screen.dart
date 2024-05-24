import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
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
  String? guardianName;
  String? studentClass;
  String? studentAddress;
  String? dob;
  bool isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController guardianNumberController =
      TextEditingController();
  final TextEditingController guardianNameController = TextEditingController();
  final TextEditingController studentClassController = TextEditingController();
  final TextEditingController studentAddressController =
      TextEditingController();

  void onRegister() async {
    final currentState = formkey.currentState;
    logger.i(currentState == null);
    if (currentState == null) return;
    if (currentState.validate()) {
      logger.i("Form is valid");
      currentState.save();
      try {
        setState(() {
          isLoading = true;
        });
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
          "masjidId": selectedMasjidRef.id, //add id if not working
          "guardianName": guardianName,
          "dob": dob,
          "class": studentClass,
          "address": studentAddress,
        });

        final jsonResponse = response.data;
        if (jsonResponse["faceId"] != null) {
          logger.i("Success");
          if (!mounted) return;
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
                message: "Yayyy!! Successfully Registered"),
          );
          ref.read(studentDetailsProvider.notifier).state = {};
          context.go("/user");
        } else {
          if (!context.mounted) return;
          showTopSnackBar(
              Overlay.of(context),
              CustomSnackBar.error(
                  message:
                      "An Error Occurred: ${jsonResponse["error"] ?? ''}"));
        }

        logger.i("Response: $jsonResponse");
      } catch (err) {
        logger.e("Error: $err");
        if (!mounted) return;
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
  }

  @override
  void dispose() {
    nameController.dispose();
    guardianNumberController.dispose();
    guardianNameController.dispose();
    studentClassController.dispose();
    studentAddressController.dispose();
    super.dispose();
  }

  void onAddImage() async {
    ref.read(studentDetailsProvider.notifier).state = {
      "name": nameController.text,
      "guardianNumber": guardianNumberController.text,
      "guardianName": guardianNameController.text,
      "dob": dob,
      "studentClass": studentClassController.text,
      "studentAddress": studentAddressController.text,
    };
    final cameras = await availableCameras();

    final firstCamera = cameras.first;
    if (!mounted) return;

    Logger().e("name: ${nameController.text == ""}");

    context.pushNamed(
      "camera_preview",
      extra: firstCamera,
      pathParameters: {"isAttendenceTracking": "false"},
    );
  }

  @override
  void initState() {
    final studentDetails = ref.read(studentDetailsProvider);
    nameController.text = studentDetails["name"] as String? ?? "";
    guardianNumberController.text =
        studentDetails["guardianNumber"] as String? ?? "";
    guardianNameController.text =
        studentDetails["guardianName"] as String? ?? "";
    dob = studentDetails["dob"] as String? ?? "";
    studentClassController.text =
        studentDetails["studentClass"] as String? ?? "";
    studentAddressController.text =
        studentDetails["studentAddress"] as String? ?? "";
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
                logger.e("Error: ${snapshot.error}");
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
                        controller: nameController,
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
                      // add dropdown list for studentClass. keep options 1-10
                      TextFormField(
                        controller: studentClassController,
                        decoration: formDecoration(label: "Class"),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a valid class";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (currentVal) {
                          studentClass = currentVal;
                        },
                      ),

                      const Gap(10),

                      TextFormField(
                        initialValue: dob,
                        decoration: formDecoration(label: "Date of Birth"),
                        readOnly: true,
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              dob = selectedDate.toString().split(" ")[0];
                            });
                          }
                        },
                        validator: (value) {
                          if (dob == null) {
                            return "Please select a valid date";
                          } else {
// check if age is between 10 and 20, if more than 20, return error
                            // if less than 10, return error
                            // value is of type string and is in the format yyyy-mm-dd
                            // convert value to datetime first
                            var dobDateTime = DateTime.parse(dob!);
                            var age = DateTime.now().year - dobDateTime.year;
                            if (age < 10 || age > 20) {
                              return "Age must be between 10 and 20";
                            }

                            return null;
                          }
                        },
                        onSaved: (value) {
                          logger.i("saved value: $value");
                          dob = value;
                        },
                      ),
                      const Gap(10),
                      // add field for student address
                      TextFormField(
                        maxLines: 3,
                        controller: studentAddressController,
                        decoration: formDecoration(label: "Address"),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a valid address";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (currentVal) {
                          studentAddress = currentVal;
                        },
                      ),
                      const Gap(10),
                      TextFormField(
                        controller: guardianNameController,
                        decoration: formDecoration(label: "Guardian Name"),
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
                          guardianName = currentVal;
                        },
                      ),
                      const Gap(10),
                      TextFormField(
                        controller: guardianNumberController,
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
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
      alignLabelWithHint: true,
      label: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}

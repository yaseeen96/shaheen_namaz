import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/providers/imam_provider.dart';
import 'package:shaheen_namaz/staff/providers/providers.dart';
import 'package:shaheen_namaz/staff/screens/student_registration/masjids_widget.dart';
import 'package:shaheen_namaz/utils/conversions/conversions.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:shaheen_namaz/staff/widgets/app_bar.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class EditStudentScreen extends ConsumerStatefulWidget {
  const EditStudentScreen({
    required this.faceId,
    super.key,
    this.image,
    this.name,
    this.guardianNumber,
    this.className,
    this.address,
    this.dob,
    this.guardianName,
  });
  final String faceId;
  final XFile? image;
  final String? name;
  final String? guardianNumber;
  final String? className;
  final String? address;
  final String? dob;
  final String? guardianName;

  @override
  ConsumerState<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends ConsumerState<EditStudentScreen> {
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

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name ?? "";
    guardianNumberController.text = widget.guardianNumber ?? "";
    guardianNameController.text = widget.guardianName ?? "";
    dob = widget.dob ?? "";
    studentClassController.text = widget.className ?? "";
    studentAddressController.text = widget.address ?? "";
  }

  void onUpdate() async {
    final masjidId = ref.read(selectedMasjidProvider);
    final imamDetails = ref.watch(imamProvider);

    final masjid = await FirebaseFirestore.instance
        .collection("Masjid")
        .doc(masjidId)
        .get();
    final masjidData = masjid.data();
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
        await FirebaseFirestore.instance
            .collection("students")
            .doc(widget.faceId)
            .update({
          "name": name,
          "guardianNumber": guardianNumber,
          "guardianName": guardianName,
          "className": studentClass,
          "address": studentAddress,
          "dob": Conversions.convertDateStringToTimestamp(dob ?? "2001-05-28"),
          "masjid_details": {
            "masjidId": masjidId,
            "masjidName": masjidData?["name"],
            "clusterNumber": masjidData?["cluster_number"],
          },
          "imam_details": imamDetails == {} ? null : imamDetails
        });
        if (!mounted) return;
        showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Student updated successfully",
            ));
        context.pop();
        context.pop();
      } catch (e) {
        logger.e("Error: $e");
        if (!mounted) return;
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "An error occurred. Please try again later",
          ),
        );
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

            return Form(
              key: formkey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
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
                          var dobDateTime = DateTime.parse(dob!);
                          var age = DateTime.now().year - dobDateTime.year;
                          if (age < 10 || age > 25) {
                            return "Age must be between 10 and 25";
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
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                    const MasjidSearchWidget(),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: onUpdate,
        child: isLoading
            ? const CircularProgressIndicator()
            : const Icon(Icons.keyboard_arrow_right_rounded),
      ),
    );
  }
}

InputDecoration formDecoration({required String label}) {
  return InputDecoration(
    alignLabelWithHint: true,
    label: Text(
      label,
      style: const TextStyle(fontSize: 12),
    ),
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
  );
}

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
import 'package:shaheen_namaz/staff/screens/student_registration/masjids_widget.dart';
import 'package:shaheen_namaz/staff/widgets/app_bar.dart';
import 'package:shaheen_namaz/staff/widgets/image_preview.dart';
import 'package:shaheen_namaz/staff/widgets/school_dropdown.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
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
  // Create a GlobalKey to interact with the form widget.
  final GlobalKey<StudentFormSectionState> _formKey =
      GlobalKey<StudentFormSectionState>();

  bool isLoading = false;

  // onAddImage remains in the parent to capture any extra actions.
  void onAddImage() async {
    // Save the current form state in a provider (or pass via callback)
    ref.read(studentDetailsProvider.notifier).state =
        _formKey.currentState?.getCurrentFormValues() ?? {};

    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    if (!mounted) return;
    context.pushNamed(
      "camera_preview",
      extra: firstCamera,
      pathParameters: {
        "isAttendenceTracking": "false",
        "isEdit": "false",
        "isManual": "false"
      },
    );
  }

  Future<void> onRegister() async {
    // Validate and get form data from the separate form widget.
    final formData = _formKey.currentState?.validateAndSave();
    if (formData == null) {
      Logger().e("Form validation failed");
      return;
    }

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

      // Process image
      final bytes = await widget.image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Get selected masjid from provider
      final String? selectedMasjidRef = ref.read(selectedMasjidProvider);
      if (selectedMasjidRef == null) {
        if (!mounted) return;
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
              message: "Please select a masjid before registering."),
        );
        return;
      }

      // Build payload merging form data with extra fields
      final payload = {
        "image_data": base64Image,
        ...formData,
        "masjidId": selectedMasjidRef,
        "volunteer_name": FirebaseAuth.instance.currentUser!.displayName,
        "volunteer_id": FirebaseAuth.instance.currentUser!.uid,
      };

      final response = await FirebaseFunctions.instance
          .httpsCallable('register_student')
          .call(payload);

      final jsonResponse = response.data;
      if (jsonResponse["faceId"] != null) {
        Logger().i("Success");
        if (!mounted) return;
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
              message: "Yayyy!! Successfully Registered"),
        );
        // Reset stored student details.
        ref.read(studentDetailsProvider.notifier).state = {};
        context.go("/user");
      } else {
        if (!mounted) return;
        showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
                message: "An Error Occurred: ${jsonResponse["error"] ?? ''}"));
      }
    } catch (err) {
      Logger().e("Error: $err");
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

  @override
  Widget build(BuildContext context) {
    DocumentReference userDoc = FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    return Scaffold(
      appBar: const CustomAppbar(),
      body: StreamBuilder(
          stream: userDoc.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              Logger().e("Error: ${snapshot.error}");
              return const Center(child: Text("Something went Wrong"));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Gap(MediaQuery.of(context).size.height * 0.05),
                  // The image section is isolated.
                  StudentImageSection(
                    image: widget.image,
                    onTap: onAddImage,
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.05),
                  // The form is encapsulated in its own widget.
                  StudentFormSection(key: _formKey),
                  const Gap(10),
                  // Masjid selection remains separate.
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Masjids",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .white, // Use your theme primary color here.
                        ),
                      ),
                    ),
                  ),
                  const MasjidSearchWidget(),
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: onRegister,
        child: isLoading
            ? const CircularProgressIndicator()
            : const Icon(Icons.keyboard_arrow_right_rounded),
      ),
    );
  }
}

/// A widget for displaying the image preview with an onTap callback.
class StudentImageSection extends StatelessWidget {
  const StudentImageSection({
    Key? key,
    required this.image,
    required this.onTap,
  }) : super(key: key);

  final XFile? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ImagePreview(
        onTap: onTap,
        image: image,
      ),
    );
  }
}

/// A widget that encapsulates the student registration form.
class StudentFormSection extends ConsumerStatefulWidget {
  const StudentFormSection({Key? key}) : super(key: key);

  @override
  StudentFormSectionState createState() => StudentFormSectionState();
}

class StudentFormSectionState extends ConsumerState<StudentFormSection> {
  final formKey = GlobalKey<FormState>();

  // Form field values
  String? name;
  String? guardianNumber;
  String? guardianName;
  String? studentClass;
  String? studentSection;
  String? studentAddress;
  String? dob;
  String? selectedGender;
  String? selectedSchool;
  bool isSpecialProgramEligible = false;

  // Controllers for text fields.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  final TextEditingController guardianNumberController =
      TextEditingController();
  final TextEditingController guardianNameController = TextEditingController();
  final TextEditingController studentClassController = TextEditingController();
  final TextEditingController studentSectionController =
      TextEditingController();
  final TextEditingController studentAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Retrieve initial values if available from a provider
    final studentDetails = ref.read(studentDetailsProvider);
    nameController.text = studentDetails["name"] as String? ?? "";
    if (dob != null) {
      dobController.text = dob!;
    }
    guardianNumberController.text =
        studentDetails["guardianNumber"] as String? ?? "";
    guardianNameController.text =
        studentDetails["guardianName"] as String? ?? "";
    dob = studentDetails["dob"] as String? ?? "";
    studentClassController.text =
        studentDetails["studentClass"] as String? ?? "";
    studentSectionController.text =
        studentDetails["studentSection"] as String? ?? "";
    studentAddressController.text =
        studentDetails["studentAddress"] as String? ?? "";
    selectedGender = studentDetails["gender"] as String?;
    selectedSchool = studentDetails["school_name"] as String?;
  }

  /// Call this to perform validation and save form values.
  /// Returns a map of form data if valid, or null if validation fails.
  Map<String, dynamic>? validateAndSave() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      return {
        "name": name,
        "guardianNumber": guardianNumber,
        "guardianName": guardianName,
        "dob": dob,
        "class": studentClass,
        "section": studentSection?.toLowerCase(),
        "address": studentAddress,
        "school_name": selectedSchool?.toLowerCase(),
        "gender": selectedGender,
        "special_program_eligible": isSpecialProgramEligible,
      };
    }
    return null;
  }

  /// This method returns the current form values (useful when saving state before navigation).
  Map<String, dynamic> getCurrentFormValues() {
    return {
      "name": nameController.text,
      "guardianNumber": guardianNumberController.text,
      "guardianName": guardianNameController.text,
      "dob": dob,
      "class": studentClassController.text,
      "section": studentSectionController.text,
      "address": studentAddressController.text,
      "school_name": selectedSchool,
      "gender": selectedGender,
      "special_program_eligible": isSpecialProgramEligible,
    };
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Name Field
          TextFormField(
            controller: nameController,
            decoration: formDecoration(label: "Name"),
            validator: (value) {
              if (value == null || value.trim().isEmpty || value.length < 2) {
                return "Please enter a valid name";
              }
              return null;
            },
            onSaved: (val) => name = val,
          ),
          const Gap(10),
          // Class Field
          TextFormField(
            controller: studentClassController,
            decoration: formDecoration(label: "Class"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter a valid class";
              }
              return null;
            },
            onSaved: (val) => studentClass = val,
          ),
          const Gap(10),
          // Section Field
          TextFormField(
            controller: studentSectionController,
            decoration: formDecoration(label: "Section"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter a valid Section";
              }
              return null;
            },
            onSaved: (val) => studentSection = val,
          ),
          const Gap(10),
          TextFormField(
            controller: dobController, // Use controller here
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
                  dob = selectedDate
                      .toString()
                      .split(" ")[0]; // Set the selected date
                  dobController.text = dob!; // Update the controller text
                });
              }
            },
            validator: (value) {
              if (dob == null || dob!.isEmpty) {
                return "Please select a valid date";
              }
              final dobDateTime = DateTime.parse(dob!);
              final age = DateTime.now().year - dobDateTime.year;
              if (age < 10 || age > 25) {
                return "Age must be between 10 and 25";
              }
              return null;
            },
            onSaved: (val) => dob = val,
          ),
          const Gap(10),
          // Gender Dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            value: selectedGender,
            onChanged: (String? newValue) {
              setState(() {
                selectedGender = newValue;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a gender' : null,
            items: ['Male', 'Female']
                .map((value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
          ),
          const Gap(10),
          // Address Field
          TextFormField(
            controller: studentAddressController,
            maxLines: 3,
            decoration: formDecoration(label: "Address"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter a valid address";
              }
              return null;
            },
            onSaved: (val) => studentAddress = val,
          ),
          const Gap(10),
          // School Dropdown
          SchoolDropdownWidget(
              initialValue: selectedSchool,
              validator: (value) {
                if (value == null || !Constants.schools.contains(value)) {
                  return "Please select a school";
                }
                return null;
              },
              onSelected: (value) {
                setState(() {
                  selectedSchool = value;
                });
              }),
          const Gap(10),
          // Guardian Name Field
          TextFormField(
            controller: guardianNameController,
            decoration: formDecoration(label: "Guardian Name"),
            validator: (value) {
              if (value == null || value.trim().isEmpty || value.length < 2) {
                return "Please enter a valid name";
              }
              return null;
            },
            onSaved: (val) => guardianName = val,
          ),
          const Gap(10),
          // Guardian Number Field
          TextFormField(
            controller: guardianNumberController,
            maxLength: 10,
            keyboardType: TextInputType.number,
            decoration: formDecoration(label: "Guardian Number"),
            validator: (value) {
              if (value == null || value.trim().isEmpty || value.length < 10) {
                return "Please enter a valid number";
              }
              return null;
            },
            onSaved: (val) => guardianNumber = val,
          ),
          // Toggle for Special Program Eligibility
          SwitchListTile(
            title: const Text("Special Program"),
            value: isSpecialProgramEligible,
            onChanged: (bool value) {
              setState(() {
                isSpecialProgramEligible = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    guardianNumberController.dispose();
    guardianNameController.dispose();
    studentClassController.dispose();
    studentSectionController.dispose();
    studentAddressController.dispose();
    super.dispose();
  }
}

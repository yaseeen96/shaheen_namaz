import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/staff/providers/providers.dart';
import 'package:shaheen_namaz/staff/widgets/app_bar.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ImagePreviewScreen extends ConsumerStatefulWidget {
  const ImagePreviewScreen({
    super.key,
    this.image,
    this.isEdit = false,
    this.isManual = false,
  });
  final XFile? image;
  final bool isEdit;
  final bool isManual;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends ConsumerState<ImagePreviewScreen> {
  bool isLoading = false;

  void onEdit() async {
    setState(() {
      isLoading = true;
    });
    final bytes = await widget.image!.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('verify_face_edit')
          .call({
        "image_data": base64Image,
      });
      final jsonResponse = response.data;
      if (jsonResponse["faceId"] != null) {
        final student = await FirebaseFirestore.instance
            .collection("students")
            .doc(jsonResponse["faceId"])
            .get();
        final studentData = student.data();
        ref.read(selectedMasjidProvider.notifier).state =
            studentData?["masjid_details"]["masjidId"];
        if (!mounted) return;
        context.pushNamed("edit_student", pathParameters: {
          "faceId": jsonResponse["faceId"],
          "name": studentData?["name"],
          "dob": studentData?["dob"] is String
              ? studentData!["dob"]
              : (studentData?["dob"] as Timestamp).toDate().toString(),
          "guardianName": studentData?["guardianName"],
          "guardianNumber": studentData?["guardianNumber"],
          "address": studentData?["address"],
          "className": studentData?["class"],
          "schoolName": studentData?["school_name"] ?? "No School Selected",
          "section": studentData?["section"] ?? "e.g B",
          "isSpecialProgramEligible":
              studentData?["special_program_eligible"].toString() ?? "false",
        });
      } else {
        if (jsonResponse["error"] != null) {
          if (!mounted) return;
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              message: "No Student found with face",
            ),
          );
        }
      }

      logger.i("Response: $jsonResponse");
    } on FirebaseFunctionsException catch (err, _) {
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: err.message ?? "Uh Ohh. Try Again",
        ),
      );
      logger.e("error response: ${err.message}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onVerify() async {
    setState(() {
      isLoading = true;
    });
    final bytes = await widget.image!.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      final response =
          await FirebaseFunctions.instance.httpsCallable('verify_face').call({
        "image_data": base64Image,
      });
      final jsonResponse = response.data;
      if (jsonResponse["faceId"] != null) {
        if (!mounted) return;
        showGeneralDialog(
            context: context,
            pageBuilder: ((context, animation, secondaryAnimation) =>
                VerificationPopup(
                  name: jsonResponse["studentData"]["studentName"],
                  streak: jsonResponse["studentData"]["streak"],
                  guardianNumber: jsonResponse["studentData"]
                      ["studentGuardianNumber"],
                  faceId: jsonResponse["faceId"],
                )));
      } else {
        if (jsonResponse["error"] != null) {
          if (!mounted) return;
          showTopSnackBar(Overlay.of(context),
              CustomSnackBar.error(message: jsonResponse["error"]));
          Navigator.of(context).pop();
        }
      }

      logger.i("Response: $jsonResponse");
    } on FirebaseFunctionsException catch (err, _) {
      if (!mounted) return;
      showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Uh Ohh. Try Again",
          ));
      logger.e("error response: ${err.message}");
      Navigator.of(context).pop();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onManualVerify() async {
    setState(() {
      isLoading = true;
    });
    final bytes = await widget.image!.readAsBytes();
    final base64Image = base64Encode(bytes);
    final selectedFaceId = ref.read(selectedFaceIdProvider);
    final response =
        await FirebaseFunctions.instance.httpsCallable("verify_face_id").call({
      "face_id": selectedFaceId,
      "image_data": base64Image,
    });
    final jsonResponse = response.data;
    logger.i("response: $jsonResponse");
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Image.file(
          File(widget.image!.path),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : widget.isEdit
                ? onEdit
                : widget.isManual
                    ? onManualVerify
                    : onVerify,
        icon: const Icon(Icons.face),
        label: isLoading
            ? const CircularProgressIndicator()
            : Text(widget.isEdit ? "Edit Student Details" : "Track Attendance"),
      ),
    );
  }
}

class VerificationPopup extends StatefulWidget {
  final String name;
  final int streak;
  final String guardianNumber;
  final String faceId;

  const VerificationPopup({
    super.key,
    required this.name,
    required this.streak,
    required this.guardianNumber,
    required this.faceId,
  });

  @override
  _VerificationPopupState createState() => _VerificationPopupState();
}

class _VerificationPopupState extends State<VerificationPopup> {
  bool isLoading = false;
  final currentId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? userDetails;
  Map<String, dynamic>? selectedMasjid;

  void getUserDetails() async {
    final userDoc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentId)
        .get();
    final user = userDoc.data();
    if (user == null) return;
    setState(() {
      userDetails = user;
      if (userDetails?["imam_details"] != null) {
        selectedMasjid = userDetails!["imam_details"];
      } else {
        selectedMasjid = (userDetails!["masjid_details"] is List)
            ? userDetails!["masjid_details"][0]
            : userDetails!["masjid_details"];
      }
    });
  }

  Future<Map<String, dynamic>> markAsPresent() async {
    setState(() {
      isLoading = true;
    });

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('mark_as_present');
      logger.i("selected masjid: $selectedMasjid");

      final response = await callable.call(<String, dynamic>{
        'faceId': widget.faceId,
        'name': widget.name,
        'guardianNumber': widget.guardianNumber,
        'streak': widget.streak,
        'masjidDetails': selectedMasjid,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'displayName': FirebaseAuth.instance.currentUser!.displayName,
      });

      final jsonResponse = response.data;
      logger.i("Response: $jsonResponse");

      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse["isSuccess"] != null) {
        if (jsonResponse["isSuccess"]) {
          return {
            "isSuccess": true,
            "message": jsonResponse["message"],
          };
        } else {
          return {
            "isSuccess": false,
            "message": jsonResponse["message"],
          };
        }
      } else {
        return {
          "isSuccess": false,
          "message": "error: $jsonResponse",
        };
      }
    } catch (e) {
      logger.e("Error calling cloud function: $e");
      return {
        "isSuccess": false,
        "message": "An error occurred: $e",
      };
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Match Found'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Name: ${widget.name}'),
            Text('Streak Uptill now: ${widget.streak}'),
            Text('Guardian Phone Number: ${widget.guardianNumber}'),
            if (userDetails != null &&
                userDetails!["isTrustee"] == true &&
                (userDetails!["imam_details"] == null ||
                    !userDetails!.containsKey("imam_details")))
              for (final masjid in userDetails!["masjid_details"])
                if (masjid is Map<String, dynamic>)
                  RadioListTile<Map<String, dynamic>>(
                    value: masjid,
                    groupValue: selectedMasjid,
                    onChanged: (value) {
                      setState(() {
                        selectedMasjid = value;
                      });
                    },
                    title: Text(
                      masjid["masjidName"],
                    ),
                  ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: isLoading
              ? null
              : () async {
                  final result = await markAsPresent();
                  if (result["isSuccess"]) {
                    if (!context.mounted) return;
                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.success(
                        message: result["message"],
                      ),
                    );
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // Pop the AlertDialog
                    Navigator.of(context).pop(); // Pop the ImagePreviewScreen
                  } else {
                    if (!context.mounted) return;
                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.error(
                        message: result["message"],
                      ),
                    );
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // Pop the AlertDialog
                    Navigator.of(context).pop(); // Pop the AlertDialog
                  }
                },
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Mark as present'),
        ),
      ],
    );
  }
}

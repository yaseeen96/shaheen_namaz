import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/staff/widgets/app_bar.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ImagePreviewScreen extends ConsumerStatefulWidget {
  const ImagePreviewScreen({super.key, this.image});
  final XFile? image;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends ConsumerState<ImagePreviewScreen> {
  bool isLoading = false;

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

      // logger.e("Errrorrrr from onVerify", error: err, stackTrace: stk);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
        onPressed: isLoading ? null : onVerify,
        icon: const Icon(Icons.face),
        label: isLoading
            ? const CircularProgressIndicator()
            : const Text("Track Attendance"),
      ),
    );
  }
}

class VerificationPopup extends StatefulWidget {
  final String name;
  final int streak;
  final String guardianNumber;
  final String faceId;

  VerificationPopup({
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

  Future<bool> markAsPresent() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("students")
          .doc(widget.faceId)
          .update({
        "streak": FieldValue.increment(1),
        "streak_last_modified": DateTime.now()
      });
      final String url =
          'http://bulksms.saakshisoftware.com/api/mt/SendSMS?user=BETTERMENTFOUNDATION&password=91647676&senderid=BDRBBF&channel=Trans&DCS=0&flashsms=0&number=${widget.guardianNumber}&text=Dear Parent, Great news! ${widget.name} prayed Fajr today, on day ${widget.streak < 40 ? (widget.streak + 1) : 40} of the 40-Day Fajr Challenge. Keep the support! BIDAR BETTERMENT FOUNDATION&route=04&DLTTemplateId=1707170436518100086&PEID=1701170408820217696';
      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, then return true.
        return true;
      } else {
        // If the server returns an error response, then throw an exception.
        throw Exception('Failed to send SMS');
      }
    } catch (error) {
      return false;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Match Found'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Name: ${widget.name}'),
            Text('Streak: ${widget.streak}'),
            Text('Guardian Phone Number: ${widget.guardianNumber}'),
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
                  final isSuccess = await markAsPresent();
                  if (isSuccess) {
                    if (!context.mounted) return;
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.success(
                        message: "Student marked as present",
                      ),
                    );
                  } else {
                    if (!context.mounted) return;

                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.error(
                        message: "Failed to mark student as present",
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Mark as present'),
        ),
      ],
    );
  }
}

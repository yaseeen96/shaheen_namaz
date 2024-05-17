// A screen that allows users to take a picture using a given camera.
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
    this.isAttendenceTracking = false,
  });

  final CameraDescription camera;
  final bool isAttendenceTracking;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.veryHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  void onCapture() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Attempt to take a picture and then get the location
      // where the image file is saved.
      final image = await _controller.takePicture();
      logger.i("isAttendenceTracking: ${widget.isAttendenceTracking}");
      if (widget.isAttendenceTracking) {
        logger.i("inside isAttendenceTracking");
        if (!mounted) return;
        context.push("/image_preview", extra: image);
      } else {
        if (!mounted) return;
        context.goNamed(
          "register_student",
          extra: image,
        );
      }
    } catch (e) {
      // If an error occurs, log the error to the console.
      logger.e("Error while capturing picture", error: e);
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fill this out in the next steps.
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return Scaffold(
            body: CameraPreview(_controller),
            floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              onPressed: onCapture,
              child: const Icon(Icons.camera),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        } else if (snapshot.hasError) {
          return Scaffold(
              body:
                  Center(child: Text("An Error Occurred: ${snapshot.error}")));
        } else {
          // Otherwise, display a loading indicator.
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/screens/admin_screen.dart';
import 'package:shaheen_namaz/staff/screens/camera/camera_preview_screen.dart';
import 'package:shaheen_namaz/staff/screens/camera/image_preview_screen.dart';
import 'package:shaheen_namaz/staff/screens/parent_screen.dart';
import 'package:shaheen_namaz/staff/screens/student_data_mobile.dart';
import 'package:shaheen_namaz/staff/screens/student_registration/student_registration_screen.dart';

final routes = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      redirect: (ctx, state) {
        if (kIsWeb) {
          return "/admin";
        } else {
          return "/user";
        }
      },
    ),
    GoRoute(
      path: "/admin",
      builder: (ctx, state) => const AdminScreen(),
    ),
    GoRoute(
      path: "/user",
      builder: (ctx, state) => const ParentScreen(),
    ),
    GoRoute(
      path: "/register_student",
      builder: (ctx, state) => StudentRegistrationScreen(
        image: state.extra as XFile?,
      ),
    ),
    GoRoute(
      path: "/camera_preview/:isAttendanceTracking",
      builder: (ctx, state) => TakePictureScreen(
        camera: state.extra! as CameraDescription,
        isAttendanceTracking:
            (state.pathParameters["isAttendanceTracking"] != null)
                ? state.pathParameters["isAttendanceTracking"]!.toLowerCase() ==
                    "true"
                : false,
      ),
    ),
    GoRoute(
      path: "/image_preview",
      builder: (ctx, state) => ImagePreviewScreen(
        image: state.extra as XFile?,
      ),
    ),
    GoRoute(
        path: "/student_data_mobile",
        builder: (ctx, state) => const StudentDataMobile()),
  ],
);

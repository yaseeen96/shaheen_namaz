import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/screens/admin_screen.dart';
import 'package:shaheen_namaz/admin/screens/jamaat_data_screen.dart';
import 'package:shaheen_namaz/admin/screens/masjid_data_screen.dart';
import 'package:shaheen_namaz/admin/screens/volunteers_data_screen.dart';
import 'package:shaheen_namaz/staff/screens/camera/camera_preview_screen.dart';
import 'package:shaheen_namaz/staff/screens/camera/image_preview_screen.dart';
import 'package:shaheen_namaz/staff/screens/edit_student/edit_student_screen.dart';
import 'package:shaheen_namaz/staff/screens/manual_attendance/manual_attendance.dart';
import 'package:shaheen_namaz/staff/screens/parent_screen.dart';
import 'package:shaheen_namaz/staff/screens/student_data_mobile.dart';
import 'package:shaheen_namaz/staff/screens/student_registration/student_registration_screen.dart';
import 'package:shaheen_namaz/staff/screens/track_attendance/track_attendance.dart';

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
        routes: [
          GoRoute(
            path: "volunteer",
            builder: (context, state) => const VolunteersDataScreen(),
          ),
          GoRoute(
            path: "masjid",
            builder: (context, state) => const MasjidDataScreen(),
          ),
          GoRoute(
            path: "jamaat",
            builder: (context, state) => const JamaatDataScreen(),
          ),
        ]),
    GoRoute(
      path: "/user",
      builder: (ctx, state) => const ParentScreen(),
    ),
    GoRoute(
      path: "/manual_attendance",
      name: "manual_attendance",
      builder: (ctx, state) => const ManualAttendance(),
    ),
    GoRoute(
      name: "register_student",
      path: "/register_student",
      builder: (ctx, state) => StudentRegistrationScreen(
        image: state.extra as XFile?,
      ),
    ),
    GoRoute(
      name: "camera_preview",
      path: "/camera_preview/:isAttendenceTracking/:isEdit/:isManual",
      builder: (ctx, state) => TakePictureScreen(
        camera: state.extra! as CameraDescription,
        isAttendenceTracking:
            state.pathParameters['isAttendenceTracking'] == "true",
        isEdit: state.pathParameters['isEdit'] == "true",
        isManual: state.pathParameters["isManual"] == "true",
      ),
    ),
    GoRoute(
        name: "edit_student",
        path:
            "/edit_student/:faceId/:name/:dob/:className/:address/:guardianName/:guardianNumber/:schoolName/:section",
        builder: (ctx, state) => EditStudentScreen(
              faceId: state.pathParameters["faceId"]!,
              name: state.pathParameters["name"],
              dob: state.pathParameters["dob"],
              guardianName: state.pathParameters["guardianName"],
              guardianNumber: state.pathParameters["guardianNumber"],
              address: state.pathParameters["address"],
              className: state.pathParameters["className"],
              schoolName: state.pathParameters["schoolName"],
              section: state.pathParameters["section"],
            )),
    GoRoute(
      name: "image_preview",
      path: "/image_preview/:isEdit/:isManual",
      builder: (ctx, state) => ImagePreviewScreen(
        image: state.extra as XFile?,
        isEdit: state.pathParameters["isEdit"] == "true",
        isManual: state.pathParameters["isManual"] == "true",
      ),
    ),
    GoRoute(
        path: "/student_data_mobile",
        builder: (ctx, state) => const TrackAttendanceScreen()),
  ],
);

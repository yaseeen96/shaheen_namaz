import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/widgets/student_data_table.dart';
import 'package:shaheen_namaz/staff/widgets/app_bar.dart';
import 'package:shaheen_namaz/staff/widgets/side_drawer.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void onTrackAttendance() async {
    final cameras = await availableCameras();

    final firstCamera = cameras.first;
    if (!mounted) return;
    context.pushNamed(
      "camera_preview",
      extra: firstCamera,
      pathParameters: {"isAttendenceTracking": "true"},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MenuButton(
            onTap: onTrackAttendance,
            imagePath: "assets/calendar_icon.png",
            title: "Track Attendance",
          ),
          const Gap(20),
          MenuButton(
            onTap: () {
              context.push("/register_student", extra: null);
            },
            imagePath: "assets/register_icon.png",
            title: "Register a Student",
          ),
        ],
      ),
      drawer: const SideDrawer(),
    );
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    this.onTap,
    required this.imagePath,
    required this.title,
  });
  final void Function()? onTap;
  final String imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Ink(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.black, blurRadius: 2, spreadRadius: 1,
                // offset: Offset.fromDirection(1, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath),
              const Gap(15),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

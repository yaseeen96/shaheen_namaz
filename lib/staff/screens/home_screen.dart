import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/staff/widgets/app_bar.dart';
import 'package:shaheen_namaz/staff/widgets/side_drawer.dart';

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
          const Expanded(
            child: MenuButton(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              onTap: null,
              imagePath: "assets/camera_icon.png",
              title: "Track Attendance",
            ),
          ),
          Expanded(
            child: MenuButton(
              backgroundColor: Colors.white,
              onTap: () {
                context.push("/register_student", extra: null);
              },
              imagePath: "assets/register_icon.png",
              title: "Register a Student",
            ),
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
    required this.backgroundColor,
    this.foregroundColor = Colors.black,
  });
  final void Function()? onTap;
  final String imagePath;
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      onTap: onTap,
      child: Ink(
        // height: MediaQuery.of(context).size.height * 0.3,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath),
            const Gap(15),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: foregroundColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar(
      {super.key, this.preferredSize = const Size.fromHeight(120)});

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      foregroundColor: Colors.white,
      toolbarHeight: 120,
      title: Image.asset(
        "assets/logo.png",
        width: 150,
        height: 150,
      ),
      backgroundColor: Colors.black,
      actions: [
        IconButton(
            onPressed: () {
              context.push("/student_data_mobile");
            },
            icon: const Icon(
              Icons.dataset_rounded,
              size: 35,
            ))
      ],
    );
  }
}

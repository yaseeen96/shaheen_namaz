import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar(
      {super.key, this.preferredSize = const Size.fromHeight(120)});

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      toolbarHeight: 120,
      title: Image.asset(
        "assets/logo.png",
        width: 150,
        height: 150,
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/widgets/side_menu.dart';

class AdminHomeWidget extends ConsumerStatefulWidget {
  const AdminHomeWidget({super.key});

  @override
  ConsumerState<AdminHomeWidget> createState() => _AdminHomeWidgetState();
}

class _AdminHomeWidgetState extends ConsumerState<AdminHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        // menu
        Expanded(
          flex: 1,
          child: SideMenuDrawer(),
        ),
        Expanded(flex: 4, child: ChildWidget()),
      ],
    );
  }
}

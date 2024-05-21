import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/providers/admin_home_provider.dart';
import 'package:shaheen_namaz/admin/widgets/side_menu.dart';

class AdminHomeWidget extends ConsumerStatefulWidget {
  const AdminHomeWidget({super.key});

  @override
  ConsumerState<AdminHomeWidget> createState() => _AdminHomeWidgetState();
}

class _AdminHomeWidgetState extends ConsumerState<AdminHomeWidget> {
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(adminNotifierProvider);
    return Row(
      children: [
        // menu
        const Expanded(
          flex: 1,
          child: SideMenuDrawer(),
        ),
        Expanded(
          flex: 4,
          child: Container(
              alignment: Alignment.center,
              child: childWidget(homeState.selectedIndex, ref)),
        ),
      ],
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/admin/providers/admin_home_provider.dart';
import 'package:shaheen_namaz/admin/widgets/masjid_widget.dart';
import 'package:shaheen_namaz/admin/widgets/users/users_widget.dart';

class SideMenuDrawer extends ConsumerWidget {
  const SideMenuDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.read(adminNotifierProvider.notifier);
    final homeState = ref.watch(adminNotifierProvider);
    return Material(
      color: Colors.black,
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            height: 100,
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[900]),
            child: Text(
              "Welcome Admin",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
            ),
          ),
          ListTile(
            title: const Text(
              "Users",
            ),
            onTap: () {
              operations.updateSelectedIndex(1);
            },
            selected: homeState.selectedIndex == 1,
            selectedTileColor: Theme.of(context).primaryColor,
          ),
          const Gap(5),
          ListTile(
            title: const Text("Masjids"),
            onTap: () {
              operations.updateSelectedIndex(2);
            },
            selected: homeState.selectedIndex == 2,
            selectedTileColor: Theme.of(context).primaryColor,
          ),
          const Spacer(),
          Image.asset("assets/logo.png"),
          const Gap(10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    )),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout")),
          )
        ],
      ),
    );
  }
}

Widget childWidget(int index) {
  switch (index) {
    case 1:
      return const UsersWidget();
    case 2:
      return const MasjidWidget();
    default:
      return Container(
        alignment: Alignment.center,
        child: const Text("Please Select a view from menu"),
      );
  }
}

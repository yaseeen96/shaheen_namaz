import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/admin/providers/admin_home_provider.dart/admin_home_provider.dart';
import 'package:shaheen_namaz/admin/widgets/masjid_widget.dart';
import 'package:shaheen_namaz/admin/widgets/users_widget.dart';

class AdminHomeWidget extends ConsumerStatefulWidget {
  const AdminHomeWidget({super.key});

  @override
  ConsumerState<AdminHomeWidget> createState() => _AdminHomeWidgetState();
}

class _AdminHomeWidgetState extends ConsumerState<AdminHomeWidget> {
  @override
  Widget build(BuildContext context) {
    final operations = ref.read(adminNotifierProvider.notifier);
    final homeState = ref.watch(adminNotifierProvider);
    return Row(
      children: [
        // menu
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  "Welcome Admin",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Gap(10),
                const Divider(),
                const Gap(10),
                ListTile(
                  title: const Text("Users"),
                  onTap: () {
                    operations.updateSelectedIndex(1);
                  },
                  selected: homeState.selectedIndex == 1,
                  selectedTileColor: Colors.amber,
                ),
                const Gap(5),
                ListTile(
                  title: Text("Masjids"),
                  onTap: () {
                    operations.updateSelectedIndex(2);
                  },
                  selected: homeState.selectedIndex == 2,
                  selectedTileColor: Colors.amber,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      icon: Icon(Icons.logout),
                      label: Text("Logout")),
                )
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
              alignment: Alignment.center,
              color: Colors.red,
              child: ChildWidget(homeState.selectedIndex)),
        ),
      ],
    );
  }
}

Widget ChildWidget(int index) {
  switch (index) {
    case 1:
      return const UsersWidget();
    case 2:
      return const MasjidWidget();
    default:
      return Container(
        alignment: Alignment.center,
        child: Text("PLease Select a view from menu"),
      );
  }
}

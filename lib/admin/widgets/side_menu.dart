import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/admin/providers/admin_home_provider.dart';
import 'package:shaheen_namaz/admin/widgets/attendance/attendance_list.dart';
import 'package:shaheen_namaz/admin/widgets/certificates/certificate_list.dart';
import 'package:shaheen_namaz/admin/widgets/change_password.dart';
import 'package:shaheen_namaz/admin/widgets/dashboard/dashboard.dart';
import 'package:shaheen_namaz/admin/widgets/statistics/statistics.dart';
import 'package:shaheen_namaz/admin/widgets/masjids/masjid_widget.dart';
import 'package:shaheen_namaz/admin/widgets/users/users_widget.dart';

class SideMenuDrawer extends ConsumerWidget {
  const SideMenuDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.read(adminNotifierProvider.notifier);
    final homeState = ref.watch(adminNotifierProvider);
    final dataCount = ref.watch(dataCountProvider);
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
              "Dashboard",
            ),
            onTap: () {
              operations.updateSelectedIndex(1);
            },
            selected: homeState.selectedIndex == 1,
            selectedTileColor: Theme.of(context).primaryColor,
          ),
          ListTile(
            title: const Text(
              "Users",
            ),
            onTap: () {
              operations.updateSelectedIndex(2);
            },
            selected: homeState.selectedIndex == 2,
            selectedTileColor: Theme.of(context).primaryColor,
          ),
          const Gap(5),
          ListTile(
            title: const Text("Masjids"),
            onTap: () {
              operations.updateSelectedIndex(3);
            },
            selected: homeState.selectedIndex == 3,
            selectedTileColor: Theme.of(context).primaryColor,
          ),
          const Gap(5),
          ListTile(
            title: const Text("Track Attendance"),
            trailing: (dataCount == 0)
                ? null
                : Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Text("$dataCount"),
                  ),
            onTap: () {
              operations.updateSelectedIndex(4);
            },
            selected: homeState.selectedIndex == 4,
            selectedTileColor: Theme.of(context).primaryColor,
          ),
          const Spacer(),
          Image.asset("assets/logo.png"),
          const Gap(10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) => const ChangePasswordWidget());
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  )),
              child: const Text("Change Password"),
            ),
          ),
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
              label: const Text("Logout"),
            ),
          )
        ],
      ),
    );
  }
}

class ChildWidget extends ConsumerStatefulWidget {
  const ChildWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChildWidgetState();
}

class _ChildWidgetState extends ConsumerState<ChildWidget> {
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(adminNotifierProvider);
    return Container(
      alignment: Alignment.center,
      child: homeState.selectedIndex == 0
          ? const ShaheenStatistics()
          : homeState.selectedIndex == 1
              ? const ShaheenDashboard()
              : homeState.selectedIndex == 2
                  ? const UsersWidget()
                  : homeState.selectedIndex == 3
                      ? const MasjidWidget()
                      : homeState.selectedIndex == 4
                          ? const AttendanceList()
                          : homeState.selectedIndex == 5
                              ? const CertificateList()
                              // ? Center(
                              //     child: MasjidDropdownWidget(
                              //     initialValue: {
                              //       'masjidId': '13F62rkjL28061lNvPMm',
                              //       'masjidName': 'Masjid-e-Ismail',
                              //       'clusterNumber': 11,
                              //     },
                              //     onSelected: (selectedMasjid) {
                              //       logger.i("Selected Masjid: $selectedMasjid");
                              //     },
                              //   ))
                              : const Text("Please Select a view from menu"),
    );
  }
}

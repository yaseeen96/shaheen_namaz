import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/admin/providers/admin_home_provider.dart';
import 'package:shaheen_namaz/admin/widgets/change_password.dart';
import 'package:shaheen_namaz/admin/widgets/side_menu.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
import 'package:sidebarx/sidebarx.dart';

class AdminHomeWidget extends ConsumerStatefulWidget {
  const AdminHomeWidget({super.key});

  @override
  ConsumerState<AdminHomeWidget> createState() => _AdminHomeWidgetState();
}

class _AdminHomeWidgetState extends ConsumerState<AdminHomeWidget> {
  late SidebarXController _sidebarController;

  @override
  void initState() {
    super.initState();
    final homeState = ref.read(adminNotifierProvider);
    _sidebarController = SidebarXController(
      selectedIndex: homeState.selectedIndex,
      extended: false,
    );
  }

  @override
  void didUpdateWidget(AdminHomeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final homeState = ref.read(adminNotifierProvider);
    if (_sidebarController.selectedIndex != homeState.selectedIndex) {
      _sidebarController = SidebarXController(
        selectedIndex: homeState.selectedIndex,
        extended: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SidebarX(
          theme: SidebarXTheme(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Constants.secondaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            hoverColor: Constants.primaryColor,
            textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            selectedTextStyle: const TextStyle(color: Colors.white),
            hoverTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            itemTextPadding: const EdgeInsets.only(left: 30),
            selectedItemTextPadding: const EdgeInsets.only(left: 30),
            itemDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Constants.secondaryColor),
            ),
            selectedItemDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Constants.primaryColor.withOpacity(0.37),
              ),
              gradient: const LinearGradient(
                colors: [Constants.secondaryColor, Constants.secondaryColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 30,
                )
              ],
            ),
            iconTheme: IconThemeData(
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            selectedIconTheme: const IconThemeData(
              color: Colors.white,
              size: 20,
            ),
          ),
          extendedTheme: const SidebarXTheme(
            width: 300,
            decoration: BoxDecoration(
              color: Constants.secondaryColor,
            ),
          ),
          controller: _sidebarController,
          headerBuilder: (context, extended) {
            return SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                    extended ? 'assets/logo.png' : "assets/logo_small.png"),
              ),
            );
          },
          items: [
            SidebarXItem(
              icon: Icons.graphic_eq,
              label: 'Statistics',
              onTap: () {
                ref.read(adminNotifierProvider.notifier).updateSelectedIndex(0);
              },
            ),
            SidebarXItem(
              icon: Icons.space_dashboard_rounded,
              label: 'Dashboard',
              onTap: () {
                ref.read(adminNotifierProvider.notifier).updateSelectedIndex(1);
              },
            ),
            SidebarXItem(
              icon: Icons.people,
              label: 'Users',
              onTap: () {
                ref.read(adminNotifierProvider.notifier).updateSelectedIndex(2);
              },
            ),
            SidebarXItem(
              icon: Icons.mosque,
              label: 'Masjids',
              onTap: () {
                ref.read(adminNotifierProvider.notifier).updateSelectedIndex(3);
              },
            ),
            SidebarXItem(
              icon: Icons.person,
              label: 'Track Attendance',
              onTap: () {
                ref.read(adminNotifierProvider.notifier).updateSelectedIndex(4);
              },
            ),
            SidebarXItem(
              icon: Icons.school,
              label: 'Certifications',
              onTap: () {
                ref.read(adminNotifierProvider.notifier).updateSelectedIndex(5);
              },
            ),
          ],
          footerBuilder: (context, extended) {
            if (!extended) {
              return Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.password),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const ChangePasswordWidget(),
                      );
                    },
                  ),
                  const Gap(5),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black.withOpacity(0.28),
                        backgroundColor: Constants.bgColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.password),
                      label: const Text('Change Password'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => const ChangePasswordWidget(),
                        );
                      },
                    ),
                  ),
                  const Gap(5),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black.withOpacity(0.28),
                        backgroundColor: Constants.bgColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
        const Expanded(child: ChildWidget()), // Replace with your ChildWidget
      ],
    );
  }
}

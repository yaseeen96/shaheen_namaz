import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/models/all_users_response.dart';
import 'package:shaheen_namaz/admin/providers/get_users_provider.dart';
import 'package:shaheen_namaz/admin/widgets/users/custom_dropdown_button.dart';
import 'package:shaheen_namaz/admin/widgets/users/subtitle_widget.dart';
import 'package:shaheen_namaz/admin/widgets/users/tab_bar.dart';
import 'package:shaheen_namaz/providers/selected_items_provider.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class UsersWidget extends ConsumerStatefulWidget {
  const UsersWidget({super.key});

  @override
  ConsumerState<UsersWidget> createState() => _UsersWidgetState();
}

class _UsersWidgetState extends ConsumerState<UsersWidget> {
  final _formKey = GlobalKey<FormState>();
  String? displayName;
  String? userEmail;
  String? password;

  bool isLoading = false;
  List<QueryDocumentSnapshot<Object?>> menuItems = [];

  @override
  void initState() {
    getMenuItems().then((value) {
      setState(() {
        menuItems = value;
      });
    });

    super.initState();
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getMenuItems() async {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection("Masjid");
    final QuerySnapshot querySnapshot = await collectionReference.get();
    final allMasjids = querySnapshot.docs.map((e) => e).toList();
    return allMasjids;
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(selectedItemsProvider);
    final users = ref.watch(getUsersProvider);
    final filteredUsers = ref.watch(filteredUsersProvider);
    return users.when(
      data: (user) {
        return Scaffold(
          appBar: AppBar(
            bottom: CustomTabBar(
              onTabChange: (index) {
                if (index == 0) {
                  ref
                      .read(filteredUsersProvider.notifier)
                      .setFilteredToVolunteer(user.users!);
                } else {
                  ref
                      .read(filteredUsersProvider.notifier)
                      .setFilteredToTrustee(user.users!);
                }
              },
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // add search bar to search for users
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Search for a user",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  ref
                      .read(filteredUsersProvider.notifier)
                      .searchUsers(user.users!, value);
                },
              ),

              const Gap(20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All Users",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return UserDetailsPopup(
                            menuItems: menuItems,
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add New User"),
                  ),
                ],
              ),
              const Gap(6),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: filteredUsers.length,
                      itemBuilder: (ctx, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          width: MediaQuery.of(context).size.width * 0.6,
                          constraints: BoxConstraints(
                            maxHeight: 300,
                          ),
                          child: ListTile(
                            key: ValueKey(filteredUsers[index].uid),
                            title: Text(filteredUsers[index].displayName!),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return UserDetailsPopup(
                                        menuItems: menuItems,
                                        user: filteredUsers[index]);
                                  });
                            },
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed:
                                  filteredUsers[index].email!.contains("admin")
                                      ? null
                                      : () async {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await FirebaseFunctions.instance
                                              .httpsCallable("delete_user")
                                              .call(
                                            {
                                              "uid": filteredUsers[index].uid!,
                                            },
                                          );
                                          ref.invalidate(getUsersProvider);
                                          setState(() {
                                            isLoading = false;
                                          });
                                        },
                            ),
                            subtitle: Wrap(runSpacing: 10, children: [
                              ...filteredUsers[index]
                                  .masjidAllocated!
                                  .map((masjidId) {
                                return SubtitleWidget(
                                  masjidId: masjidId,
                                  userId: filteredUsers[index].uid!,
                                );
                              }),
                              if (filteredUsers[index]
                                      .masjidAllocated!
                                      .isEmpty &&
                                  filteredUsers[index].isStaff == true)
                                SizedBox(
                                  width: 500,
                                  child: CustomDropDown(
                                    ref: ref,
                                    menuItems: menuItems,
                                    onChanged: (value) async {
                                      ref
                                          .read(selectedItemsProvider.notifier)
                                          .state = [
                                        ...ref.read(selectedItemsProvider),
                                        {
                                          "id": value!.id,
                                          "name": value.get("name")
                                        }
                                      ];
                                      final DocumentReference masjidRef =
                                          FirebaseFirestore.instance
                                              .collection("Masjid")
                                              .doc(value.id);
                                      await FirebaseFirestore.instance
                                          .collection("Users")
                                          .doc(filteredUsers[index].uid!)
                                          .update(
                                        {
                                          "masjid_allocated":
                                              FieldValue.arrayUnion(
                                            [masjidRef],
                                          ),
                                          "masjid_details":
                                              FieldValue.arrayUnion(
                                            [
                                              {
                                                "clusterNumber":
                                                    value.get("cluster_number"),
                                                "masjidId": value.id,
                                                "masjidName": value.get("name"),
                                              }
                                            ],
                                          ),
                                        },
                                      );
                                      ref.invalidate(getUsersProvider);
                                    },
                                  ),
                                ),
                              if (filteredUsers[index].isTrustee == true)
                                SizedBox(
                                  width: 500,
                                  child: CustomDropDown(
                                    isMultiSelect: true,
                                    ref: ref,
                                    menuItems: menuItems,
                                    onMultiSelectChanged: (value) async {
                                      for (var value in value) {
                                        ref
                                            .read(
                                                selectedItemsProvider.notifier)
                                            .state = [
                                          ...ref.read(selectedItemsProvider),
                                          {
                                            "id": value!.id,
                                            "name": value.get("name")
                                          }
                                        ];
                                        final DocumentReference masjidRef =
                                            FirebaseFirestore.instance
                                                .collection("Masjid")
                                                .doc(value.id);
                                        await FirebaseFirestore.instance
                                            .collection("Users")
                                            .doc(filteredUsers[index].uid!)
                                            .update(
                                          {
                                            "masjid_allocated":
                                                FieldValue.arrayUnion(
                                              [masjidRef],
                                            ),
                                            "masjid_details":
                                                FieldValue.arrayUnion(
                                              [
                                                {
                                                  "clusterNumber": value
                                                      .get("cluster_number"),
                                                  "masjidId": value.id,
                                                  "masjidName":
                                                      value.get("name"),
                                                }
                                              ],
                                            ),
                                          },
                                        );
                                        ref.invalidate(getUsersProvider);
                                      }
                                    },
                                  ),
                                )
                            ]),
                            tileColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        );
                      }),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stk) => Center(
        child: Text("An Error Occurred. Error: $err"),
      ),
    );
  }
}

class UserDetailsPopup extends ConsumerStatefulWidget {
  const UserDetailsPopup({
    super.key,
    required this.menuItems,
    this.user,
  });

  final List<QueryDocumentSnapshot<Object?>> menuItems;
  final Users? user;

  @override
  _UserDetailsPopupState createState() => _UserDetailsPopupState();
}

enum UserRoles { trustee, volunteer }

extension ParseToString on UserRoles {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class _UserDetailsPopupState extends ConsumerState<UserDetailsPopup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String? role;

  String? displayName;
  String? userEmail;
  String? password;
  final TextEditingController clusterController = TextEditingController();

  Future<List<QueryDocumentSnapshot<Object?>>> getDocumentsByClusterNumber(
      int clusterNumber) async {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection("Masjid");

    final QuerySnapshot querySnapshot = await collectionReference
        .where('cluster_number', isEqualTo: clusterNumber)
        .get();

    return querySnapshot.docs;
  }

  void getSelectedItems() async {
    final List<Map<String, String>> selectedItemsList = [];
    if (widget.user == null ||
        widget.user!.masjidDetails!.isEmpty ||
        widget.user?.masjidDetails == null) {
      ref.read(selectedItemsProvider.notifier).state = [];
    }
    for (var masjid in widget.user!.masjidDetails!) {
      selectedItemsList.add({
        "id": masjid.masjidId!,
        "name": masjid.masjidName!,
      });
    }
    ref.read(selectedItemsProvider.notifier).state = selectedItemsList;
  }

  @override
  void initState() {
    role = widget.user?.isTrustee == true
        ? "UserRoles.trustee"
        : "UserRoles.volunteer";
    getSelectedItems();

    super.initState();
  }

  @override
  void dispose() {
    clusterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(selectedItemsProvider);
    return AlertDialog(
      title: const Text('Enter User Details'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: widget.user?.displayName,
                  decoration: const InputDecoration(
                    label: Text("Name of User"),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        value.length < 4) {
                      return "The name must be at least 4 characters long";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    displayName = newValue;
                  },
                ),
                TextFormField(
                  initialValue: widget.user?.email,
                  decoration: const InputDecoration(
                    label: Text("User's email"),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        value.length < 8 ||
                        !value.contains("@")) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    userEmail = newValue;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("User's Password"),
                  ),
                  onSaved: (newValue) {
                    password = newValue;
                  },
                  validator: (widget.user == null)
                      ? (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.length < 6) {
                            return "Password must be at least 6 characters long";
                          }
                          return null;
                        }
                      : null,
                ),
                const Gap(20),
                const Text(
                  "User Role",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Gap(10),
                DropdownButtonFormField<UserRoles>(
                  value: (widget.user?.isTrustee == true)
                      ? UserRoles.trustee
                      : UserRoles.volunteer,
                  hint: const Text("Please select a role"),
                  items: const [
                    DropdownMenuItem(
                      value: UserRoles.trustee,
                      child: Text("Trustee"),
                    ),
                    DropdownMenuItem(
                      value: UserRoles.volunteer,
                      child: Text("Volunteer"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      role = value.toString();
                    });
                    logger.i("value: $value");
                  },
                  onSaved: (newValue) => role = newValue.toString(),
                  validator: (value) {
                    if (value == null) {
                      return "Please select a role";
                    }
                    return null;
                  },
                ),
                const Gap(20),
                const Text(
                  "Masjids Allocated",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Gap(10),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Wrap(
                    children: [
                      for (Map<String, String> item in items)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Chip(
                            label: Text(item["name"] ?? ""),
                            onDeleted: () async {
                              ref.read(selectedItemsProvider.notifier).state =
                                  items.where((e) => e != item).toList();

                              // Assuming getMenuItems is an async function that fetches the menu items
                            },
                          ),
                        ),
                      if (items.isEmpty && role == "UserRoles.volunteer")
                        SizedBox(
                            height: 100,
                            width: 300,
                            child: CustomDropDown(
                                ref: ref,
                                menuItems: widget.menuItems,
                                onChanged: (e) {
                                  ref
                                      .read(selectedItemsProvider.notifier)
                                      .state = [
                                    ...ref.read(selectedItemsProvider),
                                    {"id": e!.id, "name": e.get("name")}
                                  ];
                                })),
                      if (widget.user?.isTrustee == true ||
                          role == "UserRoles.trustee")
                        SizedBox(
                            height: 100,
                            width: 300,
                            child: CustomDropDown(
                                isMultiSelect: true,
                                ref: ref,
                                menuItems: widget.menuItems.where((item) {
                                  final masjidId = item.id;

                                  return !items.any((selectedItem) =>
                                      selectedItem['id'] == masjidId);
                                }).toList(),
                                onMultiSelectChanged: (e) {
                                  if (e.isNotEmpty) {
                                    for (var e in e) {
                                      ref
                                          .read(selectedItemsProvider.notifier)
                                          .state = [
                                        ...ref.read(selectedItemsProvider),
                                        {"id": e!.id, "name": e.get("name")}
                                      ];

                                      widget.menuItems.remove(e);
                                    }
                                  }
                                })),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              context.pop();
            },
            child: const Text("Cancel")),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : widget.user == null
                  ? () {
                      addUser(shouldUpdate: false, ref: ref);
                    }
                  : () {
                      addUser(shouldUpdate: true, ref: ref);
                    },
          child: isLoading
              ? const CircularProgressIndicator()
              : (widget.user == null)
                  ? const Text("Add")
                  : const Text("Update"),
        )
      ],
    );
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getMenuItems() async {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection("Masjid");
    final QuerySnapshot querySnapshot = await collectionReference.get();
    final allMasjids = querySnapshot.docs.map((e) => e).toList();
    return allMasjids;
  }

  void addUser({required bool shouldUpdate, required WidgetRef ref}) async {
    final String functionName =
        shouldUpdate ? "shaheen_update_user" : "add_user";
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        final selectedItems = ref.read(selectedItemsProvider);

        final masjidList = selectedItems.map((data) => data["id"]).toList();

        if (masjidList.isNotEmpty) {
          setState(() {
            isLoading = true;
          });

          try {
            logger.i("role: ${role!.split(".").last}");
            await FirebaseFunctions.instance.httpsCallable(functionName).call(
              {
                if (shouldUpdate) "uid": widget.user!.uid,
                "email": userEmail,
                "displayName": displayName,
                "masjidDocNames": masjidList,
                if (password != null) "password": password,
                "role": role!.split(".").last,
              },
            );
            if (!mounted) return;
            context.pop();
          } on FirebaseFunctionsException catch (e) {
            if (e.code == "aborted") {
              if (!mounted) return;
              showTopSnackBar(
                  Overlay.of(context),
                  const CustomSnackBar.error(
                      message:
                          "Uh Ohh. An Error Occurred. Try with different data."));
            }
            logger.e("error code: ${e.message}");
          } finally {
            setState(() {
              isLoading = false;
            });

            ref.invalidate(getUsersProvider);
          }
        }
      }
    }
  }
}

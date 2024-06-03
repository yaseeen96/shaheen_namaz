import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
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
import 'package:shaheen_namaz/utils/constants/constants.dart';
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
    final usersAsyncValue = ref.watch(getUsersProvider);
    final filteredUsers = ref.watch(filteredUsersProvider);
    return usersAsyncValue.when(
      data: (userResponse) {
        return Scaffold(
          appBar: AppBar(
            bottom: CustomTabBar(
              onTabChange: (index) {
                if (index == 0) {
                  ref
                      .read(filteredUsersProvider.notifier)
                      .setFilteredToVolunteer(userResponse.users);
                } else {
                  ref
                      .read(filteredUsersProvider.notifier)
                      .setFilteredToTrustee(userResponse.users);
                }
              },
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // Search bar to search for users
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Search for a user",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  ref
                      .read(filteredUsersProvider.notifier)
                      .searchUsers(userResponse.users, value);
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
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      itemBuilder: (ctx, index) {
                        final user = filteredUsers[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          width: MediaQuery.of(context).size.width * 0.6,
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListTile(
                            key: ValueKey(user.uid),
                            title: Text(user.displayName ?? user.email),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return UserDetailsPopup(
                                    menuItems: menuItems,
                                    user: user,
                                  );
                                },
                              );
                            },
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed: (user.email == "admin@shaheen.org")
                                  ? null
                                  : () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await FirebaseFunctions.instance
                                          .httpsCallable("delete_user")
                                          .call({"uid": user.uid});
                                      ref.invalidate(getUsersProvider);
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                            ),
                            subtitle: Wrap(
                              runSpacing: 10,
                              children: [
                                ...user.masjidDetails.map((masjid) {
                                  return SubtitleWidget(
                                    masjidId: masjid.masjidId,
                                    userId: user.uid,
                                  );
                                }),
                                if (user.masjidAllocated.isEmpty &&
                                    user.isStaff)
                                  SizedBox(
                                    width: 500,
                                    child: CustomDropDown(
                                      ref: ref,
                                      menuItems: menuItems,
                                      onChanged: (value) async {
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
                                            .doc(user.uid)
                                            .update({
                                          "masjid_allocated":
                                              FieldValue.arrayUnion(
                                                  [masjidRef]),
                                          "masjid_details":
                                              FieldValue.arrayUnion([
                                            {
                                              "clusterNumber":
                                                  value.get("cluster_number"),
                                              "masjidId": value.id,
                                              "masjidName": value.get("name"),
                                            }
                                          ]),
                                        });
                                        ref.invalidate(getUsersProvider);
                                      },
                                    ),
                                  ),
                                if (user.isTrustee)
                                  SizedBox(
                                    width: 500,
                                    child: CustomDropDown(
                                      isMultiSelect: true,
                                      ref: ref,
                                      menuItems: menuItems,
                                      onMultiSelectChanged: (value) async {
                                        for (var val in value) {
                                          ref
                                              .read(selectedItemsProvider
                                                  .notifier)
                                              .state = [
                                            ...ref.read(selectedItemsProvider),
                                            {
                                              "id": val!.id,
                                              "name": val.get("name")
                                            }
                                          ];
                                          final DocumentReference masjidRef =
                                              FirebaseFirestore.instance
                                                  .collection("Masjid")
                                                  .doc(val.id);
                                          await FirebaseFirestore.instance
                                              .collection("Users")
                                              .doc(user.uid)
                                              .update({
                                            "masjid_allocated":
                                                FieldValue.arrayUnion(
                                                    [masjidRef]),
                                            "masjid_details":
                                                FieldValue.arrayUnion([
                                              {
                                                "clusterNumber":
                                                    val.get("cluster_number"),
                                                "masjidId": val.id,
                                                "masjidName": val.get("name"),
                                              }
                                            ]),
                                          });
                                          ref.invalidate(getUsersProvider);
                                        }
                                      },
                                    ),
                                  )
                              ],
                            ),
                            tileColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stk) =>
          Center(child: Text("An Error Occurred. Error: $err")),
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
  final User? user;

  @override
  _UserDetailsPopupState createState() => _UserDetailsPopupState();
}

enum UserRoles { trustee, volunteer }

extension ParseToString on UserRoles {
  String toShortString() {
    return toString().split('.').last;
  }
}

class _UserDetailsPopupState extends ConsumerState<UserDetailsPopup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String? role;
  String? jamaatName;
  String? password;
  String? displayName;
  String? phoneNumber;

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
        widget.user!.masjidDetails.isEmpty ||
        widget.user?.masjidDetails == null) {
      ref.read(selectedItemsProvider.notifier).state = [];
    }
    for (var masjid in widget.user!.masjidDetails) {
      selectedItemsList.add({
        "id": masjid.masjidId,
        "name": masjid.masjidName,
      });
    }
    ref.read(selectedItemsProvider.notifier).state = selectedItemsList;
  }

  @override
  void initState() {
    role = widget.user?.isTrustee == true
        ? "UserRoles.trustee"
        : "UserRoles.volunteer";
    setState(() {
      jamaatName = widget.user?.jamaatName;
    });
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
                  initialValue: widget.user?.phoneNumber,
                  decoration: const InputDecoration(
                    label: Text("User's phone number"),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        value.length != 10) {
                      return "Please enter a valid phone Number";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    phoneNumber = newValue;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("User's Password"),
                  ),
                  onSaved: (newValue) {
                    password = newValue;
                  },
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
                  "NGO or Jamth associated with",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Gap(20),
                DropdownSearch<String>(
                  dropdownBuilder: (context, selectedItem) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        jamaatName ??
                            "Please select NGO or Jamth associated with",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  items: Constants.jamaatList,
                  onChanged: (value) {
                    jamaatName = value;
                  },
                  selectedItem: jamaatName,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    baseStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: const TextFieldProps(
                      decoration: InputDecoration(labelText: "Search by name"),
                    ),
                    itemBuilder: (context, item, isSelected) {
                      return ListTile(
                        title: Text(
                          item,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
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
                              ref.read(selectedItemsProvider.notifier).state = [
                                ...ref.read(selectedItemsProvider),
                                {"id": e!.id, "name": e.get("name")}
                              ];
                            },
                          ),
                        ),
                      if (widget.user?.isTrustee == true ||
                          role == "UserRoles.trustee")
                        for (var i = 1; i <= 12; i++)
                          SizedBox(
                            height: 100,
                            width: 300,
                            child: CustomDropDown(
                              labelText: "Cluster $i",
                              isMultiSelect: true,
                              ref: ref,
                              menuItems: widget.menuItems.where((item) {
                                return item.get("cluster_number") == i;
                              }).toList(),
                              onMultiSelectChanged: (e) {
                                if (e.isNotEmpty) {
                                  for (var val in e) {
                                    ref
                                        .read(selectedItemsProvider.notifier)
                                        .state = [
                                      ...ref.read(selectedItemsProvider),
                                      {"id": val!.id, "name": val.get("name")}
                                    ];
                                    widget.menuItems.remove(val);
                                  }
                                }
                              },
                            ),
                          ),
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
          child: const Text("Cancel"),
        ),
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

  Future<void> addUser(
      {required bool shouldUpdate, required WidgetRef ref}) async {
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
                "phoneNumber": "+91$phoneNumber",
                "displayName": displayName,
                "password": password ?? "",
                "masjidDocNames": masjidList,
                "role": role!.split(".").last,
                "jamaatName": jamaatName ?? "Not Associated with any Jamaat",
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
                      "Uh Ohh. An Error Occurred. Try with different data.",
                ),
              );
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

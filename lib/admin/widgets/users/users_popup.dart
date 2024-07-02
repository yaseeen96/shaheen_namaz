import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/models/all_users_response.dart';
import 'package:shaheen_namaz/admin/providers/get_users_provider.dart';
import 'package:shaheen_namaz/admin/providers/imam_provider.dart';
import 'package:shaheen_namaz/admin/providers/menu_items_provider.dart';
import 'package:shaheen_namaz/admin/widgets/users/custom_dropdown_button.dart';
import 'package:shaheen_namaz/providers/selected_items_provider.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../../utils/extensions.dart';

enum UserRoles { trustee, volunteer }

extension ParseToString on UserRoles {
  String toShortString() {
    return toString().split('.').last;
  }
}

class UserDetailsPopup extends ConsumerStatefulWidget {
  const UserDetailsPopup({
    super.key,
    this.user,
  });

  final User? user;

  @override
  _UserDetailsPopupState createState() => _UserDetailsPopupState();
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

  @override
  void initState() {
    role = widget.user?.isTrustee == true
        ? "UserRoles.trustee"
        : "UserRoles.volunteer";
    setState(() {
      jamaatName = widget.user?.jamaatName;
    });

    super.initState();
  }

  @override
  void dispose() {
    clusterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuItemsProvider);
    final items = ref.watch(selectedItemsProvider);
    final imamSelectedMasjid = ref.watch(imamProvider);
    logger.i("imamSelectedMasjid: $imamSelectedMasjid");

    return AlertDialog(
      title: const Text('Enter User Details'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            shrinkWrap: true,
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
                initialValue: (widget.user?.phoneNumber != null &&
                        widget.user!.phoneNumber!.startsWith("+91"))
                    ? widget.user?.phoneNumber?.substring(3)
                    : widget.user?.phoneNumber,
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
              if (widget.user?.isTrustee == true ||
                  role == "UserRoles.trustee" ||
                  widget.user?.jamaatName == "IMAM MASJID" ||
                  jamaatName == "IMAM MASJID")
                const Text(
                  "Assigned Masjid(only if its imam)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              if ((widget.user?.isTrustee == true ||
                      role == "UserRoles.trustee") &&
                  (widget.user?.jamaatName == "IMAM MASJID" ||
                      jamaatName == "IMAM MASJID"))
                const Gap(20),
              if (widget.user?.isTrustee == true ||
                  role == "UserRoles.trustee" ||
                  widget.user?.jamaatName == "IMAM MASJID" ||
                  jamaatName == "IMAM MASJID")
                Text("Masjid: ${imamSelectedMasjid["masjidName"]}"),
              if (widget.user?.isTrustee == true ||
                  role == "UserRoles.trustee" ||
                  widget.user?.jamaatName == "IMAM MASJID" ||
                  jamaatName == "IMAM MASJID")
                Container(
                  height: 100,
                  width: 300,
                  margin: const EdgeInsets.all(10),
                  child: CustomDropDown(
                    ref: ref,
                    menuItems: menuItems,
                    labelText: "Select Masjid",
                    onChanged: (masjid) {
                      ref.read(imamProvider.notifier).state = {
                        "masjidId": masjid!.id,
                        "masjidName": masjid.get("name"),
                        "clusterNumber": masjid.get("cluster_number")
                      };
                    },
                  ),
                ),
              const Text(
                "Masjids Allocated",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Gap(10),
              Wrap(
                children: [
                  for (Map<String, dynamic> item in items)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Chip(
                        label: Text(item["masjidName"] ?? ""),
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
                        menuItems: menuItems,
                        onChanged: (e) {
                          ref.read(selectedItemsProvider.notifier).state = [
                            ...ref.read(selectedItemsProvider),
                            {
                              "masjidId": e!.id,
                              "masjidName": e.get("name"),
                              "clusterNumber": e.get("cluster_number")
                            }
                          ];
                        },
                      ),
                    ),
                  if (widget.user?.isTrustee == true ||
                      role == "UserRoles.trustee")
                    for (var i = 1; i <= 12; i++)
                      Container(
                        height: 100,
                        width: 300,
                        margin: const EdgeInsets.all(10),
                        child: CustomDropDown(
                          labelText: "Cluster $i",
                          isMultiSelect: true,
                          ref: ref,
                          menuItems: menuItems.where((item) {
                            return item.get("cluster_number") == i;
                          }).toList(),
                          onMultiSelectChanged: (e) {
                            if (e.isNotEmpty) {
                              for (var val in e) {
                                ref.read(selectedItemsProvider.notifier).state =
                                    [
                                  ...ref.read(selectedItemsProvider),
                                  {
                                    "masjidId": val!.id,
                                    "masjidName": val.get("name"),
                                    "clusterNumber": val.get("cluster_number")
                                  }
                                ];
                                menuItems.remove(val); // Remove locally
                              }
                              ref
                                  .read(menuItemsProvider.notifier)
                                  .loadMenuItems(); // Reload menu items
                            }
                          },
                        ),
                      ),
                ],
              )
            ],
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

        setState(() {
          isLoading = true;
        });

        try {
          logger.i("role: ${role!.split(".").last}");
          final imamDetails = ref.read(imamProvider);
          logger.i("role: ${role!.split(".").last})");
          await FirebaseFunctions.instance.httpsCallable(functionName).call(
            {
              if (shouldUpdate) "uid": widget.user!.uid,
              "phoneNumber": "+91$phoneNumber",
              "displayName": displayName?.capitalize(),
              "password": password ?? "",
              "masjidDetails": selectedItems,
              "role": role!.split(".").last,
              "jamaatName": jamaatName ?? "Not Associated with any Jamaat",
              "imamDetails":
                  (imamDetails.isEmpty || role?.split(".").last != "trustee")
                      ? ""
                      : imamDetails,
            },
          );

          if (!mounted) return;
          context.pop();
        } on FirebaseFunctionsException catch (e) {
          if (e.code == "aborted") {
            if (!mounted) return;
            showTopSnackBar(
              Overlay.of(context),
              CustomSnackBar.error(
                message: "Uh Ohh. ${e.message}",
              ),
            );
          }
          logger.e("error code: ${e.message}");
        } finally {
          setState(() {
            isLoading = false;
          });
          ref.read(imamProvider.notifier).state = {};
          ref.invalidate(getUsersProvider);
        }
      }
    }
  }
}

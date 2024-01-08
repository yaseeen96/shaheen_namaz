import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/admin/providers/get_users_provider.dart';
import 'package:shaheen_namaz/admin/widgets/users/subtitle_widget.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

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
  List<QueryDocumentSnapshot<Object?>> menuItems = [];
  List<Map<String, String>> selectedItems = [];

  @override
  void initState() {
    getMenuItems().then((value) {
      menuItems = value;
    });
    super.initState();
  }

  void addUser() {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        logger.i('$displayName $userEmail $password');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$displayName $userEmail $password')),
        );
      }
    }
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getMenuItems() async {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection("Masjid");
    final QuerySnapshot querySnapshot = await collectionReference.get();
    final allMasjids = querySnapshot.docs.map((e) => e).toList();
    return allMasjids;
  }

  Future<void> showPopup() async {
    return showDialog(
      context: context,
      builder: (ctx) {
        bool setPassword = true;

        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Enter User Details'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
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
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                value: true,
                                groupValue: setPassword,
                                onChanged: (value) {
                                  setState(() {
                                    setPassword = true;
                                  });
                                },
                                title: const Text(
                                  "Give User Password",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                value: false,
                                groupValue: setPassword,
                                onChanged: (value) {
                                  setState(() {
                                    setPassword = false;
                                  });
                                },
                                title: const Text(
                                  "Send Password reset Email",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (setPassword)
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text("User's Password"),
                            ),
                            onSaved: (newValue) {
                              password = newValue;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.length < 6) {
                                return "Password must be atleast 6 chars long";
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
                        SingleChildScrollView(
                          child: Row(
                            children: [
                              for (Map<String, String> item in selectedItems)
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Chip(
                                    label: Text(item["name"] ?? ""),
                                    onDeleted: () async {
                                      setState(() {
                                        selectedItems.remove(item);
                                      });
                                      menuItems = await getMenuItems();
                                    },
                                  ),
                                ),
                              PopupMenuButton(
                                icon: const Icon(Icons.add),
                                itemBuilder: (context) {
                                  return menuItems
                                      .map(
                                        (e) => PopupMenuItem(
                                          value: e.id,
                                          onTap: () {
                                            setState(() {
                                              selectedItems.add(
                                                {
                                                  "id": e.id,
                                                  "name": e.get("name")
                                                },
                                              );
                                              menuItems.remove(e);
                                            });
                                          },
                                          child: Text(
                                            e.get("name"),
                                          ),
                                        ),
                                      )
                                      .toList();
                                },
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
                ElevatedButton(onPressed: addUser, child: const Text("Add"))
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(getUsersProvider);
    return users.when(
      data: (user) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Users",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                ),
                ElevatedButton.icon(
                  onPressed: showPopup,
                  icon: Icon(Icons.add),
                  label: Text("Add New User"),
                ),
              ],
            ),
            const Gap(6),
            ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: user.users!.length,
                itemBuilder: (ctx, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 3),
                    child: ListTile(
                      title: Text(user.users![index].email!),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                      subtitle: Row(
                        children:
                            user.users![index].masjidAllocated!.map((masjidId) {
                          return SubtitleWidget(masjidId: masjidId);
                        }).toList(),
                      ),
                      tileColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  );
                }),
          ],
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

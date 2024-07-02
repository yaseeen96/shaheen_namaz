import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/models/all_users_response.dart';
import 'package:shaheen_namaz/admin/providers/get_users_provider.dart';
import 'package:shaheen_namaz/admin/providers/imam_provider.dart';
import 'package:shaheen_namaz/admin/providers/menu_items_provider.dart';
import 'package:shaheen_namaz/admin/widgets/users/tab_bar.dart';
import 'package:shaheen_namaz/admin/widgets/users/users_popup.dart';
import 'package:shaheen_namaz/providers/selected_items_provider.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class UsersWidget extends ConsumerStatefulWidget {
  const UsersWidget({super.key});

  @override
  ConsumerState<UsersWidget> createState() => _UsersWidgetState();
}

class _UsersWidgetState extends ConsumerState<UsersWidget> {
  String? displayName;
  String? password;
  int currentIndex = 0;
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String activeLetter = '';

  @override
  void initState() {
    super.initState();
  }

  Query<Object?> getQuery() {
    Query<Object?> baseQuery = (currentIndex == 0)
        ? FirebaseFirestore.instance
            .collection('Users')
            .where("isStaff", isEqualTo: true)
        : FirebaseFirestore.instance
            .collection("Users")
            .where("isTrustee", isEqualTo: true);

    if (searchQuery.isNotEmpty) {
      baseQuery = baseQuery
          .orderBy('name')
          .startAt([searchQuery]).endAt(['$searchQuery\uf8ff']);
    }

    if (activeLetter.isNotEmpty) {
      baseQuery = baseQuery
          .orderBy('name')
          .startAt([activeLetter]).endAt(['$activeLetter\uf8ff']);
    }

    return baseQuery;
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void getSelectedItems(DocumentSnapshot<Object?>? doc) {
    final data = doc?.data() as Map<String, dynamic>? ?? {};
    final List<Map<String, dynamic>> selectedItemsList = [];
    List<MasjidDetails> masjidDetailsList = [];
    if (doc != null) {
      if (data["masjid_details"] is Map<String, dynamic>) {
        var masjid = data["masjid_details"] as Map<String, dynamic>;
        masjidDetailsList.add(
          MasjidDetails(
              clusterNumber: masjid["clusterNumber"],
              masjidId: masjid["masjidId"],
              masjidName: masjid["masjidName"]),
        );
      } else if (data["masjid_details"] is List) {
        masjidDetailsList = (data["masjid_details"] as List<dynamic>)
            .map((e) => MasjidDetails(
                  clusterNumber: e["clusterNumber"],
                  masjidId: e["masjidId"],
                  masjidName: e["masjidName"],
                ))
            .toList();
      }
    }
    if (masjidDetailsList.isEmpty || data["masjid_details"] == null) {
      ref.read(selectedItemsProvider.notifier).state = [];
    }
    for (var masjid in masjidDetailsList) {
      selectedItemsList.add({
        "masjidId": masjid.masjidId,
        "masjidName": masjid.masjidName,
        "clusterNumber": masjid.clusterNumber,
      });
    }
    ref.read(selectedItemsProvider.notifier).state = selectedItemsList;
  }

  void onLetterChanged(String letter) {
    setState(() {
      activeLetter = letter;
      searchQuery = '';
      searchController.clear();
    });
  }

  void onDelete(DocumentSnapshot<Object?> docs) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFunctions.instance
        .httpsCallable("delete_user")
        .call({"uid": docs.id});
    ref.invalidate(getUsersProvider);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuItemsProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showEditPopup(context, null, menuItems);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160.0),
          child: Column(
            children: [
              CustomTabBar(
                onTabChange: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Users...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4.0,
                runSpacing: 4.0,
                children: List.generate(26, (index) {
                  String letter = String.fromCharCode(65 + index);
                  bool isActive = letter == activeLetter;
                  return ChoiceChip(
                    label: Text(letter),
                    selected: isActive,
                    onSelected: (selected) {
                      onLetterChanged(selected ? letter : '');
                    },
                    selectedColor: Colors.black,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : Colors.black,
                    ),
                    shape: const StadiumBorder(
                      side: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  );
                }).toList()
                  ..add(
                    ChoiceChip(
                      label: const Text('All'),
                      selected: activeLetter.isEmpty,
                      onSelected: (selected) {
                        onLetterChanged('');
                      },
                      selectedColor: Colors.black,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color:
                            activeLetter.isEmpty ? Colors.white : Colors.black,
                      ),
                      shape: const StadiumBorder(
                        side: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
      body: FirestorePagination(
        isLive: true,
        key: ValueKey('$currentIndex-$searchQuery-$activeLetter'),
        query: getQuery(),
        itemBuilder: (context, docs, index) {
          final data = docs.data() as Map<String, dynamic>;
          logger.i(index);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            width: MediaQuery.of(context).size.width * 0.6,
            constraints: const BoxConstraints(maxHeight: 1500),
            child: ListTile(
              key: ValueKey(docs.id),
              title: Text(data["name"] ?? data["email"]),
              onTap: () {
                ref.read(imamProvider.notifier).state =
                    data["imam_details"] ?? {};
                logger.i("menu items length: ${menuItems.length}");
                getSelectedItems(docs);
                showEditPopup(context, docs, menuItems);
              },
              trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                  onPressed: (data["email"] == "admin@shaheen.org")
                      ? null
                      : () {
                          onDelete(docs);
                        }),
              tileColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> showEditPopup(
      BuildContext context,
      DocumentSnapshot<Object?>? docs,
      List<QueryDocumentSnapshot<Object?>> currentMenuItems) {
    final data = docs?.data() as Map<String, dynamic>?;
    return showDialog(
      context: context,
      builder: (context) {
        List<MasjidDetails> masjidDetailsList = [];
        if (docs != null) {
          if (data!["masjid_details"] is Map<String, dynamic>) {
            var masjid = data["masjid_details"] as Map<String, dynamic>;
            masjidDetailsList.add(
              MasjidDetails(
                  clusterNumber: masjid["clusterNumber"],
                  masjidId: masjid["masjidId"],
                  masjidName: masjid["masjidName"]),
            );
          } else if (data["masjid_details"] is List) {
            masjidDetailsList = (data["masjid_details"] as List<dynamic>)
                .map((e) => MasjidDetails(
                      clusterNumber: e["clusterNumber"],
                      masjidId: e["masjidId"],
                      masjidName: e["masjidName"],
                    ))
                .toList();
          }
        }

        return UserDetailsPopup(
          user: (docs == null)
              ? null
              : User(
                  displayName: data?["name"],
                  phoneNumber: data?["phone_number"].toString(),
                  uid: docs.id,
                  email: data?["email"],
                  isAdmin: data?["isAdmin"],
                  isStaff: data?["isStaff"],
                  isTrustee: data?["isTrustee"],
                  jamaatName: data?["jamaat_name"],
                  masjidAllocated: [],
                  masjidDetails: masjidDetailsList,
                  imamDetails: data?["imam_details"],
                ),
        );
      },
    );
  }
}

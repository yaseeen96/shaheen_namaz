import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemsNotifier
    extends StateNotifier<List<QueryDocumentSnapshot<Object?>>> {
  MenuItemsNotifier() : super([]) {
    loadMenuItems();
  }

  Future<void> loadMenuItems() async {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection("Masjid");
    final QuerySnapshot querySnapshot = await collectionReference.get();
    final allMasjids = querySnapshot.docs.map((e) => e).toList();
    state = allMasjids;
  }
}

final menuItemsProvider = StateNotifierProvider<MenuItemsNotifier,
    List<QueryDocumentSnapshot<Object?>>>((ref) {
  return MenuItemsNotifier();
});

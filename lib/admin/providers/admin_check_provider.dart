import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCheckNotifier extends StateNotifier<AsyncValue<bool>> {
  AdminCheckNotifier() : super(const AsyncValue.loading());

  Future<void> checkAdminStatus(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .get();
      final data = userDoc.data();
      if (data != null && data["isAdmin"] == true) {
        state = const AsyncValue.data(true);
      } else {
        state = const AsyncValue.data(false);
      }
    } catch (e, stk) {
      state = AsyncValue.error(e, stk);
    }
  }

  void reset() {
    state = const AsyncValue.loading();
  }
}

final adminCheckProvider =
    StateNotifierProvider<AdminCheckNotifier, AsyncValue<bool>>((ref) {
  return AdminCheckNotifier();
});

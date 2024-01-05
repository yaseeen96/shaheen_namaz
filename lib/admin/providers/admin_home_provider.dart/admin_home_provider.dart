import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/models/AdminHomeModel.dart';

class AdminHomeNotifier extends StateNotifier<AdminHomeModel> {
  AdminHomeNotifier() : super(AdminHomeModel());

  void updateSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}

final adminNotifierProvider =
    StateNotifierProvider<AdminHomeNotifier, AdminHomeModel>((ref) {
  return AdminHomeNotifier();
});

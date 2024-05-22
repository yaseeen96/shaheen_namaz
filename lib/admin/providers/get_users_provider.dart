import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/models/all_users_response.dart';
import 'package:shaheen_namaz/admin/services/get_users.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

final getUsersProvider = FutureProvider<AllUsersResponse>((ref) async {
  final response = await getUsers();

  ref
      .read(filteredUsersProvider.notifier)
      .setFilteredToVolunteer(response.users!);

  return response;
});

class filteredUsersNotifier extends StateNotifier<List<Users>> {
  filteredUsersNotifier() : super([]);

  void setFilteredToVolunteer(List<Users> users) {
    state = users.where((user) => user.isStaff == true).toList();
  }

  void setFilteredToTrustee(List<Users> users) {
    state = users.where((user) => user.isTrustee == true).toList();
  }

  void searchUsers(List<Users> users, String query) {
    // on backspace it should clear all values
    if (query.trim().isEmpty) {
      state = users;
      return;
    } else {
      state = users
          .where((user) =>
              user.displayName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}

final filteredUsersProvider =
    StateNotifierProvider<filteredUsersNotifier, List<Users>>((ref) {
  return filteredUsersNotifier();
});

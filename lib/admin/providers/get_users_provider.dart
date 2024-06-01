import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/models/all_users_response.dart';
import 'package:shaheen_namaz/admin/services/get_users.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

final getUsersProvider = StreamProvider<AllUsersResponse>((ref) async* {
  await for (final response in getUsers()) {
    ref
        .read(filteredUsersProvider.notifier)
        .setFilteredToVolunteer(response.users);

    yield response;
  }
});

class FilteredUsersNotifier extends StateNotifier<List<User>> {
  FilteredUsersNotifier() : super([]);

  void setFilteredToVolunteer(List<User> users) {
    state = users.where((user) => user.isStaff == true).toList();
  }

  void setFilteredToTrustee(List<User> users) {
    state = users.where((user) => user.isTrustee == true).toList();
  }

  void searchUsers(List<User> users, String query) {
    if (query.trim().isEmpty) {
      state = users;
    } else {
      try {
        state = state
            .where((user) =>
                user.displayName!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } catch (e) {
        logger.e("Error in searchUsers: $e");
      }
    }
  }
}

final filteredUsersProvider =
    StateNotifierProvider<FilteredUsersNotifier, List<User>>((ref) {
  return FilteredUsersNotifier();
});

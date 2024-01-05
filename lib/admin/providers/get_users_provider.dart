import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/models/all_users_response.dart';
import 'package:shaheen_namaz/admin/services/get_users.dart';

final getUsersProvider = FutureProvider<AllUsersResponse>((ref) async {
  final response = await getUsers();
  return response;
});

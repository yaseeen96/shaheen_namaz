import 'package:shaheen_namaz/admin/models/all_users_response.dart';
import 'package:shaheen_namaz/utils/config/dio_config.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

Future<AllUsersResponse> getUsers() async {
  try {
    final jsonResponse = await dioClient.get("/getUsers");
    final response = AllUsersResponse.fromJson(jsonResponse.data);
    return response;
  } catch (err) {
    logger.e("Error from getUsers in services: $err");
    throw Exception(err);
  }
}

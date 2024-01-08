import 'package:cloud_functions/cloud_functions.dart';
import 'package:shaheen_namaz/admin/models/all_users_response.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

Future<AllUsersResponse> getUsers() async {
  try {
    final jsonResponse =
        await FirebaseFunctions.instance.httpsCallable('get_all_users').call();
    logger.i("response ${jsonResponse.data}");

    final response =
        AllUsersResponse.fromJson(jsonResponse.data as Map<String, dynamic>);
    return response;
  } catch (err) {
    if (err is FirebaseFunctionsException) {
      logger.e("Firebase Exception: ${err.message}");
    } else {
      logger.e("Error from getUsers in services: $err");
    }
    throw Exception("Server Error. Contact Developer for more info.");
  }
}

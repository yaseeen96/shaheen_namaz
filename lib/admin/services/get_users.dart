import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shaheen_namaz/admin/models/all_users_response.dart';
import 'package:shaheen_namaz/utils/config/dio_config.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

Future<AllUsersResponse> getUsers() async {
  try {
    final jsonResponse = await dioClient.get(
      "/getUsers",
    );
    if (jsonResponse.statusCode != HttpStatus.ok) {
      logger.e("status is not 200");
    }
    final response = AllUsersResponse.fromJson(jsonResponse.data);
    return response;
  } catch (err) {
    if (err is DioException) {
      // err is here
      logger.e("Dio Exception: ${err.requestOptions.uri}");
    } else {
      logger.e("Error from getUsers in services: $err");
    }
    throw Exception("Server Error. Contact Developer for more info.");
  }
}

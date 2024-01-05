import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

var token = dotenv.env["SECRET"];

final dioClient = Dio(
  BaseOptions(
    baseUrl: dotenv.env["BASE_URL"]!,
    headers: {
      "Authorization": "Bearer $token",
    },
  ),
);

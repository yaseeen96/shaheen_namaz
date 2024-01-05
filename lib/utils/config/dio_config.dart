import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final dioClient = Dio(
  BaseOptions(
    baseUrl: dotenv.env["BASE_URL"]!,
    headers: {
      "Authorization": "Bearer ${dotenv.env["SECRET"]}",
    },
  ),
);

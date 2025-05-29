// lib/middleware/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = GetStorage();
    final token = storage.read('auth_token');

    if (token == null) {
      return const RouteSettings(name: '/landing');
    }

    return null;
  }
}
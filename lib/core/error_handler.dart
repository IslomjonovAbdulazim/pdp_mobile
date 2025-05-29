import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../core/app_constants.dart';

class ErrorHandler {
  // Handle HTTP errors
  static String handleHttpError(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Invalid data provided.';
      case 500:
        return AppConstants.serverError;
      case 503:
        return 'Service temporarily unavailable.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  // Handle network errors
  static String handleNetworkError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return AppConstants.networkError;
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timeout. Please try again.';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid response format.';
    } else {
      return 'Network error occurred.';
    }
  }

  // Show error snackbar
  static void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE53935),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Show success snackbar
  static void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Show info snackbar
  static void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2196F3),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Show warning snackbar
  static void showWarningSnackbar(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFF9800),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Log error for debugging
  static void logError(String error, [dynamic stackTrace]) {
    print('🔴 ERROR: $error');
    if (stackTrace != null) {
      print('📍 STACK TRACE: $stackTrace');
    }
  }

  // Handle and display error
  static void handleError(dynamic error, [bool showSnackbar = true]) {
    String errorMessage;

    if (error is String) {
      errorMessage = error;
    } else {
      errorMessage = handleNetworkError(error);
    }

    logError(errorMessage, error);

    if (showSnackbar) {
      showErrorSnackbar(errorMessage);
    }
  }
}
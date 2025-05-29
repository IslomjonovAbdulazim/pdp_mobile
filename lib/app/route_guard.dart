// lib/app/route_guard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/storage_service.dart';
import '../features/auth/auth_controller.dart';
import '../app/app_routes.dart';

class RouteGuard extends GetMiddleware {
  @override
  int get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Check if user is logged in
    if (!StorageService.isLoggedIn()) {
      return const RouteSettings(name: AppRoutes.landing);
    }

    // Check if token exists
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // Check if token is expired (basic check)
    if (_isTokenExpired(token)) {
      StorageService.clearAll();
      return const RouteSettings(name: AppRoutes.login);
    }

    // Check payment status
    final userData = StorageService.getUserData();
    if (userData != null) {
      final isPaid = userData['is_paid'] as bool? ?? false;
      if (!isPaid) {
        // User hasn't paid, redirect to payment page
        return const RouteSettings(name: AppRoutes.payment);
      }
    }

    // User is authenticated and has paid, allow access
    return null;
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true; // Invalid token format
      }
      // For now, just return false
      // Implement proper JWT decoding if using JWT tokens
      return false;
    } catch (e) {
      return true; // Error parsing token means it's invalid
    }
  }
}

class AuthGuard extends GetMiddleware {
  @override
  int get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    // Check if user is already logged in
    if (StorageService.isLoggedIn()) {
      final token = StorageService.getToken();
      if (token != null && token.isNotEmpty && !_isTokenExpired(token)) {
        // Check payment status to decide where to redirect
        final userData = StorageService.getUserData();
        if (userData != null) {
          final isPaid = userData['is_paid'] as bool? ?? false;
          if (isPaid) {
            // User is paid, redirect to home
            return const RouteSettings(name: AppRoutes.home);
          } else {
            // User hasn't paid, redirect to payment
            return const RouteSettings(name: AppRoutes.payment);
          }
        }
      }
    }

    // User is not authenticated, allow access to auth pages
    return null;
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }
      return false;
    } catch (e) {
      return true;
    }
  }
}

class PaymentGuard extends GetMiddleware {
  @override
  int get priority => 3;

  @override
  RouteSettings? redirect(String? route) {
    // Only check if user is logged in for payment page
    if (!StorageService.isLoggedIn()) {
      return const RouteSettings(name: AppRoutes.landing);
    }

    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // Allow access to payment page if user is authenticated
    return null;
  }
}

class OnboardingGuard extends GetMiddleware {
  @override
  int get priority => 4;

  @override
  RouteSettings? redirect(String? route) {
    // Check if user has completed onboarding
    final hasCompletedOnboarding = StorageService.getData<bool>('onboarding_completed') ?? false;

    if (!hasCompletedOnboarding) {
      // Redirect to onboarding/landing page
      return const RouteSettings(name: AppRoutes.landing);
    }

    return null;
  }
}

class RoleGuard extends GetMiddleware {
  final List<String> allowedRoles;

  RoleGuard({required this.allowedRoles});

  @override
  int get priority => 5;

  @override
  RouteSettings? redirect(String? route) {
    // Get user data from storage
    final userData = StorageService.getUserData();
    if (userData == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final userRole = userData['role'] as String?;
    if (userRole == null || !allowedRoles.contains(userRole)) {
      // User doesn't have required role, redirect to home page
      return const RouteSettings(name: AppRoutes.home);
    }

    return null;
  }
}

// Helper class for route protection
class RouteProtection {
  // Check if user is authenticated
  static bool isAuthenticated() {
    return StorageService.isLoggedIn() && StorageService.getToken() != null;
  }

  // Check if user has paid
  static bool hasPaidSubscription() {
    final userData = StorageService.getUserData();
    if (userData == null) return false;

    return userData['is_paid'] as bool? ?? false;
  }

  // Check if user has specific role
  static bool hasRole(String role) {
    final userData = StorageService.getUserData();
    if (userData == null) return false;

    final userRole = userData['role'] as String?;
    return userRole == role;
  }

  // Check if user has any of the specified roles
  static bool hasAnyRole(List<String> roles) {
    final userData = StorageService.getUserData();
    if (userData == null) return false;

    final userRole = userData['role'] as String?;
    return userRole != null && roles.contains(userRole);
  }

  // Get current user phone number
  static String? getCurrentUserPhone() {
    final userData = StorageService.getUserData();
    return userData?['phone_number'] as String?;
  }

  // Get current user ID
  static String? getCurrentUserId() {
    final userData = StorageService.getUserData();
    return userData?['id'] as String?;
  }

  // Get current user full name
  static String? getCurrentUserName() {
    final userData = StorageService.getUserData();
    return userData?['full_name'] as String?;
  }

  // Force logout and redirect to login
  static void forceLogout() {
    StorageService.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }

  // Check if route requires authentication
  static bool requiresAuth(String route) {
    const authRequiredRoutes = [
      AppRoutes.home,
      AppRoutes.attendance,
      AppRoutes.exams,
      AppRoutes.homework,
      AppRoutes.profile,
      AppRoutes.settings,
      AppRoutes.payment,
    ];

    return authRequiredRoutes.contains(route);
  }

  // Check if route requires payment
  static bool requiresPayment(String route) {
    const paymentRequiredRoutes = [
      AppRoutes.home,
      AppRoutes.attendance,
      AppRoutes.exams,
      AppRoutes.homework,
      AppRoutes.profile,
      AppRoutes.settings,
    ];

    return paymentRequiredRoutes.contains(route);
  }

  // Navigate based on user status
  static void navigateBasedOnStatus() {
    if (!isAuthenticated()) {
      Get.offAllNamed(AppRoutes.landing);
    } else if (!hasPaidSubscription()) {
      Get.offAllNamed(AppRoutes.payment);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
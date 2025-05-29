import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/storage_service.dart';
import '../app/app_routes.dart';

class RouteGuard extends GetMiddleware {
  @override
  int get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Check if user is logged in
    if (!StorageService.isLoggedIn()) {
      // If not logged in, redirect to landing page
      return const RouteSettings(name: AppRoutes.landing);
    }

    // Check if token exists
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      // If no token, redirect to login
      return const RouteSettings(name: AppRoutes.login);
    }

    // Check if token is expired (basic check)
    if (_isTokenExpired(token)) {
      // Clear storage and redirect to login
      StorageService.clearAll();
      return const RouteSettings(name: AppRoutes.login);
    }

    // User is authenticated, allow access
    return null;
  }

  // Basic token expiration check
  bool _isTokenExpired(String token) {
    try {
      // This is a basic implementation
      // In a real app, you would decode JWT and check exp claim
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
        // User is already authenticated, redirect to home
        return const RouteSettings(name: AppRoutes.home);
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

class OnboardingGuard extends GetMiddleware {
  @override
  int get priority => 3;

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
  int get priority => 4;

  @override
  RouteSettings? redirect(String? route) {
    // Get user data from storage
    final userData = StorageService.getUserData();
    if (userData == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final userRole = userData['role'] as String?;
    if (userRole == null || !allowedRoles.contains(userRole)) {
      // User doesn't have required role, redirect to unauthorized page
      // or home page
      return const RouteSettings(name: AppRoutes.home);
    }

    return null;
  }
}

// Helper class for route protection
class RouteProtection {
  // Check if user is authenticated
  static bool isAuthenticated() {
    return StorageService.isLoggedIn() &&
        StorageService.getToken() != null;
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

  // Get current user role
  static String? getCurrentUserRole() {
    final userData = StorageService.getUserData();
    return userData?['role'] as String?;
  }

  // Get current user ID
  static String? getCurrentUserId() {
    final userData = StorageService.getUserData();
    return userData?['id'] as String?;
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
    ];

    return authRequiredRoutes.contains(route);
  }
}
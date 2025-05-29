import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api_service.dart';
import '../../core/storage_service.dart';
import '../../core/error_handler.dart';
import '../../core/app_constants.dart';
import '../../app/app_routes.dart';

class AuthController extends GetxController {
  // Observable variables
  final _isLoading = false.obs;
  final _isLoggedIn = false.obs;
  final _currentUser = Rxn<Map<String, dynamic>>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  Map<String, dynamic>? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  // Check authentication status on app start
  void _checkAuthStatus() {
    final isLoggedIn = StorageService.isLoggedIn();
    final userData = StorageService.getUserData();

    _isLoggedIn.value = isLoggedIn;
    _currentUser.value = userData;

    if (isLoggedIn && userData != null) {
      // User is logged in, navigate to home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRoutes.toHome();
      });
    }
  }

  // Login method
  Future<void> login(String email, String password) async {
    try {
      _isLoading.value = true;

      final response = await ApiService.login(email, password);

      final token = response['token'] as String?;
      final userData = response['user'] as Map<String, dynamic>?;

      if (token != null && userData != null) {
        // Save auth data
        await StorageService.saveToken(token);
        await StorageService.saveUserData(userData);
        await StorageService.setLoggedIn(true);

        // Update controller state
        _isLoggedIn.value = true;
        _currentUser.value = userData;

        // Show success message
        ErrorHandler.showSuccessSnackbar(AppConstants.loginSuccess);

        // Navigate to home
        AppRoutes.toHome();
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Register method (for app store compliance - shows form but doesn't actually register)
  Future<void> register(Map<String, dynamic> userData) async {
    try {
      _isLoading.value = true;

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // For app store compliance, show waiting confirmation
      // In reality, this doesn't create an account
      ErrorHandler.showInfoSnackbar('Registration request submitted');
      AppRoutes.toWaitingConfirmation();

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Real register method (if you want to enable actual registration later)
  Future<void> _actualRegister(Map<String, dynamic> userData) async {
    try {
      _isLoading.value = true;

      final response = await ApiService.register(userData);

      ErrorHandler.showSuccessSnackbar(AppConstants.registerSuccess);
      AppRoutes.toLogin();

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      // Call logout API if needed
      try {
        await ApiService.post('/auth/logout', {});
      } catch (e) {
        // Continue with logout even if API call fails
        print('Logout API call failed: $e');
      }

      // Clear local storage
      await StorageService.clearAll();

      // Update controller state
      _isLoggedIn.value = false;
      _currentUser.value = null;

      // Show success message
      ErrorHandler.showSuccessSnackbar('Logged out successfully');

      // Navigate to landing page
      AppRoutes.toLanding();

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Forgot password method
  Future<void> forgotPassword(String email) async {
    try {
      _isLoading.value = true;

      await ApiService.post('/auth/forgot-password', {'email': email}, includeAuth: false);

      ErrorHandler.showSuccessSnackbar('Password reset link sent to your email');

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Reset password method
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      _isLoading.value = true;

      await ApiService.post('/auth/reset-password', {
        'token': token,
        'password': newPassword,
      }, includeAuth: false);

      ErrorHandler.showSuccessSnackbar('Password reset successfully');
      AppRoutes.toLogin();

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh token method
  Future<void> refreshToken() async {
    try {
      final currentToken = StorageService.getToken();
      if (currentToken == null) return;

      final response = await ApiService.post('/auth/refresh-token', {
        'token': currentToken,
      });

      final newToken = response['token'] as String?;
      if (newToken != null) {
        await StorageService.saveToken(newToken);
      }

    } catch (e) {
      // If refresh fails, logout user
      logout();
    }
  }

  // Update profile method
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      _isLoading.value = true;

      final userId = _currentUser.value?['id'];
      if (userId == null) throw Exception('User not found');

      final response = await ApiService.put('/users/$userId', profileData);

      final updatedUser = response['user'] as Map<String, dynamic>?;
      if (updatedUser != null) {
        await StorageService.saveUserData(updatedUser);
        _currentUser.value = updatedUser;
      }

      ErrorHandler.showSuccessSnackbar('Profile updated successfully');

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Change password method
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading.value = true;

      await ApiService.post('/auth/change-password', {
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      ErrorHandler.showSuccessSnackbar('Password changed successfully');

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Verify email method
  Future<void> verifyEmail(String verificationCode) async {
    try {
      _isLoading.value = true;

      await ApiService.post('/auth/verify-email', {
        'code': verificationCode,
      });

      ErrorHandler.showSuccessSnackbar('Email verified successfully');

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      _isLoading.value = true;

      final email = _currentUser.value?['email'];
      if (email == null) throw Exception('Email not found');

      await ApiService.post('/auth/resend-verification', {
        'email': email,
      });

      ErrorHandler.showSuccessSnackbar('Verification email sent');

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Check if user email is verified
  bool get isEmailVerified {
    return _currentUser.value?['email_verified'] == true;
  }

  // Get user role
  String? get userRole {
    return _currentUser.value?['role'] as String?;
  }

  // Get user name
  String get userName {
    final user = _currentUser.value;
    if (user == null) return 'User';

    final firstName = user['first_name'] as String? ?? '';
    final lastName = user['last_name'] as String? ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else {
      return user['email'] as String? ?? 'User';
    }
  }

  // Get user initials
  String get userInitials {
    final user = _currentUser.value;
    if (user == null) return 'U';

    final firstName = user['first_name'] as String? ?? '';
    final lastName = user['last_name'] as String? ?? '';

    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';

    if (firstInitial.isNotEmpty && lastInitial.isNotEmpty) {
      return '$firstInitial$lastInitial';
    } else if (firstInitial.isNotEmpty) {
      return firstInitial;
    } else {
      final email = user['email'] as String? ?? 'U';
      return email[0].toUpperCase();
    }
  }
}
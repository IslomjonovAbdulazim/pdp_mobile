// lib/features/auth/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api_service.dart';
import '../../core/storage_service.dart';
import '../../core/error_handler.dart';
import '../../core/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../app/app_routes.dart';

class AuthController extends GetxController {
  // Observable variables
  final _isLoading = false.obs;
  final _isLoggedIn = false.obs;
  final _currentUser = Rxn<User>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  User? get currentUser => _currentUser.value;

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

    if (userData != null) {
      try {
        _currentUser.value = User.fromJson(userData);
      } catch (e) {
        // If user data is corrupted, clear it
        StorageService.clearAll();
        _isLoggedIn.value = false;
      }
    }

    if (isLoggedIn && _currentUser.value != null) {
      // Check if user has paid subscription
      if (_currentUser.value!.isPaid) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRoutes.toHome();
        });
      } else {
        // Redirect to payment page if not paid
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRoutes.toPayment();
        });
      }
    }
  }

  // Login method with phone number
  Future<void> login(String phoneNumber, String password) async {
    try {
      _isLoading.value = true;

      final response = await ApiService.login(phoneNumber, password);

      final token = response['token'] as String?;
      final userData = response['user'] as Map<String, dynamic>?;

      if (token != null && userData != null) {
        // Parse user data
        final user = User.fromJson(userData);

        // Save auth data
        await StorageService.saveToken(token);
        await StorageService.saveUserData(userData);
        await StorageService.setLoggedIn(true);

        // Update controller state
        _isLoggedIn.value = true;
        _currentUser.value = user;

        // Show success message in Uzbek
        ErrorHandler.showSuccessSnackbar('Muvaffaqiyatli kirildi');

        // Navigate based on payment status
        if (user.isPaid) {
          AppRoutes.toHome();
        } else {
          AppRoutes.toPayment();
        }
      } else {
        throw Exception('Serverdan noto\'g\'ri javob keldi');
      }
    } catch (e) {
      String errorMessage = AppConstants.loginFailed;

      // Handle specific errors
      if (e.toString().contains('404')) {
        errorMessage = 'Foydalanuvchi topilmadi';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Telefon raqami yoki parol noto\'g\'ri';
      } else if (e.toString().contains('network')) {
        errorMessage = AppConstants.networkError;
      }

      ErrorHandler.showErrorSnackbar(errorMessage);
    } finally {
      _isLoading.value = false;
    }
  }

  // Register method with phone and full name
  Future<void> register(Map<String, dynamic> userData) async {
    try {
      _isLoading.value = true;

      final response = await ApiService.register(userData);

      // Show success message
      ErrorHandler.showSuccessSnackbar('Ro\'yxatdan o\'tish muvaffaqiyatli. Endi tizimga kiring.');

      // Navigate to login
      AppRoutes.toLogin();

    } catch (e) {
      String errorMessage = AppConstants.registerFailed;

      // Handle specific errors
      if (e.toString().contains('409')) {
        errorMessage = 'Bu telefon raqami allaqachon ro\'yxatdan o\'tgan';
      } else if (e.toString().contains('422')) {
        errorMessage = 'Ma\'lumotlar noto\'g\'ri kiritilgan';
      } else if (e.toString().contains('network')) {
        errorMessage = AppConstants.networkError;
      }

      ErrorHandler.showErrorSnackbar(errorMessage);
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
      ErrorHandler.showSuccessSnackbar('Tizimdan muvaffaqiyatli chiqildi');

      // Navigate to landing page
      AppRoutes.toLanding();

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Forgot password method
  Future<void> forgotPassword(String phoneNumber) async {
    try {
      _isLoading.value = true;

      await ApiService.post('/auth/forgot-password', {
        'phone_number': phoneNumber
      }, includeAuth: false);

      ErrorHandler.showSuccessSnackbar('Parolni tiklash kodi SMS orqali yuborildi');

    } catch (e) {
      String errorMessage = 'Parolni tiklashda xatolik yuz berdi';

      if (e.toString().contains('404')) {
        errorMessage = 'Bu telefon raqami ro\'yxatdan o\'tmagan';
      } else if (e.toString().contains('network')) {
        errorMessage = AppConstants.networkError;
      }

      ErrorHandler.showErrorSnackbar(errorMessage);
    } finally {
      _isLoading.value = false;
    }
  }

  // Update profile method
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      _isLoading.value = true;

      final userId = _currentUser.value?.id;
      if (userId == null) throw Exception('Foydalanuvchi topilmadi');

      final response = await ApiService.put('/users/$userId', profileData);

      final updatedUserData = response['user'] as Map<String, dynamic>?;
      if (updatedUserData != null) {
        final updatedUser = User.fromJson(updatedUserData);
        await StorageService.saveUserData(updatedUserData);
        _currentUser.value = updatedUser;
      }

      ErrorHandler.showSuccessSnackbar('Profil muvaffaqiyatli yangilandi');

    } catch (e) {
      ErrorHandler.showErrorSnackbar('Profilni yangilashda xatolik yuz berdi');
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

      ErrorHandler.showSuccessSnackbar('Parol muvaffaqiyatli o\'zgartirildi');

    } catch (e) {
      String errorMessage = 'Parolni o\'zgartirishda xatolik yuz berdi';

      if (e.toString().contains('401')) {
        errorMessage = 'Joriy parol noto\'g\'ri';
      } else if (e.toString().contains('network')) {
        errorMessage = AppConstants.networkError;
      }

      ErrorHandler.showErrorSnackbar(errorMessage);
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

  // Check payment status
  Future<void> checkPaymentStatus() async {
    try {
      final userId = _currentUser.value?.id;
      if (userId == null) return;

      final response = await ApiService.get('/users/$userId/payment-status');
      final isPaid = response['is_paid'] as bool? ?? false;

      if (_currentUser.value != null) {
        final updatedUser = _currentUser.value!.copyWith(isPaid: isPaid);
        _currentUser.value = updatedUser;

        // Update stored user data
        await StorageService.saveUserData(updatedUser.toJson());

        // Navigate based on payment status
        if (isPaid) {
          AppRoutes.toHome();
        } else {
          AppRoutes.toPayment();
        }
      }

    } catch (e) {
      print('Payment status check failed: $e');
    }
  }

  // Get user display name
  String get userName {
    return _currentUser.value?.fullName ?? 'Foydalanuvchi';
  }

  // Get user initials for avatar
  String get userInitials {
    return _currentUser.value?.initials ?? 'F';
  }

  // Get formatted phone number
  String get userPhone {
    return _currentUser.value?.formattedPhone ?? '';
  }

  // Check if user has paid subscription
  bool get hasActivePlan {
    return _currentUser.value?.isPaid ?? false;
  }

  // Get user avatar URL
  String? get userAvatarUrl {
    return _currentUser.value?.avatarUrl;
  }

  // Upload profile picture
  Future<void> uploadProfilePicture(String imagePath) async {
    try {
      _isLoading.value = true;

      final userId = _currentUser.value?.id;
      if (userId == null) throw Exception('Foydalanuvchi topilmadi');

      // This would typically upload the image to a file storage service
      // and return the URL. For now, we'll simulate it.
      final response = await ApiService.post('/users/$userId/avatar', {
        'image_path': imagePath, // In real implementation, this would be form data
      });

      final avatarUrl = response['avatar_url'] as String?;
      if (avatarUrl != null && _currentUser.value != null) {
        final updatedUser = _currentUser.value!.copyWith(avatarUrl: avatarUrl);
        _currentUser.value = updatedUser;
        await StorageService.saveUserData(updatedUser.toJson());
      }

      ErrorHandler.showSuccessSnackbar('Profil rasmi yangilandi');

    } catch (e) {
      ErrorHandler.showErrorSnackbar('Rasm yuklashda xatolik yuz berdi');
    } finally {
      _isLoading.value = false;
    }
  }
}
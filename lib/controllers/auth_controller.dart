// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/api_response_models.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();
  final _isLoading = false.obs;
  final _isLoggedIn = false.obs;
  final _loginSession = Rxn<LoginSession>();
  final _currentStudent = Rxn<Student>();
  final _availableStudents = <Student>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  LoginSession? get loginSession => _loginSession.value;
  Student? get currentStudent => _currentStudent.value;
  List<Student> get availableStudents => _availableStudents;

  String get currentPhoneNumber => _loginSession.value?.phoneNumber ?? '';
  String get currentSmsCodeId => _loginSession.value?.smsCodeId ?? '';
  AuthState get currentAuthState => _loginSession.value?.state ?? AuthState.initial;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final token = _storage.read('auth_token');
    final studentData = _storage.read('current_student');

    if (token != null && studentData != null) {
      try {
        _currentStudent.value = Student.fromJson(Map<String, dynamic>.from(studentData));
        _isLoggedIn.value = true;

        // Set token and student ID in API service
        ApiService.setAuthToken(token);
        ApiService.setCurrentStudentId(_currentStudent.value!.id);
      } catch (e) {
        // Clear corrupted data
        logout();
      }
    }
  }

  // Step 1: Check phone number
  Future<void> checkPhoneNumber(String phoneNumber) async {
    try {
      _isLoading.value = true;

      // Format phone number to ensure consistency
      String formattedPhone = _formatPhoneNumber(phoneNumber);
      print('🔍 Formatted phone: $formattedPhone');

      final response = await ApiService.checkPhoneNumber(formattedPhone);
      print('🔍 Phone check response hasPassword: ${response.hasPassword}');

      if (response.hasPassword) {
        print('✅ Has password - navigating to password entry');
        _loginSession.value = LoginSession(
          phoneNumber: formattedPhone,
          state: AuthState.phoneChecked,
        );

        Get.toNamed('/password-entry');
      } else {
        print('❌ No password - showing dialog');
        // Phone number exists but no password set, or doesn't exist
        _showPhoneNotFoundDialog(formattedPhone);
      }

    } catch (e) {
      String errorMessage = 'Telefon raqamni tekshirishda xatolik';

      if (e.toString().contains('Network error')) {
        errorMessage = 'Internet aloqasi yo\'q';
      } else if (e.toString().contains('Phone check failed')) {
        // Phone number not found - offer registration
        _showPhoneNotFoundDialog(_formatPhoneNumber(phoneNumber));
        return;
      }

      Get.snackbar(
        'Xatolik',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _showPhoneNotFoundDialog(String phoneNumber) {
    Get.dialog(
      AlertDialog(
        title: const Text('Server xatoligi'),
        content: Text(
          'Backend serverida xatolik yuz berdi.\n\n'
              'Bu test akkaunt ($phoneNumber) uchun backend jamoasi bilan bog\'laning.\n\n'
              'Error Code: 3000\n'
              'Status: 500 Internal Server Error',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Orqaga'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Use mock data for now
              _useMockDataForTesting();
            },
            child: const Text('Mock data bilan davom etish'),
          ),
        ],
      ),
    );
  }

  void _useMockDataForTesting() {
    Get.snackbar(
      'Mock Mode',
      'Backend tayyorlanguncha mock data ishlatilmoqda',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );

    // Simulate successful login with mock data
    legacyLogin('+998935808840', 'Test123!');
  }

  // Step 2: Enter password
  Future<void> enterPassword(String password) async {
    if (_loginSession.value?.state != AuthState.phoneChecked) {
      Get.snackbar('Xatolik', 'Avval telefon raqamni tekshiring');
      return;
    }

    try {
      _isLoading.value = true;

      final response = await ApiService.enterPassword(
        _loginSession.value!.phoneNumber,
        password,
      );

      if (response.success && response.smsCodeId.isNotEmpty) {
        _loginSession.value = _loginSession.value!.copyWith(
          smsCodeId: response.smsCodeId,
          state: AuthState.smsCodeSent,
        );

        Get.toNamed('/sms-verification');

        Get.snackbar(
          'SMS yuborildi',
          'Telefon raqamingizga tasdiqlash kodi yuborildi',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Xatolik',
          'Parol noto\'g\'ri yoki SMS yuborishda xatolik',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      String errorMessage = 'Parolni tekshirishda xatolik';

      if (e.toString().contains('Network error')) {
        errorMessage = 'Internet aloqasi yo\'q';
      } else if (e.toString().contains('Password verification failed')) {
        errorMessage = 'Parol noto\'g\'ri';
      }

      Get.snackbar(
        'Xatolik',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Step 3: Verify SMS code
  Future<void> verifySmsCode(String smsCode) async {
    if (_loginSession.value?.state != AuthState.smsCodeSent) {
      Get.snackbar('Xatolik', 'Avval parolni kiriting');
      return;
    }

    try {
      _isLoading.value = true;

      final response = await ApiService.verifySmsCode(
        smsCodeId: _loginSession.value!.smsCodeId!,
        smsCode: smsCode,
        phoneNumber: _loginSession.value!.phoneNumber,
      );

      if (response.success && response.token.isNotEmpty) {
        // Save token
        await _storage.write('auth_token', response.token);
        ApiService.setAuthToken(response.token);

        if (response.students.length == 1) {
          // Single student - login directly
          final student = response.students.first;
          await _completeLogin(student);
        } else if (response.students.length > 1) {
          // Multiple students - show selection
          _availableStudents.value = response.students;
          _loginSession.value = _loginSession.value!.copyWith(
            students: response.students,
            state: AuthState.multipleStudents,
          );
          Get.toNamed('/student-selection');
        } else {
          Get.snackbar(
            'Xatolik',
            'Hech qanday o\'quvchi topilmadi',
            snackPosition: SnackPosition.BOTTOM,
          );
        }

      } else {
        Get.snackbar(
          'Xatolik',
          'SMS kod noto\'g\'ri yoki muddati tugagan',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      String errorMessage = 'SMS kodni tekshirishda xatolik';

      if (e.toString().contains('Network error')) {
        errorMessage = 'Internet aloqasi yo\'q';
      } else if (e.toString().contains('SMS verification failed')) {
        errorMessage = 'SMS kod noto\'g\'ri';
      }

      Get.snackbar(
        'Xatolik',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Select student (for multiple students case)
  Future<void> selectStudent(String studentId) async {
    final student = _availableStudents.firstWhereOrNull(
          (s) => s.id == studentId,
    );

    if (student != null) {
      await _completeLogin(student);
    } else {
      Get.snackbar(
        'Xatolik',
        'O\'quvchi topilmadi',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Complete login process
  Future<void> _completeLogin(Student student) async {
    try {
      // Save student data
      await _storage.write('current_student', student.toJson());

      // Set current student
      _currentStudent.value = student;
      _isLoggedIn.value = true;

      // Set student ID in API service
      ApiService.setCurrentStudentId(student.id);

      // Update login session
      _loginSession.value = _loginSession.value?.copyWith(
        selectedStudentId: student.id,
        state: AuthState.authenticated,
      );

      Get.snackbar(
        'Muvaffaqiyat',
        'Tizimga muvaffaqiyatli kirdingiz',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/home');

    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Login jarayonini tugatishda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Legacy login method (for development/testing)
  Future<void> legacyLogin(String phoneNumber, String password) async {
    // This method is deprecated - use the new 3-step authentication flow
    // Start with phone number check
    await checkPhoneNumber(phoneNumber);
  }

  // Logout
  Future<void> logout() async {
    await _storage.erase();
    _isLoggedIn.value = false;
    _currentStudent.value = null;
    _loginSession.value = null;
    _availableStudents.clear();

    // Clear API service data
    ApiService.clearAuthData();

    Get.offAllNamed('/landing');

    Get.snackbar(
      'Chiqish',
      'Tizimdan muvaffaqiyatli chiqdingiz',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Utility methods
  String get userName => _currentStudent.value?.fullName ?? 'Foydalanuvchi';
  String get userInitials => _currentStudent.value?.initials ?? 'U';
  String get userPhone => _currentStudent.value?.phoneNumber ?? '';
  String get currentStudentId => _currentStudent.value?.id ?? '';

  String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If starts with 998, use as is with +
    if (digitsOnly.startsWith('998')) {
      return '+$digitsOnly';
    }

    // If 9 digits, add +998
    if (digitsOnly.length == 9) {
      return '+998$digitsOnly';
    }

    // If 12 digits starting with 998, add +
    if (digitsOnly.length == 12 && digitsOnly.startsWith('998')) {
      return '+$digitsOnly';
    }

    // Try without + sign for testing
    if (digitsOnly.length == 12) {
      return digitsOnly;
    }

    // Otherwise, assume it's already formatted
    return phoneNumber;
  }

  // Reset auth session (for starting over)
  void resetAuthSession() {
    _loginSession.value = null;
    _availableStudents.clear();
  }
}
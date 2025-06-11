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

        print('✅ Auto-login successful for: ${_currentStudent.value!.fullName}');
      } catch (e) {
        print('❌ Auto-login failed, clearing corrupted data: $e');
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
      print('🔍 Checking phone: $formattedPhone');

      final response = await ApiService.checkPhoneNumber(formattedPhone);
      print('🔍 Phone check response hasPassword: ${response.hasPassword}');

      if (response.hasPassword) {
        print('✅ Phone has password - proceeding to password entry');
        _loginSession.value = LoginSession(
          phoneNumber: formattedPhone,
          state: AuthState.phoneChecked,
        );

        Get.toNamed('/password-entry');
      } else {
        print('❌ Phone does not have password set');
        Get.snackbar(
          'Telefon raqam topilmadi',
          'Bu telefon raqam tizimda ro\'yxatdan o\'tmagan yoki parol o\'rnatilmagan.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }

    } catch (e) {
      String errorMessage = 'Telefon raqamni tekshirishda xatolik';

      if (e.toString().contains('Network error') || e.toString().contains('SocketException')) {
        errorMessage = 'Internet aloqasi yo\'q. Iltimos, internetni tekshiring.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Server javob bermayapti. Iltimos, qaytadan urinib ko\'ring.';
      } else if (e.toString().contains('Phone check failed') ||
          e.toString().contains('400') ||
          e.toString().contains('404')) {
        errorMessage = 'Telefon raqam tizimda topilmadi. Iltimos, to\'g\'ri raqam kiritganingizni tekshiring.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server xatoligi. Iltimos, keyinroq qaytadan urinib ko\'ring.';
      }

      print('❌ Phone check error: $e');

      Get.snackbar(
        'Xatolik',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      _isLoading.value = false;
    }
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

        print('✅ Password correct, SMS sent. SMS Code ID: ${response.smsCodeId}');

        Get.toNamed('/sms-verification');

        Get.snackbar(
          'SMS yuborildi',
          'Telefon raqamingizga 6 xonali tasdiqlash kodi yuborildi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        print('❌ Password verification failed');
        Get.snackbar(
          'Parol noto\'g\'ri',
          'Kiritilgan parol noto\'g\'ri. Iltimos, qaytadan urinib ko\'ring.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }

    } catch (e) {
      String errorMessage = 'Parolni tekshirishda xatolik';

      if (e.toString().contains('Network error') || e.toString().contains('SocketException')) {
        errorMessage = 'Internet aloqasi yo\'q. Iltimos, internetni tekshiring.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Server javob bermayapti. Iltimos, qaytadan urinib ko\'ring.';
      } else if (e.toString().contains('Password verification failed') ||
          e.toString().contains('401')) {
        errorMessage = 'Parol noto\'g\'ri. Iltimos, to\'g\'ri parolni kiriting.';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Ma\'lumotlar noto\'g\'ri. Iltimos, qaytadan urinib ko\'ring.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server xatoligi. Iltimos, keyinroq qaytadan urinib ko\'ring.';
      }

      print('❌ Password verification error: $e');

      Get.snackbar(
        'Xatolik',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
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
        print('✅ SMS verification successful');

        // Save token (API service will handle Bearer prefix)
        await _storage.write('auth_token', response.token);
        ApiService.setAuthToken(response.token);

        if (response.students.length == 1) {
          // Single student - login directly
          final student = response.students.first;
          print('✅ Single student found: ${student.fullName}');
          await _completeLogin(student);
        } else if (response.students.length > 1) {
          // Multiple students - show selection
          print('✅ Multiple students found: ${response.students.length}');
          _availableStudents.value = response.students;
          _loginSession.value = _loginSession.value!.copyWith(
            students: response.students,
            state: AuthState.multipleStudents,
          );
          Get.toNamed('/student-selection');
        } else {
          print('❌ No students found');
          Get.snackbar(
            'Xatolik',
            'Hech qanday o\'quvchi topilmadi. Iltimos, admin bilan bog\'laning.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }

      } else {
        print('❌ SMS verification failed');
        Get.snackbar(
          'SMS kod noto\'g\'ri',
          'Kiritilgan SMS kod noto\'g\'ri yoki muddati tugagan. Iltimos, qaytadan urinib ko\'ring.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }

    } catch (e) {
      String errorMessage = 'SMS kodni tekshirishda xatolik';

      if (e.toString().contains('Network error') || e.toString().contains('SocketException')) {
        errorMessage = 'Internet aloqasi yo\'q. Iltimos, internetni tekshiring.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Server javob bermayapti. Iltimos, qaytadan urinib ko\'ring.';
      } else if (e.toString().contains('SMS verification failed') ||
          e.toString().contains('400') ||
          e.toString().contains('401')) {
        errorMessage = 'SMS kod noto\'g\'ri yoki muddati tugagan. Iltimos, qaytadan urinib ko\'ring.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server xatoligi. Iltimos, keyinroq qaytadan urinib ko\'ring.';
      }

      print('❌ SMS verification error: $e');

      Get.snackbar(
        'Xatolik',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
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
      print('✅ Student selected: ${student.fullName} (${student.id})');
      await _completeLogin(student);
    } else {
      Get.snackbar(
        'Xatolik',
        'O\'quvchi topilmadi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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

      print('✅ Login completed for: ${student.fullName}');

      Get.snackbar(
        'Muvaffaqiyat!',
        '${student.fullName}, tizimga xush kelibsiz!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to home and clear all previous routes
      Get.offAllNamed('/home');

    } catch (e) {
      print('❌ Login completion error: $e');
      Get.snackbar(
        'Xatolik',
        'Login jarayonini tugatishda xatolik yuz berdi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      print('🚪 Logging out user: ${_currentStudent.value?.fullName ?? "Unknown"}');

      // Clear all stored data
      await _storage.erase();

      // Reset reactive state
      _isLoggedIn.value = false;
      _currentStudent.value = null;
      _loginSession.value = null;
      _availableStudents.clear();

      // Clear API service data
      ApiService.clearAuthData();

      // Navigate to landing page
      Get.offAllNamed('/landing');

      Get.snackbar(
        'Chiqish',
        'Tizimdan muvaffaqiyatli chiqdingiz',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      print('✅ Logout completed');
    } catch (e) {
      print('❌ Logout error: $e');
      // Even if logout fails, clear everything and redirect
      _isLoggedIn.value = false;
      _currentStudent.value = null;
      _loginSession.value = null;
      _availableStudents.clear();
      ApiService.clearAuthData();
      Get.offAllNamed('/landing');
    }
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

    // Otherwise, assume it's already formatted
    return phoneNumber;
  }

  // Reset auth session (for starting over)
  void resetAuthSession() {
    _loginSession.value = null;
    _availableStudents.clear();
    print('🔄 Auth session reset');
  }
}
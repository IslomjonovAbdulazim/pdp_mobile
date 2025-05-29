// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';
import '../data/models/models.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();
  final _isLoading = false.obs;
  final _isLoggedIn = false.obs;
  final _currentUser = Rxn<Person>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  Person? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final userData = _storage.read('user_data');
    final token = _storage.read('auth_token');

    if (userData != null && token != null) {
      try {
        _currentUser.value = Person.fromJson(Map<String, dynamic>.from(userData));
        _isLoggedIn.value = true;
      } catch (e) {
        // Clear corrupted data
        logout();
      }
    }
  }

  Future<void> login(String phoneNumber, String password) async {
    try {
      _isLoading.value = true;

      // For development, use mock login
      if (phoneNumber == '+998901234567' && password == '123456') {
        final mockUser = Person(
          fullName: 'John Doe',
          phoneNumber: phoneNumber,
          avatarUrl: null,
        );

        await _storage.write('auth_token', 'mock_token_123');
        await _storage.write('user_data', mockUser.toJson());

        _currentUser.value = mockUser;
        _isLoggedIn.value = true;

        Get.snackbar(
          'Muvaffaqiyat',
          'Tizimga muvaffaqiyatli kirdingiz',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAllNamed('/home');
        return;
      }

      // Real API call (when backend is ready)
      final response = await ApiService.login(phoneNumber, password);

      final token = response['token'];
      final userData = response['user'];

      if (token != null && userData != null) {
        final user = Person.fromJson(userData);

        await _storage.write('auth_token', token);
        await _storage.write('user_data', userData);

        _currentUser.value = user;
        _isLoggedIn.value = true;

        Get.snackbar(
          'Muvaffaqiyat',
          'Tizimga muvaffaqiyatli kirdingiz',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAllNamed('/home');
      }

    } catch (e) {
      String errorMessage = 'Login xatolik yuz berdi';

      if (e.toString().contains('Network error')) {
        errorMessage = 'Internet aloqasi yo\'q';
      } else if (e.toString().contains('Login failed')) {
        errorMessage = 'Telefon raqami yoki parol noto\'g\'ri';
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

  Future<void> logout() async {
    await _storage.erase();
    _isLoggedIn.value = false;
    _currentUser.value = null;

    Get.offAllNamed('/landing');

    Get.snackbar(
      'Chiqish',
      'Tizimdan muvaffaqiyatli chiqdingiz',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String get userName => _currentUser.value?.fullName ?? 'Foydalanuvchi';
  String get userInitials => _currentUser.value?.initials ?? 'U';
  String get userPhone => _currentUser.value?.phoneNumber ?? '';
}
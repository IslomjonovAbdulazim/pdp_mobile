import 'package:get_storage/get_storage.dart';
import '../core/app_constants.dart';

class StorageService {
  static final GetStorage _box = GetStorage();

  // Initialize storage
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Auth Token Methods
  static Future<void> saveToken(String token) async {
    await _box.write(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return _box.read(AppConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await _box.remove(AppConstants.tokenKey);
  }

  // User Data Methods
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _box.write(AppConstants.userKey, userData);
  }

  static Map<String, dynamic>? getUserData() {
    return _box.read(AppConstants.userKey);
  }

  static Future<void> removeUserData() async {
    await _box.remove(AppConstants.userKey);
  }

  // Login Status Methods
  static Future<void> setLoggedIn(bool status) async {
    await _box.write(AppConstants.isLoggedInKey, status);
  }

  static bool isLoggedIn() {
    return _box.read(AppConstants.isLoggedInKey) ?? false;
  }

  // Generic Methods
  static Future<void> saveData(String key, dynamic value) async {
    await _box.write(key, value);
  }

  static T? getData<T>(String key) {
    return _box.read(key);
  }

  static Future<void> removeData(String key) async {
    await _box.remove(key);
  }

  static Future<void> clearAll() async {
    await _box.erase();
  }

  // Check if key exists
  static bool hasData(String key) {
    return _box.hasData(key);
  }
}
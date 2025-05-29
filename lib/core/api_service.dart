import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_constants.dart';
import '../core/storage_service.dart';
import '../core/error_handler.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  // Get headers with authentication
  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint, {bool includeAuth = true}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.get(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      ErrorHandler.logError('GET $endpoint failed', e);
      throw _handleException(e);
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> data, {
        bool includeAuth = true,
      }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.post(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
        body: jsonEncode(data),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      ErrorHandler.logError('POST $endpoint failed', e);
      throw _handleException(e);
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
      String endpoint,
      Map<String, dynamic> data, {
        bool includeAuth = true,
      }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.put(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
        body: jsonEncode(data),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      ErrorHandler.logError('PUT $endpoint failed', e);
      throw _handleException(e);
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint, {bool includeAuth = true}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.delete(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      ErrorHandler.logError('DELETE $endpoint failed', e);
      throw _handleException(e);
    }
  }

  // Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          ErrorHandler.handleHttpError(response.statusCode),
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Invalid response format', response.statusCode);
    }
  }

  // Handle exceptions
  static Exception _handleException(dynamic error) {
    if (error is ApiException) {
      return error;
    } else {
      return ApiException(ErrorHandler.handleNetworkError(error), 0);
    }
  }

  // Auth specific methods
  static Future<Map<String, dynamic>> login(String email, String password) async {
    return await post(AppConstants.loginEndpoint, {
      'email': email,
      'password': password,
    }, includeAuth: false);
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await post(AppConstants.registerEndpoint, userData, includeAuth: false);
  }

  // Student specific methods
  static Future<Map<String, dynamic>> getStudents() async {
    return await get(AppConstants.studentsEndpoint);
  }

  static Future<Map<String, dynamic>> getStudent(String id) async {
    return await get('${AppConstants.studentsEndpoint}/$id');
  }

  // Attendance specific methods
  static Future<Map<String, dynamic>> getAttendance() async {
    return await get(AppConstants.attendanceEndpoint);
  }

  static Future<Map<String, dynamic>> markAttendance(Map<String, dynamic> data) async {
    return await post(AppConstants.attendanceEndpoint, data);
  }

  // Exam specific methods
  static Future<Map<String, dynamic>> getExams() async {
    return await get(AppConstants.examsEndpoint);
  }

  static Future<Map<String, dynamic>> getExam(String id) async {
    return await get('${AppConstants.examsEndpoint}/$id');
  }

  // Homework specific methods
  static Future<Map<String, dynamic>> getHomework() async {
    return await get(AppConstants.homeworkEndpoint);
  }

  static Future<Map<String, dynamic>> submitHomework(Map<String, dynamic> data) async {
    return await post(AppConstants.homeworkEndpoint, data);
  }
}

// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
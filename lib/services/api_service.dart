// lib/services/api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/models/api_response_models.dart';
import '../data/models/models.dart';

class ApiService {
  static const String baseUrl = 'http://185.74.5.104:8080/api';
  static const Duration timeout = Duration(seconds: 30);

  static String? _authToken;
  static String? _currentStudentId;

  static void setAuthToken(String token) {
    // Store token without "Bearer" prefix - we'll add it in headers
    _authToken = token.replaceFirst('Bearer ', '');
    print('🔑 Auth token set: ${_authToken?.substring(0, 20)}...');
  }

  static void setCurrentStudentId(String studentId) {
    _currentStudentId = studentId;
    print('👤 Current student ID set: $studentId');
  }

  static Map<String, String> _getHeaders({bool needsAuth = false}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add Authorization header for authenticated endpoints
    if (needsAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // ==================== AUTH ENDPOINTS ====================

  /// Step 1: Check if phone number exists and has password
  /// Backend: Bu yo'lga RequestBody da telefon raqam berib yuborasz,
  /// agar telefon bazada bo'lsa va uni passwordi bo'lsa {"hasPassword" : true} qaytaradi.
  static Future<PhoneCheckResponse> checkPhoneNumber(String phoneNumber) async {
    try {
      print('🔍 Checking phone number: $phoneNumber');

      final requestBody = {'phoneNumber': phoneNumber};

      print('📤 POST $baseUrl/auth/v1/junior-app/login');
      print('📤 Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/v1/junior-app/login'),
            headers: _getHeaders(needsAuth: false),
            body: jsonEncode(requestBody),
          )
          .timeout(timeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final phoneCheckResponse = PhoneCheckResponse.fromJson(data);
        print(
          '✅ Phone check successful - hasPassword: ${phoneCheckResponse.hasPassword}',
        );
        return phoneCheckResponse;
      } else {
        print('❌ Phone check failed: ${response.statusCode}');
        throw Exception(
          'Phone check failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in checkPhoneNumber: $e');
      throw Exception('Network error during phone check: $e');
    }
  }

  /// Step 2: Enter password and get SMS code
  /// Backend: phoneNumber bo'lsa va password to'g'ri bo'lsa sms code yuboradi telefon raqamga,
  /// szga bo'lsa kerakli malumotlarni yuboradi
  static Future<PasswordResponse> enterPassword(
    String phoneNumber,
    String password,
  ) async {
    try {
      print('🔐 Entering password for: $phoneNumber');

      final requestBody = {'phoneNumber': phoneNumber, 'password': password};

      print('📤 POST $baseUrl/auth/v1/junior-app/enter-password');
      print('📤 Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/v1/junior-app/enter-password'),
            headers: _getHeaders(needsAuth: false),
            body: jsonEncode(requestBody),
          )
          .timeout(timeout);

      print('📥 Password response status: ${response.statusCode}');
      print('📥 Password response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final passwordResponse = PasswordResponse.fromJson(data);
        print(
          '✅ Password verification successful - SMS Code ID: ${passwordResponse.smsCodeId}',
        );
        return passwordResponse;
      } else {
        print('❌ Password verification failed: ${response.statusCode}');
        throw Exception(
          'Password verification failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in enterPassword: $e');
      throw Exception('Network error during password verification: $e');
    }
  }

  /// Step 3: Verify SMS code and get token + students
  /// Backend: agar barcha malumotlar to'g'ri bo'lsa szga token va studentlarni berib yuboradi.
  /// token va studentlarni ichidagi bittasidan studentId orqali kerakli malumotlarni olish uchun murojaat qilasz
  static Future<SmsVerificationResponse> verifySmsCode({
    required String smsCodeId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    try {
      print('📱 Verifying SMS code: $smsCode');
      print('📱 SMS Code ID: $smsCodeId');
      print('📱 Phone: $phoneNumber');

      final requestBody = {
        'smsCodeId': smsCodeId,
        'smsCode': smsCode,
        'phoneNumber': phoneNumber,
      };

      print('📤 POST $baseUrl/auth/v1/junior-app/chek-sms-code');
      print('📤 Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/v1/junior-app/chek-sms-code'),
            headers: _getHeaders(needsAuth: false),
            body: jsonEncode(requestBody),
          )
          .timeout(timeout);

      print('📥 SMS verification status: ${response.statusCode}');
      print('📥 SMS verification body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final smsResponse = SmsVerificationResponse.fromJson(data);
        print('✅ SMS verification success: ${smsResponse.success}');
        print(
          '✅ Token received: ${smsResponse.token.isNotEmpty ? "Yes" : "No"}',
        );
        print('✅ Students count: ${smsResponse.students.length}');

        for (int i = 0; i < smsResponse.students.length; i++) {
          print(
            '✅ Student $i: ${smsResponse.students[i].fullName} (ID: ${smsResponse.students[i].id})',
          );
        }

        return smsResponse;
      } else {
        print('❌ SMS verification failed: ${response.statusCode}');
        throw Exception(
          'SMS verification failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in verifySmsCode: $e');
      throw Exception('Network error during SMS verification: $e');
    }
  }

  // ==================== EDUCATION ENDPOINTS ====================
  // Backend: api/education/v1/...lardagi barcha {{studentId}} lar PathVariable da keladi.

  /// Get home dashboard data
  /// Backend: Szga kerakli barcha malumotlarni olib keladigan yo'l.
  static Future<HomeDataResponse> getHomeData(String studentId) async {
    try {
      print('🏠 Fetching home data for student: $studentId');

      final url = '$baseUrl/education/v1/academy-app/home-student/$studentId';
      print('📤 GET $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders(needsAuth: true))
          .timeout(timeout);

      print('📥 Home data response status: ${response.statusCode}');
      print('📥 Home data response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HomeDataResponse.fromJson(data);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Authentication failed: ${response.statusCode} - Please login again',
        );
      } else {
        throw Exception(
          'Failed to load home data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getHomeData: $e');
      throw Exception('Network error while loading home data: $e');
    }
  }

  /// Get payment history
  /// Backend: paymentlarni barchasini olib keladi
  static Future<List<Payment>> getPaymentHistory(String studentId) async {
    try {
      print('💰 Fetching payment history for student: $studentId');

      final url =
          '$baseUrl/education/v1/academy-app/payment-history/$studentId';
      print('📤 GET $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders(needsAuth: true))
          .timeout(timeout);

      print('📥 Payment history response status: ${response.statusCode}');
      print('📥 Payment history response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle different possible response structures
        List<dynamic> paymentsData = [];

        if (data is List) {
          paymentsData = data;
        } else if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) {
            paymentsData = data['data'];
          } else if (data.containsKey('payments') && data['payments'] is List) {
            paymentsData = data['payments'];
          }
        }

        return paymentsData.map((json) => Payment.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Authentication failed: ${response.statusCode} - Please login again',
        );
      } else {
        throw Exception(
          'Failed to load payment history: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getPaymentHistory: $e');
      throw Exception('Network error while loading payment history: $e');
    }
  }

  /// Get exam history
  /// Backend: barcha exam larni olib keladi.
  static Future<List<Exam>> getExamHistory(String studentId) async {
    try {
      print('📝 Fetching exam history for student: $studentId');

      final url = '$baseUrl/education/v1/academy-app/exam-history/$studentId';
      print('📤 GET $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders(needsAuth: true))
          .timeout(timeout);

      print('📥 Exam history response status: ${response.statusCode}');
      print('📥 Exam history response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle different possible response structures
        List<dynamic> examsData = [];

        if (data is List) {
          examsData = data;
        } else if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) {
            examsData = data['data'];
          } else if (data.containsKey('exams') && data['exams'] is List) {
            examsData = data['exams'];
          }
        }

        return examsData.map((json) => Exam.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Authentication failed: ${response.statusCode} - Please login again',
        );
      } else {
        throw Exception(
          'Failed to load exam history: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getExamHistory: $e');
      throw Exception('Network error while loading exam history: $e');
    }
  }

  /// Get homework history
  /// Backend: Barcha homeworklarni olib keladi
  static Future<List<Homework>> getHomeworkHistory(String studentId) async {
    try {
      print('📚 Fetching homework history for student: $studentId');

      final url =
          '$baseUrl/education/v1/academy-app/homework-history/$studentId';
      print('📤 GET $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders(needsAuth: true))
          .timeout(timeout);

      print('📥 Homework history response status: ${response.statusCode}');
      print('📥 Homework history response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle different possible response structures
        List<dynamic> homeworkData = [];

        if (data is List) {
          homeworkData = data;
        } else if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) {
            homeworkData = data['data'];
          } else if (data.containsKey('homework') && data['homework'] is List) {
            homeworkData = data['homework'];
          }
        }

        return homeworkData.map((json) => Homework.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Authentication failed: ${response.statusCode} - Please login again',
        );
      } else {
        throw Exception(
          'Failed to load homework history: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getHomeworkHistory: $e');
      throw Exception('Network error while loading homework history: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  static void clearAuthData() {
    _authToken = null;
    _currentStudentId = null;
    print('🧹 Auth data cleared');
  }

  static String? get currentToken => _authToken;

  static String? get currentStudentId => _currentStudentId;
}

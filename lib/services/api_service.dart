// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/api_response_model.dart';
import '../data/models/models.dart';
import '../data/models/auth_models.dart';

class ApiService {
  static const String baseUrl = 'http://185.74.5.104:8080/api';
  static const Duration timeout = Duration(seconds: 30);

  static String? _authToken;
  static String? _currentStudentId;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void setCurrentStudentId(String studentId) {
    _currentStudentId = studentId;
  }

  static Map<String, String> _getHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // ==================== AUTH ENDPOINTS ====================

  /// Step 1: Check if phone number exists and has password
  static Future<PhoneCheckResponse> checkPhoneNumber(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/v1/junior-app/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PhoneCheckResponse.fromJson(data);
      } else {
        throw Exception('Phone check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during phone check: $e');
    }
  }

  /// Step 2: Enter password and get SMS code
  static Future<PasswordResponse> enterPassword(String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/v1/junior-app/enter-password'),
        headers: _getHeaders(),
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PasswordResponse.fromJson(data);
      } else {
        throw Exception('Password verification failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during password verification: $e');
    }
  }

  /// Step 3: Verify SMS code and get token + students
  static Future<SmsVerificationResponse> verifySmsCode({
    required String smsCodeId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/v1/junior-app/chek-sms-code'),
        headers: _getHeaders(),
        body: jsonEncode({
          'smsCodeId': smsCodeId,
          'smsCode': smsCode,
          'phoneNumber': phoneNumber,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SmsVerificationResponse.fromJson(data);
      } else {
        throw Exception('SMS verification failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during SMS verification: $e');
    }
  }

  // ==================== EDUCATION ENDPOINTS ====================

  /// Get home dashboard data
  static Future<HomeDataResponse> getHomeData(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/education/v1/academy-app/home-student/$studentId'),
        headers: _getHeaders(),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HomeDataResponse.fromJson(data);
      } else {
        throw Exception('Failed to load home data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while loading home data: $e');
    }
  }

  /// Get payment history
  static Future<List<Payment>> getPaymentHistory(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/education/v1/academy-app/payment-history/$studentId'),
        headers: _getHeaders(),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the API returns a list or an object with payments array
        if (data is List) {
          return data.map((json) => Payment.fromJson(json)).toList();
        } else if (data is Map && data.containsKey('payments')) {
          final List<dynamic> paymentsList = data['payments'] ?? [];
          return paymentsList.map((json) => Payment.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load payment history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while loading payment history: $e');
    }
  }

  /// Get exam history
  static Future<List<Exam>> getExamHistory(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/education/v1/academy-app/exam-history/$studentId'),
        headers: _getHeaders(),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the API returns a list or an object with exams array
        if (data is List) {
          return data.map((json) => Exam.fromJson(json)).toList();
        } else if (data is Map && data.containsKey('exams')) {
          final List<dynamic> examsList = data['exams'] ?? [];
          return examsList.map((json) => Exam.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load exam history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while loading exam history: $e');
    }
  }

  /// Get homework history
  static Future<List<Homework>> getHomeworkHistory(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/education/v1/academy-app/homework-history/$studentId'),
        headers: _getHeaders(),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the API returns a list or an object with homework array
        if (data is List) {
          return data.map((json) => Homework.fromJson(json)).toList();
        } else if (data is Map && data.containsKey('homework')) {
          final List<dynamic> homeworkList = data['homework'] ?? [];
          return homeworkList.map((json) => Homework.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load homework history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while loading homework history: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  static void clearAuthData() {
    _authToken = null;
    _currentStudentId = null;
  }

  // ==================== MOCK DATA (for development fallback) ====================

  static Future<Map<String, dynamic>> getMockHomeData() async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();

    return {
      'person': {
        'fullName': 'John Doe',
        'phoneNumber': '+998901234567',
        'avatarUrl': null,
      },
      'course': {
        'title': 'Flutter Development',
        'schedule': '15:00-18:00, toq kunlari',
      },
      'recentExams': [
        {
          'score': 85,
          'date': '2024-01-15',
          'status': true,
        },
        {
          'score': 92,
          'date': '2024-01-20',
          'status': true,
        },
        {
          'score': 67,
          'date': '2024-01-25',
          'status': false,
        },
      ],
      'recentPayments': [
        {
          'date': now.subtract(const Duration(days: 30)).toIso8601String(),
          'amount': 500000,
        },
        {
          'date': now.subtract(const Duration(days: 60)).toIso8601String(),
          'amount': 500000,
        },
        {
          'date': now.subtract(const Duration(days: 90)).toIso8601String(),
          'amount': 450000,
        },
      ],
      'recentHomework': [
        {
          'title': 'Flutter Widgets Assignment',
          'description': 'Create a todo app using Flutter widgets',
          'isSubmitted': true,
          'deadline': now.add(const Duration(days: 5)).toIso8601String(),
          'score': 88,
        },
        {
          'title': 'State Management Task',
          'description': 'Implement state management in your app',
          'isSubmitted': false,
          'deadline': now.add(const Duration(days: 10)).toIso8601String(),
          'score': null,
        },
        {
          'title': 'API Integration',
          'description': 'Connect your app to a REST API',
          'isSubmitted': true,
          'deadline': now.add(const Duration(days: 15)).toIso8601String(),
          'score': 95,
        },
      ],
    };
  }

  static Future<List<Exam>> getMockAllExams() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Exam(score: 85, date: '2024-01-15', status: true),
      Exam(score: 92, date: '2024-01-20', status: true),
      Exam(score: 67, date: '2024-01-25', status: false),
      Exam(score: 78, date: '2024-01-30', status: true),
      Exam(score: 94, date: '2024-02-05', status: true),
      Exam(score: 56, date: '2024-02-10', status: false),
      Exam(score: 89, date: '2024-02-15', status: true),
    ];
  }

  static Future<List<Payment>> getMockAllPayments() async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return [
      Payment(date: now.subtract(const Duration(days: 30)), amount: 500000),
      Payment(date: now.subtract(const Duration(days: 60)), amount: 500000),
      Payment(date: now.subtract(const Duration(days: 90)), amount: 450000),
      Payment(date: now.subtract(const Duration(days: 120)), amount: 450000),
      Payment(date: now.subtract(const Duration(days: 150)), amount: 400000),
    ];
  }

  static Future<List<Homework>> getMockAllHomework() async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return [
      Homework(
        title: 'Flutter Widgets Assignment',
        description: 'Create a todo app using Flutter widgets',
        isSubmitted: true,
        deadline: now.add(const Duration(days: 5)),
        score: 88,
      ),
      Homework(
        title: 'State Management Task',
        description: 'Implement state management in your app',
        isSubmitted: false,
        deadline: now.add(const Duration(days: 10)),
        score: null,
      ),
      Homework(
        title: 'API Integration',
        description: 'Connect your app to a REST API',
        isSubmitted: true,
        deadline: now.add(const Duration(days: 15)),
        score: 95,
      ),
      Homework(
        title: 'Database Implementation',
        description: 'Add local database to your app',
        isSubmitted: false,
        deadline: now.add(const Duration(days: 20)),
        score: null,
      ),
      Homework(
        title: 'UI/UX Design Task',
        description: 'Improve the design of your app',
        isSubmitted: true,
        deadline: now.subtract(const Duration(days: 5)),
        score: 92,
      ),
    ];
  }
}
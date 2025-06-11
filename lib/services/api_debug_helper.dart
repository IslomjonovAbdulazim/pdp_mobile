// lib/services/api_debug_helper.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ApiDebugHelper {
  /// Test basic server connectivity
  static Future<bool> testServerConnection() async {
    try {
      print('🔍 Testing server connection...');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📥 Health check response: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Server connection failed: $e');
      return false;
    }
  }

  /// Test phone number endpoint with detailed logging
  static Future<void> testPhoneNumberCheck(String phoneNumber) async {
    try {
      print('🧪 Testing phone number check...');
      print('📞 Phone: $phoneNumber');

      final requestBody = {'phoneNumber': phoneNumber};
      final url = '${ApiService.baseUrl}/auth/v1/junior-app/login';

      print('📤 POST $url');
      print('📤 Headers: ${jsonEncode({'Content-Type': 'application/json'})}');
      print('📤 Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Headers: ${response.headers}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Success! Data structure:');
        _printJsonStructure(data, 0);
      } else {
        print('❌ Failed with status ${response.statusCode}');
        try {
          final errorData = jsonDecode(response.body);
          print('Error data structure:');
          _printJsonStructure(errorData, 0);
        } catch (e) {
          print('Could not parse error response as JSON');
        }
      }

    } catch (e) {
      print('❌ Exception during phone check test: $e');
    }
  }

  /// Test full authentication flow
  static Future<void> testFullAuthFlow({
    required String phoneNumber,
    required String password,
    required String smsCode,
  }) async {
    try {
      print('🧪 Testing full authentication flow...');

      // Step 1: Phone check
      print('\n--- Step 1: Phone Check ---');
      await testPhoneNumberCheck(phoneNumber);

      // Step 2: Password entry
      print('\n--- Step 2: Password Entry ---');
      await _testPasswordEntry(phoneNumber, password);

      // Note: SMS verification would need actual SMS code from backend
      print('\n--- Step 3: SMS Verification ---');
      print('⚠️  SMS verification requires actual code from backend');

    } catch (e) {
      print('❌ Full auth flow test failed: $e');
    }
  }

  static Future<void> _testPasswordEntry(String phoneNumber, String password) async {
    try {
      final requestBody = {
        'phoneNumber': phoneNumber,
        'password': password,
      };
      final url = '${ApiService.baseUrl}/auth/v1/junior-app/enter-password';

      print('📤 POST $url');
      print('📤 Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Password verification success!');
        print('SMS Code ID: ${data['data']?['smsCodeId']}');
        _printJsonStructure(data, 0);
      } else {
        print('❌ Password verification failed');
      }

    } catch (e) {
      print('❌ Password entry test failed: $e');
    }
  }

  /// Test authenticated endpoints (requires valid token)
  static Future<void> testStudentDataEndpoints(String studentId, String token) async {
    try {
      print('🧪 Testing student data endpoints...');
      print('👤 Student ID: $studentId');
      print('🔑 Token: ${token.substring(0, 20)}...');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.replaceFirst('Bearer ', '')}',
      };

      // Test home data
      await _testEndpoint(
        'Home Data',
        '${ApiService.baseUrl}/education/v1/academy-app/home-student/$studentId',
        headers,
      );

      // Test payments
      await _testEndpoint(
        'Payment History',
        '${ApiService.baseUrl}/education/v1/academy-app/payment-history/$studentId',
        headers,
      );

      // Test exams
      await _testEndpoint(
        'Exam History',
        '${ApiService.baseUrl}/education/v1/academy-app/exam-history/$studentId',
        headers,
      );

      // Test homework
      await _testEndpoint(
        'Homework History',
        '${ApiService.baseUrl}/education/v1/academy-app/homework-history/$studentId',
        headers,
      );

    } catch (e) {
      print('❌ Student data endpoints test failed: $e');
    }
  }

  static Future<void> _testEndpoint(String name, String url, Map<String, String> headers) async {
    try {
      print('\n--- Testing $name ---');
      print('📤 GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Body length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        print('✅ $name endpoint working!');
        try {
          final data = jsonDecode(response.body);
          print('Response structure:');
          _printJsonStructure(data, 0, maxDepth: 2);
        } catch (e) {
          print('Response is not valid JSON');
        }
      } else {
        print('❌ $name endpoint failed');
        print('Response: ${response.body.substring(0, 200)}...');
      }

    } catch (e) {
      print('❌ $name endpoint test error: $e');
    }
  }

  /// Helper to print JSON structure for debugging
  static void _printJsonStructure(dynamic data, int depth, {int maxDepth = 3}) {
    final indent = '  ' * depth;

    if (depth > maxDepth) {
      print('$indent...(max depth reached)');
      return;
    }

    if (data is Map) {
      print('$indent{');
      data.forEach((key, value) {
        if (value is Map || value is List) {
          print('$indent  "$key":');
          _printJsonStructure(value, depth + 1, maxDepth: maxDepth);
        } else {
          print('$indent  "$key": ${_formatValue(value)}');
        }
      });
      print('$indent}');
    } else if (data is List) {
      print('$indent[');
      if (data.isNotEmpty) {
        print('$indent  (${data.length} items)');
        if (depth < maxDepth) {
          _printJsonStructure(data.first, depth + 1, maxDepth: maxDepth);
          if (data.length > 1) {
            print('$indent  ...(${data.length - 1} more items)');
          }
        }
      }
      print('$indent]');
    } else {
      print('$indent${_formatValue(data)}');
    }
  }

  static String _formatValue(dynamic value) {
    if (value is String) {
      return '"${value.length > 50 ? value.substring(0, 50) + '...' : value}"';
    }
    return value.toString();
  }

  /// Print current API configuration
  static void printApiConfiguration() {
    print('🔧 API Configuration:');
    print('📍 Base URL: ${ApiService.baseUrl}');
    print('🔑 Token set: ${ApiService.currentToken != null ? "Yes" : "No"}');
    print('👤 Student ID set: ${ApiService.currentStudentId != null ? "Yes" : "No"}');
    if (ApiService.currentToken != null) {
      print('🔑 Token preview: ${ApiService.currentToken!.substring(0, 20)}...');
    }
    if (ApiService.currentStudentId != null) {
      print('👤 Student ID: ${ApiService.currentStudentId}');
    }
  }
}
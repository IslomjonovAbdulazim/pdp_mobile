// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/models.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api';
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Add auth token here when available
      // 'Authorization': 'Bearer $token',
    };
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Home data endpoint - gets all dashboard data
  static Future<Map<String, dynamic>> getHomeData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/home'),
        headers: _getHeaders(),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load home data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all exams
  static Future<List<Exam>> getAllExams() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exams'),
        headers: _getHeaders(),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> examsList = data['exams'] ?? [];
        return examsList.map((json) => Exam.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exams');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all payments
  static Future<List<Payment>> getAllPayments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments'),
        headers: _getHeaders(),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> paymentsList = data['payments'] ?? [];
        return paymentsList.map((json) => Payment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payments');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all homework
  static Future<List<Homework>> getAllHomework() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/homework'),
        headers: _getHeaders(),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> homeworkList = data['homework'] ?? [];
        return homeworkList.map((json) => Homework.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load homework');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Mock data for development
  static Future<Map<String, dynamic>> getMockHomeData() async {
    // Simulate network delay
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
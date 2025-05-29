import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/respitories/student_repository.dart';
import '../../core/error_handler.dart';

class HomeController extends GetxController {
  // Observable variables
  final _isLoading = false.obs;
  final _dashboardData = <String, dynamic>{}.obs;
  final _attendanceSummary = <String, dynamic>{}.obs;
  final _recentActivities = <Map<String, dynamic>>[].obs;
  final _upcomingEvents = <Map<String, dynamic>>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  Map<String, dynamic> get dashboardData => _dashboardData;
  Map<String, dynamic> get attendanceSummary => _attendanceSummary;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  List<Map<String, dynamic>> get upcomingEvents => _upcomingEvents;

  // Quick stats getters
  double get attendancePercentage =>
      (attendanceSummary['percentage'] as num?)?.toDouble() ?? 0.0;

  int get totalClasses => attendanceSummary['total_classes'] as int? ?? 0;
  int get attendedClasses => attendanceSummary['attended_classes'] as int? ?? 0;
  int get missedClasses => totalClasses - attendedClasses;

  int get pendingHomework =>
      dashboardData['pending_homework'] as int? ?? 0;

  int get upcomingExams =>
      dashboardData['upcoming_exams'] as int? ?? 0;

  double get gpa =>
      (dashboardData['gpa'] as num?)?.toDouble() ?? 0.0;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Load dashboard data
  Future<void> loadDashboardData() async {
    try {
      _isLoading.value = true;

      // Get current user ID (you'll need to implement this)
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Load dashboard data separately to avoid casting issues
      _dashboardData.value = await StudentRepository.getDashboardData(userId);
      _attendanceSummary.value = await StudentRepository.getAttendanceSummary(userId);
      _recentActivities.value = await _loadRecentActivities(userId);
      _upcomingEvents.value = await _loadUpcomingEvents(userId);

    } catch (e) {
      ErrorHandler.handleError(e);
      _loadMockData(); // Load mock data for demo
    } finally {
      _isLoading.value = false;
    }
  }

  // Load recent activities
  Future<List<Map<String, dynamic>>> _loadRecentActivities(String userId) async {
    // This would typically come from an API
    // For now, return mock data
    return [
      {
        'id': '1',
        'type': 'attendance',
        'title': 'Attendance Marked',
        'description': 'Present in Mathematics Class',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': 'check_circle',
      },
      {
        'id': '2',
        'type': 'homework',
        'title': 'Homework Submitted',
        'description': 'Physics Assignment #3',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'icon': 'assignment_turned_in',
      },
      {
        'id': '3',
        'type': 'exam',
        'title': 'Exam Result',
        'description': 'Chemistry Mid-term: 85/100',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'icon': 'grade',
      },
    ];
  }

  // Load upcoming events
  Future<List<Map<String, dynamic>>> _loadUpcomingEvents(String userId) async {
    return [
      {
        'id': '1',
        'type': 'exam',
        'title': 'Final Exam - Mathematics',
        'date': DateTime.now().add(const Duration(days: 5)),
        'location': 'Room 101',
        'color': 'red',
      },
      {
        'id': '2',
        'type': 'homework',
        'title': 'Physics Assignment Due',
        'date': DateTime.now().add(const Duration(days: 3)),
        'location': 'Online Submission',
        'color': 'blue',
      },
      {
        'id': '3',
        'type': 'class',
        'title': 'Chemistry Lab Session',
        'date': DateTime.now().add(const Duration(days: 1)),
        'location': 'Lab 205',
        'color': 'green',
      },
    ];
  }

  // Load mock data for demo purposes
  void _loadMockData() {
    _dashboardData.value = {
      'pending_homework': 3,
      'upcoming_exams': 2,
      'gpa': 3.75,
      'current_semester': 5,
      'total_credits': 120,
    };

    _attendanceSummary.value = {
      'percentage': 87.5,
      'total_classes': 40,
      'attended_classes': 35,
      'current_streak': 5,
    };

    _recentActivities.value = [
      {
        'id': '1',
        'type': 'attendance',
        'title': 'Attendance Marked',
        'description': 'Present in Mathematics Class',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': 'check_circle',
      },
      {
        'id': '2',
        'type': 'homework',
        'title': 'Homework Submitted',
        'description': 'Physics Assignment #3',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'icon': 'assignment_turned_in',
      },
    ];

    _upcomingEvents.value = [
      {
        'id': '1',
        'type': 'exam',
        'title': 'Final Exam - Mathematics',
        'date': DateTime.now().add(const Duration(days: 5)),
        'location': 'Room 101',
        'color': 'red',
      },
      {
        'id': '2',
        'type': 'homework',
        'title': 'Physics Assignment Due',
        'date': DateTime.now().add(const Duration(days: 3)),
        'location': 'Online Submission',
        'color': 'blue',
      },
    ];
  }

  // Get current user ID
  String? _getCurrentUserId() {
    // Implementation depends on your auth system
    // This is a placeholder
    return 'user_123';
  }

  // Refresh dashboard data
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // Navigate to specific sections
  void navigateToAttendance() {
    Get.toNamed('/attendance');
  }

  void navigateToExams() {
    Get.toNamed('/exams');
  }

  void navigateToHomework() {
    Get.toNamed('/homework');
  }

  // Get attendance status color
  Color getAttendanceStatusColor() {
    if (attendancePercentage >= 80) {
      return const Color(0xFF4CAF50); // Green
    } else if (attendancePercentage >= 60) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFE53935); // Red
    }
  }

  // Get GPA status color
  Color getGpaStatusColor() {
    if (gpa >= 3.5) {
      return const Color(0xFF4CAF50); // Green
    } else if (gpa >= 2.5) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFE53935); // Red
    }
  }

  // Format date for display
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return '${difference} days';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  // Get activity icon
  IconData getActivityIcon(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'assignment_turned_in':
        return Icons.assignment_turned_in;
      case 'grade':
        return Icons.grade;
      default:
        return Icons.info;
    }
  }
}
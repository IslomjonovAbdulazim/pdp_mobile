import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import '../../data/models/student_model.dart';
import '../../data/respitories/student_repository.dart';
import '../../core/error_handler.dart';

class AttendanceController extends GetxController {
  // Observable variables
  final _isLoading = false.obs;
  final _attendanceList = <Attendance>[].obs;
  final _attendanceSummary = <String, dynamic>{}.obs;
  final _selectedMonth = DateTime.now().month.obs;
  final _selectedYear = DateTime.now().year.obs;
  final _selectedCourse = ''.obs;
  final _courses = <String>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<Attendance> get attendanceList => _attendanceList;
  Map<String, dynamic> get attendanceSummary => _attendanceSummary;
  int get selectedMonth => _selectedMonth.value;
  int get selectedYear => _selectedYear.value;
  String get selectedCourse => _selectedCourse.value;
  List<String> get courses => _courses;

  // Summary getters
  double get attendancePercentage =>
      (attendanceSummary['percentage'] as num?)?.toDouble() ?? 0.0;
  int get totalClasses => attendanceSummary['total_classes'] as int? ?? 0;
  int get attendedClasses => attendanceSummary['attended_classes'] as int? ?? 0;
  int get missedClasses => totalClasses - attendedClasses;
  int get currentStreak => attendanceSummary['current_streak'] as int? ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadAttendanceData();
  }

  // Load attendance data
  Future<void> loadAttendanceData() async {
    try {
      _isLoading.value = true;

      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Load attendance data and summary
      _attendanceList.value = await StudentRepository.getStudentAttendance(userId);
      _attendanceSummary.value = await StudentRepository.getAttendanceSummary(userId);

      // Extract unique courses
      _extractCourses();

    } catch (e) {
      ErrorHandler.handleError(e);
      _loadMockData(); // Load mock data for demo
    } finally {
      _isLoading.value = false;
    }
  }

  // Extract unique courses from attendance data
  void _extractCourses() {
    final uniqueCourses = <String>{};
    for (final attendance in _attendanceList) {
      uniqueCourses.add(attendance.courseName);
    }
    _courses.value = ['All Courses', ...uniqueCourses.toList()];
    if (_selectedCourse.value.isEmpty) {
      _selectedCourse.value = 'All Courses';
    }
  }

  // Load mock data for demo
  void _loadMockData() {
    final now = DateTime.now();
    _attendanceList.value = [
      Attendance(
        id: '1',
        studentId: 'user_123',
        courseId: 'math_101',
        courseName: 'Mathematics',
        date: now.subtract(const Duration(days: 1)),
        isPresent: true,
        remarks: 'On time',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Attendance(
        id: '2',
        studentId: 'user_123',
        courseId: 'phys_101',
        courseName: 'Physics',
        date: now.subtract(const Duration(days: 2)),
        isPresent: true,
        remarks: null,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Attendance(
        id: '3',
        studentId: 'user_123',
        courseId: 'chem_101',
        courseName: 'Chemistry',
        date: now.subtract(const Duration(days: 3)),
        isPresent: false,
        remarks: 'Sick leave',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Attendance(
        id: '4',
        studentId: 'user_123',
        courseId: 'math_101',
        courseName: 'Mathematics',
        date: now.subtract(const Duration(days: 4)),
        isPresent: true,
        remarks: 'Participated well',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Attendance(
        id: '5',
        studentId: 'user_123',
        courseId: 'eng_101',
        courseName: 'English',
        date: now.subtract(const Duration(days: 5)),
        isPresent: true,
        remarks: null,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    _attendanceSummary.value = {
      'percentage': 87.5,
      'total_classes': 40,
      'attended_classes': 35,
      'current_streak': 5,
      'this_month_classes': 12,
      'this_month_attended': 11,
    };

    _extractCourses();
  }

  // Get filtered attendance list
  List<Attendance> get filteredAttendanceList {
    var filtered = _attendanceList.where((attendance) {
      // Filter by month and year
      if (attendance.date.month != selectedMonth ||
          attendance.date.year != selectedYear) {
        return false;
      }

      // Filter by course
      if (selectedCourse != 'All Courses' &&
          attendance.courseName != selectedCourse) {
        return false;
      }

      return true;
    }).toList();

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  // Change selected month
  void changeMonth(int month) {
    _selectedMonth.value = month;
  }

  // Change selected year
  void changeYear(int year) {
    _selectedYear.value = year;
  }

  // Change selected course
  void changeCourse(String course) {
    _selectedCourse.value = course;
  }

  // Get attendance stats for selected period
  Map<String, dynamic> get periodStats {
    final filtered = filteredAttendanceList;
    final totalClasses = filtered.length;
    final attendedClasses = filtered.where((a) => a.isPresent).length;
    final percentage = totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0.0;

    return {
      'total_classes': totalClasses,
      'attended_classes': attendedClasses,
      'missed_classes': totalClasses - attendedClasses,
      'percentage': percentage,
    };
  }

  // Get attendance status color
  Color getAttendanceStatusColor(double percentage) {
    if (percentage >= 80) {
      return const Color(0xFF4CAF50); // Green
    } else if (percentage >= 60) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFE53935); // Red
    }
  }

  // Get month name
  String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Format date for display
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Format day of week
  String formatDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  // Get current user ID
  String? _getCurrentUserId() {
    return 'user_123'; // Placeholder
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadAttendanceData();
  }

  // Export attendance data (placeholder)
  Future<void> exportAttendance() async {
    try {
      // Implementation for exporting attendance data
      // This could export to PDF, Excel, etc.
      ErrorHandler.showSuccessSnackbar('Attendance data exported successfully');
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  // Get attendance calendar data for month view
  Map<int, bool?> getMonthlyAttendanceMap() {
    final map = <int, bool?>{};
    final filtered = filteredAttendanceList;

    for (final attendance in filtered) {
      map[attendance.date.day] = attendance.isPresent;
    }

    return map;
  }

  // Get days in selected month
  int get daysInMonth {
    return DateTime(selectedYear, selectedMonth + 1, 0).day;
  }

  // Check if date has attendance record
  bool hasAttendanceRecord(int day) {
    return filteredAttendanceList.any((a) => a.date.day == day);
  }

  // Get attendance for specific day
  Attendance? getAttendanceForDay(int day) {
    try {
      return filteredAttendanceList.firstWhere((a) => a.date.day == day);
    } catch (e) {
      return null;
    }
  }
}
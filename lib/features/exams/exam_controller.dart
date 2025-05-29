import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/student_model.dart';
import '../../data/respitories/student_repository.dart';
import '../../core/error_handler.dart';

class ExamController extends GetxController {
  // Observable variables
  final _isLoading = false.obs;
  final _examList = <Exam>[].obs;
  final _examResults = <Map<String, dynamic>>[].obs;
  final _selectedFilter = 'All'.obs;
  final _searchQuery = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<Exam> get examList => _examList;
  List<Map<String, dynamic>> get examResults => _examResults;
  String get selectedFilter => _selectedFilter.value;
  String get searchQuery => _searchQuery.value;

  // Filter options
  List<String> get filterOptions => ['All', 'Upcoming', 'Ongoing', 'Completed'];

  @override
  void onInit() {
    super.onInit();
    loadExamData();
  }

  // Load exam data
  Future<void> loadExamData() async {
    try {
      _isLoading.value = true;

      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Load exams and results
      _examList.value = await StudentRepository.getStudentExams(userId);
      _examResults.value = await StudentRepository.getExamResults(userId);

    } catch (e) {
      ErrorHandler.handleError(e);
      _loadMockData(); // Load mock data for demo
    } finally {
      _isLoading.value = false;
    }
  }

  // Load mock data for demo
  void _loadMockData() {
    final now = DateTime.now();

    _examList.value = [
      Exam(
        id: '1',
        title: 'Mathematics Final Exam',
        description: 'Comprehensive exam covering all topics from Semester 1',
        courseId: 'math_101',
        courseName: 'Mathematics',
        examDate: now.add(const Duration(days: 5)),
        duration: 180, // 3 hours
        totalMarks: 100,
        status: 'upcoming',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Exam(
        id: '2',
        title: 'Physics Mid-term',
        description: 'Mid-term examination for Physics course',
        courseId: 'phys_101',
        courseName: 'Physics',
        examDate: now.add(const Duration(days: 2)),
        duration: 120, // 2 hours
        totalMarks: 80,
        status: 'upcoming',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Exam(
        id: '3',
        title: 'Chemistry Lab Test',
        description: 'Practical examination in chemistry lab',
        courseId: 'chem_101',
        courseName: 'Chemistry',
        examDate: now.subtract(const Duration(days: 5)),
        duration: 90,
        totalMarks: 50,
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Exam(
        id: '4',
        title: 'English Literature Quiz',
        description: 'Weekly quiz on English literature',
        courseId: 'eng_101',
        courseName: 'English',
        examDate: now.subtract(const Duration(days: 2)),
        duration: 60,
        totalMarks: 25,
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Exam(
        id: '5',
        title: 'History Assessment',
        description: 'Assessment covering World War topics',
        courseId: 'hist_101',
        courseName: 'History',
        examDate: now,
        duration: 90,
        totalMarks: 75,
        status: 'ongoing',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ];

    _examResults.value = [
  {
    'exam_id': '3',
    'exam_title': 'Chemistry Lab Test',
    'course_name': 'Chemistry',
    'marks_obtained': 42,
    'total_marks': 50,
    'percentage': 84.0,
    'grade': 'A',
    'exam_date': now.subtract(const Duration(days: 5)),
    'result_date': now.subtract(const Duration(days: 2)),
    'remarks': 'Excellent performance in practical work',
    ),
    {
    'exam_id': '4',
    'exam_title': 'English Literature Quiz',
    'course_name': 'English',
    'marks_obtained': 20,
    'total_marks': 25,
    'percentage': 80.0,
    'grade': 'B+',
    'exam_date': now.subtract(const Duration(days: 2)),
    'result_date': now.subtract(const Duration(days: 1)),
    'remarks': 'Good understanding of the concepts',
    },
    ];
    }

    // Get filtered exam list
    List<Exam> get filteredExamList {
    var filtered = _examList.where((exam) {
    // Filter by status
    if (selectedFilter != 'All' &&
    exam.status.toLowerCase() != selectedFilter.toLowerCase()) {
    return false;
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    if (!exam.title.toLowerCase().contains(query) &&
    !exam.courseName.toLowerCase().contains(query) &&
    !exam.description.toLowerCase().contains(query)) {
    return false;
    }
    }

    return true;
    }).toList();

    // Sort by exam date
    filtered.sort((a, b) {
    if (a.status == 'upcoming' && b.status != 'upcoming') return -1;
    if (a.status != 'upcoming' && b.status == 'upcoming') return 1;
    return a.examDate.compareTo(b.examDate);
    });

    return filtered;
    }

    // Change filter
    void changeFilter(String filter) {
    _selectedFilter.value = filter;
    }

    // Update search query
    void updateSearchQuery(String query) {
    _searchQuery.value = query;
    }

    // Get exam status color
    Color getExamStatusColor(String status) {
    switch (status.toLowerCase()) {
    case 'upcoming':
    return const Color(0xFF2196F3); // Blue
    case 'ongoing':
    return const Color(0xFFFF9800); // Orange
    case 'completed':
    return const Color(0xFF4CAF50); // Green
    default:
    return const Color(0xFF757575); // Grey
    }
    }

    // Get exam status icon
    IconData getExamStatusIcon(String status) {
    switch (status.toLowerCase()) {
    case 'upcoming':
    return Icons.schedule;
    case 'ongoing':
    return Icons.access_time;
    case 'completed':
    return Icons.check_circle;
    default:
    return Icons.help_outline;
    }
    }

    // Format exam date and time
    String formatExamDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
    return 'Today at ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
    return 'Tomorrow at ${_formatTime(dateTime)}';
    } else if (difference.inDays > 0) {
    return '${difference.inDays} days left';
    } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    }

    // Format time
    String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    // Format duration
    String formatDuration(int minutes) {
    if (minutes < 60) {
    return '${minutes}m';
    } else {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
    return '${hours}h';
    } else {
    return '${hours}h ${remainingMinutes}m';
    }
    }
    }

    // Get grade color
    Color getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
    case 'A+':
    case 'A':
    return const Color(0xFF4CAF50); // Green
    case 'A-':
    case 'B+':
    return const Color(0xFF8BC34A); // Light Green
    case 'B':
    case 'B-':
    return const Color(0xFFFFEB3B); // Yellow
    case 'C+':
    case 'C':
    return const Color(0xFFFF9800); // Orange
    case 'C-':
    case 'D':
    return const Color(0xFFFF5722); // Deep Orange
    case 'F':
    return const Color(0xFFE53935); // Red
    default:
    return const Color(0xFF757575); // Grey
    }
    }

    // Calculate overall performance
    Map<String, dynamic> get overallPerformance {
    if (examResults.isEmpty) {
    return {
    'average_percentage': 0.0,
    'total_exams': 0,
    'grades_distribution': <String, int>{},
    };
    }

    double totalPercentage = 0;
    final gradesDistribution = <String, int>{};

    for (final result in examResults) {
    totalPercentage += result['percentage'] as double;
    final grade = result['grade'] as String;
    gradesDistribution[grade] = (gradesDistribution[grade] ?? 0) + 1;
    }

    return {
    'average_percentage': totalPercentage / examResults.length,
    'total_exams': examResults.length,
    'grades_distribution': gradesDistribution,
    };
    }

    // Get current user ID
    String? _getCurrentUserId() {
    return 'user_123'; // Placeholder
    }

    // Refresh data
    Future<void> refreshData() async {
    await loadExamData();
    }

    // Get exam result for specific exam
    Map<String, dynamic>? getExamResult(String examId) {
    try {
    return examResults.firstWhere((result) => result['exam_id'] == examId);
    } catch (e) {
    return null;
    }
    }

    // Check if exam has result
    bool hasResult(String examId) {
    return examResults.any((result) => result['exam_id'] == examId);
    }

    // Get upcoming exams count
    int get upcomingExamsCount {
    return examList.where((exam) => exam.status == 'upcoming').length;
    }

    // Get completed exams count
    int get completedExamsCount {
    return examList.where((exam) => exam.status == 'completed').length;
    }

    // Show notifications for upcoming exams
    List<Exam> get upcomingExamsWithin24Hours {
    final now = DateTime.now();
    return examList.where((exam) {
    return exam.status == 'upcoming' &&
    exam.examDate.difference(now).inHours <= 24 &&
    exam.examDate.isAfter(now);
    }).toList();
    }
  }
}
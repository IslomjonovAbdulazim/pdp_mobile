import 'package:get/get.dart';
import '../../data/models/student_model.dart';
import '../../data/respitories/student_repository.dart';
import '../../core/error_handler.dart';

class HomeworkController extends GetxController {
  // Observable variables
  final _isLoading = false.obs;
  final _homeworkList = <Homework>[].obs;
  final _selectedFilter = 'All'.obs;
  final _searchQuery = ''.obs;
  final _selectedCourse = 'All Courses'.obs;
  final _courses = <String>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<Homework> get homeworkList => _homeworkList;
  String get selectedFilter => _selectedFilter.value;
  String get searchQuery => _searchQuery.value;
  String get selectedCourse => _selectedCourse.value;
  List<String> get courses => _courses;

  // Filter options
  List<String> get filterOptions => ['All', 'Pending', 'Submitted', 'Graded', 'Overdue'];

  @override
  void onInit() {
    super.onInit();
    loadHomeworkData();
  }

  // Load homework data
  Future<void> loadHomeworkData() async {
    try {
      _isLoading.value = true;

      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      _homeworkList.value = await StudentRepository.getStudentHomework(userId);
      _extractCourses();

    } catch (e) {
      ErrorHandler.handleError(e);
      _loadMockData(); // Load mock data for demo
    } finally {
      _isLoading.value = false;
    }
  }

  // Extract unique courses from homework data
  void _extractCourses() {
    final uniqueCourses = <String>{};
    for (final homework in _homeworkList) {
      uniqueCourses.add(homework.courseName);
    }
    _courses.value = ['All Courses', ...uniqueCourses.toList()];
  }

  // Load mock data for demo
  void _loadMockData() {
    final now = DateTime.now();

    _homeworkList.value = [
      Homework(
        id: '1',
        title: 'Mathematics Assignment #5',
        description: 'Solve problems from Chapter 7: Calculus and Derivatives. Include step-by-step solutions.',
        courseId: 'math_101',
        courseName: 'Mathematics',
        dueDate: now.add(const Duration(days: 3)),
        status: 'pending',
        submissionUrl: null,
        grade: null,
        feedback: null,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Homework(
        id: '2',
        title: 'Physics Lab Report',
        description: 'Complete lab report for the momentum conservation experiment conducted last week.',
        courseId: 'phys_101',
        courseName: 'Physics',
        dueDate: now.add(const Duration(days: 1)),
        status: 'pending',
        submissionUrl: null,
        grade: null,
        feedback: null,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Homework(
        id: '3',
        title: 'Chemistry Research Paper',
        description: 'Write a 2000-word research paper on organic compounds and their applications.',
        courseId: 'chem_101',
        courseName: 'Chemistry',
        dueDate: now.subtract(const Duration(days: 1)),
        status: 'overdue',
        submissionUrl: null,
        grade: null,
        feedback: null,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      Homework(
        id: '4',
        title: 'English Literature Essay',
        description: 'Analyze the themes in Shakespeare\'s Hamlet. Minimum 1500 words.',
        courseId: 'eng_101',
        courseName: 'English',
        dueDate: now.subtract(const Duration(days: 5)),
        status: 'graded',
        submissionUrl: 'https://example.com/submission4.pdf',
        grade: 85,
        feedback: 'Excellent analysis of the themes. Well-structured essay with good citations.',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Homework(
        id: '5',
        title: 'History Timeline Project',
        description: 'Create a visual timeline of World War II events with detailed explanations.',
        courseId: 'hist_101',
        courseName: 'History',
        dueDate: now.subtract(const Duration(days: 3)),
        status: 'submitted',
        submissionUrl: 'https://example.com/submission5.pdf',
        grade: null,
        feedback: null,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Homework(
        id: '6',
        title: 'Computer Science Algorithm',
        description: 'Implement a sorting algorithm in Python and analyze its time complexity.',
        courseId: 'cs_101',
        courseName: 'Computer Science',
        dueDate: now.add(const Duration(days: 7)),
        status: 'pending',
        submissionUrl: null,
        grade: null,
        feedback: null,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    _extractCourses();
  }

  // Get filtered homework list
  List<Homework> get filteredHomeworkList {
    var filtered = _homeworkList.where((homework) {
      // Filter by status
      if (selectedFilter != 'All') {
        String filterStatus = selectedFilter.toLowerCase();
        if (filterStatus == 'overdue') {
          // Check if homework is overdue
          if (!(homework.status == 'pending' && homework.dueDate.isBefore(DateTime.now()))) {
            return false;
          }
        } else if (homework.status.toLowerCase() != filterStatus) {
          return false;
        }
      }

      // Filter by course
      if (selectedCourse != 'All Courses' && homework.courseName != selectedCourse) {
        return false;
      }

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!homework.title.toLowerCase().contains(query) &&
            !homework.courseName.toLowerCase().contains(query) &&
            !homework.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort by due date and status
    filtered.sort((a, b) {
      // Overdue items first
      final aOverdue = a.status == 'pending' && a.dueDate.isBefore(DateTime.now());
      final bOverdue = b.status == 'pending' && b.dueDate.isBefore(DateTime.now());

      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;

      // Then by due date
      return a.dueDate.compareTo(b.dueDate);
    });

    return filtered;
  }

  // Change filter
  void changeFilter(String filter) {
    _selectedFilter.value = filter;
  }

  // Change course filter
  void changeCourse(String course) {
    _selectedCourse.value = course;
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  // Get homework status with overdue check
  String getHomeworkStatus(Homework homework) {
    if (homework.status == 'pending' && homework.dueDate.isBefore(DateTime.now())) {
      return 'overdue';
    }
    return homework.status;
  }

  // Get homework status color
  Color getHomeworkStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF2196F3); // Blue
      case 'submitted':
        return const Color(0xFFFF9800); // Orange
      case 'graded':
        return const Color(0xFF4CAF50); // Green
      case 'overdue':
        return const Color(0xFFE53935); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  // Get homework status icon
  IconData getHomeworkStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.assignment;
      case 'submitted':
        return Icons.upload;
      case 'graded':
        return Icons.grade;
      case 'overdue':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  // Format due date
  String formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays == 0) {
      if (dueDate.isBefore(now)) {
        return 'Due today (Overdue)';
      } else {
        return 'Due today';
      }
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays > 0) {
      return 'Due in ${difference.inDays} days';
    } else {
      return 'Overdue by ${(-difference.inDays)} days';
    }
  }

  // Submit homework
  Future<void> submitHomework(String homeworkId, String submissionUrl) async {
    try {
      _isLoading.value = true;

      await StudentRepository.submitHomework(homeworkId, submissionUrl);

      // Update local data
      final index = _homeworkList.indexWhere((h) => h.id == homeworkId);
      if (index != -1) {
        _homeworkList[index] = _homeworkList[index].copyWith(
          status: 'submitted',
          submissionUrl: submissionUrl,
        );
      }

      ErrorHandler.showSuccessSnackbar('Homework submitted successfully');

    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Get homework statistics
  Map<String, int> get homeworkStats {
    final stats = <String, int>{
      'total': _homeworkList.length,
      'pending': 0,
      'submitted': 0,
      'graded': 0,
      'overdue': 0,
    };

    for (final homework in _homeworkList) {
      final status = getHomeworkStatus(homework);
      stats[status] = (stats[status] ?? 0) + 1;
      if (status != 'overdue') {
        stats[homework.status] = (stats[homework.status] ?? 0) + 1;
      }
    }

    return stats;
  }

  // Get grade color
  Color getGradeColor(int? grade) {
    if (grade == null) return Colors.grey;

    if (grade >= 90) return const Color(0xFF4CAF50); // Green
    if (grade >= 80) return const Color(0xFF8BC34A); // Light Green
    if (grade >= 70) return const Color(0xFFFFEB3B); // Yellow
    if (grade >= 60) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFE53935); // Red
  }

  // Get average grade
  double get averageGrade {
    final gradedHomework = _homeworkList.where((h) => h.grade != null).toList();
    if (gradedHomework.isEmpty) return 0.0;

    final sum = gradedHomework.fold<int>(0, (sum, h) => sum + h.grade!);
    return sum / gradedHomework.length;
  }

  // Get upcoming deadlines (within 7 days)
  List<Homework> get upcomingDeadlines {
    final now = DateTime.now();
    return _homeworkList.where((homework) {
      return homework.status == 'pending' &&
          homework.dueDate.isAfter(now) &&
          homework.dueDate.difference(now).inDays <= 7;
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get overdue homework
  List<Homework> get overdueHomework {
    final now = DateTime.now();
    return _homeworkList.where((homework) {
      return homework.status == 'pending' && homework.dueDate.isBefore(now);
    }).toList();
  }

  // Get current user ID
  String? _getCurrentUserId() {
    return 'user_123'; // Placeholder
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadHomeworkData();
  }

  // Format date for display
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Check if homework can be submitted
  bool canSubmitHomework(Homework homework) {
    return homework.status == 'pending' ||
        (homework.status == 'pending' && homework.dueDate.isBefore(DateTime.now()));
  }
}

// Extension to add copyWith method to Homework
extension HomeworkCopyWith on Homework {
  Homework copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    String? courseName,
    DateTime? dueDate,
    String? status,
    String? submissionUrl,
    int? grade,
    String? feedback,
    DateTime? createdAt,
  }) {
    return Homework(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      submissionUrl: submissionUrl ?? this.submissionUrl,
      grade: grade ?? this.grade,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
import '../../core/api_service.dart';
import '../../core/api_service.dart';
import '../../data/models/student_model.dart';

class StudentRepository {
  // Get all students
  static Future<List<Student>> getStudents() async {
    try {
      final response = await ApiService.getStudents();
      final List<dynamic> studentsData = response['data'] ?? [];
      return studentsData.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  // Get student by ID
  static Future<Student> getStudent(String id) async {
    try {
      final response = await ApiService.getStudent(id);
      return Student.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to fetch student: $e');
    }
  }

  // Get student attendance
  static Future<List<Attendance>> getStudentAttendance(String studentId) async {
    try {
      final response = await ApiService.get('/students/$studentId/attendance');
      final List<dynamic> attendanceData = response['data'] ?? [];
      return attendanceData.map((json) => Attendance.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch attendance: $e');
    }
  }

  // Mark attendance
  static Future<bool> markAttendance(String studentId, String courseId, bool isPresent, {String? remarks}) async {
    try {
      await ApiService.markAttendance({
        'student_id': studentId,
        'course_id': courseId,
        'is_present': isPresent,
        'remarks': remarks,
        'date': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // Get student exams
  static Future<List<Exam>> getStudentExams(String studentId) async {
    try {
      final response = await ApiService.get('/students/$studentId/exams');
      final List<dynamic> examsData = response['data'] ?? [];
      return examsData.map((json) => Exam.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch exams: $e');
    }
  }

  // Get student homework
  static Future<List<Homework>> getStudentHomework(String studentId) async {
    try {
      final response = await ApiService.get('/students/$studentId/homework');
      final List<dynamic> homeworkData = response['data'] ?? [];
      return homeworkData.map((json) => Homework.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch homework: $e');
    }
  }

  // Submit homework
  static Future<bool> submitHomework(String homeworkId, String submissionUrl) async {
    try {
      await ApiService.put('/homework/$homeworkId/submit', {
        'submission_url': submissionUrl,
        'status': 'submitted',
        'submitted_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to submit homework: $e');
    }
  }

  // Update student profile
  static Future<Student> updateStudentProfile(String studentId, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('/students/$studentId', data);
      return Student.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get dashboard data
  static Future<Map<String, dynamic>> getDashboardData(String studentId) async {
    try {
      final response = await ApiService.get('/students/$studentId/dashboard');
      return response['data'] ?? {};
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }

  // Get attendance summary
  static Future<Map<String, dynamic>> getAttendanceSummary(String studentId) async {
    try {
      final response = await ApiService.get('/students/$studentId/attendance/summary');
      return response['data'] ?? {};
    } catch (e) {
      throw Exception('Failed to fetch attendance summary: $e');
    }
  }

  // Get exam results
  static Future<List<Map<String, dynamic>>> getExamResults(String studentId) async {
    try {
      final response = await ApiService.get('/students/$studentId/exam-results');
      final List<dynamic> resultsData = response['data'] ?? [];
      return resultsData.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch exam results: $e');
    }
  }
}
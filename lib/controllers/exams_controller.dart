// lib/controllers/exams_controller.dart
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../data/models/models.dart';
import '../controllers/auth_controller.dart';

class ExamsController extends GetxController {
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _exams = <Exam>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  List<Exam> get exams => _exams;

  @override
  void onInit() {
    super.onInit();
    loadExams();
  }

  Future<void> loadExams() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      final authController = Get.find<AuthController>();
      final studentId = authController.currentStudentId;

      if (studentId.isEmpty) {
        throw Exception('Student ID not found');
      }

      // Use real API - with fallback to mock for development
      try {
        _exams.value = await ApiService.getExamHistory(studentId);
      } catch (apiError) {
        print('API Error: $apiError');
        print('Falling back to mock data...');

        // Fallback to mock data for development
        _exams.value = await ApiService.getMockAllExams();
      }

    } catch (e) {
      _hasError.value = true;

      if (e.toString().contains('Network error')) {
        _errorMessage.value = 'Internet aloqasi yo\'q';
      } else if (e.toString().contains('Student ID not found')) {
        _errorMessage.value = 'O\'quvchi ma\'lumotlari topilmadi';
        Get.find<AuthController>().logout();
        return;
      } else {
        _errorMessage.value = 'Imtihonlar ma\'lumotini yuklashda xatolik';
      }

      Get.snackbar(
        'Xatolik',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadExams();
  }

  // Statistics
  int get totalExams => _exams.length;
  int get passedExams => _exams.where((exam) => exam.status).length;
  int get failedExams => _exams.where((exam) => !exam.status).length;
  double get averageScore {
    if (_exams.isEmpty) return 0.0;
    final total = _exams.fold<int>(0, (sum, exam) => sum + exam.score);
    return total / _exams.length;
  }
}
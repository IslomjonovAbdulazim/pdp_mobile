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

      print('📝 Loading exams for student: $studentId');

      // Use real API only - no mock fallback in production
      _exams.value = await ApiService.getExamHistory(studentId);

      print('✅ Exams loaded successfully: ${_exams.length} exams');

    } catch (e) {
      _hasError.value = true;

      if (e.toString().contains('Network error')) {
        _errorMessage.value = 'Internet aloqasi yo\'q. Iltimos, internetni tekshiring.';
      } else if (e.toString().contains('Student ID not found')) {
        _errorMessage.value = 'O\'quvchi ma\'lumotlari topilmadi';
        Get.find<AuthController>().logout();
        return;
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        _errorMessage.value = 'Avtorizatsiya muddati tugagan. Qaytadan kiring.';
        Get.find<AuthController>().logout();
        return;
      } else {
        _errorMessage.value = 'Imtihonlar ma\'lumotini yuklashda xatolik yuz berdi.';
      }

      print('❌ Exams loading error: $e');

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
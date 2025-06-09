// lib/controllers/homework_controller.dart
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../data/models/models.dart';
import '../controllers/auth_controller.dart';

class HomeworkController extends GetxController {
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _homework = <Homework>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  List<Homework> get homework => _homework;

  @override
  void onInit() {
    super.onInit();
    loadHomework();
  }

  Future<void> loadHomework() async {
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
        _homework.value = await ApiService.getHomeworkHistory(studentId);
      } catch (apiError) {
        print('API Error: $apiError');
        print('Falling back to mock data...');

        // Fallback to mock data for development
        _homework.value = await ApiService.getMockAllHomework();
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
        _errorMessage.value = 'Vazifalar ma\'lumotini yuklashda xatolik';
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
    await loadHomework();
  }

  // Statistics
  int get totalHomework => _homework.length;
  int get submittedHomework => _homework.where((hw) => hw.isSubmitted).length;
  int get pendingHomework => _homework.where((hw) => !hw.isSubmitted).length;

  double get averageScore {
    final gradedHomework = _homework.where((hw) => hw.score != null).toList();
    if (gradedHomework.isEmpty) return 0.0;
    final total = gradedHomework.fold<int>(0, (sum, hw) => sum + hw.score!);
    return total / gradedHomework.length;
  }
}
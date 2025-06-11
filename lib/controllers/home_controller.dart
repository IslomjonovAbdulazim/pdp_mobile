// lib/controllers/home_controller.dart
import 'package:get/get.dart';
import '../data/models/api_response_model.dart';
import '../services/api_service.dart';
import '../data/models/models.dart';
import '../data/models/api_response_models.dart';
import '../controllers/auth_controller.dart';

class HomeController extends GetxController {
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;

  final _person = Rxn<Person>();
  final _course = Rxn<Course>();
  final _recentExams = <Exam>[].obs;
  final _recentPayments = <Payment>[].obs;
  final _recentHomework = <Homework>[].obs;
  final _statistics = Rxn<StudentStatistics>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  Person? get person => _person.value;
  Course? get course => _course.value;
  List<Exam> get recentExams => _recentExams;
  List<Payment> get recentPayments => _recentPayments;
  List<Homework> get recentHomework => _recentHomework;
  StudentStatistics? get statistics => _statistics.value;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
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
        final data = await ApiService.getHomeData(studentId);

        _person.value = data.person;
        _course.value = data.course;
        _recentExams.value = data.recentExams;
        _recentPayments.value = data.recentPayments;
        _recentHomework.value = data.recentHomework;
        _statistics.value = data.statistics;

      } catch (apiError) {
        print('API Error: $apiError');
        print('Falling back to mock data...');

        // Fallback to mock data for development
        final mockData = await ApiService.getMockHomeData();

        _person.value = Person.fromJson(mockData['person']);
        _course.value = Course.fromJson(mockData['course']);

        _recentExams.value = (mockData['recentExams'] as List)
            .map((json) => Exam.fromJson(json))
            .toList();

        _recentPayments.value = (mockData['recentPayments'] as List)
            .map((json) => Payment.fromJson(json))
            .toList();

        _recentHomework.value = (mockData['recentHomework'] as List)
            .map((json) => Homework.fromJson(json))
            .toList();
      }

    } catch (e) {
      _hasError.value = true;

      if (e.toString().contains('Network error')) {
        _errorMessage.value = 'Internet aloqasi yo\'q';
      } else if (e.toString().contains('Student ID not found')) {
        _errorMessage.value = 'O\'quvchi ma\'lumotlari topilmadi';
        // Redirect to login
        Get.find<AuthController>().logout();
        return;
      } else {
        _errorMessage.value = 'Ma\'lumotlarni yuklashda xatolik';
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
    await loadHomeData();
  }

  void goToAllExams() {
    Get.toNamed('/exams');
  }

  void goToAllPayments() {
    Get.toNamed('/payments');
  }

  void goToAllHomework() {
    Get.toNamed('/homework');
  }
}
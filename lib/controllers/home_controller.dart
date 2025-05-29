// lib/controllers/home_controller.dart
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../data/models/models.dart';

class HomeController extends GetxController {
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;

  final _person = Rxn<Person>();
  final _course = Rxn<Course>();
  final _recentExams = <Exam>[].obs;
  final _recentPayments = <Payment>[].obs;
  final _recentHomework = <Homework>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  Person? get person => _person.value;
  Course? get course => _course.value;
  List<Exam> get recentExams => _recentExams;
  List<Payment> get recentPayments => _recentPayments;
  List<Homework> get recentHomework => _recentHomework;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      // For development, use mock data
      final data = await ApiService.getMockHomeData();

      // Real API call (when backend is ready)
      // final data = await ApiService.getHomeData();

      _person.value = Person.fromJson(data['person']);
      _course.value = Course.fromJson(data['course']);

      _recentExams.value = (data['recentExams'] as List)
          .map((json) => Exam.fromJson(json))
          .toList();

      _recentPayments.value = (data['recentPayments'] as List)
          .map((json) => Payment.fromJson(json))
          .toList();

      _recentHomework.value = (data['recentHomework'] as List)
          .map((json) => Homework.fromJson(json))
          .toList();

    } catch (e) {
      _hasError.value = true;

      if (e.toString().contains('Network error')) {
        _errorMessage.value = 'Internet aloqasi yo\'q';
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
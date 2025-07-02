// lib/controllers/main_controller.dart - Controller for bottom navigation
import 'package:get/get.dart';

class MainController extends GetxController {
  // Current selected index for bottom navigation
  final _currentIndex = 0.obs;

  // Getters
  int get currentIndex => _currentIndex.value;

  // Change the current index
  void changeIndex(int index) {
    _currentIndex.value = index;
  }

  // Navigate to specific section with index
  void navigateToExams() {
    _currentIndex.value = 1;
  }

  void navigateToPayments() {
    _currentIndex.value = 2;
  }

  void navigateToHomework() {
    _currentIndex.value = 3;
  }

  void navigateToHome() {
    _currentIndex.value = 0;
  }

  // Reset to home when needed
  void resetToHome() {
    _currentIndex.value = 0;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize at home page
    _currentIndex.value = 0;
  }
}
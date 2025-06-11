// lib/controllers/payments_controller.dart
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../data/models/models.dart';
import '../controllers/auth_controller.dart';

class PaymentsController extends GetxController {
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _payments = <Payment>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  List<Payment> get payments => _payments;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      final authController = Get.find<AuthController>();
      final studentId = authController.currentStudentId;

      if (studentId.isEmpty) {
        throw Exception('Student ID not found');
      }

      print('💰 Loading payments for student: $studentId');

      // Use real API only - no mock fallback in production
      _payments.value = await ApiService.getPaymentHistory(studentId);

      print('✅ Payments loaded successfully: ${_payments.length} payments');

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
        _errorMessage.value = 'To\'lovlar ma\'lumotini yuklashda xatolik yuz berdi.';
      }

      print('❌ Payments loading error: $e');

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
    await loadPayments();
  }

  // Statistics
  int get totalPayments => _payments.length;
  int get totalAmountPaid {
    return _payments.fold<int>(0, (sum, payment) => sum + payment.amount);
  }

  String get formattedTotalAmount {
    return '${totalAmountPaid.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    )} so\'m';
  }
}
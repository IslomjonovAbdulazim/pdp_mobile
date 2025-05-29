// lib/controllers/payments_controller.dart
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../data/models/models.dart';

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

      // For development, use mock data
      _payments.value = await ApiService.getMockAllPayments();

      // Real API call (when backend is ready)
      // _payments.value = await ApiService.getAllPayments();

    } catch (e) {
      _hasError.value = true;

      if (e.toString().contains('Network error')) {
        _errorMessage.value = 'Internet aloqasi yo\'q';
      } else {
        _errorMessage.value = 'To\'lovlar ma\'lumotini yuklashda xatolik';
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
// lib/features/payment/payment_controller.dart
import 'package:get/get.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';
import '../../core/error_handler.dart';
import '../../core/uzbek_date_formatter.dart';

class PaymentController extends GetxController {
  // Observable variables
  final _isLoading = false.obs;
  final _payments = <Payment>[].obs;
  final _subscriptionPlans = <Map<String, dynamic>>[].obs;
  final _paymentMethods = <Map<String, dynamic>>[].obs;
  final _selectedPlan = Rxn<String>();
  final _selectedPaymentMethod = Rxn<String>();

  // Getters
  bool get isLoading => _isLoading.value;
  List<Payment> get payments => _payments;
  List<Map<String, dynamic>> get subscriptionPlans => _subscriptionPlans;
  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;
  String? get selectedPlan => _selectedPlan.value;
  String? get selectedPaymentMethod => _selectedPaymentMethod.value;

  // Get recent payments (last 5)
  List<Map<String, dynamic>> get recentPayments {
    return _payments
        .map((payment) => {
      'id': payment.id,
      'date': payment.paymentDate.toIso8601String(),
      'amount': payment.amount,
      'status': _getStatusInUzbek(payment.status),
      'description': payment.description ?? 'Oylik obuna',
    })
        .toList()
        .take(5)
        .toList();
  }

  // Get next payment date
  String get nextPaymentDate {
    // This would typically come from the backend
    final nextDate = DateTime.now().add(const Duration(days: 30));
    return UzbekDateFormatter.formatDate(nextDate);
  }

  @override
  void onInit() {
    super.onInit();
    loadPaymentData();
  }

  // Load payment data
  Future<void> loadPaymentData() async {
    try {
      _isLoading.value = true;

      // Load payments, plans, and methods concurrently
      await Future.wait([
        _loadPayments(),
        _loadSubscriptionPlans(),
        _loadPaymentMethods(),
      ]);

    } catch (e) {
      ErrorHandler.handleError(e);
      _loadMockData(); // Load mock data for demo
    } finally {
      _isLoading.value = false;
    }
  }

  // Load user payments
  Future<void> _loadPayments() async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    _payments.value = await PaymentRepository.getUserPayments(userId);
  }

  // Load subscription plans
  Future<void> _loadSubscriptionPlans() async {
    _subscriptionPlans.value = await PaymentRepository.getSubscriptionPlans();
  }

  // Load payment methods
  Future<void> _loadPaymentMethods() async {
    _paymentMethods.value = await PaymentRepository.getPaymentMethods();
  }

  // Load mock data for demo
  void _loadMockData() {
    final now = DateTime.now();

    // Mock payments
    _payments.value = [
      Payment(
        id: '1',
        userId: 'user_123',
        paymentDate: now.subtract(const Duration(days: 15)),
        amount: 200000,
        status: 'to\'langan',
        description: 'Oylik obuna - Yanvar',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Payment(
        id: '2',
        userId: 'user_123',
        paymentDate: now.subtract(const Duration(days: 45)),
        amount: 200000,
        status: 'to\'langan',
        description: 'Oylik obuna - Dekabr',
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      Payment(
        id: '3',
        userId: 'user_123',
        paymentDate: now.subtract(const Duration(days: 75)),
        amount: 150000,
        status: 'to\'langan',
        description: 'Boshlang\'ich to\'lov',
        createdAt: now.subtract(const Duration(days: 75)),
      ),
    ];

    // Mock subscription plans
    _subscriptionPlans.value = [
      {
        'id': 'monthly',
        'name': 'Oylik obuna',
        'description': 'Barcha kurslarga kirish',
        'price': 200000.0,
        'period': 'oy',
        'is_popular': true,
        'features': ['Barcha kurslar', 'Jonli darslar', 'Homework tekshirish', 'Sertifikat'],
      },
      {
        'id': 'quarterly',
        'name': '3 oylik obuna',
        'description': '15% chegirma bilan',
        'price': 510000.0,
        'period': '3 oy',
        'is_popular': false,
        'features': ['Barcha kurslar', 'Jonli darslar', 'Homework tekshirish', 'Sertifikat', '15% chegirma'],
      },
      {
        'id': 'yearly',
        'name': 'Yillik obuna',
        'description': '25% chegirma bilan',
        'price': 1800000.0,
        'period': 'yil',
        'is_popular': false,
        'features': ['Barcha kurslar', 'Jonli darslar', 'Homework tekshirish', 'Sertifikat', '25% chegirma'],
      },
    ];

    // Mock payment methods
    _paymentMethods.value = [
      {
        'type': 'payme',
        'name': 'Payme',
        'description': 'Payme orqali to\'lash',
        'enabled': true,
      },
      {
        'type': 'click',
        'name': 'Click',
        'description': 'Click orqali to\'lash',
        'enabled': true,
      },
      {
        'type': 'uzcard',
        'name': 'UzCard',
        'description': 'UzCard orqali to\'lash',
        'enabled': true,
      },
      {
        'type': 'card',
        'name': 'Bank kartasi',
        'description': 'Visa/MasterCard orqali to\'lash',
        'enabled': true,
      },
    ];
  }

  // Select subscription plan
  void selectPlan(String planId) {
    _selectedPlan.value = planId;
    _showPaymentMethodSelection();
  }

  // Select payment method
  void selectPaymentMethod(String methodType) {
    _selectedPaymentMethod.value = methodType;
    _processPayment();
  }

  // Show payment method selection
  void _showPaymentMethodSelection() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To\'lov usulini tanlang',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...paymentMethods.where((method) => method['enabled'] == true).map(
                  (method) => ListTile(
                leading: Icon(_getPaymentMethodIcon(method['type'] as String)),
                title: Text(method['name'] as String),
                subtitle: Text(method['description'] as String),
                onTap: () {
                  Get.back();
                  selectPaymentMethod(method['type'] as String);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Process payment
  Future<void> _processPayment() async {
    if (selectedPlan == null || selectedPaymentMethod == null) return;

    try {
      _isLoading.value = true;

      final plan = subscriptionPlans.firstWhere((p) => p['id'] == selectedPlan);
      final amount = plan['price'] as double;

      // Create payment request
      final paymentData = {
        'plan_id': selectedPlan,
        'payment_method': selectedPaymentMethod,
        'amount': amount,
      };

      final result = await PaymentRepository.createPayment(paymentData);

      if (result['success'] == true) {
        // Payment successful
        ErrorHandler.showSuccessSnackbar('To\'lov muvaffaqiyatli amalga oshirildi');

        // Refresh payment data
        await loadPaymentData();

        // Check payment status in auth controller
        final authController = Get.find<AuthController>();
        await authController.checkPaymentStatus();

      } else {
        // Payment failed
        final errorMessage = result['message'] as String? ?? 'To\'lovda xatolik yuz berdi';
        ErrorHandler.showErrorSnackbar(errorMessage);
      }

    } catch (e) {
      String errorMessage = 'To\'lovda xatolik yuz berdi';

      if (e.toString().contains('insufficient_funds')) {
        errorMessage = 'Kartada mablag\' yetmaydi';
      } else if (e.toString().contains('card_declined')) {
        errorMessage = 'Karta rad etildi';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Internetga ulanishda xatolik';
      }

      ErrorHandler.showErrorSnackbar(errorMessage);
    } finally {
      _isLoading.value = false;
      _selectedPlan.value = null;
      _selectedPaymentMethod.value = null;
    }
  }

  // Get payment status in Uzbek
  String _getStatusInUzbek(String status) {
    switch (status) {
      case 'to\'langan':
      case 'completed':
        return 'completed';
      case 'kutilmoqda':
      case 'pending':
        return 'pending';
      case 'bekor qilingan':
      case 'cancelled':
        return 'failed';
      default:
        return 'pending';
    }
  }

  // Get payment method icon
  IconData _getPaymentMethodIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'payme':
        return Icons.payment;
      case 'click':
        return Icons.touch_app;
      case 'uzcard':
        return Icons.credit_card_outlined;
      default:
        return Icons.payment;
    }
  }

  // Get current user ID
  String? _getCurrentUserId() {
    return 'user_123'; // Placeholder - should get from auth controller
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadPaymentData();
  }

  // Get payment statistics
  Map<String, dynamic> get paymentStats {
    if (payments.isEmpty) {
      return {
        'total_paid': 0.0,
        'this_month': 0.0,
        'payment_count': 0,
        'average_payment': 0.0,
      };
    }

    final now = DateTime.now();
    final thisMonth = payments.where((p) =>
    p.paymentDate.year == now.year &&
        p.paymentDate.month == now.month
    ).toList();

    final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);
    final thisMonthTotal = thisMonth.fold<double>(0, (sum, p) => sum + p.amount);
    final averagePayment = totalPaid / payments.length;

    return {
      'total_paid': totalPaid,
      'this_month': thisMonthTotal,
      'payment_count': payments.length,
      'average_payment': averagePayment,
    };
  }

  // Check if user can make payment
  bool canMakePayment() {
    return selectedPlan != null && paymentMethods.any((m) => m['enabled'] == true);
  }

  // Get plan by ID
  Map<String, dynamic>? getPlanById(String planId) {
    try {
      return subscriptionPlans.firstWhere((plan) => plan['id'] == planId);
    } catch (e) {
      return null;
    }
  }

  // Format amount for display
  String formatAmount(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    )} so\'m';
  }

  // Show payment receipt dialog
  void showPaymentReceipt(Payment payment) {
    Get.dialog(
      AlertDialog(
        title: const Text('To\'lov kvitansiyasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReceiptRow('Sana', UzbekDateFormatter.formatDateTime(payment.paymentDate)),
            _buildReceiptRow('Summa', payment.formattedAmount),
            _buildReceiptRow('Holat', _getStatusTextInUzbek(payment.status)),
            if (payment.description != null)
              _buildReceiptRow('Tavsif', payment.description!),
            _buildReceiptRow('To\'lov ID', payment.id),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Yopish'),
          ),
          TextButton(
            onPressed: () {
              // Share or save receipt
              Get.back();
              Get.snackbar('Kvitansiya', 'Kvitansiya saqlandi');
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusTextInUzbek(String status) {
    switch (status) {
      case 'to\'langan':
        return 'To\'langan';
      case 'kutilmoqda':
        return 'Kutilmoqda';
      case 'bekor qilingan':
        return 'Bekor qilingan';
      default:
        return 'Noma\'lum';
    }
  }
}

// lib/data/repositories/payment_repository.dart
import '../../core/api_service.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  // Get user payments
  static Future<List<Payment>> getUserPayments(String userId) async {
    try {
      final response = await ApiService.get('/users/$userId/payments');
      final List<dynamic> paymentsData = response['data'] ?? [];
      return paymentsData.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('To\'lovlar ma\'lumotini olishda xatolik: $e');
    }
  }

  // Get subscription plans
  static Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final response = await ApiService.get('/subscription-plans');
      final List<dynamic> plansData = response['data'] ?? [];
      return plansData.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Obuna rejalarini olishda xatolik: $e');
    }
  }

  // Get payment methods
  static Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await ApiService.get('/payment-methods');
      final List<dynamic> methodsData = response['data'] ?? [];
      return methodsData.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('To\'lov usullarini olishda xatolik: $e');
    }
  }

  // Create payment
  static Future<Map<String, dynamic>> createPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await ApiService.post('/payments', paymentData);
      return response;
    } catch (e) {
      throw Exception('To\'lov yaratishda xatolik: $e');
    }
  }

  // Verify payment
  static Future<Map<String, dynamic>> verifyPayment(String paymentId) async {
    try {
      final response = await ApiService.get('/payments/$paymentId/verify');
      return response;
    } catch (e) {
      throw Exception('To\'lovni tekshirishda xatolik: $e');
    }
  }

  // Cancel payment
  static Future<bool> cancelPayment(String paymentId) async {
    try {
      await ApiService.post('/payments/$paymentId/cancel', {});
      return true;
    } catch (e) {
      throw Exception('To\'lovni bekor qilishda xatolik: $e');
    }
  }

  // Get payment statistics
  static Future<Map<String, dynamic>> getPaymentStats(String userId) async {
    try {
      final response = await ApiService.get('/users/$userId/payment-stats');
      return response['data'] ?? {};
    } catch (e) {
      throw Exception('To\'lov statistikasini olishda xatolik: $e');
    }
  }
}
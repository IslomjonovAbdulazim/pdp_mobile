// lib/features/payment/payment_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/payment/payment_controller.dart';
import '../../features/auth/auth_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';
import '../../core/uzbek_date_formatter.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.put(PaymentController());
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('To\'lov'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.history),
                  title: Text('To\'lov tarixi'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () => _showPaymentHistory(context, paymentController),
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Yordam'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () => _showHelp(context),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (paymentController.isLoading) {
          return const LoadingWidget(message: 'To\'lov ma\'lumotlari yuklanmoqda...');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              _buildUserInfoCard(context, authController),
              const SizedBox(height: 24),

              // Payment Status
              _buildPaymentStatusCard(context, authController, paymentController),
              const SizedBox(height: 24),

              // Subscription Plans
              if (!authController.hasActivePlan) ...[
                _buildSubscriptionPlansSection(context, paymentController),
                const SizedBox(height: 24),
              ],

              // Payment Methods
              _buildPaymentMethodsSection(context, paymentController),
              const SizedBox(height: 24),

              // Recent Payments
              _buildRecentPaymentsSection(context, paymentController),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, AuthController authController) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.primaryColor,
              backgroundImage: authController.userAvatarUrl != null
                  ? NetworkImage(authController.userAvatarUrl!)
                  : null,
              child: authController.userAvatarUrl == null
                  ? Text(
                authController.userInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authController.userName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authController.userPhone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard(
      BuildContext context,
      AuthController authController,
      PaymentController paymentController
      ) {
    final theme = Theme.of(context);
    final hasActivePlan = authController.hasActivePlan;

    return Card(
      color: hasActivePlan ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasActivePlan ? Icons.check_circle : Icons.warning,
                  color: hasActivePlan ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  hasActivePlan ? 'Faol obuna' : 'To\'lov talab qilinadi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasActivePlan ? Colors.green[800] : Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasActivePlan
                  ? 'Obunangiz faol. Barcha xizmatlardan foydalanishingiz mumkin.'
                  : 'Ta\'lim xizmatlaridan foydalanish uchun to\'lov qiling.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasActivePlan ? Colors.green[700] : Colors.orange[700],
              ),
            ),
            if (hasActivePlan) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Keyingi to\'lov: ${paymentController.nextPaymentDate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlansSection(BuildContext context, PaymentController controller) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Obuna rejalar',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...controller.subscriptionPlans.map((plan) => _buildPlanCard(context, plan, controller)),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan, PaymentController controller) {
    final theme = Theme.of(context);
    final isPopular = plan['is_popular'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isPopular ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPopular
              ? BorderSide(color: theme.primaryColor, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan['name'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isPopular) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'MASHHUR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan['description'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(plan['price'] as num).toStringAsFixed(0)} so\'m',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        '/${plan['period']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Features
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (plan['features'] as List<String>).map((feature) =>
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ).toList(),
              ),

              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Tanlash',
                onPressed: () => controller.selectPlan(plan['id'] as String),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection(BuildContext context, PaymentController controller) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To\'lov usullari',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...controller.paymentMethods.map((method) => _buildPaymentMethodCard(context, method, controller)),
      ],
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, Map<String, dynamic> method, PaymentController controller) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPaymentMethodIcon(method['type'] as String),
            color: theme.primaryColor,
          ),
        ),
        title: Text(
          method['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(method['description'] as String),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => controller.selectPaymentMethod(method['type'] as String),
      ),
    );
  }

  Widget _buildRecentPaymentsSection(BuildContext context, PaymentController controller) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Oxirgi to\'lovlar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _showPaymentHistory(context, controller),
              child: const Text('Barchasini ko\'rish'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.recentPayments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Hali to\'lovlar yo\'q'),
            ),
          )
        else
          ...controller.recentPayments.take(3).map((payment) => _buildPaymentItem(context, payment)),
      ],
    );
  }

  Widget _buildPaymentItem(BuildContext context, Map<String, dynamic> payment) {
    final theme = Theme.of(context);
    final date = DateTime.parse(payment['date'] as String);
    final amount = payment['amount'] as double;
    final status = payment['status'] as String;

    Color statusColor;
    String statusText;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'To\'langan';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Kutilmoqda';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusText = 'Muvaffaqiyatsiz';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Noma\'lum';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            status == 'completed' ? Icons.check : Icons.schedule,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text('${amount.toStringAsFixed(0)} so\'m'),
        subtitle: Text(UzbekDateFormatter.formatDate(date)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

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

  void _showPaymentHistory(BuildContext context, PaymentController controller) {
    // Navigate to payment history page or show dialog
    Get.snackbar('To\'lov tarixi', 'To\'lov tarixi sahifasi tez orada...');
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yordam'),
        content: const Text(
            'To\'lov bilan bog\'liq savollaringiz uchun:\n\n'
                '📞 +998 90 123 45 67\n'
                '📧 support@pdp.uz\n\n'
                'Ish vaqti: Dush-Juma 9:00-18:00'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }
}
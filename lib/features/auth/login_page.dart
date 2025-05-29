// lib/features/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/auth_controller.dart';
import '../../widgets/phone_input_field.dart';
import '../../widgets/custom_password_field.dart';
import '../../widgets/custom_button.dart';
import '../../core/app_constants.dart';
import '../../app/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.put(AuthController());

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.login),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                SizedBox(height: size.height * 0.05),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppConstants.welcome,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PDP Mobile\'ga kirish',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.08),

                // Form section
                PhoneInputField(
                  label: AppConstants.phoneNumber,
                  controller: _phoneController,
                  hint: '90) 123-45-67',
                ),
                const SizedBox(height: 16),

                CustomPasswordField(
                  label: AppConstants.password,
                  controller: _passwordController,
                  hint: 'Parolingizni kiriting',
                ),
                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(
                      'Parolni unutdingizmi?',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Login button
                Obx(() => PrimaryButton(
                  text: AppConstants.login,
                  onPressed: _authController.isLoading ? null : _handleLogin,
                  isLoading: _authController.isLoading,
                  width: double.infinity,
                )),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'yoki',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Register button
                SecondaryButton(
                  text: 'Yangi hisob yaratish',
                  onPressed: () => AppRoutes.toRegister(),
                  width: double.infinity,
                ),

                const SizedBox(height: 32),

                // Demo credentials info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Test uchun',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Telefon: 90) 123-45-67\nParol: 123456',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _authController.login(
        _phoneController.fullPhoneNumber, // +998901234567
        _passwordController.text,
      );
    }
  }

  void _showForgotPasswordDialog() {
    final phoneController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Parolni tiklash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Telefon raqamingizni kiriting, parolni tiklash havolasini yuboramiz.'),
            const SizedBox(height: 16),
            PhoneInputField(
              controller: phoneController,
              hint: '90) 123-45-67',
              required: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          Obx(() => TextButton(
            onPressed: _authController.isLoading
                ? null
                : () {
              if (phoneController.text.isNotEmpty) {
                _authController.forgotPassword(phoneController.fullPhoneNumber);
                Get.back();
              }
            },
            child: _authController.isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Yuborish'),
          )),
        ],
      ),
    );
  }
}

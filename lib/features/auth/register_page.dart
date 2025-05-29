
// lib/features/auth/register_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/auth_controller.dart';
import '../../widgets/phone_input_field.dart';
import '../../widgets/custom_password_field.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../core/validators.dart';
import '../../core/app_constants.dart';
import '../../app/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  bool _acceptTerms = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ro\'yxatdan o\'tish'),
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
                          Icons.person_add,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'PDP Mobile\'ga qo\'shiling',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yangi hisob yaratish uchun ma\'lumotlarni kiriting',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Form section
                CustomTextField(
                  label: AppConstants.fullName,
                  controller: _fullNameController,
                  validator: Validators.validateFullName,
                  hint: 'To\'liq ismingizni kiriting',
                  prefixIcon: const Icon(Icons.person_outline),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                PhoneInputField(
                  label: AppConstants.phoneNumber,
                  controller: _phoneController,
                  hint: '90) 123-45-67',
                ),
                const SizedBox(height: 16),

                CustomPasswordField(
                  label: AppConstants.password,
                  controller: _passwordController,
                  hint: 'Parol yarating',
                  showStrengthIndicator: true,
                ),
                const SizedBox(height: 16),

                CustomPasswordField(
                  label: 'Parolni tasdiqlang',
                  controller: _confirmPasswordController,
                  validator: (value) => _validateConfirmPassword(value),
                  hint: 'Parolni qayta kiriting',
                ),
                const SizedBox(height: 24),

                // Terms and conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Men ',
                            style: theme.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Foydalanish shartlari',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(text: ' va '),
                              TextSpan(
                                text: 'Maxfiylik siyosati',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(text: ' bilan roziman'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Register button
                Obx(() => PrimaryButton(
                  text: 'Hisob yaratish',
                  onPressed: (_authController.isLoading || !_acceptTerms)
                      ? null
                      : _handleRegister,
                  isLoading: _authController.isLoading,
                  width: double.infinity,
                )),

                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hisobingiz bormi? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => AppRoutes.toLogin(),
                      child: Text(
                        'Kirish',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parolni tasdiqlash shart';
    }
    if (value != _passwordController.text) {
      return 'Parollar mos kelmayapti';
    }
    return null;
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        Get.snackbar(
          'Xatolik',
          'Iltimos, foydalanish shartlarini qabul qiling',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final userData = {
        'phone_number': _phoneController.fullPhoneNumber,
        'full_name': _fullNameController.text.trim(),
        'password': _passwordController.text,
      };

      _authController.register(userData);
    }
  }
}
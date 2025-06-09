// lib/pages/sms_verification_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';

class SmsVerificationPage extends StatefulWidget {
  const SmsVerificationPage({super.key});

  @override
  State<SmsVerificationPage> createState() => _SmsVerificationPageState();
}

class _SmsVerificationPageState extends State<SmsVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );
  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Tasdiqlash'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.buttonShadow,
                ),
                child: const Icon(
                  Icons.sms,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'SMS Kodni Kiriting',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Obx(() => Text(
                'Telefon raqamingizga yuborilgan 6 xonali kodni kiriting:\n${_authController.currentPhoneNumber}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              )),

              const SizedBox(height: 48),

              // SMS Code Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppTheme.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            _focusNodes[index].unfocus();
                            _handleSmsVerification();
                          }
                        }
                      },
                      onTap: () {
                        _controllers[index].selection = TextSelection.fromPosition(
                          TextPosition(offset: _controllers[index].text.length),
                        );
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Verify Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.buttonShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: _authController.isLoading ? null : _handleSmsVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _authController.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Tasdiqlash',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )),

              const SizedBox(height: 24),

              // Resend SMS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('SMS kelmadimi? '),
                  GestureDetector(
                    onTap: _handleResendSms,
                    child: Text(
                      'Qayta yuborish',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Back to login
              TextButton(
                onPressed: () => Get.offAllNamed('/login'),
                child: const Text('Loginni o\'zgartirish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _smsCode {
    return _controllers.map((controller) => controller.text).join();
  }

  void _handleSmsVerification() {
    final smsCode = _smsCode;
    if (smsCode.length == 6) {
      _authController.verifySmsCode(smsCode);
    } else {
      Get.snackbar(
        'Xatolik',
        'Iltimos, 6 xonali SMS kodni to\'liq kiriting',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handleResendSms() {
    // Implement resend SMS functionality
    Get.snackbar(
      'SMS qayta yuborildi',
      'Yangi SMS kod telefon raqamingizga yuborildi',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _clearFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }
}
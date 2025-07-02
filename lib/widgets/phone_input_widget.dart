// lib/widgets/phone_input_widget.dart - Enhanced version
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PhoneInputWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const PhoneInputWidget({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  String _formatPhoneNumber(String value) {
    // Remove all non-digit characters
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 9 digits (Uzbek phone number without country code)
    if (digitsOnly.length > 9) {
      digitsOnly = digitsOnly.substring(0, 9);
    }

    // Format as XX XXX XX XX
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 5 || i == 7) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }

    return formatted;
  }

  String get fullPhoneNumber {
    String digitsOnly = _controller.text.replaceAll(RegExp(r'[^\d]'), '');
    return '+998$digitsOnly';
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final hasText = _controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.label!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isFocused
                      ? AppTheme.getColoredShadow(AppTheme.primaryGreen, opacity: 0.2)
                      : AppTheme.subtleShadow,
                ),
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final formatted = _formatPhoneNumber(newValue.text);
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }),
                  ],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? 'XX XXX XX XX',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.textSecondary.withOpacity(0.6),
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Enhanced country code badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isFocused || hasText
                                  ? AppTheme.primaryGradient
                                  : LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen.withOpacity(0.1),
                                  AppTheme.primaryGreenLight.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isFocused
                                    ? AppTheme.primaryGreen.withOpacity(0.3)
                                    : AppTheme.primaryGreen.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '🇺🇿',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '+998',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isFocused || hasText
                                        ? Colors.white
                                        : AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Enhanced divider
                          Container(
                            width: 2,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isFocused
                                    ? [
                                  AppTheme.primaryGreen,
                                  AppTheme.primaryGreenLight,
                                ]
                                    : [
                                  Colors.grey[300]!,
                                  Colors.grey[200]!,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                    filled: true,
                    fillColor: isFocused
                        ? AppTheme.primaryGreen.withOpacity(0.05)
                        : AppTheme.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: hasText
                            ? AppTheme.primaryGreen.withOpacity(0.3)
                            : Colors.grey[300]!,
                        width: hasText ? 2 : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryGreen,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.errorRed,
                        width: 2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.errorRed,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    // Add suffix icon for validation status
                    suffixIcon: hasText
                        ? Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: _controller.text.replaceAll(RegExp(r'[^\d]'), '').length == 9
                          ? Icon(
                        Icons.check_circle,
                        color: AppTheme.successGreen,
                        size: 24,
                      )
                          : Icon(
                        Icons.pending,
                        color: AppTheme.warningOrange,
                        size: 24,
                      ),
                    )
                        : null,
                  ),
                  validator: widget.validator ?? _defaultValidator,
                  onChanged: (value) {
                    setState(() {}); // Trigger rebuild for suffix icon
                    if (widget.onChanged != null) {
                      widget.onChanged!(fullPhoneNumber);
                    }
                  },
                ),
              ),
            );
          },
        ),

        // Enhanced helper text
        if (isFocused || _controller.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _controller.text.replaceAll(RegExp(r'[^\d]'), '').length == 9
                  ? AppTheme.successGreen.withOpacity(0.1)
                  : AppTheme.infoBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _controller.text.replaceAll(RegExp(r'[^\d]'), '').length == 9
                    ? AppTheme.successGreen.withOpacity(0.3)
                    : AppTheme.infoBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _controller.text.replaceAll(RegExp(r'[^\d]'), '').length == 9
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  size: 16,
                  color: _controller.text.replaceAll(RegExp(r'[^\d]'), '').length == 9
                      ? AppTheme.successGreen
                      : AppTheme.infoBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _controller.text.replaceAll(RegExp(r'[^\d]'), '').length == 9
                        ? 'Telefon raqam to\'g\'ri formatda'
                        : 'To\'liq telefon raqamini kiriting (9 raqam)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _controller.text.replaceAll(RegExp(r'[^\d]'), '').length == 9
                          ? AppTheme.successGreen
                          : AppTheme.infoBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon raqamini kiriting';
    }

    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length != 9) {
      return 'To\'liq telefon raqamini kiriting (9 raqam)';
    }

    return null;
  }
}

// Enhanced extension to easily get full phone number from controller
extension PhoneControllerExtension on TextEditingController {
  String get fullPhoneNumber {
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    return '+998$digitsOnly';
  }

  String get digitsOnly {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  bool get isValidUzbekNumber {
    return digitsOnly.length == 9;
  }
}

// lib/widgets/custom_password_field.dart
import 'package:flutter/material.dart';
import '../core/validators.dart';
import '../core/app_constants.dart';

class CustomPasswordField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool required;
  final bool showStrengthIndicator;

  const CustomPasswordField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.required = true,
    this.showStrengthIndicator = false,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
              children: widget.required
                  ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          validator: widget.validator ?? (widget.required ? Validators.validatePassword : null),
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          obscureText: _obscureText,
          textInputAction: TextInputAction.done,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint ?? AppConstants.password,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
            ),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: _buildBorder(theme),
            enabledBorder: _buildBorder(theme),
            focusedBorder: _buildFocusedBorder(theme),
            errorBorder: _buildErrorBorder(theme),
            focusedErrorBorder: _buildErrorBorder(theme),
          ),
        ),
        if (widget.showStrengthIndicator && widget.controller != null) ...[
          const SizedBox(height: 8),
          _buildPasswordStrengthIndicator(),
        ],
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = widget.controller?.text ?? '';
    final strength = _calculatePasswordStrength(password);

    Color strengthColor;
    String strengthText;

    switch (strength) {
      case 0:
        strengthColor = Colors.red;
        strengthText = 'Juda zaif';
        break;
      case 1:
        strengthColor = Colors.orange;
        strengthText = 'Zaif';
        break;
      case 2:
        strengthColor = Colors.yellow;
        strengthText = 'O\'rtacha';
        break;
      case 3:
        strengthColor = Colors.lightGreen;
        strengthText = 'Yaxshi';
        break;
      case 4:
        strengthColor = Colors.green;
        strengthText = 'Kuchli';
        break;
      default:
        strengthColor = Colors.grey;
        strengthText = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
        ),
        const SizedBox(height: 4),
        Text(
          strengthText,
          style: TextStyle(
            fontSize: 12,
            color: strengthColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength++;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength++;

    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) strength++;

    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength > 4 ? 4 : strength;
  }

  OutlineInputBorder _buildBorder(ThemeData theme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: theme.dividerColor,
        width: 1,
      ),
    );
  }

  OutlineInputBorder _buildFocusedBorder(ThemeData theme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: theme.primaryColor,
        width: 2,
      ),
    );
  }

  OutlineInputBorder _buildErrorBorder(ThemeData theme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: theme.colorScheme.error,
        width: 2,
      ),
    );
  }
}
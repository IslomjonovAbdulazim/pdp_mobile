import 'app_constants.dart';

class Validators {
  // Phone number validation for Uzbek format
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.phoneRequired;
    }

    // Remove all non-digit characters
    String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's 9 digits (Uzbek mobile number without country code)
    if (!RegExp(AppConstants.phonePattern).hasMatch(cleanPhone)) {
      return AppConstants.invalidPhone;
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequired;
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Parol kamida ${AppConstants.minPasswordLength} ta belgidan iborat bo\'lishi kerak';
    }

    return null;
  }

  // Full name validation
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'To\'liq ism kiritish shart';
    }

    if (value.trim().length < 2) {
      return 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'Ism ${AppConstants.maxNameLength} ta belgidan oshmasligi kerak';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName kiritish shart';
    }
    return null;
  }

  // Format phone number for display
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Format as ##) ###-##-##
    if (cleanPhone.length == 9) {
      return '${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 5)}-${cleanPhone.substring(5, 7)}-${cleanPhone.substring(7, 9)}';
    }

    return phone; // Return original if can't format
  }

  // Clean phone number (remove formatting)
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }
}

// lib/core/uzbek_date_formatter.dart
class UzbekDateFormatter {
  static const List<String> _monthsUzbek = [
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
    'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
  ];

  static const List<String> _weekDaysUzbek = [
    'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba',
    'Juma', 'Shanba', 'Yakshanba'
  ];

  static const List<String> _shortWeekDaysUzbek = [
    'Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'
  ];

  // Format date as "15 Yanvar, 2025"
  static String formatDate(DateTime date) {
    return '${date.day} ${_monthsUzbek[date.month - 1]}, ${date.year}';
  }

  // Format date with weekday as "Dushanba, 15 Yanvar"
  static String formatDateWithWeekday(DateTime date) {
    return '${_weekDaysUzbek[date.weekday - 1]}, ${date.day} ${_monthsUzbek[date.month - 1]}';
  }

  // Format time as "15:30"
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Format date and time as "15 Yanvar, 15:30"
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)}, ${formatTime(date)}';
  }

  // Format relative time (e.g., "2 kun oldin", "3 soat oldin")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} kun oldin';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} soat oldin';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} daqiqa oldin';
    } else {
      return 'Hozir';
    }
  }

  // Format time until (e.g., "2 kun qoldi", "3 soat qoldi")
  static String formatTimeUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} kun qoldi';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} soat qoldi';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} daqiqa qoldi';
    } else if (difference.inSeconds > 0) {
      return 'Bir necha soniya qoldi';
    } else {
      return 'Vaqti o\'tgan';
    }
  }

  // Get month name in Uzbek
  static String getMonthName(int month) {
    return _monthsUzbek[month - 1];
  }

  // Get weekday name in Uzbek
  static String getWeekdayName(int weekday) {
    return _weekDaysUzbek[weekday - 1];
  }

  // Get short weekday name in Uzbek
  static String getShortWeekdayName(int weekday) {
    return _shortWeekDaysUzbek[weekday - 1];
  }
}
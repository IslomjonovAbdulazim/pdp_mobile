// lib/data/models/models.dart - Updated with photoId handling
class Course {
  final String title;
  final String schedule;
  final String? weekDays; // Added based on backend response

  Course({
    required this.title,
    required this.schedule,
    this.weekDays,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      title: json['title'] ?? '',
      schedule: json['schedule'] ?? '',
      weekDays: json['weekDays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'schedule': schedule,
      'weekDays': weekDays,
    };
  }

  // Convert English week days to Uzbek
  String get weekDaysInUzbek {
    if (weekDays == null || weekDays!.isEmpty) return '';

    final dayMap = {
      'MONDAY': 'Dushanba',
      'TUESDAY': 'Seshanba',
      'WEDNESDAY': 'Chorshanba',
      'THURSDAY': 'Payshanba',
      'FRIDAY': 'Juma',
      'SATURDAY': 'Shanba',
      'SUNDAY': 'Yakshanba',
    };

    final days = weekDays!.split(', ');
    final uzbekDays = days.map((day) => dayMap[day.trim()] ?? day.trim()).toList();
    return uzbekDays.join(', ');
  }

  @override
  String toString() => 'Course(title: $title, schedule: $schedule, weekDays: $weekDays)';
}

class Person {
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;
  final String? photoId; // Backend sends photoId instead of avatarUrl

  Person({
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
    this.photoId,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
      photoId: json['photoId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'photoId': photoId,
    };
  }

  String get initials {
    try {
      if (fullName.trim().isEmpty) return 'U';

      final names = fullName.trim().split(RegExp(r'\s+'));
      if (names.isEmpty) return 'U';

      if (names.length == 1) {
        final name = names[0];
        return name.isNotEmpty ? name[0].toUpperCase() : 'U';
      }

      final first = names[0].isNotEmpty ? names[0][0] : '';
      final second = names[1].isNotEmpty ? names[1][0] : '';

      final result = first + second;
      return result.isNotEmpty ? result.toUpperCase() : 'U';
    } catch (e) {
      print('❌ Error generating initials: $e');
      return 'U';
    }
  }

  // Generate profile image URL from photoId with error handling
  String? get profileImageUrl {
    try {
      if (photoId != null && photoId!.isNotEmpty) {
        // Validate that photoId looks like a valid UUID or ID
        if (photoId!.length > 5 && !photoId!.contains(' ')) {
          final url = 'http://185.74.5.104:8080/api/attachment/v1/attachment/download?id=$photoId&view=open';
          // Basic URL validation
          if (Uri.tryParse(url) != null) {
            return url;
          }
        }
      }
      return avatarUrl;
    } catch (e) {
      print('❌ Error generating profile image URL: $e');
      return avatarUrl;
    }
  }

  @override
  String toString() => 'Person(fullName: $fullName, phoneNumber: $phoneNumber)';
}

class Exam {
  final int score;
  final String date;
  final bool status; // We'll convert from backend string to bool
  final String? examTitle; // Added based on backend response

  Exam({
    required this.score,
    required this.date,
    required this.status,
    this.examTitle,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    // Handle different score field names
    int scoreValue = 0;
    if (json.containsKey('scores')) {
      scoreValue = json['scores'] ?? 0;
    } else if (json.containsKey('score')) {
      scoreValue = json['score'] ?? 0;
    }

    // Convert status string to boolean
    bool statusValue = false;
    if (json['status'] is String) {
      statusValue = json['status'].toString().toUpperCase() == 'PASSED';
    } else if (json['status'] is bool) {
      statusValue = json['status'] ?? false;
    }

    // Handle different date formats
    String dateValue = '';
    if (json.containsKey('examDate')) {
      final examDate = json['examDate'];
      if (examDate is List && examDate.isNotEmpty) {
        // Convert array format [2025, 5, 14, 14, 3, 14, 433000000] to string
        try {
          final year = examDate[0];
          final month = examDate[1];
          final day = examDate[2];
          dateValue = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        } catch (e) {
          dateValue = DateTime.now().toIso8601String().split('T')[0];
        }
      } else if (examDate is String) {
        dateValue = examDate;
      }
    } else if (json.containsKey('date')) {
      dateValue = json['date'] ?? '';
    }

    return Exam(
      score: scoreValue,
      date: dateValue,
      status: statusValue,
      examTitle: json['examTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'date': date,
      'status': status,
      'examTitle': examTitle,
    };
  }

  String get statusText => status ? 'O\'tdi' : 'O\'tmadi';

  @override
  String toString() => 'Exam(score: $score, date: $date, status: $status, title: $examTitle)';
}

class Payment {
  final DateTime date;
  final int amount;
  final String? description;
  final String? invoiceNumber; // Added invoice number field

  Payment({
    required this.date,
    required this.amount,
    this.description,
    this.invoiceNumber,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    DateTime dateValue;

    try {
      // Handle timestamp number format from backend
      if (json['date'] is num) {
        dateValue = DateTime.fromMillisecondsSinceEpoch(json['date'].toInt());
      } else if (json['date'] is String) {
        dateValue = DateTime.parse(json['date']);
      } else {
        dateValue = DateTime.now();
      }
    } catch (e) {
      dateValue = DateTime.now();
    }

    // Handle amount - backend might send double
    int amountValue = 0;
    if (json['amount'] is double) {
      amountValue = json['amount'].toInt();
    } else if (json['amount'] is int) {
      amountValue = json['amount'];
    }

    return Payment(
      date: dateValue,
      amount: amountValue,
      description: json['description'],
      invoiceNumber: json['invoiceNumber'] ?? json['invoice_number'], // Handle both naming conventions
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
      'invoiceNumber': invoiceNumber,
    };
  }

  String get formattedAmount => '${amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
  )} so\'m';

  String get formattedDate {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String get displayInvoiceNumber => invoiceNumber ?? 'N/A';

  @override
  String toString() => 'Payment(amount: $amount, date: $formattedDate, description: $description, invoiceNumber: $invoiceNumber)';
}

class Homework {
  final String title;
  final String? description; // Backend sends null sometimes
  final bool isSubmitted;
  final DateTime? deadline; // Backend sends null sometimes
  final int? score; // nullable because might not be graded yet

  Homework({
    required this.title,
    this.description,
    required this.isSubmitted,
    this.deadline,
    this.score,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    DateTime? deadlineValue;

    // Handle deadline - backend might send null
    if (json['deadline'] != null) {
      try {
        if (json['deadline'] is String) {
          deadlineValue = DateTime.parse(json['deadline']);
        } else if (json['deadline'] is num) {
          deadlineValue = DateTime.fromMillisecondsSinceEpoch(json['deadline'].toInt());
        }
      } catch (e) {
        deadlineValue = null;
      }
    }

    return Homework(
      title: json['title'] ?? '',
      description: json['description'],
      isSubmitted: json['isSubmitted'] ?? false,
      deadline: deadlineValue,
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isSubmitted': isSubmitted,
      'deadline': deadline?.toIso8601String(),
      'score': score,
    };
  }

  String get statusText => isSubmitted ? 'Topshirilgan' : 'Topshirilmagan';

  String get formattedDeadline {
    if (deadline == null) return 'Muddatsiz';

    final now = DateTime.now();
    final difference = deadline!.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} kun qoldi';
    } else if (difference.inDays == 0) {
      return 'Bugun';
    } else {
      return 'Muddati o\'tgan';
    }
  }

  String get deadlineDate {
    if (deadline == null) return 'Muddatsiz';
    return '${deadline!.day}.${deadline!.month.toString().padLeft(2, '0')}.${deadline!.year}';
  }

  @override
  String toString() => 'Homework(title: $title, isSubmitted: $isSubmitted, deadline: $deadlineDate, score: $score)';
}
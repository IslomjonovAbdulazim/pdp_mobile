// lib/data/models/models.dart
class Course {
  final String title;
  final String schedule;

  Course({
    required this.title,
    required this.schedule,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      title: json['title'] ?? '',
      schedule: json['schedule'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'schedule': schedule,
    };
  }
}

class Person {
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;

  Person({
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
    };
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.isEmpty) return 'U';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }
}

class Exam {
  final int score;
  final String date;
  final bool status; // pass or fail

  Exam({
    required this.score,
    required this.date,
    required this.status,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      score: json['score'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'date': date,
      'status': status,
    };
  }

  String get statusText => status ? 'O\'tdi' : 'O\'tmadi';
}

class Payment {
  final DateTime date;
  final int amount;

  Payment({
    required this.date,
    required this.amount,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      date: DateTime.parse(json['date']),
      amount: json['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }

  String get formattedAmount => '${amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
  )} so\'m';

  String get formattedDate {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

class Homework {
  final String title;
  final String description;
  final bool isSubmitted;
  final DateTime deadline;
  final int? score; // nullable because might not be graded yet

  Homework({
    required this.title,
    required this.description,
    required this.isSubmitted,
    required this.deadline,
    this.score,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isSubmitted: json['isSubmitted'] ?? false,
      deadline: DateTime.parse(json['deadline']),
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isSubmitted': isSubmitted,
      'deadline': deadline.toIso8601String(),
      'score': score,
    };
  }

  String get statusText => isSubmitted ? 'Topshirilgan' : 'Topshirilmagan';

  String get formattedDeadline {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} kun qoldi';
    } else if (difference.inDays == 0) {
      return 'Bugun';
    } else {
      return 'Muddati o\'tgan';
    }
  }

  String get deadlineDate {
    return '${deadline.day}.${deadline.month.toString().padLeft(2, '0')}.${deadline.year}';
  }
}
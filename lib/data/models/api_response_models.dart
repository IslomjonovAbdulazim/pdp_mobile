// lib/data/models/api_response_models.dart
// API response models and authentication-related models - Updated for actual backend

import 'models.dart'; // Import core business models

/// Response from phone number check endpoint
class PhoneCheckResponse {
  final bool hasPassword;

  PhoneCheckResponse({required this.hasPassword});

  factory PhoneCheckResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure from backend
    if (json.containsKey('data')) {
      return PhoneCheckResponse(
        hasPassword: json['data']['hasPassword'] ?? false,
      );
    } else if (json.containsKey('hasPassword')) {
      // Direct structure fallback
      return PhoneCheckResponse(
        hasPassword: json['hasPassword'] ?? false,
      );
    } else {
      // Default to false if no clear structure
      return PhoneCheckResponse(hasPassword: false);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'hasPassword': hasPassword,
    };
  }

  @override
  String toString() => 'PhoneCheckResponse(hasPassword: $hasPassword)';
}

/// Response from password entry endpoint
class PasswordResponse {
  final String smsCodeId;
  final String? smsCode; // Backend may or may not include actual SMS code
  final String? message;
  final bool success;
  final String phoneNumber;
  final bool? reliableDevice;

  PasswordResponse({
    required this.smsCodeId,
    this.smsCode,
    this.message,
    required this.success,
    required this.phoneNumber,
    this.reliableDevice,
  });

  factory PasswordResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure from backend
    if (json.containsKey('data')) {
      final data = json['data'];
      return PasswordResponse(
        smsCodeId: data['smsCodeId'] ?? '',
        smsCode: data['smsCode'],
        phoneNumber: data['phoneNumber'] ?? '',
        reliableDevice: data['reliableDevice'],
        message: data['message'] ?? json['message'],
        success: json['success'] ?? true,
      );
    } else {
      // Direct structure fallback
      return PasswordResponse(
        smsCodeId: json['smsCodeId'] ?? '',
        smsCode: json['smsCode'],
        phoneNumber: json['phoneNumber'] ?? '',
        reliableDevice: json['reliableDevice'],
        message: json['message'],
        success: json['success'] ?? true,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'smsCodeId': smsCodeId,
      'smsCode': smsCode,
      'phoneNumber': phoneNumber,
      'reliableDevice': reliableDevice,
      'message': message,
      'success': success,
    };
  }

  @override
  String toString() => 'PasswordResponse(success: $success, smsCodeId: $smsCodeId, phoneNumber: $phoneNumber)';
}

/// Student information from auth response
class Student {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;
  final String? course;
  final String? group;
  final String? firstName;
  final String? lastName;
  final String? patron;

  Student({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
    this.course,
    this.group,
    this.firstName,
    this.lastName,
    this.patron,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    // Handle different naming conventions from backend
    String fullNameFromJson = '';

    if (json.containsKey('fullName') && json['fullName'] != null) {
      fullNameFromJson = json['fullName'];
    } else if (json.containsKey('firstName') && json.containsKey('lastName')) {
      // Construct full name from firstName and lastName
      final firstName = json['firstName'] ?? '';
      final lastName = json['lastName'] ?? '';
      final patron = json['patron'] ?? '';

      if (patron.isNotEmpty) {
        fullNameFromJson = '$firstName $patron $lastName'.trim();
      } else {
        fullNameFromJson = '$firstName $lastName'.trim();
      }
    } else if (json.containsKey('name')) {
      fullNameFromJson = json['name'];
    }

    return Student(
      id: json['id'] ?? json['studentId'] ?? '',
      fullName: fullNameFromJson,
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
      course: json['course'] ?? json['courseName'],
      group: json['group'] ?? json['groupName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      patron: json['patron'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'course': course,
      'group': group,
      'firstName': firstName,
      'lastName': lastName,
      'patron': patron,
    };
  }

  String get initials {
    final names = fullName.trim().split(' ');
    if (names.isEmpty || fullName.isEmpty) return 'U';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  @override
  String toString() => 'Student(id: $id, fullName: $fullName, phoneNumber: $phoneNumber)';
}

/// Response from SMS verification endpoint
class SmsVerificationResponse {
  final String token;
  final List<Student> students;
  final bool success;
  final String? message;

  SmsVerificationResponse({
    required this.token,
    required this.students,
    required this.success,
    this.message,
  });

  factory SmsVerificationResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure from backend
    if (json.containsKey('data')) {
      final data = json['data'];
      return SmsVerificationResponse(
        token: data['token'] ?? '',
        students: (data['students'] as List<dynamic>? ?? [])
            .map((studentJson) => Student.fromJson(studentJson))
            .toList(),
        success: json['success'] ?? true,
        message: json['message'],
      );
    } else {
      // Direct structure fallback
      return SmsVerificationResponse(
        token: json['token'] ?? '',
        students: (json['students'] as List<dynamic>? ?? [])
            .map((studentJson) => Student.fromJson(studentJson))
            .toList(),
        success: json['success'] ?? true,
        message: json['message'],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'students': students.map((student) => student.toJson()).toList(),
      'success': success,
      'message': message,
    };
  }

  @override
  String toString() => 'SmsVerificationResponse(success: $success, token: ${token.length > 20 ? token.substring(0, 20) + '...' : token}, studentsCount: ${students.length})';
}

/// Auth state for managing the login process
enum AuthState {
  initial,
  phoneChecked,
  passwordEntered,
  smsCodeSent,
  authenticated,
  multipleStudents,
}

/// Login session data to keep track of the auth process
class LoginSession {
  final String phoneNumber;
  final String? smsCodeId;
  final AuthState state;
  final List<Student>? students;
  final String? selectedStudentId;

  LoginSession({
    required this.phoneNumber,
    this.smsCodeId,
    required this.state,
    this.students,
    this.selectedStudentId,
  });

  LoginSession copyWith({
    String? phoneNumber,
    String? smsCodeId,
    AuthState? state,
    List<Student>? students,
    String? selectedStudentId,
  }) {
    return LoginSession(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      smsCodeId: smsCodeId ?? this.smsCodeId,
      state: state ?? this.state,
      students: students ?? this.students,
      selectedStudentId: selectedStudentId ?? this.selectedStudentId,
    );
  }

  @override
  String toString() => 'LoginSession(phoneNumber: $phoneNumber, state: $state, studentsCount: ${students?.length ?? 0})';
}

/// Response from home-student endpoint
class HomeDataResponse {
  final Person? person;
  final Course? course;
  final List<Exam> recentExams;
  final List<Payment> recentPayments;
  final List<Homework> recentHomework;
  final StudentStatistics? statistics;

  HomeDataResponse({
    this.person,
    this.course,
    required this.recentExams,
    required this.recentPayments,
    required this.recentHomework,
    this.statistics,
  });

  factory HomeDataResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure from backend
    Map<String, dynamic> data = json;

    if (json.containsKey('data')) {
      data = json['data'];
    }

    // Parse each section with error handling
    List<Exam> exams = [];
    List<Payment> payments = [];
    List<Homework> homework = [];

    try {
      if (data['recentExams'] is List) {
        exams = (data['recentExams'] as List<dynamic>)
            .map((examJson) {
          try {
            return Exam.fromJson(examJson);
          } catch (e) {
            print('❌ Error parsing exam: $e');
            print('Exam JSON: $examJson');
            return null;
          }
        })
            .where((exam) => exam != null)
            .cast<Exam>()
            .toList();
      }
    } catch (e) {
      print('❌ Error parsing exams list: $e');
    }

    try {
      if (data['recentPayments'] is List) {
        payments = (data['recentPayments'] as List<dynamic>)
            .map((paymentJson) {
          try {
            return Payment.fromJson(paymentJson);
          } catch (e) {
            print('❌ Error parsing payment: $e');
            print('Payment JSON: $paymentJson');
            return null;
          }
        })
            .where((payment) => payment != null)
            .cast<Payment>()
            .toList();
      }
    } catch (e) {
      print('❌ Error parsing payments list: $e');
    }

    try {
      if (data['recentHomeworks'] is List) {
        homework = (data['recentHomeworks'] as List<dynamic>)
            .map((homeworkJson) {
          try {
            return Homework.fromJson(homeworkJson);
          } catch (e) {
            print('❌ Error parsing homework: $e');
            print('Homework JSON: $homeworkJson');
            return null;
          }
        })
            .where((hw) => hw != null)
            .cast<Homework>()
            .toList();
      }
    } catch (e) {
      print('❌ Error parsing homework list: $e');
    }

    Person? person;
    try {
      person = data['person'] != null ? Person.fromJson(data['person']) : null;
    } catch (e) {
      print('❌ Error parsing person: $e');
    }

    Course? course;
    try {
      course = data['course'] != null ? Course.fromJson(data['course']) : null;
    } catch (e) {
      print('❌ Error parsing course: $e');
    }

    return HomeDataResponse(
      person: person,
      course: course,
      recentExams: exams,
      recentPayments: payments,
      recentHomework: homework,
      statistics: data['statistics'] != null
          ? StudentStatistics.fromJson(data['statistics'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person': person?.toJson(),
      'course': course?.toJson(),
      'recentExams': recentExams.map((exam) => exam.toJson()).toList(),
      'recentPayments': recentPayments.map((payment) => payment.toJson()).toList(),
      'recentHomework': recentHomework.map((homework) => homework.toJson()).toList(),
      'statistics': statistics?.toJson(),
    };
  }

  @override
  String toString() => 'HomeDataResponse(person: ${person?.fullName}, examsCount: ${recentExams.length}, paymentsCount: ${recentPayments.length})';
}

/// Student statistics that might come from the API
class StudentStatistics {
  final int totalExams;
  final int passedExams;
  final double averageScore;
  final int totalHomework;
  final int submittedHomework;
  final double homeworkCompletion;
  final int totalPayments;
  final int paidAmount;
  final int pendingAmount;

  StudentStatistics({
    required this.totalExams,
    required this.passedExams,
    required this.averageScore,
    required this.totalHomework,
    required this.submittedHomework,
    required this.homeworkCompletion,
    required this.totalPayments,
    required this.paidAmount,
    required this.pendingAmount,
  });

  factory StudentStatistics.fromJson(Map<String, dynamic> json) {
    return StudentStatistics(
      totalExams: json['totalExams'] ?? 0,
      passedExams: json['passedExams'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      totalHomework: json['totalHomework'] ?? 0,
      submittedHomework: json['submittedHomework'] ?? 0,
      homeworkCompletion: (json['homeworkCompletion'] ?? 0.0).toDouble(),
      totalPayments: json['totalPayments'] ?? 0,
      paidAmount: json['paidAmount'] ?? 0,
      pendingAmount: json['pendingAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalExams': totalExams,
      'passedExams': passedExams,
      'averageScore': averageScore,
      'totalHomework': totalHomework,
      'submittedHomework': submittedHomework,
      'homeworkCompletion': homeworkCompletion,
      'totalPayments': totalPayments,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
    };
  }

  @override
  String toString() => 'StudentStatistics(totalExams: $totalExams, passedExams: $passedExams, averageScore: $averageScore)';
}
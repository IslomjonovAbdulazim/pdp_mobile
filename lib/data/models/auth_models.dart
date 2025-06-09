// lib/data/models/auth_models.dart

/// Response from phone number check endpoint
class PhoneCheckResponse {
  final bool hasPassword;

  PhoneCheckResponse({required this.hasPassword});

  factory PhoneCheckResponse.fromJson(Map<String, dynamic> json) {
    return PhoneCheckResponse(
      hasPassword: json['hasPassword'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasPassword': hasPassword,
    };
  }
}

/// Response from password entry endpoint
class PasswordResponse {
  final String smsCodeId;
  final String? message;
  final bool success;

  PasswordResponse({
    required this.smsCodeId,
    this.message,
    required this.success,
  });

  factory PasswordResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResponse(
      smsCodeId: json['smsCodeId'] ?? '',
      message: json['message'],
      success: json['success'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'smsCodeId': smsCodeId,
      'message': message,
      'success': success,
    };
  }
}

/// Student information from auth response
class Student {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;
  final String? course;
  final String? group;

  Student({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
    this.course,
    this.group,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? json['studentId'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
      course: json['course'] ?? json['courseName'],
      group: json['group'] ?? json['groupName'],
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
    };
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.isEmpty) return 'U';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }
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
    return SmsVerificationResponse(
      token: json['token'] ?? '',
      students: (json['students'] as List<dynamic>? ?? [])
          .map((studentJson) => Student.fromJson(studentJson))
          .toList(),
      success: json['success'] ?? true,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'students': students.map((student) => student.toJson()).toList(),
      'success': success,
      'message': message,
    };
  }
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
}
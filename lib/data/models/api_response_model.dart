// lib/data/models/api_response_models.dart
import 'models.dart';

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
    return HomeDataResponse(
      person: json['person'] != null ? Person.fromJson(json['person']) : null,
      course: json['course'] != null ? Course.fromJson(json['course']) : null,
      recentExams: (json['recentExams'] as List<dynamic>? ?? [])
          .map((examJson) => Exam.fromJson(examJson))
          .toList(),
      recentPayments: (json['recentPayments'] as List<dynamic>? ?? [])
          .map((paymentJson) => Payment.fromJson(paymentJson))
          .toList(),
      recentHomework: (json['recentHomework'] as List<dynamic>? ?? [])
          .map((homeworkJson) => Homework.fromJson(homeworkJson))
          .toList(),
      statistics: json['statistics'] != null
          ? StudentStatistics.fromJson(json['statistics'])
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
}

/// Generic API error response
class ApiErrorResponse {
  final String message;
  final int? code;
  final String? details;

  ApiErrorResponse({
    required this.message,
    this.code,
    this.details,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      message: json['message'] ?? 'Unknown error',
      code: json['code'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
      'details': details,
    };
  }
}

/// Generic API success response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiErrorResponse? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {int? code, String? details}) {
    return ApiResponse<T>(
      success: false,
      error: ApiErrorResponse(
        message: message,
        code: code,
        details: details,
      ),
    );
  }

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    if (json['success'] == true || json['error'] == null) {
      return ApiResponse<T>(
        success: true,
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        message: json['message'],
      );
    } else {
      return ApiResponse<T>(
        success: false,
        error: ApiErrorResponse.fromJson(json['error'] ?? json),
        message: json['message'],
      );
    }
  }
}
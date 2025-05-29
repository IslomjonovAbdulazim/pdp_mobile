class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String studentId;
  final String phone;
  final String? profileImage;
  final DateTime dateOfBirth;
  final String address;
  final String course;
  final int semester;
  final double? gpa;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.phone,
    this.profileImage,
    required this.dateOfBirth,
    required this.address,
    required this.course,
    required this.semester,
    this.gpa,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get full name
  String get fullName => '$firstName $lastName';

  // Get initials
  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  // Calculate age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Create from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      studentId: json['student_id'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'],
      dateOfBirth: DateTime.parse(json['date_of_birth'] ?? DateTime.now().toIso8601String()),
      address: json['address'] ?? '',
      course: json['course'] ?? '',
      semester: json['semester'] ?? 1,
      gpa: json['gpa']?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'student_id': studentId,
      'phone': phone,
      'profile_image': profileImage,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'address': address,
      'course': course,
      'semester': semester,
      'gpa': gpa,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  Student copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? studentId,
    String? phone,
    String? profileImage,
    DateTime? dateOfBirth,
    String? address,
    String? course,
    int? semester,
    double? gpa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      course: course ?? this.course,
      semester: semester ?? this.semester,
      gpa: gpa ?? this.gpa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Student{id: $id, fullName: $fullName, email: $email, studentId: $studentId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Additional models for related data
class Attendance {
  final String id;
  final String studentId;
  final String courseId;
  final String courseName;
  final DateTime date;
  final bool isPresent;
  final String? remarks;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.isPresent,
    this.remarks,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      courseId: json['course_id'] ?? '',
      courseName: json['course_name'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      isPresent: json['is_present'] ?? false,
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'course_id': courseId,
      'course_name': courseName,
      'date': date.toIso8601String(),
      'is_present': isPresent,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Exam {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String courseName;
  final DateTime examDate;
  final int duration; // in minutes
  final int totalMarks;
  final String status; // upcoming, ongoing, completed
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.courseName,
    required this.examDate,
    required this.duration,
    required this.totalMarks,
    required this.status,
    required this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      courseId: json['course_id'] ?? '',
      courseName: json['course_name'] ?? '',
      examDate: DateTime.parse(json['exam_date'] ?? DateTime.now().toIso8601String()),
      duration: json['duration'] ?? 60,
      totalMarks: json['total_marks'] ?? 100,
      status: json['status'] ?? 'upcoming',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course_id': courseId,
      'course_name': courseName,
      'exam_date': examDate.toIso8601String(),
      'duration': duration,
      'total_marks': totalMarks,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Homework {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String courseName;
  final DateTime dueDate;
  final String status; // pending, submitted, graded
  final String? submissionUrl;
  final int? grade;
  final String? feedback;
  final DateTime createdAt;

  Homework({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.courseName,
    required this.dueDate,
    required this.status,
    this.submissionUrl,
    this.grade,
    this.feedback,
    required this.createdAt,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      courseId: json['course_id'] ?? '',
      courseName: json['course_name'] ?? '',
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      submissionUrl: json['submission_url'],
      grade: json['grade'],
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course_id': courseId,
      'course_name': courseName,
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'submission_url': submissionUrl,
      'grade': grade,
      'feedback': feedback,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
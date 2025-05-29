class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://your-api-domain.com/api';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String studentsEndpoint = '/students';
  static const String attendanceEndpoint = '/attendance';
  static const String examsEndpoint = '/exams';
  static const String homeworkEndpoint = '/homework';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // App Settings
  static const String appName = 'PDP Mobile';
  static const String appVersion = '1.0.0';

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String validationError = 'Please check your input';
  static const String loginRequired = 'Please login to continue';

  // Success Messages
  static const String loginSuccess = 'Successfully logged in';
  static const String registerSuccess = 'Registration successful';
  static const String dataUpdated = 'Data updated successfully';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
}
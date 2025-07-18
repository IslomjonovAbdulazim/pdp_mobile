// lib/routes/app_routes.dart
import 'package:get/get.dart';
import 'package:pdp_mobile/pages/main_page.dart';
import '../pages/landing_page.dart';
import '../pages/login_page.dart';
import '../pages/password_entry_page.dart';
import '../pages/sms_verification_page.dart';
import '../pages/student_selection_page.dart';
import '../pages/register_page.dart';
import '../pages/home_page.dart';
import '../pages/exams_page.dart';
import '../pages/payments_page.dart';
import '../pages/homework_page.dart';
import '../middleware/auth_middleware.dart';

class AppRoutes {
  static const String landing = '/landing';
  static const String login = '/login';
  static const String passwordEntry = '/password-entry';
  static const String smsVerification = '/sms-verification';
  static const String studentSelection = '/student-selection';
  static const String register = '/register';
  static const String home = '/home';
  static const String main = '/main';
  static const String exams = '/exams';
  static const String payments = '/payments';
  static const String homework = '/homework';

  static List<GetPage> routes = [
    GetPage(
      name: landing,
      page: () => const LandingPage(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: passwordEntry,
      page: () => const PasswordEntryPage(),
    ),
    GetPage(
      name: smsVerification,
      page: () => const SmsVerificationPage(),
    ),
    GetPage(
      name: studentSelection,
      page: () => const StudentSelectionPage(),
    ),
    GetPage(
      name: main,
      page: () => const MainPage(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: exams,
      page: () => const ExamsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: payments,
      page: () => const PaymentsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: homework,
      page: () => const HomeworkPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
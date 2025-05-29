import 'package:get/get.dart';
import '../features/auth/landing_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/auth/waiting_confirmation_page.dart';
import '../features/home/home_page.dart';
import '../features/attendance/attendance_page.dart';
import '../features/exams/exam_page.dart';
import '../features/homework/homework_page.dart';
import '../app/route_guard.dart';

class AppRoutes {
  // Route names
  static const String initial = '/';
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String waitingConfirmation = '/waiting-confirmation';
  static const String home = '/home';
  static const String attendance = '/attendance';
  static const String exams = '/exams';
  static const String homework = '/homework';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Get pages configuration
  static List<GetPage> pages = [
    // Auth Routes
    GetPage(
      name: landing,
      page: () => const LandingPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: waitingConfirmation,
      page: () => const WaitingConfirmationPage(),
      transition: Transition.rightToLeft,
    ),

    // Protected Routes
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      middlewares: [RouteGuard()],
    ),
    GetPage(
      name: attendance,
      page: () => const AttendancePage(),
      transition: Transition.rightToLeft,
      middlewares: [RouteGuard()],
    ),
    GetPage(
      name: exams,
      page: () => const ExamPage(),
      transition: Transition.rightToLeft,
      middlewares: [RouteGuard()],
    ),
    GetPage(
      name: homework,
      page: () => const HomeworkPage(),
      transition: Transition.rightToLeft,
      middlewares: [RouteGuard()],
    ),
  ];

  // Helper methods for navigation
  static void toLogin() {
    Get.toNamed(login);
  }

  static void toRegister() {
    Get.toNamed(register);
  }

  static void toWaitingConfirmation() {
    Get.toNamed(waitingConfirmation);
  }

  static void toHome() {
    Get.offAllNamed(home);
  }

  static void toAttendance() {
    Get.toNamed(attendance);
  }

  static void toExams() {
    Get.toNamed(exams);
  }

  static void toHomework() {
    Get.toNamed(homework);
  }

  static void toLanding() {
    Get.offAllNamed(landing);
  }

  // Navigation with arguments
  static void toExamDetail(String examId) {
    Get.toNamed('$exams/detail', arguments: {'examId': examId});
  }

  static void toHomeworkDetail(String homeworkId) {
    Get.toNamed('$homework/detail', arguments: {'homeworkId': homeworkId});
  }

  // Back navigation
  static void back() {
    Get.back();
  }

  // Check if can go back
  static bool canGoBack() {
    return Get.key.currentState?.canPop() ?? false;
  }

  // Get current route
  static String getCurrentRoute() {
    return Get.currentRoute;
  }

  // Clear all routes and go to specific route
  static void offAllTo(String routeName) {
    Get.offAllNamed(routeName);
  }

  // Go to route and clear until specific route
  static void offNamedUntil(String routeName, String untilRoute) {
    Get.offNamedUntil(routeName, ModalRoute.withName(untilRoute));
  }
}
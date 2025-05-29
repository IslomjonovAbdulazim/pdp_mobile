import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app_theme.dart';
import 'app/app_routes.dart';
import 'core/storage_service.dart';
import 'features/auth/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService.init();

  // Initialize auth controller
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PDP Mobile',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: _getInitialRoute(),
      getPages: AppRoutes.pages,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  String _getInitialRoute() {
    // Check if user is logged in
    if (StorageService.isLoggedIn()) {
      return AppRoutes.home;
    } else {
      return AppRoutes.landing;
    }
  }
}
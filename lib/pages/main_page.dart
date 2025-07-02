// lib/pages/main_page.dart - Main scaffold with bottom navigation
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/main_controller.dart';
import '../pages/exams_page.dart';
import '../pages/home_page.dart';
import '../pages/homework_page.dart';
import '../pages/payments_page.dart';
import '../theme/app_theme.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: Obx(() {
          switch (controller.currentIndex) {
            case 0:
              return Text(
                'Salom, ${authController.userName.split(' ').first}!',
              );
            case 1:
              return const Text(
                'Imtihonlar',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              );
            case 2:
              return const Text(
                'To\'lovlar',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              );
            case 3:
              return const Text(
                'Vazifalar',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              );
            default:
              return const Text(
                'PDP Academy',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              );
          }
        }),

        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: PopupMenuButton(
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Obx(
                    () => Text(
                      authController.userInitials,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.infoBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppTheme.infoBlue,
                            size: 20,
                          ),
                        ),
                        title: const Text('Profil'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () {
                        // TODO: Navigate to profile page
                      },
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.logout,
                            color: AppTheme.errorRed,
                            size: 20,
                          ),
                        ),
                        title: const Text('Chiqish'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () => _showLogoutDialog(context, authController),
                    ),
                  ],
            ),
          ),
        ],
      ),
      body: Obx(() {
        switch (controller.currentIndex) {
          case 0:
            return const HomePage();
          case 1:
            return const ExamsPage();
          case 2:
            return const PaymentsPage();
          case 3:
            return const HomeworkPage();
          default:
            return const HomePage();
        }
      }),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Bosh sahifa',
                    index: 0,
                    controller: controller,
                  ),
                  _buildNavItem(
                    icon: Icons.quiz_outlined,
                    activeIcon: Icons.quiz,
                    label: 'Imtihonlar',
                    index: 1,
                    controller: controller,
                  ),
                  _buildNavItem(
                    icon: Icons.payment_outlined,
                    activeIcon: Icons.payment,
                    label: 'To\'lovlar',
                    index: 2,
                    controller: controller,
                  ),
                  _buildNavItem(
                    icon: Icons.assignment_outlined,
                    activeIcon: Icons.assignment,
                    label: 'Vazifalar',
                    index: 3,
                    controller: controller,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required MainController controller,
  }) {
    final isActive = controller.currentIndex == index;

    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppTheme.primaryGreen.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color:
                    isActive ? AppTheme.primaryGreen : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color:
                    isActive ? AppTheme.primaryGreen : AppTheme.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.logout, color: AppTheme.errorRed, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Chiqish'),
              ],
            ),
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Hisobingizdan chiqishga ishonchingiz komilmi?',
                style: TextStyle(height: 1.5),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Bekor qilish',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    authController.logout();
                  },
                  child: const Text(
                    'Chiqish',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

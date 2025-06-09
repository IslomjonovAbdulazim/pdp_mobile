// lib/pages/student_selection_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../data/models/auth_models.dart';
import '../theme/app_theme.dart';

class StudentSelectionPage extends StatelessWidget {
  const StudentSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('O\'quvchi tanlash'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.buttonShadow,
                      ),
                      child: const Icon(
                        Icons.people,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'O\'quvchi tanlang',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ushbu telefon raqamga bog\'langan o\'quvchilardan birini tanlang',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Students List
              Expanded(
                child: Obx(() {
                  final students = authController.availableStudents;

                  if (students.isEmpty) {
                    return const Center(
                      child: Text('Hech qanday o\'quvchi topilmadi'),
                    );
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _buildStudentCard(student, authController, theme);
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context, authController),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Boshqa telefon raqam bilan kirish',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(
      Student student,
      AuthController authController,
      ThemeData theme,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => authController.selectStudent(student.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.primaryColor,
                backgroundImage: student.avatarUrl != null
                    ? NetworkImage(student.avatarUrl!)
                    : null,
                child: student.avatarUrl == null
                    ? Text(
                  student.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),

              const SizedBox(width: 16),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (student.course != null) ...[
                      Text(
                        'Kurs: ${student.course}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    if (student.group != null) ...[
                      Text(
                        'Guruh: ${student.group}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: theme.primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chiqish'),
        content: const Text(
          'Boshqa telefon raqam bilan kirishni xohlaysizmi? Bu jarayon sizni tizimdan chiqaradi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            child: const Text(
              'Ha, chiqish',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
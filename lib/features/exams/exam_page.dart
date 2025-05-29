import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/exams/exam_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_textfield.dart';
import '../../data/models/student_model.dart';

class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExamController());
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exams'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Exams', icon: Icon(Icons.quiz)),
              Tab(text: 'Results', icon: Icon(Icons.grade)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _showUpcomingNotifications(context, controller),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading) {
            return const LoadingWidget(message: 'Loading exams...');
          }

          return TabBarView(
            children: [
              _buildExamsTab(context, controller),
              _buildResultsTab(context, controller),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildExamsTab(BuildContext context, ExamController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  hint: 'Search exams...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: controller.updateSearchQuery,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() => Row(
                    children: controller.filterOptions.map((filter) {
                      final isSelected = controller.selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => controller.changeFilter(filter),
                        ),
                      );
                    }).toList(),
                  )),
                ),
              ],
            ),
          ),

          // Exams List
          Expanded(
            child: Obx(() {
              final examList = controller.filteredExamList;

              if (examList.isEmpty) {
                return const NoDataWidget(
                  title: 'No Exams Found',
                  message: 'No exams match your current filters.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: examList.length,
                itemBuilder: (context, index) {
                  final exam = examList[index];
                  return _buildExamCard(context, exam, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Exam exam, ExamController controller) {
    final theme = Theme.of(context);
    final statusColor = controller.getExamStatusColor(exam.status);
    final hasResult = controller.hasResult(exam.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showExamDetails(context, exam, controller),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.getExamStatusIcon(exam.status),
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          exam.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (hasResult)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'RESULT',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title and course
              Text(
                exam.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exam.courseName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                exam.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Info row
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    controller.formatExamDateTime(exam.examDate),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    controller.formatDuration(exam.duration),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '${exam.totalMarks} marks',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsTab(BuildContext context, ExamController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance Summary
            _buildPerformanceSummary(context, controller),
            const SizedBox(height: 24),

            // Results List
            Text(
              'Exam Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Obx(() {
              final results = controller.examResults;

              if (results.isEmpty) {
                return const NoDataWidget(
                  title: 'No Results Available',
                  message: 'Exam results will appear here once published.',
                );
              }

              return Column(
                children: results.map((result) => _buildResultCard(context, result, controller)).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary(BuildContext context, ExamController controller) {
    final theme = Theme.of(context);
    final performance = controller.overallPerformance;
    final averagePercentage = performance['average_percentage'] as double;
    final totalExams = performance['total_exams'] as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceItem(
                    'Average Score',
                    '${averagePercentage.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    controller.getGradeColor(_getGradeFromPercentage(averagePercentage)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPerformanceItem(
                    'Total Exams',
                    totalExams.toString(),
                    Icons.quiz,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, Map<String, dynamic> result, ExamController controller) {
    final theme = Theme.of(context);
    final percentage = result['percentage'] as double;
    final grade = result['grade'] as String;
    final gradeColor = controller.getGradeColor(grade);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['exam_title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result['course_name'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: gradeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    grade,
                    style: TextStyle(
                      color: gradeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Score details
            Row(
              children: [
                Expanded(
                  child: _buildScoreItem(
                    'Score',
                    '${result['marks_obtained']}/${result['total_marks']}',
                    Icons.grade,
                  ),
                ),
                Expanded(
                  child: _buildScoreItem(
                    'Percentage',
                    '${percentage.toStringAsFixed(1)}%',
                    Icons.percent,
                  ),
                ),
                Expanded(
                  child: _buildScoreItem(
                    'Grade',
                    grade,
                    Icons.star,
                  ),
                ),
              ],
            ),

            if (result['remarks'] != null && (result['remarks'] as String).isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remarks',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result['remarks'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),
            // Date info
            Row(
              children: [
                Icon(Icons.event, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Exam: ${_formatDate(result['exam_date'] as DateTime)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Icon(Icons.publish, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Result: ${_formatDate(result['result_date'] as DateTime)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showExamDetails(BuildContext context, Exam exam, ExamController controller) {
    final result = controller.getExamResult(exam.id);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exam.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Details
              _buildDetailRow('Course', exam.courseName),
              _buildDetailRow('Date', controller.formatExamDateTime(exam.examDate)),
              _buildDetailRow('Duration', controller.formatDuration(exam.duration)),
              _buildDetailRow('Total Marks', '${exam.totalMarks}'),
              _buildDetailRow('Status', exam.status.toUpperCase()),

              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(exam.description),

              if (result != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Result',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Score', '${result['marks_obtained']}/${result['total_marks']}'),
                _buildDetailRow('Percentage', '${result['percentage']}%'),
                _buildDetailRow('Grade', result['grade']),
                if (result['remarks'] != null && (result['remarks'] as String).isNotEmpty)
                  _buildDetailRow('Remarks', result['remarks']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showUpcomingNotifications(BuildContext context, ExamController controller) {
    final upcomingExams = controller.upcomingExamsWithin24Hours;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upcoming Exams'),
        content: upcomingExams.isEmpty
            ? const Text('No exams scheduled within 24 hours.')
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: upcomingExams.map((exam) => ListTile(
            title: Text(exam.title),
            subtitle: Text(controller.formatExamDateTime(exam.examDate)),
            leading: Icon(
              Icons.warning,
              color: Colors.orange,
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getGradeFromPercentage(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 85) return 'A';
    if (percentage >= 80) return 'A-';
    if (percentage >= 75) return 'B+';
    if (percentage >= 70) return 'B';
    if (percentage >= 65) return 'B-';
    if (percentage >= 60) return 'C+';
    if (percentage >= 55) return 'C';
    if (percentage >= 50) return 'C-';
    if (percentage >= 40) return 'D';
    return 'F';
  }
}
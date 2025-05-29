import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/homework/homework_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../data/models/student_model.dart';

class HomeworkPage extends StatelessWidget {
  const HomeworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeworkController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showDeadlineNotifications(context, controller),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Statistics'),
                onTap: () => _showStatistics(context, controller),
              ),
              PopupMenuItem(
                child: const Text('Upcoming Deadlines'),
                onTap: () => _showUpcomingDeadlines(context, controller),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const LoadingWidget(message: 'Loading homework...');
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: Column(
            children: [
              // Statistics Summary
              _buildStatsSummary(context, controller),

              // Search and Filter Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      hint: 'Search homework...',
                      prefixIcon: const Icon(Icons.search),
                      onChanged: controller.updateSearchQuery,
                    ),
                    const SizedBox(height: 12),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(() => Row(
                        children: [
                          ...controller.filterOptions.map((filter) {
                            final isSelected = controller.selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (_) => controller.changeFilter(filter),
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          // Course filter dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButton<String>(
                              value: controller.selectedCourse,
                              underline: const SizedBox(),
                              items: controller.courses.map((course) {
                                return DropdownMenuItem(
                                  value: course,
                                  child: Text(course, style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.changeCourse(value);
                                }
                              },
                            ),
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              ),

              // Homework List
              Expanded(
                child: Obx(() {
                  final homeworkList = controller.filteredHomeworkList;

                  if (homeworkList.isEmpty) {
                    return const NoDataWidget(
                      title: 'No Homework Found',
                      message: 'No homework matches your current filters.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: homeworkList.length,
                    itemBuilder: (context, index) {
                      final homework = homeworkList[index];
                      return _buildHomeworkCard(context, homework, controller);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatsSummary(BuildContext context, HomeworkController controller) {
    final theme = Theme.of(context);
    final stats = controller.homeworkStats;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total',
                      '${stats['total']}',
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Pending',
                      '${stats['pending']}',
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Overdue',
                      '${stats['overdue']}',
                      Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Graded',
                      '${stats['graded']}',
                      Colors.green,
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildHomeworkCard(BuildContext context, Homework homework, HomeworkController controller) {
    final theme = Theme.of(context);
    final status = controller.getHomeworkStatus(homework);
    final statusColor = controller.getHomeworkStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showHomeworkDetails(context, homework, controller),
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
                          controller.getHomeworkStatusIcon(status),
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
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
                  if (homework.grade != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: controller.getGradeColor(homework.grade).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${homework.grade}/100',
                        style: TextStyle(
                          color: controller.getGradeColor(homework.grade),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title and course
              Text(
                homework.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                homework.courseName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                homework.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Due date and actions
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: status == 'overdue' ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    controller.formatDueDate(homework.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: status == 'overdue' ? Colors.red : Colors.grey[600],
                      fontWeight: status == 'overdue' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (controller.canSubmitHomework(homework))
                    TextButton(
                      onPressed: () => _showSubmissionDialog(context, homework, controller),
                      child: const Text('Submit', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHomeworkDetails(BuildContext context, Homework homework, HomeworkController controller) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        homework.title,
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

                // Course and status
                _buildDetailRow('Course', homework.courseName),
                _buildDetailRow('Status', controller.getHomeworkStatus(homework).toUpperCase()),
                _buildDetailRow('Due Date', controller.formatDate(homework.dueDate)),
                _buildDetailRow('Assigned Date', controller.formatDate(homework.createdAt)),

                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(homework.description),

                if (homework.submissionUrl != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow('Submission', 'Submitted'),
                  TextButton(
                    onPressed: () {
                      // Open submission URL
                      Get.snackbar('Submission', 'Opening submission...');
                    },
                    child: const Text('View Submission'),
                  ),
                ],

                if (homework.grade != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Grade & Feedback',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Grade', '${homework.grade}/100'),
                  if (homework.feedback != null && homework.feedback!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
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
                              'Feedback:',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(homework.feedback!),
                          ],
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 16),
                if (controller.canSubmitHomework(homework))
                  PrimaryButton(
                    text: 'Submit Homework',
                    onPressed: () {
                      Navigator.pop(context);
                      _showSubmissionDialog(context, homework, controller);
                    },
                    width: double.infinity,
                  ),
              ],
            ),
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

  void _showSubmissionDialog(BuildContext context, Homework homework, HomeworkController controller) {
    final submissionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Homework'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Submit your homework for: ${homework.title}'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: submissionController,
              hint: 'Enter submission URL or file path',
              label: 'Submission URL',
              prefixIcon: const Icon(Icons.link),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Obx(() => TextButton(
            onPressed: controller.isLoading
                ? null
                : () {
              if (submissionController.text.isNotEmpty) {
                controller.submitHomework(homework.id, submissionController.text);
                Navigator.pop(context);
              }
            },
            child: controller.isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Submit'),
          )),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context, HomeworkController controller) {
    final stats = controller.homeworkStats;
    final averageGrade = controller.averageGrade;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Homework Statistics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total Homework', '${stats['total']}'),
              _buildStatRow('Pending', '${stats['pending']}'),
              _buildStatRow('Submitted', '${stats['submitted']}'),
              _buildStatRow('Graded', '${stats['graded']}'),
              _buildStatRow('Overdue', '${stats['overdue']}'),
              const Divider(),
              _buildStatRow('Average Grade', averageGrade > 0 ? '${averageGrade.toStringAsFixed(1)}/100' : 'N/A'),
            ],
          ),
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showUpcomingDeadlines(BuildContext context, HomeworkController controller) {
    final upcomingDeadlines = controller.upcomingDeadlines;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upcoming Deadlines'),
        content: upcomingDeadlines.isEmpty
            ? const Text('No upcoming deadlines within 7 days.')
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: upcomingDeadlines.map((homework) => ListTile(
            title: Text(homework.title),
            subtitle: Text(homework.courseName),
            trailing: Text(
              controller.formatDueDate(homework.dueDate),
              style: const TextStyle(fontSize: 12),
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

  void _showDeadlineNotifications(BuildContext context, HomeworkController controller) {
    final overdueHomework = controller.overdueHomework;
    final upcomingDeadlines = controller.upcomingDeadlines;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deadline Notifications'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overdueHomework.isNotEmpty) ...[
                Text(
                  'Overdue (${overdueHomework.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                ...overdueHomework.map((homework) => ListTile(
                  dense: true,
                  title: Text(homework.title),
                  subtitle: Text(homework.courseName),
                  leading: const Icon(Icons.warning, color: Colors.red, size: 20),
                )),
                const Divider(),
              ],
              if (upcomingDeadlines.isNotEmpty) ...[
                Text(
                  'Due Soon (${upcomingDeadlines.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                ...upcomingDeadlines.map((homework) => ListTile(
                  dense: true,
                  title: Text(homework.title),
                  subtitle: Text(homework.courseName),
                  leading: const Icon(Icons.schedule, color: Colors.orange, size: 20),
                  trailing: Text(
                    controller.formatDueDate(homework.dueDate),
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
              ],
              if (overdueHomework.isEmpty && upcomingDeadlines.isEmpty)
                const Text('No urgent deadlines at the moment.'),
            ],
          ),
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
}
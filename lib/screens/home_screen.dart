import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../widgets/app_card.dart';
import '../widgets/attendance_summary_card.dart';
import '../widgets/pill.dart';
import '../widgets/subject_form_dialog.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.onSeeAllTasks,
  });

  final AppController controller;
  final VoidCallback onSeeAllTasks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 24),
            SizedBox(width: 10),
            Text('Campus Companion'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final now = DateTime.now();
          final textTheme = Theme.of(context).textTheme;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                greetingFor(now),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatLongDate(now),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 16),
              AttendanceSummaryCard(
                percentage: controller.overallAttendance,
                attended: controller.totalAttended,
                total: controller.totalConducted,
                subjectCount: controller.subjects.length,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.pending_actions,
                      label: 'Pending tasks',
                      value: controller.pendingCount,
                      color: AppColors.warning,
                      background: AppColors.warningBg,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.task_alt,
                      label: 'Completed',
                      value: controller.completedCount,
                      color: AppColors.success,
                      background: AppColors.successBg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Quick actions',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => showSubjectDialog(context, controller),
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Add attendance'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => openTaskForm(context, controller),
                      icon: const Icon(Icons.add_task),
                      label: const Text('Add task'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Upcoming deadlines',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onSeeAllTasks,
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ..._buildUpcoming(context),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildUpcoming(BuildContext context) {
    final upcoming = controller.upcomingTasks();
    if (upcoming.isEmpty) {
      return [
        AppCard(
          child: Row(
            children: [
              const Icon(Icons.event_available, color: AppColors.navy),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.tasks.isEmpty
                      ? 'No deadlines yet. Add a task to get started.'
                      : 'No pending deadlines. Nice work!',
                ),
              ),
            ],
          ),
        ),
      ];
    }
    return [
      for (final task in upcoming) ...[
        _UpcomingTile(
          task: task,
          onTap: () {
            openTaskForm(context, controller, existing: task);
          },
        ),
        const SizedBox(height: 8),
      ],
    ];
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final overdue = task.isOverdue();
    final (priorityFg, priorityBg) = priorityColors(task.priority);
    return AppCard(
      onTap: onTap,
      color: overdue ? const Color(0xFFFFF7F7) : Colors.white,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            overdue ? Icons.warning_amber_rounded : Icons.event_outlined,
            color: overdue ? AppColors.danger : AppColors.navy,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dueLabel(task.dueDate, completed: false),
                  style: TextStyle(
                    fontSize: 12,
                    color: overdue ? AppColors.danger : AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Pill(
            text: task.priority.label,
            foreground: priorityFg,
            background: priorityBg,
          ),
        ],
      ),
    );
  }
}

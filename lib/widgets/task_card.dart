import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import 'app_card.dart';
import 'pill.dart';

/// Colours used for each priority level.
(Color, Color) priorityColors(Priority p) {
  switch (p) {
    case Priority.low:
      return (AppColors.success, AppColors.successBg);
    case Priority.medium:
      return (AppColors.warning, AppColors.warningBg);
    case Priority.high:
      return (AppColors.danger, AppColors.dangerBg);
  }
}

/// Card for one task. Overdue pending tasks are highlighted in red.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final overdue = task.isOverdue();
    final (priorityFg, priorityBg) = priorityColors(task.priority);
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      color: overdue ? const Color(0xFFFFF7F7) : Colors.white,
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      onTap: onEdit,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(value: task.completed, onChanged: (_) => onToggle()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.completed ? AppColors.mutedText : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Pill(
                        icon: overdue
                            ? Icons.warning_amber_rounded
                            : Icons.event_outlined,
                        text: dueLabel(task.dueDate, completed: task.completed),
                        foreground: overdue ? AppColors.danger : AppColors.navy,
                        background: overdue
                            ? AppColors.dangerBg
                            : AppColors.lightBlue,
                      ),
                      Pill(
                        text: '${task.priority.label} priority',
                        foreground: priorityFg,
                        background: priorityBg,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40,
            width: 40,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              tooltip: 'More options',
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else {
                  onDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

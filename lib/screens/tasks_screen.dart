import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/app_controller.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

enum TaskFilter { all, pending, completed }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskFilter _filter = TaskFilter.all;

  AppController get _c => widget.controller;

  List<Task> _visibleTasks() {
    final all = _c.sortedTasks();
    switch (_filter) {
      case TaskFilter.all:
        return all;
      case TaskFilter.pending:
        return all.where((t) => !t.completed).toList();
      case TaskFilter.completed:
        return all.where((t) => t.completed).toList();
    }
  }

  Future<void> _delete(Task task) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDelete(
      context,
      title: 'Delete task?',
      message: '"${task.title}" will be removed permanently.',
    );
    if (!ok) return;
    await _c.deleteTask(task.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Task deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openTaskForm(context, _c),
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: ListenableBuilder(
        listenable: _c,
        builder: (context, _) {
          final tasks = _visibleTasks();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TaskFilter>(
                    segments: const [
                      ButtonSegment(value: TaskFilter.all, label: Text('All')),
                      ButtonSegment(
                        value: TaskFilter.pending,
                        label: Text('Pending'),
                      ),
                      ButtonSegment(
                        value: TaskFilter.completed,
                        label: Text('Done'),
                      ),
                    ],
                    selected: {_filter},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) =>
                        setState(() => _filter = s.first),
                  ),
                ),
              ),
              Expanded(child: _buildList(tasks)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<Task> tasks) {
    if (_c.tasks.isEmpty) {
      return EmptyState(
        icon: Icons.task_alt,
        title: 'No tasks yet',
        message: 'Add assignments and deadlines so you never miss one.',
        actionLabel: 'Add task',
        onAction: () => openTaskForm(context, _c),
      );
    }
    if (tasks.isEmpty) {
      return EmptyState(
        icon: Icons.filter_list,
        title: _filter == TaskFilter.pending
            ? 'No pending tasks'
            : 'No completed tasks',
        message: _filter == TaskFilter.pending
            ? 'You are all caught up.'
            : 'Completed tasks will show up here.',
      );
    }
    return ListView.separated(
      // Extra bottom space so the floating button never hides the last card.
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          key: ValueKey(task.id),
          task: task,
          onToggle: () => _c.toggleTask(task.id),
          onEdit: () => openTaskForm(context, _c, existing: task),
          onDelete: () => _delete(task),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';

/// Opens the add/edit task screen and shows a success message when saved.
Future<void> openTaskForm(
  BuildContext context,
  AppController controller, {
  Task? existing,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) =>
          TaskFormScreen(controller: controller, existing: existing),
    ),
  );
  if (saved == true) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(existing == null ? 'Task added' : 'Task updated'),
        ),
      );
  }
}

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, required this.controller, this.existing});

  final AppController controller;
  final Task? existing;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late DateTime _dueDate;
  late Priority _priority;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    // New tasks default to tomorrow.
    _dueDate =
        t?.dueDate ?? dateOnly(DateTime.now().add(const Duration(days: 1)));
    _priority = t?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = dateOnly(picked));
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final existing = widget.existing;
    if (existing == null) {
      await widget.controller.addTask(
        title: _title.text,
        description: _description.text,
        dueDate: _dueDate,
        priority: _priority,
      );
    } else {
      await widget.controller.updateTask(
        existing.id,
        title: _title.text,
        description: _description.text,
        dueDate: _dueDate,
        priority: _priority,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Add task' : 'Edit task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: appInputDecoration('Title'),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLength: 80,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Enter a title';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  decoration: appInputDecoration(
                    'Description (optional)',
                    alignLabelWithHint: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 300,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: appInputDecoration(
                      'Due date',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(formatDate(_dueDate)),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Priority', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<Priority>(
                    segments: [
                      for (final p in Priority.values)
                        ButtonSegment<Priority>(value: p, label: Text(p.label)),
                    ],
                    selected: {_priority},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        setState(() => _priority = selection.first),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: Text(
                      widget.existing == null ? 'Add task' : 'Save changes',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

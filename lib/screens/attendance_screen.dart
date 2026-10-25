import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../services/app_controller.dart';
import '../widgets/attendance_summary_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/subject_card.dart';
import '../widgets/subject_form_dialog.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key, required this.controller});

  final AppController controller;

  Future<void> _delete(BuildContext context, Subject subject) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDelete(
      context,
      title: 'Delete subject?',
      message: '"${subject.name}" and its attendance record will be removed.',
    );
    if (!ok) return;
    await controller.deleteSubject(subject.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Subject deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSubjectDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add subject'),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final subjects = controller.subjects;
          if (subjects.isEmpty) {
            return EmptyState(
              icon: Icons.school_outlined,
              title: 'No subjects yet',
              message: 'Add your subjects and record classes attended to track attendance.',
              actionLabel: 'Add subject',
              onAction: () => showSubjectDialog(context, controller),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: subjects.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return AttendanceSummaryCard(
                  percentage: controller.overallAttendance,
                  attended: controller.totalAttended,
                  total: controller.totalConducted,
                  subjectCount: subjects.length,
                );
              }
              final subject = subjects[index - 1];
              return SubjectCard(
                key: ValueKey(subject.id),
                subject: subject,
                onEdit: () =>
                    showSubjectDialog(context, controller, existing: subject),
                onDelete: () => _delete(context, subject),
              );
            },
          );
        },
      ),
    );
  }
}

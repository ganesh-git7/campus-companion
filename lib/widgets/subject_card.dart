import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../services/attendance_calculator.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'attendance_summary_card.dart';

/// Card for one subject: name, counts, percentage and a 75% warning.
class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final pct = AttendanceCalculator.percentage(
      subject.attended,
      subject.total,
    );
    final hasClasses = subject.total > 0;
    final low = hasClasses && pct < AttendanceCalculator.requiredPercentage;

    final Color color;
    final Color background;
    final IconData icon;
    final String advice;

    if (!hasClasses) {
      color = AppColors.mutedText;
      background = AppColors.background;
      icon = Icons.info_outline;
      advice = 'No classes recorded yet.';
    } else if (low) {
      final needed =
          AttendanceCalculator.classesNeeded(subject.attended, subject.total) ??
          0;
      color = AppColors.danger;
      background = AppColors.dangerBg;
      icon = Icons.warning_amber_rounded;
      advice =
          'Below ${AttendanceCalculator.requiredPercentage}%. Attend the '
          'next ${classesText(needed)} in a row to reach '
          '${AttendanceCalculator.requiredPercentage}%.';
    } else {
      final skip = AttendanceCalculator.classesCanSkip(
        subject.attended,
        subject.total,
      );
      color = AppColors.success;
      background = AppColors.successBg;
      icon = Icons.check_circle_outline;
      advice = skip > 0
          ? 'On track. You can miss ${classesText(skip)} and stay at '
                '${AttendanceCalculator.requiredPercentage}% or above.'
          : 'On track, but right at the limit. Try not to miss the next class.';
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subject.name,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(
                height: 32,
                width: 32,
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
          const SizedBox(height: 4),
          Text(
            '${subject.attended} of ${subject.total} classes attended',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (pct / 100).clamp(0.0, 1.0).toDouble(),
                    minHeight: 8,
                    color: color,
                    backgroundColor: AppColors.lightBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    advice,
                    style: TextStyle(color: color, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

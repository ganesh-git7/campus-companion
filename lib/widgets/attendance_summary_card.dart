import 'package:flutter/material.dart';

import '../services/attendance_calculator.dart';
import 'app_card.dart';

String classesText(int n) => n == 1 ? '1 class' : '$n classes';

/// Navy card showing overall attendance (used on Home and Attendance).
class AttendanceSummaryCard extends StatelessWidget {
  const AttendanceSummaryCard({
    super.key,
    required this.percentage,
    required this.attended,
    required this.total,
    required this.subjectCount,
  });

  final double percentage;
  final int attended;
  final int total;
  final int subjectCount;

  @override
  Widget build(BuildContext context) {
    final hasData = total > 0;
    final low = hasData && percentage < AttendanceCalculator.requiredPercentage;
    final needed = AttendanceCalculator.classesNeeded(attended, total) ?? 0;

    final String status;
    if (!hasData) {
      status = 'Add subjects and classes to see your attendance.';
    } else if (low) {
      status =
          'Below ${AttendanceCalculator.requiredPercentage}%. Attend the '
          'next ${classesText(needed)} in a row to reach '
          '${AttendanceCalculator.requiredPercentage}% overall.';
    } else {
      status =
          'Great job! You are above '
          '${AttendanceCalculator.requiredPercentage}%.';
    }

    return AppCard(
      color: const Color(0xFF14285B),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall attendance',
            style: TextStyle(color: Color(0xFFBFD3F2), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: const Color(0xFF3A4F8A),
              color: low ? const Color(0xFFFFB4AB) : const Color(0xFF9FD3FF),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                low ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 18,
                color: low ? const Color(0xFFFFB4AB) : const Color(0xFF9FD3FF),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          if (hasData) ...[
            const SizedBox(height: 8),
            Text(
              '$attended of $total classes across $subjectCount '
              '${subjectCount == 1 ? 'subject' : 'subjects'}',
              style: const TextStyle(color: Color(0xFFBFD3F2), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

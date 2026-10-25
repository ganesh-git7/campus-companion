const _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const _longMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// Drops the time part of a date.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// e.g. "5 Mar 2026"
String formatDate(DateTime d) =>
    '${d.day} ${_shortMonths[d.month - 1]} ${d.year}';

/// e.g. "Sunday, 25 October 2026"
String formatLongDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_longMonths[d.month - 1]} ${d.year}';

/// Whole days from [now] until [due] (negative when [due] is in the past).
/// Uses UTC dates so daylight-saving changes cannot skew the result.
int daysUntil(DateTime due, DateTime now) {
  final a = DateTime.utc(due.year, due.month, due.day);
  final b = DateTime.utc(now.year, now.month, now.day);
  return a.difference(b).inDays;
}

/// Human-friendly due text such as "Due today" or "Overdue by 2 days".
String dueLabel(DateTime due, {required bool completed, DateTime? now}) {
  if (completed) return 'Due ${formatDate(due)}';
  final days = daysUntil(due, now ?? DateTime.now());
  if (days < 0) {
    final n = -days;
    return 'Overdue by $n ${n == 1 ? 'day' : 'days'}';
  }
  if (days == 0) return 'Due today';
  if (days == 1) return 'Due tomorrow';
  return 'Due ${formatDate(due)}';
}

String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}

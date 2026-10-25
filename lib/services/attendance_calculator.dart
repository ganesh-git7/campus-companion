import '../models/subject.dart';

/// All attendance maths lives here (pure Dart, covered by unit tests).
class AttendanceCalculator {
  AttendanceCalculator._();

  /// Minimum attendance percentage required.
  static const int requiredPercentage = 75;

  /// attended / total * 100. Returns 0 when no classes were conducted and
  /// never returns a negative, NaN or >100 value.
  static double percentage(int attended, int total) {
    if (total <= 0 || attended <= 0) return 0;
    final value = attended / total * 100;
    return value > 100 ? 100 : value;
  }

  /// Overall attendance = total attended / total conducted * 100
  /// (NOT the average of the subject percentages).
  static double overallPercentage(Iterable<Subject> subjects) {
    return percentage(totalAttended(subjects), totalConducted(subjects));
  }

  static int totalAttended(Iterable<Subject> subjects) =>
      subjects.fold(0, (sum, s) => sum + s.attended);

  static int totalConducted(Iterable<Subject> subjects) =>
      subjects.fold(0, (sum, s) => sum + s.total);

  /// How many classes in a row must be attended (with no absences) to reach
  /// [target] percent.
  ///
  /// Solves (attended + x) / (total + x) >= target / 100 for the smallest
  /// whole x:  x >= (target * total - 100 * attended) / (100 - target).
  /// Returns 0 if the target is already met, and null when it is
  /// mathematically impossible (target >= 100 while some class was missed).
  static int? classesNeeded(
    int attended,
    int total, {
    int target = requiredPercentage,
  }) {
    if (total <= 0) return 0;
    final numerator = target * total - 100 * attended;
    if (numerator <= 0) return 0;
    final denominator = 100 - target;
    if (denominator <= 0) return null;
    return (numerator + denominator - 1) ~/ denominator; // ceiling division
  }

  /// How many upcoming classes can be missed while staying at or above
  /// [target] percent.
  ///
  /// Solves attended / (total + y) >= target / 100 for the largest whole y.
  static int classesCanSkip(
    int attended,
    int total, {
    int target = requiredPercentage,
  }) {
    if (total <= 0 || target <= 0) return 0;
    final numerator = 100 * attended - target * total;
    if (numerator < 0) return 0;
    return numerator ~/ target;
  }

  /// Returns an error message, or null when the pair of numbers is valid.
  static String? validateCounts(int attended, int total) {
    if (attended < 0 || total < 0) return 'Values cannot be negative';
    if (attended > total) return 'Attended classes cannot exceed total classes';
    return null;
  }
}

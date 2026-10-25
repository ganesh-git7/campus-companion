import 'package:campus_companion/models/subject.dart';
import 'package:campus_companion/services/attendance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Subject _subject(int attended, int total) =>
    Subject(id: 'x', name: 'Math', attended: attended, total: total);

void main() {
  group('percentage', () {
    test('is 0 when zero classes were conducted', () {
      expect(AttendanceCalculator.percentage(0, 0), equals(0.0));
    });

    test('calculates attended / total * 100', () {
      expect(AttendanceCalculator.percentage(30, 40), closeTo(75.0, 0.001));
      expect(AttendanceCalculator.percentage(1, 3), closeTo(33.333, 0.001));
      expect(AttendanceCalculator.percentage(10, 10), closeTo(100.0, 0.001));
    });

    test('below 75% is reported correctly', () {
      final pct = AttendanceCalculator.percentage(5, 10);
      expect(pct, closeTo(50.0, 0.001));
      expect(pct < AttendanceCalculator.requiredPercentage, isTrue);
    });

    test('invalid input never gives NaN, negative or above 100', () {
      expect(AttendanceCalculator.percentage(-3, 10), equals(0.0));
      expect(AttendanceCalculator.percentage(5, -10), equals(0.0));
      expect(AttendanceCalculator.percentage(11, 10), closeTo(100.0, 0.001));
    });
  });

  group('overallPercentage', () {
    test('is 0 with no subjects', () {
      expect(AttendanceCalculator.overallPercentage([]), equals(0.0));
    });

    test('is 0 when all subjects have zero classes', () {
      expect(
        AttendanceCalculator.overallPercentage([
          _subject(0, 0),
          _subject(0, 0),
        ]),
        equals(0.0),
      );
    });

    test('uses total attended / total conducted, not an average of percentages', () {
      // 9/10 and 1/30 -> 10/40 = 25%. (Averaging 90% and 3.3% would be wrong.)
      final pct = AttendanceCalculator.overallPercentage([
        _subject(9, 10),
        _subject(1, 30),
      ]);
      expect(pct, closeTo(25.0, 0.001));
    });
  });

  group('classesNeeded (to reach 75%)', () {
    test('is 0 when there are no classes yet', () {
      expect(AttendanceCalculator.classesNeeded(0, 0), equals(0));
    });

    test('is 0 when attendance is already at or above 75%', () {
      expect(AttendanceCalculator.classesNeeded(30, 40), equals(0));
      expect(AttendanceCalculator.classesNeeded(10, 10), equals(0));
    });

    test('5/10 needs 10 consecutive classes', () {
      expect(AttendanceCalculator.classesNeeded(5, 10), equals(10));
      // (5 + 10) / (10 + 10) = 75%
      expect(AttendanceCalculator.percentage(15, 20), closeTo(75.0, 0.001));
    });

    test('rounds up to a whole class', () {
      // 7/10: x >= 3*10 - 4*7 = 2 -> 9/12 = 75%.
      expect(AttendanceCalculator.classesNeeded(7, 10), equals(2));
      // 0/1: x >= 3 -> 3/4 = 75%.
      expect(AttendanceCalculator.classesNeeded(0, 1), equals(3));
      // 3/5: x >= 15 - 12 = 3 -> 6/8 = 75%.
      expect(AttendanceCalculator.classesNeeded(3, 5), equals(3));
    });

    test('result is the smallest number that reaches 75%', () {
      for (var total = 1; total <= 40; total++) {
        for (var attended = 0; attended <= total; attended++) {
          final x = AttendanceCalculator.classesNeeded(attended, total)!;
          expect((attended + x) * 100 >= 75 * (total + x), isTrue);
          if (x > 0) {
            expect((attended + x - 1) * 100 >= 75 * (total + x - 1), isFalse);
          }
        }
      }
    });

    test('returns null when the target is impossible', () {
      expect(AttendanceCalculator.classesNeeded(9, 10, target: 100), isNull);
      expect(
        AttendanceCalculator.classesNeeded(10, 10, target: 100),
        equals(0),
      );
    });
  });

  group('classesCanSkip', () {
    test('is 0 below 75% or with zero classes', () {
      expect(AttendanceCalculator.classesCanSkip(5, 10), equals(0));
      expect(AttendanceCalculator.classesCanSkip(0, 0), equals(0));
    });

    test('9/10 can skip 2 classes (9/12 = 75%)', () {
      expect(AttendanceCalculator.classesCanSkip(9, 10), equals(2));
    });
  });

  group('validateCounts', () {
    test('accepts valid values', () {
      expect(AttendanceCalculator.validateCounts(0, 0), isNull);
      expect(AttendanceCalculator.validateCounts(8, 10), isNull);
      expect(AttendanceCalculator.validateCounts(10, 10), isNull);
    });

    test('rejects negative values and attended > total', () {
      expect(AttendanceCalculator.validateCounts(-1, 10), isNotNull);
      expect(AttendanceCalculator.validateCounts(1, -10), isNotNull);
      expect(AttendanceCalculator.validateCounts(11, 10), isNotNull);
    });
  });
}

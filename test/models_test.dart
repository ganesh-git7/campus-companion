import 'package:campus_companion/models/subject.dart';
import 'package:campus_companion/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subject', () {
    test('survives a JSON round trip', () {
      const s = Subject(id: '1', name: 'DBMS', attended: 8, total: 10);
      final back = Subject.tryFromJson(s.toJson())!;
      expect(back.name, equals('DBMS'));
      expect(back.attended, equals(8));
      expect(back.total, equals(10));
    });

    test('rejects invalid saved data instead of crashing', () {
      expect(Subject.tryFromJson(null), isNull);
      expect(Subject.tryFromJson('text'), isNull);
      expect(Subject.tryFromJson({'id': '1'}), isNull);
      expect(
        Subject.tryFromJson({
          'id': '1',
          'name': 'A',
          'attended': 5,
          'total': 2,
        }),
        isNull,
      );
      expect(
        Subject.tryFromJson({
          'id': '1',
          'name': 'A',
          'attended': -1,
          'total': 2,
        }),
        isNull,
      );
      expect(
        Subject.tryFromJson({
          'id': '1',
          'name': ' ',
          'attended': 1,
          'total': 2,
        }),
        isNull,
      );
    });
  });

  group('Task', () {
    final due = DateTime(2026, 10, 25);
    final task = Task(
      id: '1',
      title: 'Lab report',
      description: 'Chapter 3',
      dueDate: due,
      priority: Priority.high,
    );

    test('survives a JSON round trip', () {
      final back = Task.tryFromJson(task.toJson())!;
      expect(back.title, equals('Lab report'));
      expect(back.priority == Priority.high, isTrue);
      expect(back.completed, isFalse);
      expect(back.dueDate == due, isTrue);
    });

    test('rejects invalid saved data and defaults unknown priority', () {
      expect(Task.tryFromJson(null), isNull);
      expect(Task.tryFromJson({'id': '1', 'title': 'x'}), isNull);
      expect(
        Task.tryFromJson({'id': '1', 'title': 'x', 'dueDate': 'not-a-date'}),
        isNull,
      );
      final t = Task.tryFromJson({
        'id': '1',
        'title': 'x',
        'dueDate': '2026-10-25T00:00:00.000',
        'priority': 'urgent',
      })!;
      expect(t.priority == Priority.medium, isTrue);
    });

    test('isOverdue only for pending tasks due before today', () {
      final now = DateTime(2026, 10, 25, 15, 30);
      expect(
        task.copyWith(dueDate: DateTime(2026, 10, 24)).isOverdue(now),
        isTrue,
      );
      expect(
        task.copyWith(dueDate: DateTime(2026, 10, 25)).isOverdue(now),
        isFalse,
      );
      expect(
        task.copyWith(dueDate: DateTime(2026, 10, 26)).isOverdue(now),
        isFalse,
      );
      expect(
        task
            .copyWith(dueDate: DateTime(2026, 10, 1), completed: true)
            .isOverdue(now),
        isFalse,
      );
    });
  });
}

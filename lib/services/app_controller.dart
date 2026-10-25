import 'package:flutter/foundation.dart';

import '../models/subject.dart';
import '../models/task.dart';
import 'attendance_calculator.dart';
import 'storage_service.dart';

/// Holds app data in memory, saves every change, and notifies the UI.
class AppController extends ChangeNotifier {
  AppController(this._storage);

  final StorageService _storage;

  List<Subject> _subjects = [];
  List<Task> _tasks = [];

  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Loads saved data. Never throws: on any error the app starts empty.
  Future<void> load() async {
    try {
      _subjects = await _storage.loadSubjects();
      _tasks = await _storage.loadTasks();
    } catch (_) {
      _subjects = [];
      _tasks = [];
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------- stats

  double get overallAttendance =>
      AttendanceCalculator.overallPercentage(_subjects);
  int get totalAttended => AttendanceCalculator.totalAttended(_subjects);
  int get totalConducted => AttendanceCalculator.totalConducted(_subjects);

  int get pendingCount => _tasks.where((t) => !t.completed).length;
  int get completedCount => _tasks.where((t) => t.completed).length;

  /// Pending tasks, earliest due date first (overdue ones come first).
  List<Task> upcomingTasks({int limit = 5}) {
    final pending = _tasks.where((t) => !t.completed).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return pending.take(limit).toList();
  }

  /// Pending tasks first (by due date), then completed ones.
  List<Task> sortedTasks() {
    final list = List<Task>.of(_tasks);
    list.sort((a, b) {
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      return a.dueDate.compareTo(b.dueDate);
    });
    return list;
  }

  bool subjectNameExists(String name, {String? exceptId}) {
    final wanted = name.trim().toLowerCase();
    return _subjects.any(
      (s) => s.id != exceptId && s.name.trim().toLowerCase() == wanted,
    );
  }

  // ------------------------------------------------------------- subjects

  Future<void> addSubject(String name, int attended, int total) async {
    _subjects = [
      ..._subjects,
      Subject(
        id: _newId(),
        name: name.trim(),
        attended: attended,
        total: total,
      ),
    ];
    await _saveSubjects();
  }

  Future<void> updateSubject(
    String id,
    String name,
    int attended,
    int total,
  ) async {
    _subjects = [
      for (final s in _subjects)
        if (s.id == id)
          s.copyWith(name: name.trim(), attended: attended, total: total)
        else
          s,
    ];
    await _saveSubjects();
  }

  Future<void> deleteSubject(String id) async {
    _subjects = _subjects.where((s) => s.id != id).toList();
    await _saveSubjects();
  }

  // ---------------------------------------------------------------- tasks

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required Priority priority,
  }) async {
    _tasks = [
      ..._tasks,
      Task(
        id: _newId(),
        title: title.trim(),
        description: description.trim(),
        dueDate: dueDate,
        priority: priority,
      ),
    ];
    await _saveTasks();
  }

  Future<void> updateTask(
    String id, {
    required String title,
    required String description,
    required DateTime dueDate,
    required Priority priority,
  }) async {
    _tasks = [
      for (final t in _tasks)
        if (t.id == id)
          t.copyWith(
            title: title.trim(),
            description: description.trim(),
            dueDate: dueDate,
            priority: priority,
          )
        else
          t,
    ];
    await _saveTasks();
  }

  Future<void> toggleTask(String id) async {
    _tasks = [
      for (final t in _tasks)
        if (t.id == id) t.copyWith(completed: !t.completed) else t,
    ];
    await _saveTasks();
  }

  Future<void> deleteTask(String id) async {
    _tasks = _tasks.where((t) => t.id != id).toList();
    await _saveTasks();
  }

  // -------------------------------------------------------------- helpers

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // The UI is updated first; a failed disk write must not crash the app.
  Future<void> _saveSubjects() async {
    notifyListeners();
    try {
      await _storage.saveSubjects(_subjects);
    } catch (e) {
      debugPrint('Could not save subjects: $e');
    }
  }

  Future<void> _saveTasks() async {
    notifyListeners();
    try {
      await _storage.saveTasks(_tasks);
    } catch (e) {
      debugPrint('Could not save tasks: $e');
    }
  }
}

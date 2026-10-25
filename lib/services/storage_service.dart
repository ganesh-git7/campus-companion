import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/subject.dart';
import '../models/task.dart';

/// Saves and loads subjects and tasks as JSON strings in shared_preferences.
class StorageService {
  static const _subjectsKey = 'subjects_v1';
  static const _tasksKey = 'tasks_v1';

  Future<List<Subject>> loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_subjectsKey), Subject.tryFromJson);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_tasksKey), Task.tryFromJson);
  }

  Future<void> saveSubjects(List<Subject> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _subjectsKey,
      jsonEncode(subjects.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  /// Decodes a JSON list; empty, invalid or corrupted data gives an empty
  /// list, and individual invalid entries are skipped.
  List<T> _decodeList<T>(String? raw, T? Function(Object?) parse) {
    if (raw == null || raw.isEmpty) return <T>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <T>[];
      return decoded.map(parse).whereType<T>().toList();
    } catch (_) {
      return <T>[];
    }
  }
}

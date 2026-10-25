/// Task priority levels.
enum Priority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  /// Unknown or missing names fall back to [Priority.medium].
  static Priority fromName(Object? name) {
    for (final p in Priority.values) {
      if (p.name == name) return p;
    }
    return Priority.medium;
  }
}

/// A task or assignment. No Flutter imports, so it is unit-testable.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.completed = false,
  });

  final String id;
  final String title;
  final String description;

  /// Only the date part is meaningful (time is ignored).
  final DateTime dueDate;
  final Priority priority;
  final bool completed;

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    bool? completed,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
    );
  }

  /// True when the task is still pending and its due date is before today.
  bool isOverdue([DateTime? now]) {
    if (completed) return false;
    final today = now ?? DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(todayDate);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority.name,
    'completed': completed,
  };

  /// Returns null for invalid data so one bad record cannot break loading.
  static Task? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final title = json['title'];
    final description = json['description'];
    final dueRaw = json['dueDate'];
    final completed = json['completed'];
    if (id is! String || title is! String || title.trim().isEmpty) return null;
    if (dueRaw is! String) return null;
    final due = DateTime.tryParse(dueRaw);
    if (due == null) return null;
    return Task(
      id: id,
      title: title,
      description: description is String ? description : '',
      dueDate: due,
      priority: Priority.fromName(json['priority']),
      completed: completed is bool ? completed : false,
    );
  }
}

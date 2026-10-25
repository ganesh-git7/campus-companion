/// A subject whose attendance is tracked.
///
/// This file has no Flutter imports so it can be unit tested with plain Dart.
class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.attended,
    required this.total,
  });

  final String id;
  final String name;

  /// Classes the student attended.
  final int attended;

  /// Total classes conducted.
  final int total;

  Subject copyWith({String? name, int? attended, int? total}) {
    return Subject(
      id: id,
      name: name ?? this.name,
      attended: attended ?? this.attended,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'attended': attended,
    'total': total,
  };

  /// Returns null when [json] is missing fields or holds invalid values, so
  /// corrupted saved data is skipped instead of crashing the app.
  static Subject? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final name = json['name'];
    final attended = json['attended'];
    final total = json['total'];
    if (id is! String || name is! String) return null;
    if (attended is! int || total is! int) return null;
    if (name.trim().isEmpty) return null;
    if (attended < 0 || total < 0 || attended > total) return null;
    return Subject(id: id, name: name, attended: attended, total: total);
  }
}

class CalendarEventModel {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;

  CalendarEventModel({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  factory CalendarEventModel.fromMap(Map<String, dynamic> map) {
    return CalendarEventModel(
      id: map['id'],
      title: map['title'],
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
    );
  }
}

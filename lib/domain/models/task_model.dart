import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

class Task extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final TaskPriority priority;
  final bool isReadyToSchedule;

  Task({
    String? id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
    this.priority = TaskPriority.medium,
    this.isReadyToSchedule = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    TaskPriority? priority,
    bool? isReadyToSchedule,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      isReadyToSchedule: isReadyToSchedule ?? this.isReadyToSchedule,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, isCompleted, createdAt, priority, isReadyToSchedule];
}

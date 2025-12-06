import 'package:equatable/equatable.dart';
import 'package:time_gem/models/task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskLoading extends TaskState {}

enum OrganizationStatus { initial, loading, success, failure }

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final OrganizationStatus organizationStatus;

  const TaskLoaded({
    this.tasks = const [],
    this.organizationStatus = OrganizationStatus.initial,
  });

  TaskLoaded copyWith({
    List<Task>? tasks,
    OrganizationStatus? organizationStatus,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      organizationStatus: organizationStatus ?? this.organizationStatus,
    );
  }

  @override
  List<Object?> get props => [tasks, organizationStatus];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}

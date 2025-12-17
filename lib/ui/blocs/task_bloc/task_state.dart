import 'package:equatable/equatable.dart';
import 'package:time_gem/domain/models/task_model.dart';
import 'package:time_gem/domain/models/calendar_event_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskLoading extends TaskState {}

enum OrganizationStatus { initial, loading, success, failure, empty }

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final OrganizationStatus organizationStatus;
  final List<CalendarEventModel> lastOrganizedEvents;

  const TaskLoaded({
    this.tasks = const [],
    this.organizationStatus = OrganizationStatus.initial,
    this.lastOrganizedEvents = const [],
  });

  TaskLoaded copyWith({
    List<Task>? tasks,
    OrganizationStatus? organizationStatus,
    List<CalendarEventModel>? lastOrganizedEvents,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      organizationStatus: organizationStatus ?? this.organizationStatus,
      lastOrganizedEvents: lastOrganizedEvents ?? this.lastOrganizedEvents,
    );
  }

  List<Task> get readyToOrganizeTasks =>
      tasks.where((t) => t.isReadyToSchedule).toList();

  @override
  List<Object?> get props => [tasks, organizationStatus, lastOrganizedEvents];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}

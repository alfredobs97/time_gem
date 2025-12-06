import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:time_gem/models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;

  const AddTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class OrganizeTasks extends TaskEvent {}

class TasksUpdated extends TaskEvent {
  final List<Task> tasks;

  const TasksUpdated(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class SetTimeRange extends TaskEvent {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const SetTimeRange(this.startTime, this.endTime);

  @override
  List<Object> get props => [startTime, endTime];
}

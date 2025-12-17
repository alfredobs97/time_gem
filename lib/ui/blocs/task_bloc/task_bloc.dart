import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/domain/services/ai_service.dart';
import 'package:time_gem/domain/models/task_model.dart';
import 'package:time_gem/domain/models/working_hours.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_event.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_state.dart';

import 'dart:async';
import 'package:time_gem/data/services/task_service.dart';
import 'package:time_gem/data/services/storage_service.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _taskService;
  final AIService _aiService;
  final StorageService _storageService;
  late StreamSubscription<List<Task>> _tasksSubscription;

  TaskBloc({
    required TaskService taskService,
    required AIService aiService,
    required StorageService storageService,
  })  : _taskService = taskService,
        _aiService = aiService,
        _storageService = storageService,
        super(const TaskLoaded()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<OrganizeTasks>(_onOrganizeTasks);
    on<TasksUpdated>(_onTasksUpdated);
    on<SetTimeRange>(_onSetTimeRange);

    _tasksSubscription = _taskService.tasksStream.listen(
      (tasks) => add(TasksUpdated(tasks)),
    );
  }

  WorkingHours? _workingHours;

  @override
  Future<void> close() {
    _tasksSubscription.cancel();
    return super.close();
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    emit(TaskLoaded(tasks: _taskService.tasks));
    _workingHours = WorkingHours(
        startTime: TimeOfDay.fromDateTime(_storageService.startTime!),
        endTime: TimeOfDay.fromDateTime(_storageService.endTime!));
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TaskState> emit) {
    emit(TaskLoaded(tasks: event.tasks));
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) {
    _taskService.addTask(event.task);
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) {
    _taskService.updateTask(event.task);
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) {
    _taskService.deleteTask(event.taskId);
  }

  Future<void> _onOrganizeTasks(
      OrganizeTasks event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(currentState.copyWith(
          organizationStatus: OrganizationStatus.loading));

      try {
        if (currentState.readyToOrganizeTasks.isEmpty) {
          emit(currentState.copyWith(
              organizationStatus: OrganizationStatus.empty));
          return;
        }
        final createdEvents = await _aiService.organizeTasks(
          currentState.readyToOrganizeTasks,
          _workingHours!,
        );
        await _taskService
            .moveTaskToCalendar(currentState.readyToOrganizeTasks);
        emit(currentState.copyWith(
          organizationStatus: OrganizationStatus.success,
          lastOrganizedEvents: createdEvents,
        ));

        emit(currentState.copyWith(
            organizationStatus: OrganizationStatus.initial));
      } catch (e) {
        emit(currentState.copyWith(
            organizationStatus: OrganizationStatus.failure));
      }
    }
  }

  void _onSetTimeRange(SetTimeRange event, Emitter<TaskState> emit) {
    _workingHours =
        WorkingHours(startTime: event.startTime, endTime: event.endTime);

    final now = DateTime.now();
    final startDateTime = DateTime(now.year, now.month, now.day,
        event.startTime.hour, event.startTime.minute);
    final endDateTime = DateTime(
        now.year, now.month, now.day, event.endTime.hour, event.endTime.minute);

    _storageService.saveUserPreferences(start: startDateTime, end: endDateTime);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/models/task_model.dart';
import 'package:time_gem/task_bloc/task_event.dart';
import 'package:time_gem/task_bloc/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(const TaskLoaded()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    // Ideally fetch from repository
    // For now, keep existing state or load empty if initial
    if (state is! TaskLoaded) {
      emit(const TaskLoaded(tasks: []));
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final List<Task> updatedTasks = List.from((state as TaskLoaded).tasks)
        ..add(event.task);
      emit(TaskLoaded(tasks: updatedTasks));
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final List<Task> updatedTasks = (state as TaskLoaded).tasks.map((task) {
        return task.id == event.task.id ? event.task : task;
      }).toList();
      emit(TaskLoaded(tasks: updatedTasks));
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final List<Task> updatedTasks = (state as TaskLoaded)
          .tasks
          .where((task) => task.id != event.taskId)
          .toList();
      emit(TaskLoaded(tasks: updatedTasks));
    }
  }
}

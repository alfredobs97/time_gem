import 'dart:async';
import 'package:time_gem/domain/models/task_model.dart';

class TaskService {
  final List<Task> _tasks = [];

  final _tasksController = StreamController<List<Task>>.broadcast();
  final _organizationCompleteController = StreamController<void>.broadcast();

  TaskService();

  Stream<List<Task>> get tasksStream => _tasksController.stream;
  Stream<void> get organizationCompleteStream =>
      _organizationCompleteController.stream;

  List<Task> get tasks => List.unmodifiable(_tasks);

  void addTask(Task task) {
    _tasks.add(task);
    _notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    _notifyListeners();
  }

  Future<void> moveTaskToCalendar(List<Task> tasks) async {
    for (final task in tasks) {
      deleteTask(task.id);
    }
    _organizationCompleteController.add(null);
  }

  void _notifyListeners() {
    _tasksController.add(List.unmodifiable(_tasks));
  }

  void dispose() {
    _tasksController.close();
    _organizationCompleteController.close();
  }
}

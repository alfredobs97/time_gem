import 'package:time_gem/models/calendar_event_model.dart';
import 'package:time_gem/models/task_model.dart';
import 'package:time_gem/models/working_hours.dart';

abstract class AIService {
  Future<List<CalendarEventModel>> organizeTasks(
    List<Task> tasks,
    WorkingHours workingHours,
  );
}

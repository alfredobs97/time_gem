import 'package:time_gem/domain/models/calendar_event_model.dart';
import 'package:time_gem/domain/models/task_model.dart';
import 'package:time_gem/domain/models/working_hours.dart';

abstract class AIService {
  Future<List<CalendarEventModel>> organizeTasks(
    List<Task> tasks,
    WorkingHours workingHours,
  );
}

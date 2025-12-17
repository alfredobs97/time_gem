import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/domain/models/task_model.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_bloc.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_event.dart';
import 'package:time_gem/ui/screens/home/widgets/add_task_bottom_sheet.dart';

class TaskTileWidget extends StatelessWidget {
  final Task task;

  const TaskTileWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => _showTaskDialog(context, task: task),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Checkbox / Circle
            GestureDetector(
              onTap: () {
                context.read<TaskBloc>().add(
                      UpdateTask(
                        task.copyWith(
                            isReadyToSchedule: !task.isReadyToSchedule),
                      ),
                    );
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isReadyToSchedule
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isReadyToSchedule
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    width: 2,
                  ),
                ),
                child: task.isReadyToSchedule
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Task title
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            // Arrow button to move task
            IconButton(
              onPressed: () {
                context.read<TaskBloc>().add(
                      UpdateTask(
                        task.copyWith(
                            isReadyToSchedule: !task.isReadyToSchedule),
                      ),
                    );
              },
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: IconButton.filledTonal(
                  icon: Icon(
                    Icons.delete,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    showAdaptiveDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                          'Are you sure you want to delete this task?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<TaskBloc>().add(DeleteTask(task.id));
                              Navigator.pop(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, {Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return AddTaskBottomSheet(
          task: task,
          onSave: (title, priority) {
            if (task == null) {
              context.read<TaskBloc>().add(
                    AddTask(
                      Task(
                        title: title,
                        priority: priority,
                      ),
                    ),
                  );
            } else {
              context.read<TaskBloc>().add(
                    UpdateTask(
                      task.copyWith(
                        title: title,
                        priority: priority,
                      ),
                    ),
                  );
            }
          },
        );
      },
    );
  }
}

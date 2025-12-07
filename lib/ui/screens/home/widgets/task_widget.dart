import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/models/task_model.dart';
import 'package:time_gem/task_bloc/task_bloc.dart';
import 'package:time_gem/task_bloc/task_event.dart';
import 'package:time_gem/task_bloc/task_state.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: BlocListener<TaskBloc, TaskState>(
          listener: (context, state) {
            switch (state) {
              case TaskLoaded state
                  when state.organizationStatus == OrganizationStatus.success:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tasks Organized!'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
                break;
              case TaskLoaded state
                  when state.organizationStatus == OrganizationStatus.failure:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to organize tasks.'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                break;
              default:
                break;
            }
          },
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TaskLoaded) {
                return Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Drafts Column
                          Expanded(
                            child: DragTarget<Task>(
                              onAcceptWithDetails: (details) {
                                context.read<TaskBloc>().add(
                                      UpdateTask(
                                        details.data
                                            .copyWith(isReadyToSchedule: false),
                                      ),
                                    );
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Drafts',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildTaskList(
                                        context,
                                        state.tasks
                                            .where((t) => !t.isReadyToSchedule)
                                            .toList(),
                                        isDraft: true,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const VerticalDivider(width: 1),
                          // Ready to Schedule Column
                          Expanded(
                            child: DragTarget<Task>(
                              onAccept: (task) {
                                context.read<TaskBloc>().add(
                                      UpdateTask(
                                        task.copyWith(isReadyToSchedule: true),
                                      ),
                                    );
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Ready to Schedule',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildTaskList(
                                        context,
                                        state.tasks
                                            .where((t) => t.isReadyToSchedule)
                                            .toList(),
                                        isDraft: false,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (state is TaskError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks,
      {required bool isDraft}) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks'));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          color: _getPriorityColor(context, task.priority),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onLongPress: () => _showTaskDialog(context, task: task),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          context.read<TaskBloc>().add(
                                UpdateTask(
                                  task.copyWith(isCompleted: value),
                                ),
                              );
                        },
                      ),
                      const Spacer(),
                      if (isDraft)
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          onPressed: () {
                            context.read<TaskBloc>().add(
                                  UpdateTask(
                                    task.copyWith(isReadyToSchedule: true),
                                  ),
                                );
                          },
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20),
                          onPressed: () {
                            context.read<TaskBloc>().add(
                                  UpdateTask(
                                    task.copyWith(isReadyToSchedule: false),
                                  ),
                                );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          context.read<TaskBloc>().add(DeleteTask(task.id));
                        },
                      ),
                      Draggable<Task>(
                        data: task,
                        feedback: Material(
                          elevation: 4.0,
                          child: SizedBox(
                            width: 200,
                            child: Card(
                              color: _getPriorityColor(context, task.priority),
                              child: ListTile(
                                title: Text(task.title),
                              ),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.drag_indicator,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(BuildContext context, TaskPriority priority) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (priority) {
      case TaskPriority.high:
        return colorScheme.errorContainer;
      case TaskPriority.medium:
        return colorScheme.tertiaryContainer;
      case TaskPriority.low:
        return colorScheme.secondaryContainer;
    }
  }

  void _showTaskDialog(BuildContext context, {Task? task}) {
    final TextEditingController controller =
        TextEditingController(text: task?.title ?? '');
    TaskPriority selectedPriority = task?.priority ?? TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(task == null ? 'Add Task' : 'Edit Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(hintText: 'Enter task title'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<TaskPriority>(
                    value: selectedPriority,
                    isExpanded: true,
                    items: TaskPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedPriority = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      if (task == null) {
                        context.read<TaskBloc>().add(
                              AddTask(
                                Task(
                                  title: controller.text,
                                  priority: selectedPriority,
                                ),
                              ),
                            );
                      } else {
                        context.read<TaskBloc>().add(
                              UpdateTask(
                                task.copyWith(
                                  title: controller.text,
                                  priority: selectedPriority,
                                ),
                              ),
                            );
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(task == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

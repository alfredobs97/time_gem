import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/domain/models/task_model.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_bloc.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_event.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_state.dart';
import 'package:time_gem/ui/screens/home/widgets/add_task_bottom_sheet.dart';
import 'package:time_gem/ui/screens/home/widgets/task_tile_widget.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Task sections
                Expanded(
                  child: BlocListener<TaskBloc, TaskState>(
                    listener: (context, state) {
                      switch (state) {
                        case TaskLoaded state
                            when state.organizationStatus ==
                                OrganizationStatus.success:
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tasks Organized!'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                          break;
                        case TaskLoaded state
                            when state.organizationStatus ==
                                OrganizationStatus.failure:
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to organize tasks.'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
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
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is TaskLoaded) {
                          final draftTasks = state.tasks
                              .where((t) => !t.isReadyToSchedule)
                              .toList();
                          final readyTasks = state.tasks
                              .where((t) => t.isReadyToSchedule)
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Draft Tasks Section
                                      Text(
                                        'Draft Tasks',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (draftTasks.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Text(
                                            'No draft tasks',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        )
                                      else
                                        ...draftTasks
                                            .map((task) => TaskTileWidget(
                                                  task: task,
                                                )),
                                      const SizedBox(height: 24),
                                      // Ready to Schedule Section
                                      Text(
                                        'Ready to Schedule',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (readyTasks.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Text(
                                            'No tasks ready to schedule',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        )
                                      else
                                        ...readyTasks
                                            .map((task) => TaskTileWidget(
                                                  task: task,
                                                )),
                                    ],
                                  ),
                                ),
                              ),
                              // Bottom section with info text and Schedule button
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        "Only tasks marked 'Ready to Schedule' will be processed by the AI.",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              context
                                                  .read<TaskBloc>()
                                                  .add(OrganizeTasks());
                                            },
                                            icon:
                                                const Icon(Icons.auto_awesome),
                                            label:
                                                const Text('Schedule with AI'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(28),
                                              ),
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              _showTaskDialog(context);
                                            },
                                            icon: const Icon(Icons.add),
                                            padding: const EdgeInsets.all(12),
                                            tooltip: 'Add Task',
                                          ),
                                        ),
                                      ],
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
              ],
            ),
          ),
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

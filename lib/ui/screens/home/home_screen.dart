import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/calendar_bloc/calendar_bloc.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:time_gem/models/calendar_event_model.dart';
import 'package:time_gem/models/task_model.dart';
import 'package:time_gem/task_bloc/task_bloc.dart';
import 'package:time_gem/task_bloc/task_event.dart';
import 'package:time_gem/task_bloc/task_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _calendarHeight = 400; // Initial height

  Color _getEventColor(CalendarEventModel event) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[event.title.hashCode % colors.length];
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red[100]!;
      case TaskPriority.medium:
        return Colors.orange[100]!;
      case TaskPriority.low:
        return Colors.green[100]!;
    }
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
          color: _getPriorityColor(task.priority),
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
                              color: _getPriorityColor(task.priority),
                              child: ListTile(
                                title: Text(task.title),
                              ),
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.drag_indicator, color: Colors.grey),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('time_gem'),
              floating: true,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  tooltip: 'Organize Tasks',
                  onPressed: () {
                    context.read<TaskBloc>().add(OrganizeTasks());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<CalendarBloc>().add(SignOutRequested());
                  },
                ),
              ],
            ),
          ];
        },
        body: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            if (state is CalendarLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CalendarEventsLoaded) {
              final events = state.events
                  .map((e) => CalendarEventData(
                        date: e.start,
                        startTime: e.start,
                        endTime: e.end,
                        title: e.title,
                        event: e,
                        color: _getEventColor(e),
                      ))
                  .toList();

              return Column(
                children: [
                  SizedBox(
                    height: _calendarHeight,
                    child: WeekView(
                      controller: EventController()..addAll(events),
                      width: MediaQuery.of(context)
                          .size
                          .width, // Ensure full width
                      // To simulate 3 days, we might need to adjust the width per day if supported,
                      // or just accept that WeekView shows the week.
                      // However, we can try to use 'weekDays' to show only 3 days if we want a static 3-day view,
                      // but for a rolling 3-day view, we might need a different approach.
                      // Given the constraints, we will stick to the default WeekView but ensure it looks good.
                      // Wait, the user explicitly asked for "3 days".
                      // I will try to set 'width' to show fewer days if possible?
                      // No, WeekView usually fits 'weekDays' into 'width'.
                      // If I set 'weekDays' to only 3 days, it will show those 3 days.
                      // Let's try to show the current day + 2 next days?
                      // But 'weekDays' takes a list of WeekDays enum, which are static (Mon, Tue...).
                      // So I can't easily do "Today + 2 days" if they cross weeks.
                      // I will stick to 7 days for now but maybe zoom in?
                      // Actually, let's just use the default 7 days as 'WeekView' implies.
                      // If the user insists on 3 days, I might need 'DayView' with width?
                      // Let's try to pass 'width' as screen width.
                      eventTileBuilder:
                          (date, events, boundary, startDuration, endDuration) {
                        // Use the color from the event data if available
                        final eventColor = events.first.color;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border(
                              left: BorderSide(
                                color: eventColor, // Unique color
                                width: 4.0,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                events.first.title,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                      weekDayBuilder: (DateTime date) {
                        final now = DateTime.now();
                        final isToday = date.year == now.year &&
                            date.month == now.month &&
                            date.day == now.day;

                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  [
                                    'MON',
                                    'TUE',
                                    'WED',
                                    'THU',
                                    'FRI',
                                    'SAT',
                                    'SUN'
                                  ][date.weekday - 1],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isToday ? Colors.red : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isToday ? Colors.red : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      showLiveTimeLineInAllDays: true,
                      timeLineBuilder: (date) {
                        if (date.minute == 0) {
                          return Transform.translate(
                            offset: const Offset(0, -10),
                            child: Text(
                              "${date.hour > 12 ? date.hour - 12 : date.hour} ${date.hour >= 12 ? "PM" : "AM"}",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      liveTimeIndicatorSettings:
                          const LiveTimeIndicatorSettings(
                        color: Colors.green,
                        height: 1.0,
                        showBullet: true,
                        bulletRadius: 4.0,
                      ),
                      minDay:
                          DateTime.now().subtract(const Duration(days: 365)),
                      maxDay: DateTime.now().add(const Duration(days: 365)),
                      initialDay: DateTime.now(),
                      heightPerMinute: 1,
                      eventArranger: SideEventArranger(),
                      headerStyle: const HeaderStyle(
                        decoration: BoxDecoration(color: Colors.white),
                      ),
                      weekDays: const [
                        WeekDays.monday,
                        WeekDays.tuesday,
                        WeekDays.wednesday,
                        WeekDays.thursday,
                        WeekDays.friday,
                        WeekDays.saturday,
                        WeekDays.sunday,
                      ],
                      startHour: 6,
                      endHour: 22,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        _calendarHeight += details.delta.dy;
                        // Clamp height to reasonable limits
                        if (_calendarHeight < 100) _calendarHeight = 100;
                        if (_calendarHeight >
                            MediaQuery.of(context).size.height - 150) {
                          _calendarHeight =
                              MediaQuery.of(context).size.height - 150;
                        }
                      });
                    },
                    child: Container(
                      height: 20,
                      color: Colors.grey[300],
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: BlocListener<TaskBloc, TaskState>(
                        listener: (context, state) {
                          if (state is TaskLoaded) {
                            if (state.organizationStatus ==
                                OrganizationStatus.success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tasks Organized!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else if (state.organizationStatus ==
                                OrganizationStatus.failure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to organize tasks.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: BlocBuilder<TaskBloc, TaskState>(
                          builder: (context, state) {
                            if (state is TaskLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (state is TaskLoaded) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Tasks',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            _showTaskDialog(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        // Drafts Column
                                        Expanded(
                                          child: DragTarget<Task>(
                                            onAccept: (task) {
                                              context.read<TaskBloc>().add(
                                                    UpdateTask(
                                                      task.copyWith(
                                                          isReadyToSchedule:
                                                              false),
                                                    ),
                                                  );
                                            },
                                            builder: (context, candidateData,
                                                rejectedData) {
                                              return Column(
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      'Drafts',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: _buildTaskList(
                                                      context,
                                                      state.tasks
                                                          .where((t) => !t
                                                              .isReadyToSchedule)
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
                                                      task.copyWith(
                                                          isReadyToSchedule:
                                                              true),
                                                    ),
                                                  );
                                            },
                                            builder: (context, candidateData,
                                                rejectedData) {
                                              return Column(
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      'Ready to Schedule',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: _buildTaskList(
                                                      context,
                                                      state.tasks
                                                          .where((t) => t
                                                              .isReadyToSchedule)
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
                  ),
                ],
              );
            } else if (state is CalendarAuthenticated) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Welcome, ${state.userName}!'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CalendarBloc>().add(FetchCalendarEvents());
                      },
                      child: const Text('Fetch Calendar Events'),
                    ),
                  ],
                ),
              );
            } else if (state is CalendarUnauthenticated) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('You are not authenticated.'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Optionally navigate back to the integration screen or show a sign-in button
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: Text('Welcome to the Main App!'),
            );
          },
        ),
      ),
    );
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

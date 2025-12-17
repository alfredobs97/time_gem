import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/ui/blocs/calendar_bloc/calendar_bloc.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:time_gem/domain/models/calendar_event_model.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_bloc.dart';
import 'package:time_gem/ui/screens/home/widgets/ai_events_overview.dart';
import 'package:time_gem/ui/screens/home/widgets/calendar_widget.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_state.dart';
import 'package:time_gem/ui/screens/home/widgets/task_widget.dart';
import 'package:time_gem/ui/screens/tasks/task_screen.dart';
import 'package:time_gem/ui/screens/welcome/welcome_screen.dart';
import 'package:time_gem/ui/widgets/ai_loading_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically fetch calendar events when HomeScreen loads
    context.read<CalendarBloc>().add(FetchCalendarEvents());
  }

  double _calendarHeight = 400; // Initial height

  Color _getEventColor(CalendarEventModel event) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];
    return colors[event.title.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Time Gem',
          style:
              Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Tasks',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TaskScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<CalendarBloc>().add(SignOutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskLoaded &&
              state.organizationStatus == OrganizationStatus.success &&
              state.lastOrganizedEvents.isNotEmpty) {
            showModalBottomSheet(
              context: context,
              builder: (context) => AiEventsOverview(
                organizedEvents: state.lastOrganizedEvents,
              ),
            ).whenComplete(() {
              if (context.mounted) {
                context.read<CalendarBloc>().add(FetchCalendarEvents());
              }
            });
          }
        },
        child: Stack(
          children: [
            BlocBuilder<CalendarBloc, CalendarState>(
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
                        child: CalendarWidget(events: events),
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
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TaskWidget(),
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
                            context
                                .read<CalendarBloc>()
                                .add(FetchCalendarEvents());
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
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                bool isLoading = false;
                if (state is TaskLoading) {
                  isLoading = true;
                } else if (state is TaskLoaded &&
                    state.organizationStatus == OrganizationStatus.loading) {
                  isLoading = true;
                }

                if (isLoading) {
                  return const AiLoadingOverlay();
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

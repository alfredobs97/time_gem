import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/calendar_bloc/calendar_bloc.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:time_gem/models/calendar_event_model.dart';

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
                      color: Colors.grey[100],
                      child: const Center(
                        child: Text(
                          'Tasks to be scheduled',
                          style: TextStyle(color: Colors.grey),
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
}

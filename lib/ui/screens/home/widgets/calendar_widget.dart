import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:time_gem/domain/models/calendar_event_model.dart';
import 'package:time_gem/ui/screens/home/widgets/event_details.dart';

class CalendarWidget extends StatelessWidget {
  final List<CalendarEventData<CalendarEventModel>> events;

  const CalendarWidget({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return WeekView(
      controller: EventController()..addAll(events),
      width: MediaQuery.of(context).size.width,
      eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
        final eventColor = events.first.color;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4.0),
            border: Border(
              left: BorderSide(
                color: eventColor,
                width: 4.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date.day.toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
        color: Theme.of(context).colorScheme.secondary,
        height: 1.0,
        showBullet: true,
        bulletRadius: 4.0,
      ),
      minDay: DateTime.now(),
      maxDay: DateTime.now().add(const Duration(days: 10)),
      initialDay: DateTime.now(),
      heightPerMinute: 0.9,
      eventArranger: SideEventArranger(),
      headerStyle: HeaderStyle(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      ),
      headerStringBuilder: (date, {secondaryDate}) {
        final now = DateTime.now();
        final startOfCurrentWeek = now.subtract(
            Duration(days: now.weekday - 1)); // Monday of current week
        final startOfDisplayedWeek = date.subtract(
            Duration(days: date.weekday - 1)); // Monday of displayed week

        if (startOfDisplayedWeek.year == startOfCurrentWeek.year &&
            startOfDisplayedWeek.month == startOfCurrentWeek.month &&
            startOfDisplayedWeek.day == startOfCurrentWeek.day) {
          return "This Week";
        }
        final endDate = secondaryDate ??
            date.add(const Duration(
                days: 6)); // Default to 7 days if secondaryDate is null
        return "${date.day}/${date.month} - ${endDate.day}/${endDate.month}";
      },
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
      onEventTap: (events, date) {
        if (events.isNotEmpty) {
          final event = events.first.event as CalendarEventModel?;
          if (event != null) {
            showDialog(
              context: context,
              builder: (context) => EventDetails(event: event),
            );
          }
        }
      },
      backgroundColor: Theme.of(context).colorScheme.onError,
    );
  }
}

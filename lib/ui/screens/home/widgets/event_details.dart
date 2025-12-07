import 'package:flutter/material.dart';
import 'package:time_gem/models/calendar_event_model.dart';

class EventDetails extends StatelessWidget {
  final CalendarEventModel event;

  const EventDetails({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(event.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Start at ${event.start.hour}:${event.start.minute} of ${event.start.day}'),
          Text(
              'End at ${event.end.hour}:${event.end.minute} of ${event.end.day}'),
          // Add description if available in the model later
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

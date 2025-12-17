import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:time_gem/data/services/google_calendar_service.dart';
import 'package:time_gem/domain/services/ai_service.dart';
import 'package:time_gem/domain/models/calendar_event_model.dart';
import 'package:time_gem/domain/models/task_model.dart';
import 'package:time_gem/domain/models/working_hours.dart';

class GeminiAIService implements AIService {
  late final GenerativeModel _model;
  final GoogleCalendarService _googleCalendarRepository;

  static const _numberOfDaysToOrganize = 4;

  GeminiAIService({
    required GoogleCalendarService googleCalendarRepository,
  }) : _googleCalendarRepository = googleCalendarRepository {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3-flash',
      tools: [
        Tool.functionDeclarations([
          FunctionDeclaration(
            'get_day_calendar_events',
            'Get calendar events for a specific day',
            parameters: {
              'day': Schema.string(
                description: 'The day to fetch events for (ISO8601 format)',
              ),
            },
          ),
          FunctionDeclaration(
            'create_calendar_event',
            'Create a new calendar event',
            parameters: {
              'title': Schema.string(description: 'Title of the event'),
              'start': Schema.string(description: 'Start time (ISO8601)'),
              'end': Schema.string(description: 'End time (ISO8601)'),
              'description': Schema.string(
                description: 'Description (optional)',
                nullable: true,
              ),
            },
          ),
        ]),
      ],
      systemInstruction: Content.text(
          '''You are a helpful assistant that helps organize tasks into a schedule. Skip the non working days.

      You can use the `get_day_calendar_events` tool to check for existing events on the relevant day(s) to avoid conflicts. But DO NOT use it if the day is not a working day.
      You can use the `create_calendar_event` tool to schedule the tasks as events in the calendar. But DO NOT use it if the day is not a working day.

      Calculate the end duration of the event based on the start time and the task description.
      '''),
    );
  }

  @override
  Future<List<CalendarEventModel>> organizeTasks(
    List<Task> tasks,
    WorkingHours workingHours,
  ) async {
    final prompt = _buildPrompt(tasks, workingHours);
    final content = Content.text(prompt);
    final List<CalendarEventModel> createdEvents = [];

    try {
      final chat = _model.startChat();
      debugPrint('--- Sending tasks to Gemini ---');

      GenerateContentResponse response = await chat.sendMessage(content);

      while (response.functionCalls.isNotEmpty) {
        final functionCall = response.functionCalls.first;
        switch (functionCall.name) {
          case 'get_day_calendar_events':
            try {
              final events = await _getDayCalendarEvents(functionCall);
              response = await chat.sendMessage(Content.functionResponse(
                functionCall.name,
                {'events': events},
              ));
            } catch (e) {
              debugPrint('Error getting events: $e');
              response = await chat.sendMessage(Content.functionResponse(
                functionCall.name,
                {
                  'Error': e.toString(),
                },
              ));
            }
            break;
          case 'create_calendar_event':
            try {
              final event = await _createCalendarEvent(functionCall);
              response = await chat.sendMessage(Content.functionResponse(
                functionCall.name,
                {'status': 'success', 'message': 'Event created'},
              ));
              createdEvents.add(event);
              debugPrint('Event created: $event');
            } catch (e) {
              debugPrint('Error creating event: $e');
              response = await chat.sendMessage(Content.functionResponse(
                functionCall.name,
                {
                  'Error': e.toString(),
                },
              ));
            }
            break;
          default:
            debugPrint('Unknown function call: ${functionCall.name}');
            response = await chat.sendMessage(Content.functionResponse(
              functionCall.name,
              {'Error': 'Unknown function call'},
            ));
            break;
        }
      }

      debugPrint('Gemini Response: ${response.text}');
      return createdEvents;
    } catch (e) {
      debugPrint('Error calling Gemini: $e');
      return [];
    }
  }

  String _buildPrompt(List<Task> tasks, WorkingHours workingHours) {
    final taskList = tasks
        .map((t) => '- ${t.title} (Priority: ${t.priority}, ID: ${t.id})')
        .join('\n');
    final today = DateTime.now().toIso8601String();
    final endDate = DateTime.now()
        .add(const Duration(days: _numberOfDaysToOrganize))
        .toIso8601String();

    return '''
    Organize the following tasks into a schedule within the working hours of ${_formatTime(workingHours.startTime)} to ${_formatTime(workingHours.endTime)}.

    The events should be scheduled for the next $_numberOfDaysToOrganize days. Starting from $today to $endDate.
    
    Tasks:
    $taskList
    ''';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<List<Map<String, dynamic>>> _getDayCalendarEvents(
    FunctionCall functionCall,
  ) async {
    final dayString = functionCall.args['day'] as String?;

    if (dayString == null) {
      throw Exception('Day is required');
    }

    final day = DateTime.parse(dayString);
    // Fetch events for the whole day
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    debugPrint('Fetching events for $start to $end');
    final events = await _googleCalendarRepository.getEvents(start, end);

    return events.map((e) => e.toMap()).toList();
  }

  Future<CalendarEventModel> _createCalendarEvent(
    FunctionCall functionCall,
  ) async {
    debugPrint('Gemini is requesting to create event: ${functionCall.args}');
    final title = functionCall.args['title'] as String?;
    final startString = functionCall.args['start'] as String?;
    final endString = functionCall.args['end'] as String?;

    if (title == null || startString == null || endString == null) {
      throw Exception('Title, start, and end are required');
    }

    final start = DateTime.parse(startString);
    final end = DateTime.parse(endString);
    final event = CalendarEventModel(
      id: '',
      title: title,
      start: start,
      end: end,
    );

    debugPrint('Creating event: $title ($start - $end)');
    await _googleCalendarRepository.insertEvent(event);
    return event;
  }
}

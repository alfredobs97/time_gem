import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:time_gem/data/services/google_calendar_service.dart';
import 'package:time_gem/data/services/local_calendar_service.dart';
import 'package:time_gem/models/calendar_event_model.dart' as model_event;
import 'dart:async';
import 'package:time_gem/services/task_service.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GoogleCalendarService _googleCalendarRepository;
  final LocalCalendarService? localCalendarService;
  final TaskService _taskService;
  late StreamSubscription<void> _organizationCompleteSubscription;

  CalendarBloc({
    required GoogleCalendarService googleCalendarRepository,
    required TaskService taskService,
    this.localCalendarService,
  })  : _googleCalendarRepository = googleCalendarRepository,
        _taskService = taskService,
        super(CalendarInitial()) {
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<FetchCalendarEvents>(_onFetchCalendarEvents);
    on<AddLocalEvent>(_onAddLocalEvent);
    on<DeleteLocalEvent>(_onOnDeleteLocalEvent);
    on<FetchLocalEvents>(_onFetchLocalEvents);

    _organizationCompleteSubscription =
        _taskService.organizationCompleteStream.listen((_) {
      add(FetchCalendarEvents());
    });
  }

  @override
  Future<void> close() {
    _organizationCompleteSubscription.cancel();
    return super.close();
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      final googleUser = await _googleCalendarRepository.signIn();
      if (googleUser == null) {
        emit(CalendarUnauthenticated());
        return;
      }
      emit(CalendarAuthenticated(userName: googleUser.displayName ?? 'User'));
    } catch (e) {
      emit(CalendarError(message: 'Google Sign-In failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      await _googleCalendarRepository.signOut();
      emit(CalendarUnauthenticated());
    } catch (e) {
      emit(CalendarError(message: 'Google Sign-Out failed: ${e.toString()}'));
    }
  }

  Future<void> _onFetchCalendarEvents(
    FetchCalendarEvents event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      if (_googleCalendarRepository.isAuthenticated) {
        final now = DateTime.now();
        final sevenDaysLater = now.add(const Duration(days: 7));

        final calendarEvents =
            await _googleCalendarRepository.getEvents(now, sevenDaysLater);
        emit(CalendarEventsLoaded(events: calendarEvents));
      } else if (localCalendarService != null) {
        final localEvents = await localCalendarService!.getEvents();
        emit(CalendarEventsLoaded(events: localEvents));
      } else {
        emit(CalendarError(message: 'No calendar service available.'));
      }
    } catch (e) {
      emit(CalendarError(
          message: 'Failed to fetch calendar events: ${e.toString()}'));
    }
  }

  Future<void> _onAddLocalEvent(
    AddLocalEvent event,
    Emitter<CalendarState> emit,
  ) async {
    if (localCalendarService == null) {
      emit(CalendarError(message: 'Local calendar service not available.'));
      return;
    }
    try {
      await localCalendarService!.insertEvent(event.event);
      add(FetchLocalEvents()); // Refresh local events after adding
    } catch (e) {
      emit(
          CalendarError(message: 'Failed to add local event: ${e.toString()}'));
    }
  }

  Future<void> _onOnDeleteLocalEvent(
    DeleteLocalEvent event,
    Emitter<CalendarState> emit,
  ) async {
    if (localCalendarService == null) {
      emit(CalendarError(message: 'Local calendar service not available.'));
      return;
    }
    try {
      await localCalendarService!.deleteEvent(event.eventId);
      add(FetchLocalEvents()); // Refresh local events after deleting
    } catch (e) {
      emit(CalendarError(
          message: 'Failed to delete local event: ${e.toString()}'));
    }
  }

  Future<void> _onFetchLocalEvents(
    FetchLocalEvents event,
    Emitter<CalendarState> emit,
  ) async {
    if (localCalendarService == null) {
      emit(CalendarError(message: 'Local calendar service not available.'));
      return;
    }
    emit(CalendarLoading());
    try {
      final localEvents = await localCalendarService!.getEvents();
      emit(CalendarEventsLoaded(events: localEvents));
    } catch (e) {
      emit(CalendarError(
          message: 'Failed to fetch local events: ${e.toString()}'));
    }
  }
}

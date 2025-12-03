import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:time_gem/calendar_bloc/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:time_gem/local_calendar/local_calendar_service.dart';
import 'package:time_gem/models/calendar_event_model.dart' as model_event;
import 'package:firebase_auth/firebase_auth.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GoogleSignIn _googleSignIn;
  final LocalCalendarService? localCalendarService;
  google_calendar.CalendarApi? _calendarApi;

  CalendarBloc({
    required GoogleSignIn googleSignIn,
    this.localCalendarService,
    google_calendar.CalendarApi? calendarApi,
  })  : _googleSignIn = googleSignIn,
        _calendarApi = calendarApi,
        super(CalendarInitial()) {
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<FetchCalendarEvents>(_onFetchCalendarEvents);
    on<AddLocalEvent>(_onAddLocalEvent);
    on<DeleteLocalEvent>(_onOnDeleteLocalEvent);
    on<FetchLocalEvents>(_onFetchLocalEvents);
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(CalendarUnauthenticated());
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final hasPermissions = await _googleSignIn.requestScopes([
        'https://www.googleapis.com/auth/calendar.readonly',
        'https://www.googleapis.com/auth/calendar.events'
      ]);

      if (!hasPermissions) {
        emit(CalendarError(message: 'Calendar permissions were not granted.'));
        return;
      }

      _calendarApi =
          google_calendar.CalendarApi(await googleUser.toAuthClient());
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
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      _calendarApi = null;
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
      if (_googleSignIn.currentUser != null && _calendarApi != null) {
        final now = DateTime.now();
        final sevenDaysLater = now.add(const Duration(days: 7));

        final events = await _calendarApi!.events.list(
          'primary',
          timeMin: now.toUtc(),
          timeMax: sevenDaysLater.toUtc(),
          singleEvents: true,
          orderBy: 'startTime',
        );

        final calendarEvents = events.items
                ?.map((e) => model_event.CalendarEventModel(
                      id: e.id ?? '',
                      title: e.summary ?? 'No Title',
                      start: e.start?.dateTime ?? DateTime.now(),
                      end: e.end?.dateTime ?? DateTime.now(),
                    ))
                .toList() ??
            [];
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

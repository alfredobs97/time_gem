import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:time_gem/calendar_bloc/extension_google_sign_in_as_googleapis_auth.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GoogleSignIn _googleSignIn;

  CalendarBloc({required GoogleSignIn googleSignIn})
      : _googleSignIn = googleSignIn,
        super(CalendarInitial()) {
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<FetchCalendarEvents>(_onFetchCalendarEvents);
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final hasPermissions = await _googleSignIn.requestScopes([
          'https://www.googleapis.com/auth/calendar.readonly',
          'https://www.googleapis.com/auth/calendar.events'
        ]);

        if (hasPermissions) {
          emit(CalendarAuthenticated(userName: googleUser.displayName ?? 'User'));
        } else {
          await _googleSignIn.signOut();
          emit(CalendarError(message: 'Calendar permissions were not granted.'));
        }
      } else {
        emit(CalendarError(message: 'Google Sign-In aborted by user.'));
      }
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
      emit(CalendarInitial());
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
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        emit(CalendarError(message: 'Authentication failed.'));
        return;
      }

      final calendarApi = google_calendar.CalendarApi(authClient);
      final events = await calendarApi.events.list('primary');
      final eventSummaries =
          events.items?.map((e) => e.summary ?? 'No Title').toList() ?? [];
      emit(CalendarEventsLoaded(events: eventSummaries));
    } catch (e) {
      emit(CalendarError(message: 'Failed to fetch calendar events: ${e.toString()}'));
    }
  }
}

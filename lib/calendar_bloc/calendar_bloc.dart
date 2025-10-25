import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GoogleSignIn _googleSignIn;

  CalendarBloc({required GoogleSignIn googleSignIn})
      : _googleSignIn = googleSignIn,
        super(CalendarInitial()) {
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      // Requesting calendar scopes
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser != null) {
        final hasPermissions = await _googleSignIn.requestScopes([
          'https://www.googleapis.com/auth/calendar.readonly',
          'https://www.googleapis.com/auth/calendar.events'
        ]);

        if (hasPermissions) {
          emit(CalendarAuthenticated(userName: googleUser.displayName ?? 'User'));
        } else {
          // Handle case where user denies permissions
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
}

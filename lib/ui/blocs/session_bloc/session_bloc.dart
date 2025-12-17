import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/data/services/google_calendar_service.dart';
import 'package:time_gem/data/services/storage_service.dart';
import 'package:time_gem/ui/blocs/session_bloc/session_event.dart';
import 'package:time_gem/ui/blocs/session_bloc/session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final StorageService _storageService;
  final GoogleCalendarService _googleCalendarService;

  SessionBloc({
    required StorageService storageService,
    required GoogleCalendarService googleCalendarService,
  })  : _storageService = storageService,
        _googleCalendarService = googleCalendarService,
        super(Unauthenticated()) {
    on<AppStarted>(_onAppStarted);
    on<OnboardingCompleted>(_onOnboardingCompleted);
  }

  Future<void> _onAppStarted(
      AppStarted event, Emitter<SessionState> emit) async {
    emit(SessionLoading());

    if (!_storageService.isOnboardingCompleted) {
      emit(OnboardingIncomplete());
      return;
    }
    try {
      final user = await _googleCalendarService.restoreSession();
      emit(user != null ? Authenticated(user) : Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onOnboardingCompleted(
      OnboardingCompleted event, Emitter<SessionState> emit) async {
    await _storageService.setOnboardingCompleted(true);
    // After marking as complete, we can check session or just assume if they connected calendar they are auth
    // But if they skipped, they might not be Authenticated in the Google sense, but "App Authenticated" to use local.
    // The current Authenticated state relies on GoogleSignInAccount.
    // If we support local usage, we might need a "LocalAuthenticated" or just Authenticated with null user.
    // For now, let's check repo. If not auth, valid.

    if (_googleCalendarService.isAuthenticated) {
      // We can't easily get the account user object here without calling signInSilently or having it cached.
      // But typically they just signed in.
      // For simplicity, we can emit Authenticated if we have a user, or something else.
      // Or we can just emit Authenticated(null) if we change state to nullable user?
      // Let's stick to the flow:
      // If connected, CalendarBloc handles auth. SessionBloc just needs to know we are good to go.
      // Actually, we might just emit Authenticated if we have a user, or if we are skipping login.
      // Let's verify what restoreSession returns.

      // If they skipped login, restoreSession returns null.
      // So Unauthenticated logic in AppStarted maps to "Onboarding done but no google session".
      // Which currently maps to WelcomeScreen(page 3).
      // If we allow "Skip", we need a way to say "Logged in as Guest".
    }

    // Simplification for this refactor:
    // If we are here, onboarding is done.
    // If we have a google session, great. If not, we are in "Guest" mode (which effectively is Unauthenticated but allowed to Home).
    // But `Unauthenticated` in `AppStarted` forces re-login.
    // We might need a `GuestSession` state or handle `Unauthenticated` differently.

    // However, looking at the previous logic:
    // If session restoration fails, we went to `WelcomeScreen(page: 3)`.
    // This implies we enforce Google Auth or explicit Re-skip.

    // Trigger a check again?
    // Let's just emit Authenticated to force Home navigation if that's what we want,
    // BUT `Authenticated` requires a user.

    // Let's modify logic:
    // If they skip, they are "Authenticated" but user is null? Or new state `Guest`.
    // Let's assume for now if they connect, we have a user.
    // If they skip, we are in a "Guest" loop.

    // Actually, `CalendarIntegrationWidget` calls `Navigator.pushReplacement`.
    // It doesn't rely on `SessionBloc` to navigate AFTER onboarding.
    // So `OnboardingCompleted` is mainly for updating storage.
    // But we probably want the Bloc to drive navigation too.

    // Let's just update storage. The UI listener will handle navigation or we can emit a state.
    // Let's emit `Authenticated` with a dummy or null (if state allows) if we want to drive it.
    // But `Authenticated` expects `GoogleSignInAccount`.

    // Let's make `Authenticated` accept nullable user for Guest mode.
    // Or add `Guest` state.

    // For now, adhering to strict "Google Auth" or "Skip"
    // If "Skip", we probably are "Unauthenticated" but we want to go Home.
    // The `AppStarted` logic `restoreSession` returns null -> `Unauthenticated` -> `WelcomeScreen`.
    // This effectively prevents Guest mode from persisting if we don't save some "IsGuest" flag or handle it.
    // But user requirement was: "if session invalid... go to last step".
    // "Continue without connecting" implies Guest.
    // If I restart app as Guest, `restoreSession` fails. I go back to onboarding.
    // This seems to be a flaw in the original requirement vs "Skip" feature.
    // I should probably fix this.

    // Fix: `Authenticated` can implement a "Guest" mode or `Unauthenticated` is fine if we check another flag.
    // But let's stick to the requested refactor first.
    // I will just update storage.
  }
}

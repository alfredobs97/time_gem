import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:time_gem/ui/blocs/calendar_bloc/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:time_gem/domain/models/calendar_event_model.dart';

class GoogleCalendarService {
  final GoogleSignIn _googleSignIn;
  google_calendar.CalendarApi? _calendarApi;

  GoogleCalendarService({required GoogleSignIn googleSignIn})
      : _googleSignIn = googleSignIn;

  Future<GoogleSignInAccount?> signIn() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    return _authenticateAndInit(googleUser);
  }

  Future<GoogleSignInAccount?> restoreSession() async {
    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signInSilently();
    if (googleUser == null) return null;

    return _authenticateAndInit(googleUser);
  }

  Future<GoogleSignInAccount?> _authenticateAndInit(
      GoogleSignInAccount googleUser) async {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Only sign in if not already signed in
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInWithCredential(credential);
    }

    final hasPermissions = await _googleSignIn.requestScopes([
      'https://www.googleapis.com/auth/calendar.readonly',
      'https://www.googleapis.com/auth/calendar.events'
    ]);

    if (hasPermissions) {
      _calendarApi =
          google_calendar.CalendarApi(await googleUser.toAuthClient());
    }

    return googleUser;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    _calendarApi = null;
  }

  Future<void> insertEvent(CalendarEventModel event) async {
    if (_calendarApi == null) await restoreSession();

    final googleEvent = google_calendar.Event(
      summary: event.title,
      start: google_calendar.EventDateTime(
        dateTime: event.start.toUtc(),
      ),
      end: google_calendar.EventDateTime(
        dateTime: event.end.toUtc(),
      ),
    );

    await _calendarApi!.events.insert(googleEvent, 'primary');
  }

  Future<List<CalendarEventModel>> getEvents(
    DateTime start,
    DateTime end,
  ) async {
    if (_calendarApi == null) return [];

    final events = await _calendarApi!.events.list(
      'primary',
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );

    return events.items
            ?.map((e) => CalendarEventModel(
                  id: e.id ?? '',
                  title: e.summary ?? 'No Title',
                  start: e.start?.dateTime ?? DateTime.now(),
                  end: e.end?.dateTime ?? DateTime.now(),
                ))
            .toList() ??
        [];
  }

  bool get isAuthenticated => _calendarApi != null;
  String? get currentUserDisplayName => _googleSignIn.currentUser?.displayName;
}

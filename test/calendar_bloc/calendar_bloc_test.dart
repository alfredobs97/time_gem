import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:time_gem/calendar_bloc/calendar_bloc.dart';
import 'package:time_gem/calendar_bloc/extension_google_sign_in_as_googleapis_auth.dart';

import 'calendar_bloc_test.mocks.dart';

// Generate mocks for GoogleSignIn, GoogleSignInAccount, and calendar.CalendarApi
@GenerateMocks([
  GoogleSignIn,
  GoogleSignInAccount,
  auth.AuthClient,
  calendar.CalendarApi,
  calendar.EventsResource,
])
void main() {
  group('CalendarBloc', () {
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockAuthClient mockAuthClient;
    late MockCalendarApi mockCalendarApi;
    late MockEventsResource mockEventsResource;

    setUp(() {
      mockGoogleSignIn = MockGoogleSignIn();
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockAuthClient = MockAuthClient();
      mockCalendarApi = MockCalendarApi();
      mockEventsResource = MockEventsResource();

      when(mockGoogleSignIn.currentUser).thenReturn(null);
      when(mockGoogleSignIn.onCurrentUserChanged)
          .thenAnswer((_) => Stream.fromIterable([]));
      when(mockGoogleSignIn.signInSilently())
          .thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

     /*  when(mockGoogleSignInAccount.authentication)
          .thenAnswer((_) async => GoogleSignInAuthentication(
                accessToken: 'mock_access_token', // Provide a non-null value for accessToken
                idToken: 'mock_id_token', // Provide a non-null value for idToken
              )); */
      when(mockGoogleSignInAccount.authHeaders).thenAnswer((_) async => {
            'Authorization': 'Bearer mock_access_token',
          });

      when(mockGoogleSignInAccount.toAuthClient())
          .thenAnswer((_) async => mockAuthClient);

      when(mockAuthClient.close()).thenReturn(null);

      when(mockCalendarApi.events).thenReturn(mockEventsResource);
    });

    blocTest<CalendarBloc, CalendarState>(
      'emits [CalendarLoading, CalendarAuthenticated] when Google Sign-In is successful',
      build: () {
        when(mockGoogleSignIn.currentUser)
            .thenAnswer((_) => mockGoogleSignInAccount);
        return CalendarBloc(googleSignIn: mockGoogleSignIn);
      },
      act: (bloc) => bloc.add(SignInWithGoogleRequested()),
      expect: () => [
        CalendarLoading(),
        CalendarAuthenticated(userName: 'User'),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'emits [CalendarLoading, CalendarAuthenticated] when Google Sign-In is successful after user interaction',
      build: () => CalendarBloc(googleSignIn: mockGoogleSignIn),
      act: (bloc) => bloc.add(SignInWithGoogleRequested()),
      expect: () => [
        CalendarLoading(),
        CalendarAuthenticated(userName: 'User'),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'emits [CalendarLoading, CalendarUnauthenticated] when Google Sign-Out is successful',
      build: () {
        when(mockGoogleSignIn.currentUser)
            .thenAnswer((_) => mockGoogleSignInAccount);
        return CalendarBloc(googleSignIn: mockGoogleSignIn);
      },
      act: (bloc) => bloc.add(SignOutRequested()),
      expect: () => [
        CalendarLoading(),
        CalendarUnauthenticated(),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'emits [CalendarLoading, CalendarEventsLoaded] when FetchCalendarEvents is successful',
      build: () {
        when(mockGoogleSignIn.currentUser)
            .thenAnswer((_) => mockGoogleSignInAccount);
        when(mockEventsResource.list(
          'primary',
        )).thenAnswer((_) async => calendar.Events(items: []));
        return CalendarBloc(
            googleSignIn: mockGoogleSignIn, calendarApi: mockCalendarApi);
      },
      act: (bloc) => bloc.add(FetchCalendarEvents()),
      expect: () => [
        CalendarLoading(),
        isA<CalendarEventsLoaded>(),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'emits [CalendarLoading, CalendarError] when Google Sign-In fails',
      build: () {
        when(mockGoogleSignIn.signInSilently())
            .thenThrow(Exception('Sign-in failed'));
        return CalendarBloc(googleSignIn: mockGoogleSignIn);
      },
      act: (bloc) => bloc.add(SignInWithGoogleRequested()),
      expect: () => [
        CalendarLoading(),
        isA<CalendarError>(),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'emits [CalendarLoading, CalendarError] when FetchCalendarEvents fails',
      build: () {
        when(mockGoogleSignIn.currentUser)
            .thenAnswer((_) => mockGoogleSignInAccount);
        when(mockEventsResource.list(
          'primary',
        )).thenThrow(Exception('Failed to fetch events'));
        return CalendarBloc(
            googleSignIn: mockGoogleSignIn, calendarApi: mockCalendarApi);
      },
      act: (bloc) => bloc.add(FetchCalendarEvents()),
      expect: () => [
        CalendarLoading(),
        isA<CalendarError>(),
      ],
    );
  });
}

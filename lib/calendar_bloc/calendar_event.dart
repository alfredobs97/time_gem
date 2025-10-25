part of 'calendar_bloc.dart';

@immutable
sealed class CalendarEvent {}

class SignInWithGoogleRequested extends CalendarEvent {}

class SignOutRequested extends CalendarEvent {}

class FetchCalendarEvents extends CalendarEvent {}

part of 'calendar_bloc.dart';

@immutable
sealed class CalendarEvent {}

class SignInWithGoogleRequested extends CalendarEvent {}

class SignOutRequested extends CalendarEvent {}

class FetchCalendarEvents extends CalendarEvent {}

class AddLocalEvent extends CalendarEvent {
  final model_event.CalendarEventModel event;

  AddLocalEvent(this.event);
}

class DeleteLocalEvent extends CalendarEvent {
  final String eventId;

  DeleteLocalEvent(this.eventId);
}

class FetchLocalEvents extends CalendarEvent {}

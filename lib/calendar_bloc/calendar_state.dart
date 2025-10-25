part of 'calendar_bloc.dart';

@immutable
sealed class CalendarState {}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarAuthenticated extends CalendarState {
  final String userName;

  CalendarAuthenticated({required this.userName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarAuthenticated && other.userName == userName);

  @override
  int get hashCode => userName.hashCode;
}

class CalendarEventsLoaded extends CalendarState {
  final List<String> events;

  CalendarEventsLoaded({required this.events});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEventsLoaded &&
          listEquals(other.events, events));

  @override
  int get hashCode => events.hashCode;
}

class CalendarError extends CalendarState {
  final String message;

  CalendarError({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarError && other.message == message);

  @override
  int get hashCode => message.hashCode;
}

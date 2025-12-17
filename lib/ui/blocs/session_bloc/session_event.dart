import 'package:equatable/equatable.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends SessionEvent {}

class OnboardingCompleted extends SessionEvent {}

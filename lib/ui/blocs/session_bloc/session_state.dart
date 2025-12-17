import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionLoading extends SessionState {}

class Authenticated extends SessionState {
  final GoogleSignInAccount user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends SessionState {}

class OnboardingIncomplete extends SessionState {}

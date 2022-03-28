import 'package:equatable/equatable.dart';
import 'package:myflexbox/repos/models/user.dart';

// Stores the state of the authentication for the user, hence whether
// the user is logged in or not logged in or the auth process is currently
// running.
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

// Starting State
class AuthUninitialized extends AuthState {}

// User is logged in
// Here the user is saved, and is available in the entire app.
class AuthAuthenticated extends AuthState {
  final DBUser user;

  AuthAuthenticated(this.user);
}

// User is not logged in
class AuthUnauthenticated extends AuthState {}

// It is checked whether the user is logged in or not
class AuthLoading extends AuthState {}



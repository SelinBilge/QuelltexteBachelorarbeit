import 'package:equatable/equatable.dart';
import 'package:myflexbox/repos/models/form_data.dart';

// Login States
// email and passwords are stored in the base class, so they are
// available in all states.
abstract class LoginState extends Equatable {
  final Email email;
  final Password password;
  LoginState({this.email, this.password});

  //sets the value on which two states are compared. The UI is only rebuild, if
  //two stated are different.
  @override
  List<Object> get props => [];
}

// Initial State, is emitted at the start, and also if
// the email or password is changed by the user
class LoginInitial extends LoginState {
  final Email email;
  final Password password;
  LoginInitial({this.email, this.password});

  @override
  List<Object> get props => [email, password];
}

// Loading state, is emitted when the user is tried to log in
// email and password objects are created, otherwise they would be null which
// would lead to an error in the form widget
class LoadingLoginState extends LoginState {
  final Email email = Email();
  final Password password = Password();
}

//State that gets emitted after an unsuccessful login try.
class LoginFailure extends LoginState {
  final Email email;
  final Password password;
  LoginFailure({this.email, this.password});

  @override
  List<Object> get props => [email, password];
}

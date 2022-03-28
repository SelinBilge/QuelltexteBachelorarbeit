import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myflexbox/repos/models/form_data.dart';


// Register States
// email, username and passwords are stored in the base class, so they are
// available in all states.
abstract class RegisterState extends Equatable {
  final Email email;
  final Password password;
  final Username username;
  final Telephone telephone;
  RegisterState({this.email, this.password, this.username, this.telephone});

  //sets the value on which two states are compared. The UI is only rebuild, if
  //two stated are different.
  @override
  List<Object> get props => [];
}

// Initial State, is emitted at the start, and also if
// the email, username or password is changed by the user
class RegisterInitial extends RegisterState {
  RegisterInitial({
    Email email,
    Password password,
    Username username,
    Telephone telephone
  }) : super(
    email: email,
    password: password,
    username: username,
    telephone: telephone
  );

  @override
  List<Object> get props => [email, password, username, telephone];
}

// Loading state, is emitted when the user is tried to register
// email, username and password objects are created, otherwise they would be null which
// would lead to an error in the form widget
class RegisterLoadingState extends RegisterState {
  RegisterLoadingState(): super(
    email: Email(),
    password: Password(),
    username: Username(),
    telephone: Telephone()
  );
}

//State that gets emitted after an unsuccessful register try.
class RegisterFailure extends RegisterState {
  RegisterFailure({
    Email email,
    Password password,
    Username username,
    Telephone telephone
  }) : super(
      email: email,
      password: password,
      username: username,
      telephone: telephone
  );

  @override
  List<Object> get props => [email, password, username, telephone];
}

//State that gets emitted after an successful register try.
class RegisterSuccess extends RegisterState {
  RegisterSuccess({
    Email email,
    Password password,
    Username username,
    Telephone telephone
  }) : super(
      email: email,
      password: password,
      username: username,
      telephone: telephone
  );

  @override
  List<Object> get props => [email, password, username, telephone];
}